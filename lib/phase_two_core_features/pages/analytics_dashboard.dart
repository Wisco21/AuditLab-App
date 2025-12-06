// File: improved_dashboard.dart

import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/phase_two_core_features/dashboard_filter_sheet.dart';
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/phase_two_core_features/provider/audit_lo_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Dashboard Statistics Model
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

// Dashboard Filter Model
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
    bool clearPeriod = false,
    bool clearYear = false,
    bool clearSector = false,
    bool clearStatus = false,
  }) {
    return DashboardFilter(
      selectedPeriodId: clearPeriod
          ? null
          : (selectedPeriodId ?? this.selectedPeriodId),
      selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
      selectedSector: clearSector
          ? null
          : (selectedSector ?? this.selectedSector),
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
    );
  }

  bool get hasActiveFilters =>
      selectedPeriodId != null ||
      selectedYear != null ||
      selectedSector != null ||
      selectedStatus != null;
}

// Dashboard Filter Provider
final dashboardFilterProvider = StateProvider<DashboardFilter>(
  (ref) => DashboardFilter(),
);

// Dashboard Stats Provider
final dashboardStatsProvider =
    FutureProvider.family<
      DashboardStats,
      ({String districtId, DashboardFilter filter})
    >((ref, params) async {
      return await _fetchDashboardStats(params.districtId, params.filter);
    });

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

// Main Dashboard Widget
class ImprovedDashboard extends ConsumerStatefulWidget {
  const ImprovedDashboard({super.key});

  @override
  ConsumerState<ImprovedDashboard> createState() => _ImprovedDashboardState();
}

class _ImprovedDashboardState extends ConsumerState<ImprovedDashboard> {
  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final districtIdAsync = ref.watch(userDistrictIdProvider);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
    final filter = ref.watch(dashboardFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDrawer(context),
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          final statsAsync = ref.watch(
            dashboardStatsProvider((districtId: districtId, filter: filter)),
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  userDataAsync.whenOrNull(
                        data: (userData) => _buildGreeting(context, userData),
                      ) ??
                      const SizedBox.shrink(),

                  const SizedBox(height: 16),

                  // Active Filters Display
                  if (filter.hasActiveFilters) _buildActiveFilters(filter),

                  const SizedBox(height: 16),

                  // Stats Loading/Display
                  statsAsync.when(
                    data: (stats) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Key Metrics
                        _buildKeyMetrics(context, stats),
                        const SizedBox(height: 24),

                        // Charts Section
                        if (isSupervisor) ...[
                          _buildSectionHeader(context, 'Analytics Overview'),
                          const SizedBox(height: 16),
                          _buildChartsSection(context, stats),
                          const SizedBox(height: 24),

                          _buildSectionHeader(context, 'Issue Analysis'),
                          const SizedBox(height: 16),
                          _buildIssuesAnalysis(context, stats),
                          const SizedBox(height: 24),

                          _buildSectionHeader(context, 'Sector Distribution'),
                          const SizedBox(height: 16),
                          _buildSectorDistribution(context, stats),
                          const SizedBox(height: 24),
                        ],

                        // Recent Activity
                        _buildSectionHeader(context, 'Recent Activity'),
                        const SizedBox(height: 16),
                        _RecentActivity(
                          districtId: districtId,
                          isSupervisor: isSupervisor,
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error loading stats: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(dashboardStatsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, Map<String, dynamic>? userData) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    Color iconColor;

    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny;
      iconColor = Colors.orange;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_cloudy;
      iconColor = Colors.blue;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nights_stay;
      iconColor = Colors.indigo;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userData?['role'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
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

  Widget _buildActiveFilters(DashboardFilter filter) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Active Filters:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(dashboardFilterProvider.notifier).state =
                        DashboardFilter();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filter.selectedYear != null)
                  _FilterChip(
                    label: 'Year: ${filter.selectedYear}',
                    onDelete: () {
                      ref.read(dashboardFilterProvider.notifier).state = filter
                          .copyWith(clearYear: true);
                    },
                  ),
                if (filter.selectedPeriodId != null)
                  _FilterChip(
                    label: 'Period Selected',
                    onDelete: () {
                      ref.read(dashboardFilterProvider.notifier).state = filter
                          .copyWith(clearPeriod: true);
                    },
                  ),
                if (filter.selectedSector != null)
                  _FilterChip(
                    label: 'Sector: ${_getSectorName(filter.selectedSector!)}',
                    onDelete: () {
                      ref.read(dashboardFilterProvider.notifier).state = filter
                          .copyWith(clearSector: true);
                    },
                  ),
                if (filter.selectedStatus != null)
                  _FilterChip(
                    label: 'Status: ${filter.selectedStatus}',
                    onDelete: () {
                      ref.read(dashboardFilterProvider.notifier).state = filter
                          .copyWith(clearStatus: true);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSectorName(String code) {
    final sector = Sector.getByCode(code);
    return sector?.displayName ?? code;
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cardWidth = isWide
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Total Cheques',
              value: stats.totalCheques.toString(),
              icon: Icons.receipt_long,
              color: Colors.blue,
              subtitle: '${stats.totalFolders} folders',
              width: cardWidth,
            ),
            _MetricCard(
              title: 'Cleared',
              value: stats.clearedCheques.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
              subtitle: '${stats.completionRate.toStringAsFixed(1)}% complete',
              width: cardWidth,
            ),
            _MetricCard(
              title: 'Issues',
              value: stats.chequesWithIssues.toString(),
              icon: Icons.warning_amber,
              color: Colors.red,
              subtitle: '${stats.totalIssues} total issues',
              width: cardWidth,
            ),
            _MetricCard(
              title: 'Pending',
              value: stats.pendingCheques.toString(),
              icon: Icons.pending,
              color: Colors.orange,
              subtitle: 'Awaiting review',
              width: cardWidth,
            ),
            _MetricCard(
              title: 'Missing',
              value: stats.missingCheques.toString(),
              icon: Icons.help_outline,
              color: Colors.grey,
              subtitle: 'Not found',
              width: cardWidth,
            ),
            _MetricCard(
              title: 'Canceled',
              value: stats.canceledCheques.toString(),
              icon: Icons.cancel,
              color: Colors.brown,
              subtitle: 'Voided cheques',
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StatusDistributionChart(stats: stats)),
              const SizedBox(width: 16),
              Expanded(child: _CompletionProgressChart(stats: stats)),
            ],
          );
        } else {
          return Column(
            children: [
              _StatusDistributionChart(stats: stats),
              const SizedBox(height: 16),
              _CompletionProgressChart(stats: stats),
            ],
          );
        }
      },
    );
  }

  Widget _buildIssuesAnalysis(BuildContext context, DashboardStats stats) {
    return _IssuesByTypeChart(stats: stats);
  }

  Widget _buildSectorDistribution(BuildContext context, DashboardStats stats) {
    return _SectorDistributionChart(stats: stats);
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DashboardFilterSheet(
        districtId: ref.read(userDistrictIdProvider).value!,
      ),
    );
  }
}

// Continue in next artifact...
// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _FilterChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 18),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.blue),
      ),
    );
  }
}

// Metric Card Widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final double width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Status Distribution Pie Chart
class _StatusDistributionChart extends StatelessWidget {
  final DashboardStats stats;

  const _StatusDistributionChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Distribution',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: stats.totalCheques > 0
                  ? Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieSections(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              pieTouchData: PieTouchData(enabled: true),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildLegend(),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: Text('No data available')),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = stats.totalCheques.toDouble();
    final sections = <PieChartSectionData>[];

    if (stats.clearedCheques > 0) {
      sections.add(
        PieChartSectionData(
          value: stats.clearedCheques.toDouble(),
          title: '${((stats.clearedCheques / total) * 100).toInt()}%',
          color: Colors.green,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    if (stats.chequesWithIssues > 0) {
      sections.add(
        PieChartSectionData(
          value: stats.chequesWithIssues.toDouble(),
          title: '${((stats.chequesWithIssues / total) * 100).toInt()}%',
          color: Colors.red,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    if (stats.pendingCheques > 0) {
      sections.add(
        PieChartSectionData(
          value: stats.pendingCheques.toDouble(),
          title: '${((stats.pendingCheques / total) * 100).toInt()}%',
          color: Colors.blue,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    if (stats.missingCheques > 0) {
      sections.add(
        PieChartSectionData(
          value: stats.missingCheques.toDouble(),
          title: '${((stats.missingCheques / total) * 100).toInt()}%',
          color: Colors.grey,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    if (stats.canceledCheques > 0) {
      sections.add(
        PieChartSectionData(
          value: stats.canceledCheques.toDouble(),
          title: '${((stats.canceledCheques / total) * 100).toInt()}%',
          color: Colors.brown,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return sections;
  }

  List<Widget> _buildLegend() {
    return [
      if (stats.clearedCheques > 0)
        _LegendItem('Cleared', Colors.green, stats.clearedCheques),
      if (stats.chequesWithIssues > 0)
        _LegendItem('Issues', Colors.red, stats.chequesWithIssues),
      if (stats.pendingCheques > 0)
        _LegendItem('Pending', Colors.blue, stats.pendingCheques),
      if (stats.missingCheques > 0)
        _LegendItem('Missing', Colors.grey, stats.missingCheques),
      if (stats.canceledCheques > 0)
        _LegendItem('Canceled', Colors.brown, stats.canceledCheques),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _LegendItem(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label ($count)',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Completion Progress Chart
class _CompletionProgressChart extends StatelessWidget {
  final DashboardStats stats;

  const _CompletionProgressChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: stats.completionRate / 100,
                          strokeWidth: 15,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(stats.completionRate),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${stats.completionRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(
                                    stats.completionRate,
                                  ),
                                ),
                              ),
                              const Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProgressStat(
                        'Completed',
                        stats.clearedCheques,
                        Colors.green,
                      ),
                      _ProgressStat(
                        'Remaining',
                        stats.totalCheques - stats.clearedCheques,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ProgressStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Issues By Type Bar Chart
class _IssuesByTypeChart extends StatelessWidget {
  final DashboardStats stats;

  const _IssuesByTypeChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final sortedIssues = stats.issuesByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issues by Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stats.totalIssues} Total',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (sortedIssues.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No issues reported'),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (sortedIssues.first.value + 5).toDouble(),
                    barGroups: sortedIssues.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value.toDouble(),
                            color: _getIssueColor(entry.key),
                            width: 40,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
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
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getIssueTypeLabel(
                                  sortedIssues[value.toInt()].key,
                                ),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getIssueColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  String _getIssueTypeLabel(String type) {
    switch (type) {
      case 'missing_signatories':
        return 'Missing\nSignatories';
      case 'missing_voucher':
        return 'Missing\nVoucher';
      case 'missing_loose_minute':
        return 'Missing\nLoose Minute';
      case 'missing_requisition':
        return 'Missing\nRequisition';
      case 'missing_signing_sheet':
        return 'Missing\nSigning Sheet';
      case 'no_invoice':
        return 'No\nInvoice';
      case 'improper_support':
        return 'Improper\nSupport';
      default:
        return 'Other';
    }
  }
}

// Sector Distribution Chart
class _SectorDistributionChart extends StatelessWidget {
  final DashboardStats stats;

  const _SectorDistributionChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final sortedSectors = stats.chequesBySector.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cheques by Sector',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (sortedSectors.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No data available'),
                ),
              )
            else
              ...sortedSectors.map((entry) {
                final percentage = (entry.value / stats.totalCheques) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getSectorName(entry.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            _getSectorColor(sortedSectors.indexOf(entry)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getSectorName(String code) {
    final sector = Sector.getByCode(code);
    return sector?.displayName ?? code;
  }

  Color _getSectorColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}

// Recent Activity Widget (referenced in main dashboard)
class _RecentActivity extends ConsumerWidget {
  final String districtId;
  final bool isSupervisor;

  const _RecentActivity({required this.districtId, required this.isSupervisor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSupervisor) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text('Activity log available for supervisors only'),
            ],
          ),
        ),
      );
    }

    final logsAsync = ref.watch(auditLogsProvider(districtId));

    return logsAsync.when(
      data: (logs) {
        final recentLogs = logs.take(10).toList();

        if (recentLogs.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No recent activity'),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: recentLogs.asMap().entries.map((entry) {
              final log = entry.value;
              final isLast = entry.key == recentLogs.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: _getActionIcon(log.action),
                    title: Text(
                      '${log.userName} ${_getActionText(log.action)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, h:mm a').format(log.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: _buildRoleBadge(log.userRole),
                  ),
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _getActionIcon(AuditAction action) {
    IconData icon;
    Color color;

    switch (action) {
      case AuditAction.created:
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case AuditAction.updated:
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case AuditAction.deleted:
        icon = Icons.delete;
        color = Colors.red;
        break;
      case AuditAction.assigned:
        icon = Icons.person_add;
        color = Colors.orange;
        break;
      case AuditAction.resolved:
        icon = Icons.check_circle;
        color = Colors.teal;
        break;
      case AuditAction.statusChanged:
        icon = Icons.swap_horiz;
        color = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getActionText(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return 'created an item';
      case AuditAction.updated:
        return 'updated an item';
      case AuditAction.deleted:
        return 'deleted an item';
      case AuditAction.assigned:
        return 'assigned a task';
      case AuditAction.resolved:
        return 'resolved an issue';
      case AuditAction.statusChanged:
        return 'changed status';
    }
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getRoleColor(role),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'DOF':
        return Colors.blue;
      case 'CA':
        return Colors.green;
      case 'Accountant':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
