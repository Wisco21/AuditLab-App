// State providers for filtering and sorting
import 'package:auditlab/phase_two_core_features/fix_provider_scope.dart';
import 'package:auditlab/models/period.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_folders_screen.dart';
import 'package:auditlab/phase_two_core_features/provider/period_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
//============================================================

// ========== THEME & STYLING ==========
class PeriodsTheme {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color accent = Color(0xFF7209B7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);

  static const LinearGradient yearGradient = LinearGradient(
    colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFF7209B7), Color(0xFFB5179E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient completedGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pendingGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(20));
}

// ========== PROVIDERS ==========
final periodSearchQueryProvider = StateProvider<String>((ref) => '');
final periodStatusFilterProvider = StateProvider<String?>((ref) => null);
final periodSortOptionProvider = StateProvider<String>((ref) => 'newest');
final expandedYearsProvider = StateProvider<Set<String>>((ref) => {});

// ========== MAIN PERIODS SCREEN ==========
class ModernPeriodsScreen extends ConsumerStatefulWidget {
  const ModernPeriodsScreen({super.key});

  @override
  ConsumerState<ModernPeriodsScreen> createState() =>
      _ModernPeriodsScreenState();
}

class _ModernPeriodsScreenState extends ConsumerState<ModernPeriodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      ref.read(periodSearchQueryProvider.notifier).state =
          _searchController.text;
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _toggleYearExpansion(String year) {
    final expandedYears = ref.read(expandedYearsProvider);
    final newExpandedYears = Set<String>.from(expandedYears);

    if (newExpandedYears.contains(year)) {
      newExpandedYears.remove(year);
    } else {
      newExpandedYears.add(year);
    }

    ref.read(expandedYearsProvider.notifier).state = newExpandedYears;
  }

  void _expandAllYears(Map<String, List<Period>> groupedPeriods) {
    final allYears = groupedPeriods.keys.toSet();
    ref.read(expandedYearsProvider.notifier).state = allYears;
  }

  void _collapseAllYears() {
    ref.read(expandedYearsProvider.notifier).state = {};
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final districtIdAsync = ref.watch(userDistrictIdProvider);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
    final searchQuery = ref.watch(periodSearchQueryProvider);
    final statusFilter = ref.watch(periodStatusFilterProvider);
    final sortOption = ref.watch(periodSortOptionProvider);
    final expandedYears = ref.watch(expandedYearsProvider);

    return Scaffold(
      backgroundColor: PeriodsTheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: PeriodsTheme.surface,
              surfaceTintColor: PeriodsTheme.surface,
              elevation: _isScrolled ? 2 : 0,
              shadowColor: Colors.black.withOpacity(0.1),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    // gradient: PeriodsTheme.yearGradient,
                    // borderRadius: const BorderRadius.only(
                    //   bottomLeft: Radius.circular(30),
                    //   bottomRight: Radius.circular(30),
                    // ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        // vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(context),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showFilterBottomSheet(context, ref),
                  icon: Icon(Icons.filter_list_rounded, color: Colors.white),
                  tooltip: 'Filter & Sort',
                ),
              ],
            ),
            if (statusFilter != null)
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeaderDelegate(
                  statusFilter: statusFilter,
                  onClear: () =>
                      ref.read(periodStatusFilterProvider.notifier).state =
                          null,
                ),
              ),
          ];
        },
        body: districtIdAsync.when(
          data: (districtId) {
            if (districtId == null) {
              return _buildNoDistrictView();
            }
            return _buildPeriodsContent(districtId);
          },
          loading: () => _buildLoadingSkeleton(),
          error: (error, _) => _buildErrorView(error),
        ),
      ),
      floatingActionButton: isSupervisor
          ? FutureBuilder<String?>(
              future: ref.watch(userRoleProvider.future),
              builder: (context, snapshot) {
                final userRole = snapshot.data;
                if (userRole == 'DOF' || userRole == 'CA') {
                  return FloatingActionButton.extended(
                    onPressed: () => _showCreatePeriodBottomSheet(context, ref),
                    backgroundColor: Colors.white,
                    foregroundColor: PeriodsTheme.primary,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Period'),
                    shape: RoundedRectangleBorder(
                      borderRadius: PeriodsTheme.pillRadius,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: PeriodsTheme.cardRadius,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Periods',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage and track audit periods',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: PeriodsTheme.pillRadius,
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
          hintText: 'Search periods...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(periodSearchQueryProvider.notifier).state = '';
                  },
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        cursorColor: Colors.white,
      ),
    );
  }

  Widget _buildNoDistrictView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 80,
            color: PeriodsTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No District Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PeriodsTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator',
            style: TextStyle(
              fontSize: 14,
              color: PeriodsTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Periods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PeriodsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: PeriodsTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final districtId = ref.read(userDistrictIdProvider).value;
                if (districtId != null) {
                  ref.invalidate(periodsProvider(districtId));
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PeriodsTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: PeriodsTheme.cardRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodsContent(String districtId) {
    final periodsAsync = ref.watch(periodsProvider(districtId));
    final expandedYears = ref.watch(expandedYearsProvider);

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.invalidate(periodsProvider(districtId));
      },
      color: PeriodsTheme.primary,
      backgroundColor: PeriodsTheme.surface,
      displacement: 40,
      edgeOffset: 20,
      child: periodsAsync.when(
        data: (periods) {
          if (periods.isEmpty) {
            return _buildEmptyState();
          }

          final filteredPeriods = _filterAndSortPeriods(
            periods,
            ref.read(periodSearchQueryProvider),
            ref.read(periodStatusFilterProvider),
            ref.read(periodSortOptionProvider),
          );

          if (filteredPeriods.isEmpty) {
            return _buildNoResultsState();
          }

          final groupedPeriods = _groupPeriodsByYear(filteredPeriods);

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // Year folders
              ...groupedPeriods.entries.map((entry) {
                final year = entry.key;
                final yearPeriods = entry.value;
                final isExpanded = expandedYears.contains(year);

                return _YearFolder(
                  year: year,
                  periods: yearPeriods,
                  isExpanded: isExpanded,
                  onTap: () => _toggleYearExpansion(year),
                  districtId: districtId,
                );
              }),
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => _buildPeriodsLoading(),
        error: (error, _) => _buildPeriodsError(error, districtId),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PeriodsTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 60,
                color: PeriodsTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Periods Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PeriodsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ref.watch(isSupervisorProvider).value ?? false
                  ? 'Create your first audit period to get started'
                  : 'Waiting for supervisor to create periods',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: PeriodsTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: PeriodsTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Matching Periods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PeriodsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: PeriodsTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(periodSearchQueryProvider.notifier).state = '';
                ref.read(periodStatusFilterProvider.notifier).state = null;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PeriodsTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodsLoading() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodsError(Object error, String districtId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Periods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PeriodsTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: PeriodsTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(periodsProvider(districtId)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PeriodsTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: PeriodsTheme.cardRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Period> _filterAndSortPeriods(
    List<Period> periods,
    String searchQuery,
    String? statusFilter,
    String sortOption,
  ) {
    var filtered = periods.where((period) {
      final matchesSearch =
          searchQuery.isEmpty ||
          period.year.toLowerCase().contains(searchQuery.toLowerCase()) ||
          period.range.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus =
          statusFilter == null || period.status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    switch (sortOption) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'year_asc':
        filtered.sort((a, b) => a.year.compareTo(b.year));
        break;
      case 'year_desc':
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'status':
        filtered.sort((a, b) => a.status.compareTo(b.status));
        break;
    }

    return filtered;
  }

  Map<String, List<Period>> _groupPeriodsByYear(List<Period> periods) {
    final grouped = <String, List<Period>>{};
    for (var period in periods) {
      grouped.putIfAbsent(period.year, () => []);
      grouped[period.year]!.add(period);
    }
    return grouped;
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheetContent(),
    );
  }

  void _showCreatePeriodBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePeriodBottomSheet(),
    );
  }
}

// ========== YEAR FOLDER WIDGET ==========
class _YearFolder extends StatelessWidget {
  final String year;
  final List<Period> periods;
  final bool isExpanded;
  final VoidCallback onTap;
  final String districtId;

  const _YearFolder({
    required this.year,
    required this.periods,
    required this.isExpanded,
    required this.onTap,
    required this.districtId,
  });

  @override
  Widget build(BuildContext context) {
    final completedPeriods = periods
        .where((p) => p.status == 'Completed')
        .length;
    final progressPercentage = periods.isNotEmpty
        ? ((completedPeriods / periods.length) * 100).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Year folder header
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                // gradient: PeriodsTheme.yearGradient,
                borderRadius: PeriodsTheme.cardRadius,
                boxShadow: [PeriodsTheme.cardShadow],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: PeriodsTheme.cardRadius,
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year $year',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${periods.length} period${periods.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: PeriodsTheme.pillRadius,
                    ),
                    child: Text(
                      '$progressPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Periods list (animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpanded
                  ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          ...periods.map(
                            (period) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _PeriodCard(
                                period: period,
                                districtId: districtId,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== PERIOD CARD WIDGET ==========
class _PeriodCard extends ConsumerWidget {
  final Period period;
  final String districtId;

  const _PeriodCard({required this.period, required this.districtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<double>(
      future: _calculateProgress(period, districtId),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: PeriodsTheme.cardRadius),
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
            borderRadius: PeriodsTheme.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Progress indicator
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: Colors.grey.shade200,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(period.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Period details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.range,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created ${_formatDate(period.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: PeriodsTheme.textSecondary,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // _StatusChip(status: period.status),
                      ],
                    ),
                  ),
                  _StatusChip(status: period.status),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<double> _calculateProgress(Period period, String districtId) async {
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
        return const Color(0xFF2ECC71);
      case 'In Progress':
        return const Color(0xFFF39C12);
      default:
        return PeriodsTheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

// ========== STATUS CHIP ==========
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: PeriodsTheme.pillRadius,
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 12, color: _getColor()),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'Completed':
        return const Color(0xFF2ECC71);
      case 'In Progress':
        return const Color(0xFFF39C12);
      default:
        return PeriodsTheme.primary;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }
}

// ========== FILTER HEADER DELEGATE ==========
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String statusFilter;
  final VoidCallback onClear;

  _FilterHeaderDelegate({required this.statusFilter, required this.onClear});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: PeriodsTheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: PeriodsTheme.primary.withOpacity(0.1),
                borderRadius: PeriodsTheme.pillRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    size: 14,
                    color: PeriodsTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Status: $statusFilter',
                    style: TextStyle(
                      fontSize: 13,
                      color: PeriodsTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: PeriodsTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// ========== FILTER BOTTOM SHEET ==========
class _FilterBottomSheetContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(periodStatusFilterProvider);
    final sortOption = ref.watch(periodSortOptionProvider);

    return Container(
      decoration: const BoxDecoration(
        color: PeriodsTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PeriodsTheme.textSecondary.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.filter_list_rounded, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(periodStatusFilterProvider.notifier).state =
                          null;
                      ref.read(periodSortOptionProvider.notifier).state =
                          'newest';
                    },
                    child: const Text('Reset'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterOption(
                          label: 'All',
                          selected: statusFilter == null,
                          onTap: () =>
                              ref
                                      .read(periodStatusFilterProvider.notifier)
                                      .state =
                                  null,
                        ),
                        _FilterOption(
                          label: 'Pending',
                          selected: statusFilter == 'Pending',
                          onTap: () =>
                              ref
                                      .read(periodStatusFilterProvider.notifier)
                                      .state =
                                  'Pending',
                        ),
                        _FilterOption(
                          label: 'In Progress',
                          selected: statusFilter == 'In Progress',
                          onTap: () =>
                              ref
                                      .read(periodStatusFilterProvider.notifier)
                                      .state =
                                  'In Progress',
                        ),
                        _FilterOption(
                          label: 'Completed',
                          selected: statusFilter == 'Completed',
                          onTap: () =>
                              ref
                                      .read(periodStatusFilterProvider.notifier)
                                      .state =
                                  'Completed',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterOption(
                          label: 'Newest First',
                          selected: sortOption == 'newest',
                          onTap: () =>
                              ref
                                      .read(periodSortOptionProvider.notifier)
                                      .state =
                                  'newest',
                        ),
                        _FilterOption(
                          label: 'Oldest First',
                          selected: sortOption == 'oldest',
                          onTap: () =>
                              ref
                                      .read(periodSortOptionProvider.notifier)
                                      .state =
                                  'oldest',
                        ),
                        _FilterOption(
                          label: 'Year (A-Z)',
                          selected: sortOption == 'year_asc',
                          onTap: () =>
                              ref
                                      .read(periodSortOptionProvider.notifier)
                                      .state =
                                  'year_asc',
                        ),
                        _FilterOption(
                          label: 'Year (Z-A)',
                          selected: sortOption == 'year_desc',
                          onTap: () =>
                              ref
                                      .read(periodSortOptionProvider.notifier)
                                      .state =
                                  'year_desc',
                        ),
                        _FilterOption(
                          label: 'Status',
                          selected: sortOption == 'status',
                          onTap: () =>
                              ref
                                      .read(periodSortOptionProvider.notifier)
                                      .state =
                                  'status',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== FILTER OPTION ==========
class _FilterOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? PeriodsTheme.primary.withOpacity(0.1)
              : PeriodsTheme.background,
          borderRadius: PeriodsTheme.cardRadius,
          border: Border.all(
            color: selected
                ? PeriodsTheme.primary
                : PeriodsTheme.textSecondary.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? PeriodsTheme.primary : PeriodsTheme.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ========== CREATE PERIOD BOTTOM SHEET ==========
// (Keep the existing CreatePeriodBottomSheet with minor styling updates)
// You can update the existing CreatePeriodBottomSheet to match the new theme
// by changing colors and border radius to use PeriodsTheme constants
// //============================================================
// final periodSearchQueryProvider = StateProvider<String>((ref) => '');
// final periodStatusFilterProvider = StateProvider<String?>((ref) => null);
// final periodSortOptionProvider = StateProvider<String>((ref) => 'newest');

// class PeriodsScreen extends ConsumerWidget {
//   const PeriodsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final districtIdAsync = ref.watch(userDistrictIdProvider);
//     final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
//     final searchQuery = ref.watch(periodSearchQueryProvider);
//     final statusFilter = ref.watch(periodStatusFilterProvider);
//     final sortOption = ref.watch(periodSortOptionProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Audit Periods'),
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () => _showFilterBottomSheet(context, ref),
//           ),
//         ],
//       ),
//       body: districtIdAsync.when(
//         data: (districtId) {
//           if (districtId == null) {
//             return const Center(child: Text('No district assigned'));
//           }

//           final periodsAsync = ref.watch(periodsProvider(districtId));

//           return Column(
//             children: [
//               // Search bar
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TextField(
//                   onChanged: (value) =>
//                       ref.read(periodSearchQueryProvider.notifier).state =
//                           value,
//                   decoration: InputDecoration(
//                     hintText: 'Search periods...',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: searchQuery.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () =>
//                                 ref
//                                         .read(
//                                           periodSearchQueryProvider.notifier,
//                                         )
//                                         .state =
//                                     '',
//                           )
//                         : null,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                   ),
//                 ),
//               ),

//               // Active filters chip
//               if (statusFilter != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Chip(
//                         label: Text('Status: $statusFilter'),
//                         onDeleted: () =>
//                             ref
//                                     .read(periodStatusFilterProvider.notifier)
//                                     .state =
//                                 null,
//                         deleteIcon: const Icon(Icons.close, size: 18),
//                       ),
//                     ],
//                   ),
//                 ),

//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     ref.invalidate(periodsProvider(districtId));
//                   },
//                   child: periodsAsync.when(
//                     data: (periods) {
//                       if (periods.isEmpty) {
//                         return Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today_outlined,
//                                 size: 64,
//                                 color: Colors.grey[400],
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No periods yet',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 isSupervisor
//                                     ? 'Tap the + button to create a period'
//                                     : 'Waiting for supervisor to create periods',
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                             ],
//                           ),
//                         );
//                       }

//                       // Apply filters and search
//                       var filteredPeriods = periods.where((period) {
//                         final matchesSearch =
//                             searchQuery.isEmpty ||
//                             period.year.toLowerCase().contains(
//                               searchQuery.toLowerCase(),
//                             ) ||
//                             period.range.toLowerCase().contains(
//                               searchQuery.toLowerCase(),
//                             );

//                         final matchesStatus =
//                             statusFilter == null ||
//                             period.status == statusFilter;

//                         return matchesSearch && matchesStatus;
//                       }).toList();

//                       // Apply sorting
//                       filteredPeriods = _sortPeriods(
//                         filteredPeriods,
//                         sortOption,
//                       );

//                       if (filteredPeriods.isEmpty) {
//                         return Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.search_off,
//                                 size: 64,
//                                 color: Colors.grey[400],
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No periods found',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Try adjusting your filters',
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                             ],
//                           ),
//                         );
//                       }

//                       // Group by year
//                       final groupedPeriods = <String, List<Period>>{};
//                       for (var period in filteredPeriods) {
//                         groupedPeriods.putIfAbsent(period.year, () => []);
//                         groupedPeriods[period.year]!.add(period);
//                       }

//                       return ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: groupedPeriods.length * 2,
//                         itemBuilder: (context, index) {
//                           if (index.isOdd) {
//                             return const SizedBox(height: 16);
//                           }

//                           final yearIndex = index ~/ 2;
//                           final year = groupedPeriods.keys.elementAt(yearIndex);
//                           final yearPeriods = groupedPeriods[year]!;

//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Year divider
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                   horizontal: 4,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Theme.of(
//                                           context,
//                                         ).primaryColor.withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         year,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Divider(
//                                         color: Colors.grey[300],
//                                         thickness: 1,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               // Period cards for this year
//                               ...yearPeriods.map(
//                                 (period) => Padding(
//                                   padding: const EdgeInsets.only(bottom: 12),
//                                   child: _PeriodCard(
//                                     period: period,
//                                     districtId: districtId,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (error, stack) => Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             size: 48,
//                             color: Colors.red,
//                           ),
//                           const SizedBox(height: 16),
//                           Text('Error: $error'),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () =>
//                                 ref.invalidate(periodsProvider(districtId)),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//       floatingActionButton: isSupervisor
//           ? FutureBuilder<String?>(
//               future: ref.watch(userRoleProvider.future),
//               builder: (context, snapshot) {
//                 final userRole = snapshot.data;
//                 // Only show FAB for DOF and CA
//                 if (userRole == 'DOF' || userRole == 'CA') {
//                   return FloatingActionButton.extended(
//                     onPressed: () => _showCreatePeriodBottomSheet(context, ref),
//                     icon: const Icon(Icons.add),
//                     label: const Text('New Period'),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             )
//           : null,
//     );
//   }

//   List<Period> _sortPeriods(List<Period> periods, String sortOption) {
//     switch (sortOption) {
//       case 'newest':
//         return periods..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       case 'oldest':
//         return periods..sort((a, b) => a.createdAt.compareTo(b.createdAt));
//       case 'year_asc':
//         return periods..sort((a, b) => a.year.compareTo(b.year));
//       case 'year_desc':
//         return periods..sort((a, b) => b.year.compareTo(a.year));
//       case 'status':
//         return periods..sort((a, b) => a.status.compareTo(b.status));
//       default:
//         return periods;
//     }
//   }

//   void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Filter & Sort',
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             Text('Status', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: [
//                 FilterChip(
//                   label: const Text('All'),
//                   selected: ref.watch(periodStatusFilterProvider) == null,
//                   onSelected: (_) =>
//                       ref.read(periodStatusFilterProvider.notifier).state =
//                           null,
//                 ),
//                 FilterChip(
//                   label: const Text('Pending'),
//                   selected: ref.watch(periodStatusFilterProvider) == 'Pending',
//                   onSelected: (_) =>
//                       ref.read(periodStatusFilterProvider.notifier).state =
//                           'Pending',
//                 ),
//                 FilterChip(
//                   label: const Text('In Progress'),
//                   selected:
//                       ref.watch(periodStatusFilterProvider) == 'In Progress',
//                   onSelected: (_) =>
//                       ref.read(periodStatusFilterProvider.notifier).state =
//                           'In Progress',
//                 ),
//                 FilterChip(
//                   label: const Text('Completed'),
//                   selected:
//                       ref.watch(periodStatusFilterProvider) == 'Completed',
//                   onSelected: (_) =>
//                       ref.read(periodStatusFilterProvider.notifier).state =
//                           'Completed',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: [
//                 ChoiceChip(
//                   label: const Text('Newest'),
//                   selected: ref.watch(periodSortOptionProvider) == 'newest',
//                   onSelected: (_) =>
//                       ref.read(periodSortOptionProvider.notifier).state =
//                           'newest',
//                 ),
//                 ChoiceChip(
//                   label: const Text('Oldest'),
//                   selected: ref.watch(periodSortOptionProvider) == 'oldest',
//                   onSelected: (_) =>
//                       ref.read(periodSortOptionProvider.notifier).state =
//                           'oldest',
//                 ),
//                 ChoiceChip(
//                   label: const Text('Year ↑'),
//                   selected: ref.watch(periodSortOptionProvider) == 'year_asc',
//                   onSelected: (_) =>
//                       ref.read(periodSortOptionProvider.notifier).state =
//                           'year_asc',
//                 ),
//                 ChoiceChip(
//                   label: const Text('Year ↓'),
//                   selected: ref.watch(periodSortOptionProvider) == 'year_desc',
//                   onSelected: (_) =>
//                       ref.read(periodSortOptionProvider.notifier).state =
//                           'year_desc',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCreatePeriodBottomSheet(BuildContext context, WidgetRef ref) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => const CreatePeriodBottomSheet(),
//     );
//   }
// }

// class _PeriodCard extends ConsumerWidget {
//   final Period period;
//   final String districtId;

//   const _PeriodCard({required this.period, required this.districtId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final firestoreService = ref.watch(firestoreServiceProvider);

//     return FutureBuilder<Map<String, dynamic>?>(
//       future: firestoreService.getUserProfile(period.supervisorId),
//       builder: (context, snapshot) {
//         final supervisorName = snapshot.data?['name'] ?? 'Loading...';

//         return FutureBuilder<double>(
//           future: _calculateProgress(),
//           builder: (context, progressSnapshot) {
//             final progress = progressSnapshot.data ?? 0.0;

//             return Card(
//               margin: EdgeInsets.zero,
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: BorderSide(
//                   color: _getStatusColor(period.status),
//                   width: 3,
//                 ),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   ref.read(selectedPeriodProvider.notifier).state = period;
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           FoldersScreen(districtId: districtId, period: period),
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   height: 160,
//                   padding: const EdgeInsets.all(20),
//                   child: Row(
//                     children: [
//                       // Progress circle
//                       SizedBox(
//                         width: 80,
//                         height: 80,
//                         child: Stack(
//                           children: [
//                             Center(
//                               child: SizedBox(
//                                 width: 80,
//                                 height: 80,
//                                 child: CircularProgressIndicator(
//                                   value: progress,
//                                   strokeWidth: 6,
//                                   backgroundColor: Colors.grey[200],
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     _getStatusColor(period.status),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Center(
//                               child: Text(
//                                 '${(progress * 100).toInt()}%',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: _getStatusColor(period.status),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 20),
//                       // Period details
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               '${period.year} • ${period.range}',
//                               style: Theme.of(context).textTheme.titleLarge
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.person_outline,
//                                   size: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     supervisorName,
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 14,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             _StatusChip(status: period.status),
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         Icons.chevron_right,
//                         color: Colors.grey[400],
//                         size: 32,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<double> _calculateProgress() async {
//     try {
//       final foldersSnapshot = await FirebaseFirestore.instance
//           .collection('districts')
//           .doc(districtId)
//           .collection('periods')
//           .doc(period.id)
//           .collection('folders')
//           .get();

//       if (foldersSnapshot.docs.isEmpty) return 0.0;

//       int completedFolders = 0;
//       for (var doc in foldersSnapshot.docs) {
//         if (doc.data()['status'] == 'Completed') {
//           completedFolders++;
//         }
//       }

//       return completedFolders / foldersSnapshot.docs.length;
//     } catch (e) {
//       return 0.0;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Completed':
//         return Colors.green;
//       case 'In Progress':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }
// }

// class _StatusChip extends StatelessWidget {
//   final String status;

//   const _StatusChip({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: _getColor().withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _getColor(), width: 1.5),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: _getColor(),
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Color _getColor() {
//     switch (status) {
//       case 'Completed':
//         return Colors.green;
//       case 'In Progress':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }
// }

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

  // Future<void> _createPeriod() async {
  //   if (!_formKey.currentState!.validate() ||
  //       _selectedRange == null ||
  //       _selectedSupervisorId == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final service = ref.read(periodServiceProvider);
  //     final userData = await ref.read(currentUserDataProvider.future);
  //     final districtId = userData!['districtId'] as String;

  //     await service.createPeriod(
  //       districtId: districtId,
  //       year: _yearController.text,
  //       range: _selectedRange!,
  //       createdBy: userData['uid'] ?? '',
  //       supervisorId: _selectedSupervisorId!,
  //       userName: userData['name'] ?? 'Unknown',
  //       userRole: userData['role'] ?? 'Unknown',
  //     );

  //     if (mounted) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Period created successfully'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

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

      // ✅ This call now automatically sends notifications!
      // The notification logic is inside the service method
      await service.createPeriod(
        districtId: districtId,
        year: _yearController.text,
        range: _selectedRange!,
        createdBy: userData['uid'] ?? '',
        supervisorId:
            _selectedSupervisorId!, // ← Notification sent to this user
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

  Future<void> _createPeriodWithNotificationConfirmation() async {
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

      // Get supervisor name for the message
      final supervisorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedSupervisorId!)
          .get();
      final supervisorName = supervisorDoc.data()?['name'] ?? 'Supervisor';

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

        // Enhanced success message showing notification was sent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Period created successfully',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '📬 Notification sent to $supervisorName',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
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
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Colors.white,
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
                            onPressed: _isLoading
                                ? null
                                : _createPeriodWithNotificationConfirmation,
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
