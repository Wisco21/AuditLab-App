import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/phase_two_core_features/provider/audit_lo_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UniversalDashboard extends ConsumerWidget {
  const UniversalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final districtIdAsync = ref.watch(userDistrictIdProvider);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentUserDataProvider);
            },
          ),
        ],
      ),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentUserDataProvider);
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

                  const SizedBox(height: 24),

                  // Metrics Summary
                  _MetricsSummary(
                    districtId: districtId,
                    isSupervisor: isSupervisor,
                  ),

                  const SizedBox(height: 24),

                  // Charts Section
                  if (isSupervisor) ...[
                    Text(
                      'Analytics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartsSection(districtId: districtId),
                    const SizedBox(height: 24),
                  ],

                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RecentActivity(
                    districtId: districtId,
                    isSupervisor: isSupervisor,
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
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              _getGreetingIcon(hour),
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    userData?['name'] ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userData?['role'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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

  IconData _getGreetingIcon(int hour) {
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 17) return Icons.wb_cloudy;
    return Icons.nights_stay;
  }
}

/// Metrics Summary Cards
class _MetricsSummary extends ConsumerWidget {
  final String districtId;
  final bool isSupervisor;

  const _MetricsSummary({required this.districtId, required this.isSupervisor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This would ideally be a real provider that aggregates data
    // For now, using placeholder data
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Total Issues',
              value: '0',
              icon: Icons.warning_amber,
              color: Colors.orange,
              trend: '+0%',
              isPositive: false,
              width: isWide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth,
            ),
            _MetricCard(
              title: 'Pending',
              value: '0',
              icon: Icons.pending_actions,
              color: Colors.blue,
              trend: '+0%',
              isPositive: true,
              width: isWide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth,
            ),
            _MetricCard(
              title: 'Resolved',
              value: '0',
              icon: Icons.check_circle,
              color: Colors.green,
              trend: '+0%',
              isPositive: true,
              width: isWide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;
  final double width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Charts Section
class _ChartsSection extends StatelessWidget {
  final String districtId;

  const _ChartsSection({required this.districtId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _IssuesByCategoryChart()),
              const SizedBox(width: 16),
              Expanded(child: _StatusDistributionChart()),
            ],
          );
        } else {
          return Column(
            children: [
              _IssuesByCategoryChart(),
              const SizedBox(height: 16),
              _StatusDistributionChart(),
            ],
          );
        }
      },
    );
  }
}

class _IssuesByCategoryChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issues by Category',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barGroups: [
                    _buildBarGroup(0, 5, Colors.red),
                    _buildBarGroup(1, 3, Colors.orange),
                    _buildBarGroup(2, 2, Colors.blue),
                    _buildBarGroup(3, 1, Colors.purple),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const categories = [
                            'Missing\nReceipt',
                            'Wrong\nCoding',
                            'Over\nExpend',
                            'Other',
                          ];
                          return Text(
                            categories[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
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

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _StatusDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Distribution',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: '40%',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: '30%',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: '30%',
                      color: Colors.blue,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Cleared', Colors.green),
        _buildLegendItem('Issues', Colors.orange),
        _buildLegendItem('Pending', Colors.blue),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Recent Activity Feed
class _RecentActivity extends ConsumerWidget {
  final String districtId;
  final bool isSupervisor;

  const _RecentActivity({required this.districtId, required this.isSupervisor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSupervisor) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
        final recentLogs = logs.take(5).toList();

        if (recentLogs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No recent activity'),
            ),
          );
        }

        return Card(
          child: Column(
            children: recentLogs.map((log) {
              return ListTile(
                leading: _getActionIcon(log.action),
                title: Text('${log.userName} ${_getActionText(log.action)}'),
                subtitle: Text(
                  DateFormat('MMM d, h:mm a').format(log.timestamp),
                ),
                trailing: _buildRoleBadge(log.userRole),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
      backgroundColor: color.withOpacity(0.1),
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
      default:
        return Colors.grey;
    }
  }
}
