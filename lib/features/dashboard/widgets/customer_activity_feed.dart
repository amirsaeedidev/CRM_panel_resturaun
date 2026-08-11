import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';

// --- Models (Usually in models folder, kept here for self-containment) ---
enum ActivityType { orderPlaced, discountUsed, addressAdded, unknown }

class ActivityModel {
  final String id;
  final String customerName;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  ActivityModel({
    required this.id,
    required this.customerName,
    required this.description,
    required this.timestamp,
    this.type = ActivityType.unknown,
  });
}
// -------------------------------------------------------------------------

class CustomerActivityFeed extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const CustomerActivityFeed({
    super.key,
    required this.activities,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  String _getRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.orderPlaced: return Icons.shopping_cart_checkout;
      case ActivityType.discountUsed: return Icons.discount_outlined;
      case ActivityType.addressAdded: return Icons.add_location_alt_outlined;
      case ActivityType.unknown: return Icons.history;
    }
  }

  Color _getIconColor(ActivityType type, BuildContext context) {
    switch (type) {
      case ActivityType.orderPlaced: return AppColors.success;
      case ActivityType.discountUsed: return AppColors.primary;
      case ActivityType.addressAdded: return AppColors.info;
      case ActivityType.unknown: return AppColors.getSecondaryText(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryText(context),
                    ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          
          // States Handling
          if (error != null)
            _buildErrorState(context)
          else if (isLoading && activities.isEmpty)
            _buildLoadingState(context)
          else if (activities.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.getBorder(context).withOpacity(0.5),
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(context, activity);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: _getIconColor(activity.type, context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(activity.type),
              color: _getIconColor(activity.type, context),
              size: 18,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getPrimaryText(context),
                        ),
                    children: [
                      TextSpan(
                        text: activity.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' ${activity.description}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRelativeTime(activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getSecondaryText(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.getBorder(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: AppColors.getBorder(context),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 100,
                    color: AppColors.getBorder(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_toggle_off, size: 40, color: AppColors.getSecondaryText(context)),
            const SizedBox(height: AppSizes.md),
            Text(
              'No recent activity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getSecondaryText(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: AppSizes.md),
            Text(
              error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.md),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}