import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';

// --- Models (Usually in models folder, kept here for self-containment) ---
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
}
// -------------------------------------------------------------------------

class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationsProvider() {
    // In a real app, you would fetch initial notifications from a Repository
    // and subscribe to RealtimeService for new ones.
    // fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // final data = await _repository.getNotifications();
      // _notifications = data;
      _calculateUnread();
    } catch (e, st) {
      LoggerService.error('Fetch notifications failed', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // In a real app, call repository to update status
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        description: _notifications[index].description,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        type: _notifications[index].type,
      );
      _calculateUnread();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    // In a real app, call repository to update all
    _notifications = _notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      description: n.description,
      timestamp: n.timestamp,
      isRead: true,
      type: n.type,
    )).toList();
    
    _unreadCount = 0;
    notifyListeners();
  }

  void _calculateUnread() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}