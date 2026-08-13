import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../core/services/supabase_service.dart';

// --- Models (Kept here for self-containment as per Prompt 16) ---
enum NotificationType { newOrder, newReservation, newCustomer, unknown }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.unknown,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}
// -------------------------------------------------------------------------

class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  
  // Channel reference for cleanup
  late final RealtimeChannel _ordersChannel;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationsProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    try {
      _ordersChannel = SupabaseService.client
          .channel('orders-realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              final newOrder = payload.newRecord;
              _addNotification(
                NotificationModel(
                  id: newOrder['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'سفارش جدید',
                  description: 'سفارش جدید ثبت شد — مبلغ: ${newOrder['total_amount'] ?? '?'}',
                  type: NotificationType.newOrder,
                  isRead: false,
                  timestamp: DateTime.now(),
                ),
              );
            },
          )
          .subscribe();
          
      LoggerService.info('Subscribed to orders realtime channel');
    } catch (e, st) {
      LoggerService.error('Failed to subscribe to realtime', error: e, stackTrace: st);
    }
  }

  void _addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _calculateUnread();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  void _calculateUnread() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  @override
  void dispose() {
    try {
      SupabaseService.client.removeChannel(_ordersChannel);
      LoggerService.info('Unsubscribed from orders realtime channel');
    } catch (e) {
      LoggerService.error('Error removing realtime channel', error: e);
    }
    super.dispose();
  }
}