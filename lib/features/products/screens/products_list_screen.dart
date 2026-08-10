import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../models/product_model.dart';
import '../../../providers/products_provider.dart';
import '../../../shared/dialogs/delete_dialog.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
import '../../../shared/widgets/pagination_widget.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                'Products Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'Add New Product',
                icon: Icons.add_rounded,
                width: 200,
                onPressed: () {
                  context.push('/products/add');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Search Bar
          AppSearch(
            controller: _searchController,
            onChanged: (value) {
              context.read<ProductsProvider>().setSearchQuery(value);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Content Area
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const Center(child: AppLoading());
                }

                if (provider.error != null && provider.products.isEmpty) {
                  return app_error.AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchProducts(),
                  );
                }

                if (provider.products.isEmpty) {
                  return const EmptyWidget(
                    title: 'No Products Found',
                    message: 'There are no products matching your criteria.',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Desktop & Tablet: Table View
                    if (constraints.maxWidth > 600) {
                      return _buildDesktopTable(context, provider);
                    }
                    // Mobile: Card View
                    return _buildMobileList(context, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ProductsProvider provider) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.medium),
                topRight: Radius.circular(AppRadius.medium),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderText(context, 'Product', 3),
                _buildHeaderText(context, 'Price', 2),
                _buildHeaderText(context, 'Rating', 1),
                _buildHeaderText(context, 'Status', 1),
                _buildHeaderText(context, 'Actions', 1),
              ],
            ),
          ),
          // Table Rows
          Expanded(
            child: ListView.separated(
              itemCount: provider.products.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return _buildDesktopRow(context, provider, product);
              },
            ),
          ),
          if (provider.totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: PaginationWidget(
                currentPage: provider.currentPage,
                totalPages: provider.totalPages,
                onPageChanged: (page) {
                  provider.changePage(page);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(BuildContext context, String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildDesktopRow(BuildContext context, ProductsProvider provider, ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Row(
        children: [
          // Product Name & Category
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (product.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.network(
                      product.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(Icons.image_outlined, color: AppColors.getSecondaryText(context)),
                  ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.isPopular) ...[
                            const SizedBox(width: AppSizes.sm),
                            const CustomChip(label: 'Popular', type: ChipType.primary),
                          ]
                        ],
                      ),
                      Text(
                        product.categoryId,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.getSecondaryText(context),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Expanded(
            flex: 2,
            child: _buildPriceWidget(context, product),
          ),
          
          // Rating
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  product.rating != null 
                      ? '${product.rating!.toStringAsFixed(1)} (${product.reviewCount ?? 0})'
                      : 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Status Toggle
          Expanded(
            flex: 1,
            child: _buildStatusToggle(context, provider, product),
          ),
          
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, color: AppColors.info),
                  onPressed: () {
                    context.push('/products/details/${product.id}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () {
                    context.push('/products/edit/${product.id}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    DeleteDialog.show(
                      context: context,
                      title: 'Delete Product',
                      message: 'Are you sure you want to delete "${product.name}"?',
                      onDelete: () {
                        provider.deleteProduct(product.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, ProductsProvider provider) {
    return ListView.separated(
      itemCount: provider.products.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: Image.network(
                        product.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.broken_image, size: 60),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.getBackground(context),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Icon(Icons.image_outlined, color: AppColors.getSecondaryText(context)),
                    ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.isPopular)
                              const CustomChip(label: 'Popular', type: ChipType.primary),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        _buildPriceWidget(context, product),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              product.rating != null 
                                  ? '${product.rating!.toStringAsFixed(1)} (${product.reviewCount ?? 0})'
                                  : 'N/A',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusToggle(context, provider, product),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, color: AppColors.info),
                        onPressed: () {
                          context.push('/products/details/${product.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () {
                          context.push('/products/edit/${product.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () {
                          DeleteDialog.show(
                            context: context,
                            title: 'Delete Product',
                            message: 'Are you sure you want to delete "${product.name}"?',
                            onDelete: () {
                              provider.deleteProduct(product.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceWidget(BuildContext context, ProductModel product) {
    if (product.discountedPrice != null && product.discountedPrice! < product.price) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_currencyFormatter.format(product.price)} T',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.getSecondaryText(context),
                ),
          ),
          Text(
            '${_currencyFormatter.format(product.discountedPrice)} T',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
          ),
        ],
      );
    }
    
    return Text(
      '${_currencyFormatter.format(product.price)} T',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatusToggle(BuildContext context, ProductsProvider provider, ProductModel product) {
    // In a real app, you might want to track which specific item is loading
    // For simplicity, we use the provider's general loading state or a local one
    // Here we use a local approach to avoid rebuilding the whole list
    return StatefulBuilder(
      builder: (context, setState) {
        bool isToggling = false; // This should ideally come from provider per item ID

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.status == 'active',
              onChanged: (val) async {
                setState(() => isToggling = true);
                await provider.toggleProductStatus(product.id, val);
                if (context.mounted) {
                  setState(() => isToggling = false);
                }
              },
              activeColor: AppColors.success,
            ),
            if (isToggling)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                product.status == 'active' ? 'Available' : 'Unavailable',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: product.status == 'active' ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        );
      },
    );
  }
}