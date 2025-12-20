// File: dashboard_filter_sheet.dart

import 'package:auditlab/dummy.dart';
import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardFilterSheet extends ConsumerStatefulWidget {
  final String districtId;

  const DashboardFilterSheet({super.key, required this.districtId});

  @override
  ConsumerState<DashboardFilterSheet> createState() =>
      _DashboardFilterSheetState();
}

class _DashboardFilterSheetState extends ConsumerState<DashboardFilterSheet> {
  String? _selectedYear;
  String? _selectedPeriodId;
  String? _selectedSector;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(dashboardFilterProvider);
    _selectedYear = currentFilter.selectedYear;
    _selectedPeriodId = currentFilter.selectedPeriodId;
    _selectedSector = currentFilter.selectedSector;
    _selectedStatus = currentFilter.selectedStatus;
  }

  void _applyFilters() {
    ref.read(dashboardFilterProvider.notifier).state = DashboardFilter(
      selectedYear: _selectedYear,
      selectedPeriodId: _selectedPeriodId,
      selectedSector: _selectedSector,
      selectedStatus: _selectedStatus,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedPeriodId = null;
      _selectedSector = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filter Options
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year Filter
                      _buildSectionTitle('Filter by Year'),
                      const SizedBox(height: 12),
                      _YearSelector(
                        districtId: widget.districtId,
                        selectedYear: _selectedYear,
                        onChanged: (year) => setState(() {
                          _selectedYear = year;
                          // Clear period when year changes
                          _selectedPeriodId = null;
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Period Filter
                      _buildSectionTitle('Filter by Period'),
                      const SizedBox(height: 12),
                      _PeriodSelector(
                        districtId: widget.districtId,
                        selectedYear: _selectedYear,
                        selectedPeriodId: _selectedPeriodId,
                        onChanged: (periodId) =>
                            setState(() => _selectedPeriodId = periodId),
                      ),

                      const SizedBox(height: 24),

                      // Sector Filter
                      _buildSectionTitle('Filter by Sector'),
                      const SizedBox(height: 12),
                      _SectorSelector(
                        selectedSector: _selectedSector,
                        onChanged: (sector) =>
                            setState(() => _selectedSector = sector),
                      ),

                      const SizedBox(height: 24),

                      // Status Filter
                      _buildSectionTitle('Filter by Status'),
                      const SizedBox(height: 12),
                      _StatusSelector(
                        selectedStatus: _selectedStatus,
                        onChanged: (status) =>
                            setState(() => _selectedStatus = status),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

// Year Selector Widget
class _YearSelector extends StatelessWidget {
  final String districtId;
  final String? selectedYear;
  final ValueChanged<String?> onChanged;

  const _YearSelector({
    required this.districtId,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No periods available');
        }

        // Extract unique years
        final years = <String>{};
        for (var doc in snapshot.data!.docs) {
          final year = doc.data() as Map<String, dynamic>;
          years.add(year['year'] as String);
        }

        final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All Years'),
              selected: selectedYear == null,
              onSelected: (_) => onChanged(null),
            ),
            ...sortedYears.map(
              (year) => FilterChip(
                label: Text(year),
                selected: selectedYear == year,
                onSelected: (_) => onChanged(year),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Period Selector Widget
class _PeriodSelector extends StatelessWidget {
  final String districtId;
  final String? selectedYear;
  final String? selectedPeriodId;
  final ValueChanged<String?> onChanged;

  const _PeriodSelector({
    required this.districtId,
    required this.selectedYear,
    required this.selectedPeriodId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedYear == null) {
      return Card(
        color: Colors.grey[100],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select a year first to filter by period',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .where('year', isEqualTo: selectedYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No periods available for selected year');
        }

        return Column(
          children: [
            FilterChip(
              label: const Text('All Periods'),
              selected: selectedPeriodId == null,
              onSelected: (_) => onChanged(null),
            ),
            const SizedBox(height: 8),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isSelected = selectedPeriodId == doc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => onChanged(doc.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['year']} - ${data['range']}',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? Colors.blue : null,
                                ),
                              ),
                              Text(
                                'Status: ${data['status']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// Sector Selector Widget
class _SectorSelector extends StatelessWidget {
  final String? selectedSector;
  final ValueChanged<String?> onChanged;

  const _SectorSelector({
    required this.selectedSector,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All Sectors'),
          selected: selectedSector == null,
          onSelected: (_) => onChanged(null),
        ),
        ...Sector.allSectors.map(
          (sector) => FilterChip(
            label: Text(sector.displayName),
            selected: selectedSector == sector.code,
            onSelected: (_) => onChanged(sector.code),
          ),
        ),
      ],
    );
  }
}

// Status Selector Widget
class _StatusSelector extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onChanged;

  const _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('Pending', Icons.pending, Colors.blue),
      ('Has Issues', Icons.warning, Colors.red),
      ('Cleared', Icons.check_circle, Colors.green),
      ('Missing', Icons.help_outline, Colors.grey),
      ('Canceled', Icons.cancel, Colors.brown),
    ];

    return Column(
      children: [
        FilterChip(
          label: const Text('All Statuses'),
          selected: selectedStatus == null,
          onSelected: (_) => onChanged(null),
        ),
        const SizedBox(height: 8),
        ...statuses.map((status) {
          final isSelected = selectedStatus == status.$1;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? status.$3.withOpacity(0.1) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? status.$3 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: () => onChanged(status.$1),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      status.$2,
                      color: isSelected ? status.$3 : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.$1,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? status.$3 : null,
                        ),
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: status.$3),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
