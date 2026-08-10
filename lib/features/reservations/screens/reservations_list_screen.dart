import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../models/reservation_model.dart';
// import '../../../providers/reservations_provider.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;

class ReservationsListScreen extends StatefulWidget {
  const ReservationsListScreen({super.key});

  @override
  State<ReservationsListScreen> createState() => _ReservationsListScreenState();
}

class _ReservationsListScreenState extends State<ReservationsListScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  final List<String> _filters = ['all', 'pending', 'confirmed', 'seated', 'cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<ReservationsProvider>().fetchReservations();
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
          Text(
            'Reservations Management',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Search Bar
          AppSearch(
            controller: _searchController,
            onChanged: (value) {
              // context.read<ReservationsProvider>().setSearchQuery(value);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Filter Tabs
          _buildFilterTabs(),
          const SizedBox(height: AppSizes.lg),

          // Content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter);
                // context.read<ReservationsProvider>().setStatusFilter(filter);
              }
            },
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  // Dummy provider data for structure. Replace with Consumer<ReservationsProvider>
  Widget _buildContent(BuildContext context) {
    final bool isLoading = false;
    final String? error = null;
    final List<ReservationModel> reservations = [];
    final bool isEmpty = reservations.isEmpty && !isLoading && error == null;

    if (isLoading) {
      return const Center(child: AppLoading());
    }

    if (error != null) {
      return app_error.AppErrorWidget(
        message: error,
        onRetry: () {
          // context.read<ReservationsProvider>().fetchReservations();
        },
      );
    }

    if (isEmpty) {
      return const EmptyWidget(
        title: 'No Reservations Found',
        message: 'There are no reservations matching your criteria.',
        icon: Icons.event_busy_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildDesktopTable(context, reservations);
        }
        return _buildMobileList(context, reservations);
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<ReservationModel> reservations) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: Row(
              children: [
                _buildHeaderText(context, 'Customer', 2),
                _buildHeaderText(context, 'Phone', 2),
                _buildHeaderText(context, 'Date & Time', 2),
                _buildHeaderText(context, 'Party Size', 1),
                _buildHeaderText(context, 'Table', 1),
                _buildHeaderText(context, 'Status', 1),
                _buildHeaderText(context, 'Actions', 1),
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.separated(
              itemCount: reservations.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, index) {
                final res = reservations[index];
                return _buildDesktopRow(context, res);
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

  Widget _buildDesktopRow(BuildContext context, ReservationModel res) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.customerName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (res.note != null && res.note!.isNotEmpty)
                  Text('Note: ${res.note}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(res.customerPhone, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            flex: 2,
            child: Text(
              '${_dateFormatter.format(res.date)} - ${res.time}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(flex: 1, child: Text('${res.partySize} pax', style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(flex: 1, child: Text('T-${res.tableNumber}', style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(flex: 1, child: _buildStatusChip(context, res.status)),
          Expanded(flex: 1, child: _buildActionMenu(context, res)),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<ReservationModel> reservations) {
    return ListView.separated(
      itemCount: reservations.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        final res = reservations[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(res.customerName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  _buildStatusChip(context, res.status),
                ],
              ),
              const Divider(height: AppSizes.md),
              _buildMobileRow(context, Icons.phone, res.customerPhone),
              _buildMobileRow(context, Icons.calendar_today, '${_dateFormatter.format(res.date)} - ${res.time}'),
              _buildMobileRow(context, Icons.group, '${res.partySize} pax at Table ${res.tableNumber}'),
              if (res.note != null && res.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text('Note: ${res.note}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: AppSizes.md),
              Align(
                alignment: Alignment.centerLeft,
                child: _buildActionMenu(context, res),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: AppSizes.sm),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReservationStatus status) {
    ChipType type;
    switch (status) {
      case ReservationStatus.pending: type = ChipType.warning; break;
      case ReservationStatus.confirmed: type = ChipType.info; break;
      case ReservationStatus.seated: type = ChipType.success; break;
      case ReservationStatus.cancelled: type = ChipType.error; break;
    }
    return CustomChip(
      label: status.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
      type: type,
    );
  }

  Widget _buildActionMenu(BuildContext context, ReservationModel res) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
      tooltip: 'Change Status',
      onSelected: (String newStatus) {
        // context.read<ReservationsProvider>().updateReservationStatus(res.id, newStatus);
      },
      itemBuilder: (context) {
        final statuses = ['pending', 'confirmed', 'seated', 'cancelled'];
        return statuses.map((status) {
          return PopupMenuItem<String>(
            value: status,
            enabled: status != res.status.name,
            child: Text(status.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
          );
        }).toList();
      },
    );
  }
}