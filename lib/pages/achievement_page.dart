import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip.dart';
import '../providers/trip_provider.dart';

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('成就')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: tripListAsync.when(
          data: (trips) {
            final totalCount = trips.length;
            final totalCost = trips.fold<double>(0, (sum, t) => sum + t.price);
            final totalDuration = _calcTotalDuration(trips);
            return Column(
              children: [
                _StatGrid(
                  totalCount: totalCount,
                  totalCost: totalCost,
                  totalDuration: totalDuration,
                  onAchievementTap: () =>
                      _navigateToAchievementDetail(context, totalCount),
                ),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) =>
              Text('加载失败', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ),
    );
  }

  Duration _calcTotalDuration(List<Trip> trips) {
    var total = Duration.zero;
    for (final t in trips) {
      if (t.arrivalTime != null) {
        final diff = t.arrivalTime!.difference(t.departureTime);
        if (diff.inMinutes > 0) total += diff;
      }
    }
    return total;
  }

  void _navigateToCollector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _CollectorPage()),
    );
  }

  void _navigateToNavigator(BuildContext context, int totalCount) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _NavigatorPage(totalCount: totalCount)),
    );
  }

  void _navigateToAchievementDetail(BuildContext context, int totalCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AchievementDetailPage(totalCount: totalCount),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final int totalCount;
  final double totalCost;
  final Duration totalDuration;
  final VoidCallback onAchievementTap;

  const _StatGrid({
    required this.totalCount,
    required this.totalCost,
    required this.totalDuration,
    required this.onAchievementTap,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '0m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '总运转次数',
                  value: '$totalCount',
                  color: theme.colorScheme.primaryContainer,
                  onColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '总花费金额',
                  value:
                      '¥${totalCost.toStringAsFixed(totalCost.truncateToDouble() == totalCost ? 0 : 2)}',
                  color: theme.colorScheme.secondaryContainer,
                  onColor: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '总运转时长',
                  value: _formatDuration(totalDuration),
                  color: theme.colorScheme.tertiaryContainer,
                  onColor: theme.colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '成就系统',
                  value: '查看详情',
                  color: theme.colorScheme.surfaceContainerHighest,
                  onColor: theme.colorScheme.onSurface,
                  isAction: true,
                  onTap: onAchievementTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color onColor;
  final bool isAction;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
    this.isAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: onColor),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: isAction
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onColor,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 20, color: onColor),
                    ],
                  )
                : Text(
                    value,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onColor,
                    ),
                    maxLines: 1,
                  ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Card(
        color: color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      );
    }

    return Card(color: color, child: child);
  }
}

class _AchievementEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AchievementEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementDetailPage extends StatelessWidget {
  final int totalCount;

  const _AchievementDetailPage({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('成就系统')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _AchievementEntryCard(
              icon: Icons.directions_train,
              title: '收集者',
              subtitle: '车底型号覆盖率统计',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _CollectorPage()),
              ),
            ),
            const SizedBox(height: 12),
            _AchievementEntryCard(
              icon: Icons.navigation,
              title: '领航者',
              subtitle: '运转次数勋章',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _NavigatorPage(totalCount: totalCount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorPage extends ConsumerWidget {
  const _CollectorPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('收集者')),
      body: tripListAsync.when(
        data: (trips) {
          final collected = <String>{};
          for (final t in trips) {
            final key = _buildModelKey(t);
            if (key.isNotEmpty) collected.add(key);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_train,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '已收集 ${collected.length} 种车型',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '详细统计开发中',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Center(
          child: Text('加载失败', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ),
    );
  }

  String _buildModelKey(Trip t) {
    final parts = <String>[];
    if (t.trainPlatformKey != null) parts.add(t.trainPlatformKey!);
    if (t.trainSeriesKey != null) parts.add(t.trainSeriesKey!);
    if (t.trainVariant != null) parts.add(t.trainVariant!);
    return parts.join(' ');
  }
}

class _NavigatorPage extends StatelessWidget {
  final int totalCount;

  const _NavigatorPage({required this.totalCount});

  static const _milestones = [1, 10, 50, 100, 200, 500, 1000, 5000];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('领航者')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前运转次数：$totalCount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _milestones.length,
                itemBuilder: (context, index) {
                  final milestone = _milestones[index];
                  final unlocked = totalCount >= milestone;
                  return _MilestoneCard(
                    milestone: milestone,
                    unlocked: unlocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final int milestone;
  final bool unlocked;

  const _MilestoneCard({required this.milestone, required this.unlocked});

  String _formatCount(int n) {
    if (n >= 1000) return '${n ~/ 1000},000';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: unlocked ? cs.primaryContainer : cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
              size: 32,
              color: unlocked ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              _formatCount(milestone),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: unlocked ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
            Text(
              '次',
              style: theme.textTheme.labelSmall?.copyWith(
                color: unlocked ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
