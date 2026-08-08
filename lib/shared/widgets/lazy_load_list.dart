import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class LazyLoadListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool hasReachedMax;
  final Widget? loadingWidget;

  const LazyLoadListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasReachedMax,
    this.loadingWidget,
  });

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !widget.isLoading && !widget.hasReachedMax) {
      widget.onLoadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more when user reaches 90% of the list
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    // Add 1 to item count to show loading indicator at the bottom
    final itemCount = widget.hasReachedMax ? widget.items.length : widget.items.length + 1;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Show bottom loading indicator
          return _buildBottomLoader();
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  Widget _buildBottomLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}