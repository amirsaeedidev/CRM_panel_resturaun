import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../shared/dialogs/delete_dialog.dart';
import '../../../core/theme/app_radius.dart';
class BannersListScreen extends StatefulWidget {
  const BannersListScreen({super.key});

  @override
  State<BannersListScreen> createState() => _BannersListScreenState();
}

class _BannersListScreenState extends State<BannersListScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _banners = [
    {'id': 1, 'title': 'جشنواره تابستانه', 'order': 1, 'isActive': true},
    {'id': 2, 'title': 'تخفیف ویژه پوشاک', 'order': 2, 'isActive': true},
    {'id': 3, 'title': 'بنر صفحه اصلی', 'order': 3, 'isActive': false},
    {'id': 4, 'title': 'معرفی محصولات جدید', 'order': 4, 'isActive': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مدیریت بنرها',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'افزودن بنر جدید',
                icon: Icons.add_rounded,
                width: 200,
                onPressed: () {
                  // TODO: Navigate to Add Banner Screen
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Banners Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
              ),
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image Placeholder
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.getBackground(context),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.large),
                            ),
                          ),
                          child: Icon(Icons.image_outlined, size: 40, color: AppColors.getSecondaryText(context)),
                        ),
                      ),
                      // Banner Info
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    banner['title'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.getPrimaryText(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert, color: AppColors.getSecondaryText(context)),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      // TODO: Navigate to Edit Screen
                                    } else if (value == 'delete') {
                                      DeleteDialog.show(
                                        context: context,
                                        title: 'حذف بنر',
                                        message: 'آیا از حذف این بنر مطمئن هستید؟',
                                        onDelete: () {
                                          // TODO: Implement delete
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ترتیب: ${banner['order']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.getSecondaryText(context),
                                      ),
                                ),
                                CustomSwitch(
                                  value: banner['isActive'],
                                  onChanged: (val) {
                                    setState(() {
                                      banner['isActive'] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}