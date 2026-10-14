import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/logger_service.dart';
import '../core/services/supabase_service.dart';

// -----------------------------------------------------------------------------
// Notification model
// -----------------------------------------------------------------------------

enum NotificationType {
  newOrder,
  newReservation,
  newCustomer,
  unknown,
}

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.unknown,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

// -----------------------------------------------------------------------------
// Notifications provider
// -----------------------------------------------------------------------------

class NotificationsProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;

  /// Limits in-memory notifications to prevent unbounded growth.
  final int _maxNotifications;

  final List<NotificationModel> _notifications = [];

  RealtimeChannel? _adminChannel;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  bool _isRealtimeConnected = false;
  bool _disposed = false;

  String? _activeUserId;
  String? _checkingUserId;
  String? _resolvedUserId;

  int _sessionGeneration = 0;

  NotificationsProvider({
    int maxNotifications = 100,
  }) : _maxNotifications = maxNotifications < 1
            ? 100
            : maxNotifications {
    _listenToAuthChanges();

    // Covers the case where the session already exists when this provider
    // is created. Duplicate checks prevent a second subscription.
    final userId = _client.auth.currentUser?.id;

    if (userId != null) {
      unawaited(_syncForUser(userId));
    }
  }

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  bool get isRealtimeConnected => _isRealtimeConnected;

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  // ---------------------------------------------------------------------------
  // Authentication and authorization
  // ---------------------------------------------------------------------------

  void _listenToAuthChanges() {
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (authState) {
        unawaited(_syncForUser(authState.session?.user.id));
      },
      onError: (Object error, StackTrace stackTrace) {
        LoggerService.error(
          'Notification auth-state listener failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Only an authenticated, active admin should receive admin notifications.
  ///
  /// The database RLS policies remain the real security boundary.
  Future<void> _syncForUser(String? userId) async {
    if (_disposed) return;

    // Sign-out: immediately stop listening and remove the previous user's
    // notifications from memory.
    if (userId == null) {
      _sessionGeneration++;

      _checkingUserId = null;
      _resolvedUserId = null;
      _activeUserId = null;

      await _removeChannel();

      final hadNotifications = _notifications.isNotEmpty;
      _notifications.clear();

      _isLoading = false;
      _isRealtimeConnected = false;

      if (hadNotifications || !_disposed) {
        _notifyIfAlive();
      }

      return;
    }

    // Avoid repeated profile checks and duplicate channels on token refresh.
    if (_resolvedUserId == userId) return;
    if (_checkingUserId == userId) return;

    final generation = ++_sessionGeneration;

    _checkingUserId = userId;
    _isLoading = true;
    _notifyIfAlive();

    // Tear down a channel belonging to a previous account.
    await _removeChannel();

    if (_activeUserId != userId) {
      _notifications.clear();
    }

    _activeUserId = userId;

    try {
      // This checks the current user's database role.
      // Never use user-editable userMetadata to authorize admin access.
      final profile = await _client
          .from('profiles')
          .select('role, status')
          .eq('id', userId)
          .maybeSingle();

      if (!_isCurrentSession(userId, generation)) return;

      _resolvedUserId = userId;

      final isActiveAdmin = profile != null &&
          profile['role'] == 'admin' &&
          profile['status'] == 'active';

      if (!isActiveAdmin) {
        _isRealtimeConnected = false;

        LoggerService.info(
          'Realtime admin notifications disabled for non-admin user',
        );

        return;
      }

      _subscribeToAdminEvents(userId);
    } catch (e, st) {
      if (_isCurrentSession(userId, generation)) {
        LoggerService.error(
          'Failed to initialize admin notifications',
          error: e,
          stackTrace: st,
        );
      }
    } finally {
      if (!_disposed && generation == _sessionGeneration) {
        _checkingUserId = null;
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  bool _isCurrentSession(String userId, int generation) {
    return !_disposed &&
        generation == _sessionGeneration &&
        _client.auth.currentUser?.id == userId;
  }

  /// Manually recheck the current user's role and retry the subscription.
  ///
  /// Call this after an administrator role is changed while the same account
  /// is still signed in, or if the initial subscription failed.
  Future<void> refreshAuthorization() async {
    if (_disposed) return;

    _resolvedUserId = null;

    await _syncForUser(_client.auth.currentUser?.id);
  }

  // ---------------------------------------------------------------------------
  // Supabase Realtime
  // ---------------------------------------------------------------------------

  void _subscribeToAdminEvents(String userId) {
    if (_disposed || _adminChannel != null) return;

    final channel = _client.channel('admin-notifications-$userId');
    _adminChannel = channel;

    try {
      // New orders
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'orders',
        callback: _handleNewOrder,
      );

      // New reservations
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'reservations',
        callback: _handleNewReservation,
      );

      // New customer profiles
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'profiles',
        callback: _handleNewCustomer,
      );

      channel.subscribe((status, error) {
        if (_disposed) return;

        switch (status) {
          case RealtimeSubscribeStatus.subscribed:
            _isRealtimeConnected = true;

            LoggerService.info(
              'Admin notifications Realtime connected',
            );

            _notifyIfAlive();
            break;

          case RealtimeSubscribeStatus.channelError:
            _isRealtimeConnected = false;

            LoggerService.error(
              'Admin notifications Realtime channel error',
              error: error,
            );

            _notifyIfAlive();
            break;

          case RealtimeSubscribeStatus.timedOut:
            _isRealtimeConnected = false;

            LoggerService.error(
              'Admin notifications Realtime timed out',
              error: error,
            );

            _notifyIfAlive();
            break;

          case RealtimeSubscribeStatus.closed:
            _isRealtimeConnected = false;
            _notifyIfAlive();
            break;
        }
      });
    } catch (e, st) {
      LoggerService.error(
        'Failed to configure Realtime listeners',
        error: e,
        stackTrace: st,
      );

      // Avoid leaving a partially configured channel around.
      unawaited(_removeChannel());
    }
  }

  void _handleNewOrder(PostgresChangePayload payload) {
    final record = payload.newRecord;
    final orderId = _stringValue(record['id']);

    if (orderId.isEmpty) return;

    final amount = record['total_amount'];
    final amountText = amount == null ? 'نامشخص' : amount.toString();

    _addNotification(
      NotificationModel(
        id: orderId,
        title: 'سفارش جدید',
        description: 'سفارش جدید ثبت شد — مبلغ: $amountText',
        timestamp: _readTimestamp(record['created_at']),
        type: NotificationType.newOrder,
      ),
    );
  }

  void _handleNewReservation(PostgresChangePayload payload) {
    final record = payload.newRecord;
    final reservationId = _stringValue(record['id']);

    if (reservationId.isEmpty) return;

    final guestCount = record['guest_count'];
    final guestText =
        guestCount == null ? 'نامشخص' : guestCount.toString();

    _addNotification(
      NotificationModel(
        id: reservationId,
        title: 'رزرو جدید',
        description: 'رزرو جدید ثبت شد — تعداد مهمان: $guestText',
        timestamp: _readTimestamp(record['created_at']),
        type: NotificationType.newReservation,
      ),
    );
  }

  void _handleNewCustomer(PostgresChangePayload payload) {
    final record = payload.newRecord;
    final customerId = _stringValue(record['id']);

    if (customerId.isEmpty) return;

    final firstName = _stringValue(record['first_name']);
    final lastName = _stringValue(record['last_name']);

    final customerName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ');

    final description = customerName.isNotEmpty
        ? 'پروفایل مشتری $customerName ایجاد شد'
        : 'پروفایل مشتری جدید ایجاد شد';

    _addNotification(
      NotificationModel(
        id: customerId,
        title: 'مشتری جدید',
        description: description,
        timestamp: _readTimestamp(record['created_at']),
        type: NotificationType.newCustomer,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification management
  // ---------------------------------------------------------------------------

  void _addNotification(NotificationModel notification) {
    if (_disposed) return;

    // Protect against duplicate events and reconnect-related duplicates.
    final alreadyExists = _notifications.any(
      (existing) =>
          existing.id == notification.id &&
          existing.type == notification.type,
    );

    if (alreadyExists) return;

    _notifications.insert(0, notification);

    // Keep newest notifications and discard the oldest beyond the limit.
    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(
        _maxNotifications,
        _notifications.length,
      );
    }

    _notifyIfAlive();
  }

  /// Marks a notification as read in the current app session.
  ///
  /// This is intentionally in-memory only; see the notes below about
  /// database persistence.
  Future<void> markAsRead(String id) async {
    if (_disposed) return;

    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(
      isRead: true,
    );

    _notifyIfAlive();
  }

  /// Marks every in-memory notification as read.
  Future<void> markAllAsRead() async {
    if (_disposed) return;

    final hasUnread = _notifications.any(
      (notification) => !notification.isRead,
    );

    if (!hasUnread) return;

    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(
          isRead: true,
        );
      }
    }

    _notifyIfAlive();
  }

  void clearNotifications() {
    if (_disposed || _notifications.isEmpty) return;

    _notifications.clear();
    _notifyIfAlive();
  }

  // ---------------------------------------------------------------------------
  // Helpers and cleanup
  // ---------------------------------------------------------------------------

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  DateTime _readTimestamp(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }

    return DateTime.now();
  }

  Future<void> _removeChannel() async {
    final channel = _adminChannel;

    _adminChannel = null;
    _isRealtimeConnected = false;

    if (channel == null) return;

    try {
      await _client.removeChannel(channel);

      LoggerService.info(
        'Admin notifications Realtime channel removed',
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to remove notifications Realtime channel',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _removeChannelAfterDispose(
    RealtimeChannel channel,
  ) async {
    try {
      await _client.removeChannel(channel);
    } catch (e, st) {
      LoggerService.error(
        'Realtime cleanup failed during dispose',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionGeneration++;

    final subscription = _authSubscription;
    _authSubscription = null;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    final channel = _adminChannel;
    _adminChannel = null;

    if (channel != null) {
      unawaited(_removeChannelAfterDispose(channel));
    }

    super.dispose();
  }
}