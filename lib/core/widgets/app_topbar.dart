import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';

class AppTopbar extends StatefulWidget {
  final String title;
  final VoidCallback onMenuTap;

  /// Called when the search query changes.
  /// Connect this to your actual search/filter logic.
  final ValueChanged<String>? onSearchChanged;

  /// Called when a notification is selected.
  final ValueChanged<String>? onNotificationSelected;

  /// Called when "mark all as read" is selected.
  final VoidCallback? onMarkAllNotificationsRead;

  const AppTopbar({
    super.key,
    required this.title,
    required this.onMenuTap,
    this.onSearchChanged,
    this.onNotificationSelected,
    this.onMarkAllNotificationsRead,
  });

  @override
  State<AppTopbar> createState() => _AppTopbarState();
}

class _AppTopbarState extends State<AppTopbar> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.topBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getBorder(context),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 760;
          final isVeryNarrow = width < 380;

          return Row(
            children: [
              _buildMenuButton(context),
              SizedBox(width: AppSizes.sm),

              // Title shrinks instead of overflowing on narrow screens.
              if (isCompact)
                Expanded(
                  child: _buildTitle(context),
                )
              else
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildTitle(context),
                ),

              if (!isCompact) ...[
                SizedBox(width: AppSizes.lg),
                Expanded(
                  flex: 2,
                  child: _buildSearchField(context),
                ),
              ] else ...[
                _buildActionButton(
                  icon: Icons.search,
                  tooltip: 'جستجو',
                  onPressed: () => _showSearchDialog(context),
                  color: AppColors.getPrimaryText(context),
                ),
              ],

              SizedBox(width: AppSizes.xs),

              _buildNotificationBell(context),

              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildActionButton(
                    icon: themeProvider.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    tooltip: themeProvider.isDarkMode
                        ? 'حالت روشن'
                        : 'حالت تاریک',
                    color: AppColors.getPrimaryText(context),
                    onPressed: themeProvider.toggleTheme,
                  );
                },
              ),

              // The decorative profile avatar is hidden on very narrow
              // screens to preserve room for the essential actions.
              if (!isVeryNarrow) ...[
                SizedBox(width: AppSizes.xs),
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: AppSizes.iconSm,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      tooltip: 'باز کردن منو',
      onPressed: widget.onMenuTap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: Icon(
        Icons.menu,
        color: AppColors.getPrimaryText(context),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.titleLarge.copyWith(
        color: AppColors.getPrimaryText(context),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: Icon(
        icon,
        color: color,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      onSubmitted: widget.onSearchChanged,
      textInputAction: TextInputAction.search,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.getPrimaryText(context),
      ),
      decoration: InputDecoration(
        hintText: 'جستجو...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.getSecondaryText(context),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.getSecondaryText(context),
          size: AppSizes.iconSm,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.getBackground(context),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.circular,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.circular,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.circular,
          ),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.getSurface(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          title: Text(
            'جستجو',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.getPrimaryText(dialogContext),
            ),
          ),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: widget.onSearchChanged,
            onSubmitted: (value) {
              widget.onSearchChanged?.call(value);
              Navigator.of(dialogContext).pop();
            },
            textInputAction: TextInputAction.search,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.getPrimaryText(dialogContext),
            ),
            decoration: InputDecoration(
              hintText: 'عبارت موردنظر را وارد کنید...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.getSecondaryText(dialogContext),
              ),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.getBackground(dialogContext),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppRadius.circular,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Keep the notification popup inside the available screen width.
    final popupMaxWidth =
        (screenWidth - 24).clamp(220.0, 360.0).toDouble();
    final popupMinWidth =
        (screenWidth - 48).clamp(200.0, 300.0).toDouble();

    return Selector<NotificationsProvider, int>(
      selector: (context, provider) => provider.unreadCount,
      builder: (context, unreadCount, child) {
        return PopupMenuButton<String>(
          tooltip: 'اعلان‌ها',
          padding: EdgeInsets.zero,
          icon: SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_none,
                    color: AppColors.getPrimaryText(context),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 9
                            ? '۹+'
                            : _toPersianDigits('$unreadCount'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          color: AppColors.getSurface(context),
          constraints: BoxConstraints(
            minWidth: popupMinWidth,
            maxWidth: popupMaxWidth,
          ),
          position: PopupMenuPosition.under,
          onSelected: (value) {
            if (value == 'mark_all_read') {
              widget.onMarkAllNotificationsRead?.call();
            } else {
              widget.onNotificationSelected?.call(value);
            }
          },
          itemBuilder: (context) => _buildNotificationItems(
            context,
            popupMaxWidth,
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildNotificationItems(
    BuildContext context,
    double popupMaxWidth,
  ) {
    final provider = context.read<NotificationsProvider>();

    if (provider.notifications.isEmpty) {
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: popupMaxWidth - 48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 36,
                  color: AppColors.getSecondaryText(context),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  'اعلان جدیدی وجود ندارد',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.getSecondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final items = <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        enabled: false,
        child: Text(
          'اعلان‌ها',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getPrimaryText(context),
              ),
        ),
      ),
      const PopupMenuDivider(),
    ];

    for (final notif in provider.notifications.take(5)) {
      items.add(
        PopupMenuItem<String>(
          value: notif.id,
          // Disable the item unless the parent provides its handler.
          enabled: widget.onNotificationSelected != null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: popupMaxWidth - 48,
            ),
            child: _buildNotificationItem(context, notif),
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider());

    items.add(
      PopupMenuItem<String>(
        value: 'mark_all_read',
        enabled: widget.onMarkAllNotificationsRead != null,
        child: Center(
          child: Text(
            'علامت‌گذاری همه به‌عنوان خوانده‌شده',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    return items;
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notif,
  ) {
    final color = _getNotifColor(notif.type);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotifIcon(notif.type),
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: notif.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                ),
                SizedBox(height: 2),
                Text(
                  notif.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getSecondaryText(context),
                      ),
                ),
              ],
            ),
          ),
          if (!notif.isRead) ...[
            SizedBox(width: AppSizes.xs),
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 5),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getNotifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return Icons.shopping_cart_checkout;
      case NotificationType.newReservation:
        return Icons.event_seat;
      case NotificationType.newCustomer:
        return Icons.person_add;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }

  Color _getNotifColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOrder:
        return AppColors.success;
      case NotificationType.newReservation:
        return AppColors.warning;
      case NotificationType.newCustomer:
        return AppColors.info;
      case NotificationType.unknown:
        return AppColors.primary;
    }
  }

  String _toPersianDigits(String value) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';

    return value.split('').map((character) {
      final index = english.indexOf(character);
      return index == -1 ? character : persian[index];
    }).join();
  }
}