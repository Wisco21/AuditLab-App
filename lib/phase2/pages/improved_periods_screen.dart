// State providers for filtering and sorting
import 'package:auditlab/phase2/fix_provider_scope.dart';
import 'package:auditlab/phase2/models/period.dart';
import 'package:auditlab/phase2/pages/folder_screen.dart';
import 'package:auditlab/phase2/provider/period_provider.dart';
import 'package:auditlab/phase2/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final periodSearchQueryProvider = StateProvider<String>((ref) => '');
final periodStatusFilterProvider = StateProvider<String?>((ref) => null);
final periodSortOptionProvider = StateProvider<String>((ref) => 'newest');

class PeriodsScreen extends ConsumerWidget {
  const PeriodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtIdAsync = ref.watch(userDistrictIdProvider);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
    final searchQuery = ref.watch(periodSearchQueryProvider);
    final statusFilter = ref.watch(periodStatusFilterProvider);
    final sortOption = ref.watch(periodSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Periods'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, ref),
          ),
        ],
      ),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          final periodsAsync = ref.watch(periodsProvider(districtId));

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) =>
                      ref.read(periodSearchQueryProvider.notifier).state =
                          value,
                  decoration: InputDecoration(
                    hintText: 'Search periods...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                ref
                                        .read(
                                          periodSearchQueryProvider.notifier,
                                        )
                                        .state =
                                    '',
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),

              // Active filters chip
              if (statusFilter != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Chip(
                        label: Text('Status: $statusFilter'),
                        onDeleted: () =>
                            ref
                                    .read(periodStatusFilterProvider.notifier)
                                    .state =
                                null,
                        deleteIcon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(periodsProvider(districtId));
                  },
                  child: periodsAsync.when(
                    data: (periods) {
                      if (periods.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No periods yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isSupervisor
                                    ? 'Tap the + button to create a period'
                                    : 'Waiting for supervisor to create periods',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      // Apply filters and search
                      var filteredPeriods = periods.where((period) {
                        final matchesSearch =
                            searchQuery.isEmpty ||
                            period.year.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) ||
                            period.range.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            );

                        final matchesStatus =
                            statusFilter == null ||
                            period.status == statusFilter;

                        return matchesSearch && matchesStatus;
                      }).toList();

                      // Apply sorting
                      filteredPeriods = _sortPeriods(
                        filteredPeriods,
                        sortOption,
                      );

                      if (filteredPeriods.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No periods found',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      // Group by year
                      final groupedPeriods = <String, List<Period>>{};
                      for (var period in filteredPeriods) {
                        groupedPeriods.putIfAbsent(period.year, () => []);
                        groupedPeriods[period.year]!.add(period);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: groupedPeriods.length * 2,
                        itemBuilder: (context, index) {
                          if (index.isOdd) {
                            return const SizedBox(height: 16);
                          }

                          final yearIndex = index ~/ 2;
                          final year = groupedPeriods.keys.elementAt(yearIndex);
                          final yearPeriods = groupedPeriods[year]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Year divider
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        year,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Period cards for this year
                              ...yearPeriods.map(
                                (period) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PeriodCard(
                                    period: period,
                                    districtId: districtId,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(periodsProvider(districtId)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: isSupervisor
          ? FutureBuilder<String?>(
              future: ref.watch(userRoleProvider.future),
              builder: (context, snapshot) {
                final userRole = snapshot.data;
                // Only show FAB for DOF and CA
                if (userRole == 'DOF' || userRole == 'CA') {
                  return FloatingActionButton.extended(
                    onPressed: () => _showCreatePeriodBottomSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('New Period'),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : null,
      // floatingActionButton: isSupervisor
      //     ? FloatingActionButton.extended(
      //         onPressed: () => _showCreatePeriodBottomSheet(context, ref),
      //         icon: const Icon(Icons.add),
      //         label: const Text('New Period'),
      //       )
      //     : null,
    );
  }

  List<Period> _sortPeriods(List<Period> periods, String sortOption) {
    switch (sortOption) {
      case 'newest':
        return periods..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'oldest':
        return periods..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'year_asc':
        return periods..sort((a, b) => a.year.compareTo(b.year));
      case 'year_desc':
        return periods..sort((a, b) => b.year.compareTo(a.year));
      case 'status':
        return periods..sort((a, b) => a.status.compareTo(b.status));
      default:
        return periods;
    }
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter & Sort',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text('Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: ref.watch(periodStatusFilterProvider) == null,
                  onSelected: (_) =>
                      ref.read(periodStatusFilterProvider.notifier).state =
                          null,
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: ref.watch(periodStatusFilterProvider) == 'Pending',
                  onSelected: (_) =>
                      ref.read(periodStatusFilterProvider.notifier).state =
                          'Pending',
                ),
                FilterChip(
                  label: const Text('In Progress'),
                  selected:
                      ref.watch(periodStatusFilterProvider) == 'In Progress',
                  onSelected: (_) =>
                      ref.read(periodStatusFilterProvider.notifier).state =
                          'In Progress',
                ),
                FilterChip(
                  label: const Text('Completed'),
                  selected:
                      ref.watch(periodStatusFilterProvider) == 'Completed',
                  onSelected: (_) =>
                      ref.read(periodStatusFilterProvider.notifier).state =
                          'Completed',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Newest'),
                  selected: ref.watch(periodSortOptionProvider) == 'newest',
                  onSelected: (_) =>
                      ref.read(periodSortOptionProvider.notifier).state =
                          'newest',
                ),
                ChoiceChip(
                  label: const Text('Oldest'),
                  selected: ref.watch(periodSortOptionProvider) == 'oldest',
                  onSelected: (_) =>
                      ref.read(periodSortOptionProvider.notifier).state =
                          'oldest',
                ),
                ChoiceChip(
                  label: const Text('Year ↑'),
                  selected: ref.watch(periodSortOptionProvider) == 'year_asc',
                  onSelected: (_) =>
                      ref.read(periodSortOptionProvider.notifier).state =
                          'year_asc',
                ),
                ChoiceChip(
                  label: const Text('Year ↓'),
                  selected: ref.watch(periodSortOptionProvider) == 'year_desc',
                  onSelected: (_) =>
                      ref.read(periodSortOptionProvider.notifier).state =
                          'year_desc',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePeriodBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePeriodBottomSheet(),
    );
  }
}

class _PeriodCard extends ConsumerWidget {
  final Period period;
  final String districtId;

  const _PeriodCard({required this.period, required this.districtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return FutureBuilder<Map<String, dynamic>?>(
      future: firestoreService.getUserProfile(period.supervisorId),
      builder: (context, snapshot) {
        final supervisorName = snapshot.data?['name'] ?? 'Loading...';

        return FutureBuilder<double>(
          future: _calculateProgress(),
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.data ?? 0.0;

            return Card(
              margin: EdgeInsets.zero,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _getStatusColor(period.status),
                  width: 3,
                ),
              ),
              child: InkWell(
                onTap: () {
                  ref.read(selectedPeriodProvider.notifier).state = period;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FoldersScreen(districtId: districtId, period: period),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Progress circle
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(period.status),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(period.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Period details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${period.year} • ${period.range}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    supervisorName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _StatusChip(status: period.status),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<double> _calculateProgress() async {
    try {
      final foldersSnapshot = await FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(period.id)
          .collection('folders')
          .get();

      if (foldersSnapshot.docs.isEmpty) return 0.0;

      int completedFolders = 0;
      for (var doc in foldersSnapshot.docs) {
        if (doc.data()['status'] == 'Completed') {
          completedFolders++;
        }
      }

      return completedFolders / foldersSnapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

// Separate file or at the bottom
class CreatePeriodBottomSheet extends ConsumerStatefulWidget {
  const CreatePeriodBottomSheet({super.key});

  @override
  ConsumerState<CreatePeriodBottomSheet> createState() =>
      _CreatePeriodBottomSheetState();
}

class _CreatePeriodBottomSheetState
    extends ConsumerState<CreatePeriodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();

  String? _selectedSupervisorId;
  String? _selectedRange;
  DateTimeRange? _customDateRange;
  bool _isLoading = false;
  bool _useCustomRange = false;

  final List<String> _predefinedRanges = [
    'Jan-Mar',
    'Apr-Jun',
    'Jul-Sep',
    'Oct-Dec',
  ];

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedRange =
            '${_formatDate(picked.start)} - ${_formatDate(picked.end)}';
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _createPeriod() async {
    if (!_formKey.currentState!.validate() ||
        _selectedRange == null ||
        _selectedSupervisorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(periodServiceProvider);
      final userData = await ref.read(currentUserDataProvider.future);
      final districtId = userData!['districtId'] as String;

      await service.createPeriod(
        districtId: districtId,
        year: _yearController.text,
        range: _selectedRange!,
        createdBy: userData['uid'] ?? '',
        supervisorId: _selectedSupervisorId!,
        userName: userData['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Period created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Stream<List<Map<String, dynamic>>> _getSupervisorsStream(String districtId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('districtId', isEqualTo: districtId)
        .where('role', whereIn: ['DOF', 'CA'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'uid': doc.id, ...doc.data()})
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final districtIdAsync = ref.watch(userDistrictIdProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Period',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Year field
                        TextFormField(
                          controller: _yearController,
                          decoration: InputDecoration(
                            labelText: 'Year',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter year';
                            }
                            final year = int.tryParse(value);
                            if (year == null || year < 2000 || year > 2100) {
                              return 'Please enter valid year';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Supervisor selection
                        districtIdAsync.when(
                          data: (districtId) {
                            if (districtId == null) {
                              return const Text('No district assigned');
                            }

                            return StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _getSupervisorsStream(districtId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text('No supervisors available');
                                }

                                final supervisors = snapshot.data!;

                                return DropdownButtonFormField<String>(
                                  value: _selectedSupervisorId,
                                  decoration: InputDecoration(
                                    labelText: 'Supervisor',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: supervisors.map((supervisor) {
                                    return DropdownMenuItem<String>(
                                      value: supervisor['uid'] as String,
                                      child: Text(
                                        supervisor['name'] ?? 'Unknown',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedSupervisorId = value,
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select supervisor';
                                    }
                                    return null;
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                        const SizedBox(height: 20),

                        // Range type toggle
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Predefined Quarter'),
                                selected: !_useCustomRange,
                                onSelected: (selected) {
                                  setState(() {
                                    _useCustomRange = false;
                                    _selectedRange = null;
                                    _customDateRange = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Custom Range'),
                                selected: _useCustomRange,
                                onSelected: (selected) {
                                  setState(() {
                                    _useCustomRange = true;
                                    _selectedRange = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Range selection
                        if (!_useCustomRange)
                          DropdownButtonFormField<String>(
                            value: _selectedRange,
                            decoration: InputDecoration(
                              labelText: 'Quarter',
                              prefixIcon: const Icon(Icons.date_range),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _predefinedRanges.map((range) {
                              return DropdownMenuItem(
                                value: range,
                                child: Text(range),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedRange = value),
                            validator: (value) {
                              if (!_useCustomRange && value == null) {
                                return 'Please select quarter';
                              }
                              return null;
                            },
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _selectCustomDateRange,
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _customDateRange == null
                                      ? 'Select Date Range'
                                      : _selectedRange!,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              if (_customDateRange != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Selected: ${_customDateRange!.start.toString().split(' ')[0]} to ${_customDateRange!.end.toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // Create button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createPeriod,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Period',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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
}
