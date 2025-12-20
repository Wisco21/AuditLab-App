// File: modern_dashboard.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/phase_two_core_features/provider/audit_lo_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// ========== THEME & STYLING ==========
class DashboardTheme {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color accent = Color(0xFF7209B7);
  static const Color success = Color(0xFF4CC9F0);
  static const Color warning = Color(0xFFF8961E);
  static const Color error = Color(0xFFF72585);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFB5179E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(12));
}

// ========== MODELS & PROVIDERS ==========
class DashboardStats {
  final int totalCheques;
  final int clearedCheques;
  final int chequesWithIssues;
  final int pendingCheques;
  final int missingCheques;
  final int canceledCheques;
  final int totalFolders;
  final int completedFolders;
  final int totalPeriods;
  final int totalIssues;
  final int resolvedIssues;
  final Map<String, int> issuesByType;
  final Map<String, int> chequesBySector;
  final Map<String, int> chequesByStatus;
  final double completionRate;

  DashboardStats({
    required this.totalCheques,
    required this.clearedCheques,
    required this.chequesWithIssues,
    required this.pendingCheques,
    required this.missingCheques,
    required this.canceledCheques,
    required this.totalFolders,
    required this.completedFolders,
    required this.totalPeriods,
    required this.totalIssues,
    required this.resolvedIssues,
    required this.issuesByType,
    required this.chequesBySector,
    required this.chequesByStatus,
    required this.completionRate,
  });
}

class DashboardFilter {
  final String? selectedPeriodId;
  final String? selectedYear;
  final String? selectedSector;
  final String? selectedStatus;

  DashboardFilter({
    this.selectedPeriodId,
    this.selectedYear,
    this.selectedSector,
    this.selectedStatus,
  });

  DashboardFilter copyWith({
    String? selectedPeriodId,
    String? selectedYear,
    String? selectedSector,
    String? selectedStatus,
  }) {
    return DashboardFilter(
      selectedPeriodId: selectedPeriodId ?? this.selectedPeriodId,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedSector: selectedSector ?? this.selectedSector,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  bool get hasActiveFilters =>
      selectedPeriodId != null ||
      selectedYear != null ||
      selectedSector != null ||
      selectedStatus != null;
}

final dashboardFilterProvider = StateProvider<DashboardFilter>(
  (ref) => DashboardFilter(),
);

final dashboardStatsProvider =
    FutureProvider.family<
      DashboardStats,
      ({String districtId, DashboardFilter filter})
    >((ref, params) async {
      return await _fetchDashboardStats(params.districtId, params.filter);
    });

// ========== MAIN DASHBOARD WIDGET ==========
class ModernDashboard extends ConsumerStatefulWidget {
  const ModernDashboard({super.key});

  @override
  ConsumerState<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends ConsumerState<ModernDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _handleRefresh() async {
    _refreshController.forward(from: 0);
    ref.invalidate(dashboardStatsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshController.reset();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(dashboardFilterProvider);
    final userData = ref.watch(currentUserDataProvider);
    final districtId = ref.watch(userDistrictIdProvider);

    return Scaffold(
      backgroundColor: DashboardTheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: DashboardTheme.surface,
              surfaceTintColor: DashboardTheme.surface,
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
                    // gradient: DashboardTheme.primaryGradient,
                    // borderRadius: const BorderRadius.only(
                    //   bottomLeft: Radius.circular(20),
                    //   bottomRight: Radius.circular(20),
                    // ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          userData.when(
                            data: (data) => _buildWelcomeHeader(data),
                            loading: () => _buildWelcomeHeaderShimmer(),
                            error: (_, __) => const _WelcomeHeaderPlaceholder(),
                          ),
                          const SizedBox(height: 24),
                          _buildFilterIndicator(filter),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (filter.hasActiveFilters) ...[
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeaderDelegate(filter: filter),
              ),
            ],
          ];
        },
        body: districtId.when(
          data: (districtId) {
            if (districtId == null) {
              return _buildNoDistrictView();
            }
            return _buildDashboardContent(districtId);
          },
          loading: () => _buildLoadingSkeleton(),
          error: (error, _) => _buildErrorView(error),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleRefresh,
        backgroundColor: DashboardTheme.surface,
        foregroundColor: DashboardTheme.primary,
        elevation: 4,
        icon: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_refreshController),
          child: const Icon(Icons.refresh_rounded),
        ),
        label: const Text('Refresh'),
        shape: RoundedRectangleBorder(borderRadius: DashboardTheme.smallRadius),
      ),
    );
  }

  Widget _buildWelcomeHeader(Map<String, dynamic>? userData) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.cloud_outlined;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nights_stay_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: DashboardTheme.smallRadius,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userData?['name'] ?? 'Auditor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: DashboardTheme.smallRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                userData?['role']?.toUpperCase() ?? 'USER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterIndicator(DashboardFilter filter) {
    if (!filter.hasActiveFilters) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: DashboardTheme.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt_rounded, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            '${_countActiveFilters(filter)} filter${_countActiveFilters(filter) > 1 ? 's' : ''} active',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _countActiveFilters(DashboardFilter filter) {
    int count = 0;
    if (filter.selectedYear != null) count++;
    if (filter.selectedPeriodId != null) count++;
    if (filter.selectedSector != null) count++;
    if (filter.selectedStatus != null) count++;
    return count;
  }

  Widget _buildNoDistrictView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 80,
            color: DashboardTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No District Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DashboardTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator',
            style: TextStyle(
              fontSize: 14,
              color: DashboardTheme.textSecondary.withOpacity(0.7),
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
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DashboardTheme.cardRadius,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: DashboardTheme.cardRadius,
                  ),
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
                color: DashboardTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: DashboardTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DashboardTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DashboardTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(dashboardStatsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: DashboardTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: DashboardTheme.smallRadius,
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

  Widget _buildDashboardContent(String districtId) {
    final filter = ref.watch(dashboardFilterProvider);
    final statsAsync = ref.watch(
      dashboardStatsProvider((districtId: districtId, filter: filter)),
    );

    return RefreshIndicator.adaptive(
      onRefresh: _handleRefresh,
      color: DashboardTheme.primary,
      backgroundColor: DashboardTheme.surface,
      displacement: 40,
      edgeOffset: 20,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // const SizedBox(height: 10),
          statsAsync.when(
            data: (stats) => _buildStatsContent(stats),
            loading: () => _buildStatsLoading(),
            error: (error, stack) => _buildStatsError(error),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        _buildSummaryCards(stats),
        const SizedBox(height: 32),

        // Charts Section
        _buildChartsSection(stats),
        const SizedBox(height: 32),

        // Recent Activity
        _buildRecentActivitySection(),
      ],
    );
  }

  Widget _buildSummaryCards(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle('Overview'),
            const Spacer(),
            IconButton(
              onPressed: () => _showFilterBottomSheet(context),
              icon: const Icon(Icons.tune_rounded),
              style: IconButton.styleFrom(
                backgroundColor: DashboardTheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: DashboardTheme.smallRadius,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildStatCard(index, stats);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(int index, DashboardStats stats) {
    final List<_StatCardData> cardData = [
      _StatCardData(
        title: 'Total Cheques',
        value: stats.totalCheques,
        icon: Icons.receipt_long_rounded,
        color: DashboardTheme.primary,
        gradient: DashboardTheme.primaryGradient,
      ),
      _StatCardData(
        title: 'Cleared',
        value: stats.clearedCheques,
        icon: Icons.check_circle_rounded,
        color: DashboardTheme.success,
        gradient: const LinearGradient(
          colors: [DashboardTheme.success, Color(0xFF4895EF)],
        ),
        subtitle: '${stats.completionRate.toStringAsFixed(1)}% complete',
      ),
      _StatCardData(
        title: 'With Issues',
        value: stats.chequesWithIssues,
        icon: Icons.warning_rounded,
        color: DashboardTheme.warning,
        gradient: const LinearGradient(
          colors: [DashboardTheme.warning, Color(0xFFF3722C)],
        ),
        subtitle: '${stats.totalIssues} issues found',
      ),
      _StatCardData(
        title: 'Pending',
        value: stats.pendingCheques,
        icon: Icons.pending_actions_rounded,
        color: Color(0xFF4361EE),
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF3A86FF)],
        ),
        subtitle: 'Awaiting review',
      ),
      _StatCardData(
        title: 'Missing',
        value: stats.missingCheques,
        icon: Icons.search_off_rounded,
        color: DashboardTheme.textSecondary,
        gradient: LinearGradient(
          colors: [DashboardTheme.textSecondary, Colors.grey.shade500],
        ),
        subtitle: 'Not located',
      ),
      _StatCardData(
        title: 'Canceled',
        value: stats.canceledCheques,
        icon: Icons.cancel_rounded,
        color: DashboardTheme.error,
        gradient: const LinearGradient(
          colors: [DashboardTheme.error, Color(0xFFEF476F)],
        ),
        subtitle: 'Voided cheques',
      ),
    ];

    final data = cardData[index];
    return _StatCard(data: data);
  }

  Widget _buildChartsSection(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Analytics'),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildPieChartCard(stats),
            const SizedBox(height: 16),
            _buildProgressCard(stats),
            const SizedBox(height: 16),
            _buildIssuesChartCard(stats),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChartCard(DashboardStats stats) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Status Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DashboardTheme.primary.withOpacity(0.1),
                  borderRadius: DashboardTheme.smallRadius,
                ),
                child: Text(
                  '${stats.totalCheques} Total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: stats.totalCheques > 0
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 1,
                            centerSpaceRadius: 60,
                            sections: _buildPieChartSections(stats),
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {},
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: _buildPieChartLegend(stats)),
                    ],
                  )
                : const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: DashboardTheme.textSecondary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(DashboardStats stats) {
    final total = stats.totalCheques.toDouble();
    const double radius = 40;

    return [
      if (stats.clearedCheques > 0)
        PieChartSectionData(
          value: stats.clearedCheques.toDouble(),
          color: DashboardTheme.success,
          radius: radius,
          title: '${(stats.clearedCheques / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      if (stats.chequesWithIssues > 0)
        PieChartSectionData(
          value: stats.chequesWithIssues.toDouble(),
          color: DashboardTheme.warning,
          radius: radius,
          title:
              '${(stats.chequesWithIssues / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      if (stats.pendingCheques > 0)
        PieChartSectionData(
          value: stats.pendingCheques.toDouble(),
          color: DashboardTheme.primary,
          radius: radius,
          title: '${(stats.pendingCheques / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      if (stats.missingCheques > 0)
        PieChartSectionData(
          value: stats.missingCheques.toDouble(),
          color: DashboardTheme.textSecondary,
          radius: radius,
          title: '${(stats.missingCheques / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      if (stats.canceledCheques > 0)
        PieChartSectionData(
          value: stats.canceledCheques.toDouble(),
          color: DashboardTheme.error,
          radius: radius,
          title: '${(stats.canceledCheques / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
    ];
  }

  Widget _buildPieChartLegend(DashboardStats stats) {
    final items = [
      if (stats.clearedCheques > 0)
        _LegendItem('Cleared', DashboardTheme.success, stats.clearedCheques),
      if (stats.chequesWithIssues > 0)
        _LegendItem(
          'With Issues',
          DashboardTheme.warning,
          stats.chequesWithIssues,
        ),
      if (stats.pendingCheques > 0)
        _LegendItem('Pending', DashboardTheme.primary, stats.pendingCheques),
      if (stats.missingCheques > 0)
        _LegendItem(
          'Missing',
          DashboardTheme.textSecondary,
          stats.missingCheques,
        ),
      if (stats.canceledCheques > 0)
        _LegendItem('Canceled', DashboardTheme.error, stats.canceledCheques),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildProgressCard(DashboardStats stats) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Completion Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${stats.completionRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(stats.completionRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: stats.completionRate / 100,
                      strokeWidth: 12,
                      backgroundColor: DashboardTheme.background,
                      valueColor: AlwaysStoppedAnimation(
                        _getProgressColor(stats.completionRate),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${stats.clearedCheques}/${stats.totalCheques}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'cheques cleared',
                        style: TextStyle(
                          fontSize: 12,
                          color: DashboardTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesChartCard(DashboardStats stats) {
    final sortedIssues = stats.issuesByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Issues by Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DashboardTheme.warning.withOpacity(0.1),
                  borderRadius: DashboardTheme.smallRadius,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: DashboardTheme.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${stats.totalIssues} issues',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sortedIssues.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: DashboardTheme.success,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No issues reported',
                    style: TextStyle(color: DashboardTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: (sortedIssues.first.value * 1.2).toDouble(),
                  barGroups: sortedIssues.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.value.toDouble(),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          color: _getChartColor(index),
                          gradient: LinearGradient(
                            colors: [
                              _getChartColor(index),
                              _getChartColor(index).withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedIssues.length) {
                            return const SizedBox();
                          }
                          final type = sortedIssues[value.toInt()].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getIssueTypeLabel(type),
                              style: const TextStyle(
                                fontSize: 10,
                                color: DashboardTheme.textSecondary,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateInterval(
                          sortedIssues.first.value.toDouble(),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(
                      sortedIssues.first.value.toDouble(),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Recent Activity'),
        const SizedBox(height: 16),
        ModernCard(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: DashboardTheme.cardRadius,
            child: _RecentActivityStream(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: DashboardTheme.cardRadius,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: DashboardTheme.cardRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsError(Object error) {
    return ModernCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: DashboardTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load statistics',
            style: TextStyle(
              color: DashboardTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: DashboardTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(dashboardStatsProvider),
            style: FilledButton.styleFrom(
              backgroundColor: DashboardTheme.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return DashboardTheme.success;
    if (percentage >= 50) return DashboardTheme.warning;
    return DashboardTheme.error;
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 5) return 1;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    return 50;
  }

  Color _getChartColor(int index) {
    final colors = [
      DashboardTheme.primary,
      DashboardTheme.secondary,
      DashboardTheme.accent,
      DashboardTheme.success,
      DashboardTheme.warning,
      DashboardTheme.error,
    ];
    return colors[index % colors.length];
  }

  String _getIssueTypeLabel(String type) {
    final labels = {
      'missing_signatories': 'Signatories',
      'missing_voucher': 'Voucher',
      'missing_loose_minute': 'Loose Minute',
      'missing_requisition': 'Requisition',
      'missing_signing_sheet': 'Signing Sheet',
      'no_invoice': 'Invoice',
      'improper_support': 'Support Docs',
    };
    return labels[type] ?? type;
  }

  void _showFilterBottomSheet(BuildContext context) {
    final districtId = ref.read(userDistrictIdProvider).value;
    if (districtId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(districtId: districtId),
    );
  }
}

// ========== SUPPORTING WIDGETS ==========
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? DashboardTheme.surface,
        borderRadius: DashboardTheme.cardRadius,
        boxShadow: [DashboardTheme.subtleShadow],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DashboardTheme.textPrimary,
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final String? subtitle;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
    this.subtitle,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: data.gradient,
                  borderRadius: DashboardTheme.smallRadius,
                ),
                child: Icon(data.icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                data.value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: data.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (data.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: DashboardTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int value;

  const _LegendItem(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DashboardFilter filter;

  _FilterHeaderDelegate({required this.filter});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 60,
      color: DashboardTheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [..._buildFilterChips(context)],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips(BuildContext context) {
    final chips = <Widget>[];

    if (filter.selectedYear != null) {
      chips.add(
        _FilterChip(
          label: 'Year: ${filter.selectedYear}',
          onDelete: () => _clearFilter('year'),
        ),
      );
    }

    if (filter.selectedPeriodId != null) {
      chips.add(
        _FilterChip(
          label: 'Period Selected',
          onDelete: () => _clearFilter('period'),
        ),
      );
    }

    if (filter.selectedSector != null) {
      final sector = Sector.getByCode(filter.selectedSector!);
      chips.add(
        _FilterChip(
          label: 'Sector: ${sector?.displayName ?? filter.selectedSector}',
          onDelete: () => _clearFilter('sector'),
        ),
      );
    }

    if (filter.selectedStatus != null) {
      chips.add(
        _FilterChip(
          label: 'Status: ${filter.selectedStatus}',
          onDelete: () => _clearFilter('status'),
        ),
      );
    }

    chips.add(
      GestureDetector(
        onTap: _clearAllFilters,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DashboardTheme.background,
            borderRadius: DashboardTheme.smallRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.clear_all_rounded,
                size: 14,
                color: DashboardTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  color: DashboardTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return chips;
  }

  void _clearFilter(String type) {
    // This would need to be connected to the provider
    // For now, it's a placeholder
  }

  void _clearAllFilters() {
    // This would need to be connected to the provider
    // For now, it's a placeholder
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _FilterChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DashboardTheme.primary.withOpacity(0.1),
        borderRadius: DashboardTheme.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: DashboardTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: DashboardTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder widgets for loading/error states
class _WelcomeHeaderPlaceholder extends StatelessWidget {
  const _WelcomeHeaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: Colors.white24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Auditor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildWelcomeHeaderShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.white24,
    highlightColor: Colors.white38,
    child: const _WelcomeHeaderPlaceholder(),
  );
}

// ========== FILTER BOTTOM SHEET ==========
class FilterBottomSheet extends ConsumerStatefulWidget {
  final String districtId;

  const FilterBottomSheet({super.key, required this.districtId});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? _selectedYear;
  String? _selectedPeriodId;
  String? _selectedSector;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(dashboardFilterProvider);
    _selectedYear = filter.selectedYear;
    _selectedPeriodId = filter.selectedPeriodId;
    _selectedSector = filter.selectedSector;
    _selectedStatus = filter.selectedStatus;
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
    return Container(
      decoration: const BoxDecoration(
        color: DashboardTheme.surface,
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
                color: DashboardTheme.textSecondary.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // Filter Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      title: 'Year',
                      child: _buildYearFilter(),
                    ),
                    const SizedBox(height: 24),

                    _buildFilterSection(
                      title: 'Period',
                      child: _buildPeriodFilter(),
                    ),
                    const SizedBox(height: 24),

                    _buildFilterSection(
                      title: 'Sector',
                      child: _buildSectorFilter(),
                    ),
                    const SizedBox(height: 24),

                    _buildFilterSection(
                      title: 'Status',
                      child: _buildStatusFilter(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: DashboardTheme.cardRadius,
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DashboardTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildYearFilter() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('districts')
          .doc(widget.districtId)
          .collection('periods')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final years = <String>{};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          years.add(data['year'] as String);
        }

        final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterOption(
              label: 'All Years',
              selected: _selectedYear == null,
              onTap: () => setState(() => _selectedYear = null),
            ),
            ...sortedYears.map(
              (year) => _FilterOption(
                label: year,
                selected: _selectedYear == year,
                onTap: () => setState(() => _selectedYear = year),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodFilter() {
    if (_selectedYear == null) {
      return const Text(
        'Select a year first',
        style: TextStyle(color: DashboardTheme.textSecondary),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('districts')
          .doc(widget.districtId)
          .collection('periods')
          .where('year', isEqualTo: _selectedYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Text(
            'No periods available',
            style: TextStyle(color: DashboardTheme.textSecondary),
          );
        }

        return Column(
          children: [
            _FilterOption(
              label: 'All Periods',
              selected: _selectedPeriodId == null,
              onTap: () => setState(() => _selectedPeriodId = null),
            ),
            const SizedBox(height: 8),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _FilterOption(
                label: data['range'] as String,
                selected: _selectedPeriodId == doc.id,
                onTap: () => setState(() => _selectedPeriodId = doc.id),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSectorFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterOption(
          label: 'All Sectors',
          selected: _selectedSector == null,
          onTap: () => setState(() => _selectedSector = null),
        ),
        ...Sector.allSectors.map(
          (sector) => _FilterOption(
            label: sector.displayName,
            selected: _selectedSector == sector.code,
            onTap: () => setState(() => _selectedSector = sector.code),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      ('Pending', Icons.pending_rounded),
      ('Has Issues', Icons.warning_rounded),
      ('Cleared', Icons.check_circle_rounded),
      ('Missing', Icons.search_off_rounded),
      ('Canceled', Icons.cancel_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterOption(
          label: 'All Statuses',
          selected: _selectedStatus == null,
          onTap: () => setState(() => _selectedStatus = null),
        ),
        ...statuses.map(
          (status) => _FilterOption(
            label: status.$1,
            icon: status.$2,
            selected: _selectedStatus == status.$1,
            onTap: () => setState(() => _selectedStatus = status.$1),
          ),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    this.icon,
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
              ? DashboardTheme.primary.withOpacity(0.1)
              : DashboardTheme.background,
          borderRadius: DashboardTheme.smallRadius,
          border: Border.all(
            color: selected
                ? DashboardTheme.primary
                : DashboardTheme.textSecondary.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? DashboardTheme.primary
                    : DashboardTheme.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? DashboardTheme.primary
                    : DashboardTheme.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== RECENT ACTIVITY STREAM ==========
class _RecentActivityStream extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtId = ref.watch(userDistrictIdProvider).value;
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;

    if (districtId == null) {
      return const SizedBox();
    }

    if (!isSupervisor) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.visibility_off_rounded,
              size: 48,
              color: DashboardTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Activity log available\nfor supervisors only',
              textAlign: TextAlign.center,
              style: TextStyle(color: DashboardTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final logsAsync = ref.watch(auditLogsProvider(districtId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 48,
                  color: DashboardTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No recent activity',
                  style: TextStyle(color: DashboardTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return Column(
          children: logs.take(5).map((log) {
            return _ActivityItem(log: log);
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'Failed to load activity',
          style: TextStyle(color: DashboardTheme.textSecondary),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final AuditLog log;

  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DashboardTheme.background, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getActionColor(log.action).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActionIcon(log.action),
              size: 20,
              color: _getActionColor(log.action),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActionText(log.action),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: DashboardTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM d').format(log.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: DashboardTheme.textSecondary,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(log.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: DashboardTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return Icons.add_rounded;
      case AuditAction.updated:
        return Icons.edit_rounded;
      case AuditAction.deleted:
        return Icons.delete_rounded;
      case AuditAction.assigned:
        return Icons.person_add_rounded;
      case AuditAction.resolved:
        return Icons.check_circle_rounded;
      case AuditAction.statusChanged:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return DashboardTheme.success;
      case AuditAction.updated:
        return DashboardTheme.primary;
      case AuditAction.deleted:
        return DashboardTheme.error;
      case AuditAction.assigned:
        return DashboardTheme.accent;
      case AuditAction.resolved:
        return DashboardTheme.success;
      case AuditAction.statusChanged:
        return DashboardTheme.warning;
    }
  }

  String _getActionText(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return 'Created new item';
      case AuditAction.updated:
        return 'Updated item';
      case AuditAction.deleted:
        return 'Deleted item';
      case AuditAction.assigned:
        return 'Assigned task';
      case AuditAction.resolved:
        return 'Resolved issue';
      case AuditAction.statusChanged:
        return 'Changed status';
    }
  }
}

Future<DashboardStats> _fetchDashboardStats(
  String districtId,
  DashboardFilter filter,
) async {
  final db = FirebaseFirestore.instance;

  // Build base query
  Query periodsQuery = db
      .collection('districts')
      .doc(districtId)
      .collection('periods');

  // Apply year filter
  if (filter.selectedYear != null) {
    periodsQuery = periodsQuery.where('year', isEqualTo: filter.selectedYear);
  }

  // Apply period filter
  if (filter.selectedPeriodId != null) {
    periodsQuery = periodsQuery.where(
      FieldPath.documentId,
      isEqualTo: filter.selectedPeriodId,
    );
  }

  final periodsSnapshot = await periodsQuery.get();

  int totalCheques = 0;
  int clearedCheques = 0;
  int chequesWithIssues = 0;
  int pendingCheques = 0;
  int missingCheques = 0;
  int canceledCheques = 0;
  int totalFolders = 0;
  int completedFolders = 0;
  int totalIssues = 0;
  int resolvedIssues = 0;
  Map<String, int> issuesByType = {};
  Map<String, int> chequesBySector = {};
  Map<String, int> chequesByStatus = {};

  for (var periodDoc in periodsSnapshot.docs) {
    final foldersSnapshot = await db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodDoc.id)
        .collection('folders')
        .get();

    totalFolders += foldersSnapshot.docs.length;

    for (var folderDoc in foldersSnapshot.docs) {
      final folderData = folderDoc.data();
      if (folderData['status'] == 'Completed') {
        completedFolders++;
      }

      Query chequesQuery = db
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(periodDoc.id)
          .collection('folders')
          .doc(folderDoc.id)
          .collection('cheques');

      // Apply sector filter
      if (filter.selectedSector != null) {
        chequesQuery = chequesQuery.where(
          'sectorCode',
          isEqualTo: filter.selectedSector,
        );
      }

      // Apply status filter
      if (filter.selectedStatus != null) {
        chequesQuery = chequesQuery.where(
          'status',
          isEqualTo: filter.selectedStatus,
        );
      }

      final chequesSnapshot = await chequesQuery.get();

      for (var chequeDoc in chequesSnapshot.docs) {
        final chequeData = chequeDoc.data();
        totalCheques++;

        // Count by status
        final status =
            (chequeData as Map<String, dynamic>?)?['status'] ?? 'Pending';
        chequesByStatus[status] = (chequesByStatus[status] ?? 0) + 1;

        switch (status) {
          case 'Cleared':
            clearedCheques++;
            break;
          case 'Has Issues':
            chequesWithIssues++;
            break;
          case 'Missing':
            missingCheques++;
            break;
          case 'Canceled':
            canceledCheques++;
            break;
          default:
            pendingCheques++;
        }

        // Count by sector
        final sector = chequeData?['sectorCode'] ?? 'Unknown';
        chequesBySector[sector] = (chequesBySector[sector] ?? 0) + 1;

        // Count issues
        final issues = chequeData?['issues'] as List<dynamic>? ?? [];
        totalIssues += issues.length;

        for (var issue in issues) {
          if (issue['status'] == 'Resolved') {
            resolvedIssues++;
          }

          final issueType = issue['type'] ?? 'other';
          issuesByType[issueType] = (issuesByType[issueType] ?? 0) + 1;
        }
      }
    }
  }

  final completionRate = totalCheques > 0
      ? (clearedCheques / totalCheques) * 100
      : 0.0;

  return DashboardStats(
    totalCheques: totalCheques,
    clearedCheques: clearedCheques,
    chequesWithIssues: chequesWithIssues,
    pendingCheques: pendingCheques,
    missingCheques: missingCheques,
    canceledCheques: canceledCheques,
    totalFolders: totalFolders,
    completedFolders: completedFolders,
    totalPeriods: periodsSnapshot.docs.length,
    totalIssues: totalIssues,
    resolvedIssues: resolvedIssues,
    issuesByType: issuesByType,
    chequesBySector: chequesBySector,
    chequesByStatus: chequesByStatus,
    completionRate: completionRate,
  );
}
