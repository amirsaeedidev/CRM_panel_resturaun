import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';

class AppTopbar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const AppTopbar({
    super.key,
    required this.title,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu Button (For Mobile/Tablet)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onMenuTap,
            color: AppColors.getPrimaryText(context),
          ),
          const SizedBox(width: AppSizes.sm),
          
          // Page Title
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.getPrimaryText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Search Field (Responsive)
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.getSecondaryText(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryText(context), size: AppSizes.iconSm),
                filled: true,
                fillColor: AppColors.getBackground(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Spacer(flex: 3),
          
          // Notification Bell with Selector
          _buildNotificationBell(context),
          
          // Dark Mode Toggle Button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.getPrimaryText(context),
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          
          const SizedBox(width: AppSizes.sm),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: AppSizes.iconSm),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    // Using Selector to only rebuild the bell icon when unreadCount changes
    return Selector<NotificationsProvider, int>(
      selector: (context, provider) => provider.unreadCount,
      builder: (context, unreadCount, child) {
        return PopupMenuButton<String>(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none, color: AppColors.getPrimaryText(context)),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          color: AppColors.getSurface(context),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            minWidth: 300,
          ),
          position: PopupMenuPosition.under,
          itemBuilder: (context) => _buildNotificationItems(context),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildNotificationItems(BuildContext context) {
    final provider = context.read<NotificationsProvider>();

    if (provider.notifications.isEmpty) {
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Icon(Icons.notifications_off_outlined, size: 40, color: AppColors.getSecondaryText(context)),
                const SizedBox(height: AppSizes.sm),
                Text('No new notifications', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ];
    }

    List<PopupMenuEntry<String>> items = [
      PopupMenuItem<String>(
        enabled: false,
        child: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      const PopupMenuDivider(),
    ];

    // Add up to 5 recent notifications
    for (var notif in provider.notifications.take(5)) {
      items.add(
        PopupMenuItem<String>(
          value: notif.id,
          enabled: true,
          child: _buildNotificationItem(context, notif),
        ),
      );
    }

    items.add(const PopupMenuDivider());
    items.add(
      PopupMenuItem<String>(
        value: 'mark_all_read',
        child: Center(
          child: Text(
            'Mark all as read',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return items;
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif) {
    return InkWell(
      onTap: () {
        // Handle notification tap
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: _getNotifColor(notif.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getNotifIcon(notif.type), color: _getNotifColor(notif.type), size: 16),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getSecondaryText(context),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder: return Icons.shopping_cart_checkout;
      case NotificationType.newReservation: return Icons.event_seat;
      case NotificationType.newCustomer: return Icons.person_add;
      case NotificationType.unknown: return Icons.notifications;
    }
  }

  Color _getNotifColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder: return AppColors.success;
      case NotificationType.newReservation: return AppColors.warning;
      case NotificationType.newCustomer: return AppColors.info;
      case NotificationType.unknown: return AppColors.primary;
    }
  }
}