import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/train_hierarchy.dart';
import '../models/trip.dart';
import '../providers/train_data_provider.dart';
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
    final hierarchyAsync = ref.watch(trainHierarchyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('收集者')),
      body: tripListAsync.when(
        data: (trips) => hierarchyAsync.when(
          data: (hierarchy) => _buildBody(context, trips, hierarchy),
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => Center(
            child: Text(
              '加载失败',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Center(
          child: Text('加载失败', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Trip> trips,
    TrainHierarchy hierarchy,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final collectedKeys = <String>{};
    for (final t in trips) {
      final key = _buildModelKey(t);
      if (key.isNotEmpty) collectedKeys.add(key);
    }

    final allModels = _buildAllModelList(hierarchy);
    final total = allModels.length;
    final collected = total > 0
        ? allModels.where((m) => collectedKeys.contains(m.key)).length
        : 0;
    final ratio = total > 0 ? collected / total : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(cs, collected, total, ratio),
          const SizedBox(height: 16),
          Text(
            '全车型一览',
            style: theme.textTheme.titleSmall?.copyWith(color: cs.primary),
          ),
          const SizedBox(height: 12),
          _buildModelGrid(allModels, collectedKeys, cs),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    ColorScheme cs,
    int collected,
    int total,
    double ratio,
  ) {
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_train, color: cs.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  '收集进度',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: cs.primaryContainer,
                valueColor: AlwaysStoppedAnimation(cs.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(ratio * 100).toStringAsFixed(1)}%（$collected / $total 种）',
              style: TextStyle(color: cs.onPrimaryContainer, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  static const _modelUrls = {
    'CR450 AF': 'https://www.china-emu.cn/Trains/Model/CR450AF',
    'CR450 BF': 'https://www.china-emu.cn/Trains/Model/CR450BF',
    'CR400 AF': 'https://www.china-emu.cn/Trains/Model/Detail-12002-101-S.html',
    'CR400 BF': 'https://www.china-emu.cn/Trains/Model/Detail-13032-101-S.html',
    'CR300 AF': 'https://www.china-emu.cn/Trains/Model/Detail-11032-101-S.html',
    'CR300 BF': 'https://www.china-emu.cn/Trains/Model/Detail-11036-101-S.html',
    'CR220J 1': 'https://www.china-emu.cn/Trains/Model/Detail-10302-101-S.html',
    'CR220J 3': 'https://www.china-emu.cn/Trains/Model/Detail-10304-101-S.html',
    'CR200J-1 1-A': 'https://www.china-emu.cn/Trains/Model/Detail-10021-101-S.html',
    'CR200J-1 2-A': 'https://www.china-emu.cn/Trains/Model/Detail-10023-101-S.html',
    'CR200J-1 3-A': 'https://www.china-emu.cn/Trains/Model/Detail-10025-101-S.html',
    'CR200J-2 1-B': 'https://www.china-emu.cn/Trains/Model/Detail-10051-101-S.html',
    'CR200J-2 2-B': 'https://www.china-emu.cn/Trains/Model/Detail-10053-101-S.html',
    'CR200J-2 3-B': 'https://www.china-emu.cn/Trains/Model/Detail-10055-101-S.html',
    'CR200J-2 S-G': 'https://www.china-emu.cn/Trains/Model/Detail-10058-106-S.html',
    'CR200J-3 1-C': 'https://www.china-emu.cn/Trains/Model/Detail-10101-101-S.html',
    'CR200J-3 1-D': 'https://www.china-emu.cn/Trains/Model/Detail-10103-101-S.html',
    'CR200J-3 2-C': 'https://www.china-emu.cn/Trains/Model/Detail-10105-102-S.html',
    'CR200J-3 3-C': 'https://www.china-emu.cn/Trains/Model/Detail-10111-101-S.html',
    'CRH380 A': 'https://www.china-emu.cn/Trains/Model/Detail-30001-101-S.html',
    'CRH380 B': 'https://www.china-emu.cn/Trains/Model/Detail-31002-101-S.html',
    'CRH380 CL': 'https://www.china-emu.cn/Trains/Model/Detail-31010-101-S.html',
    'CRH380 D': 'https://www.china-emu.cn/Trains/Model/Detail-32001-101-S.html',
    'CRH1 A': 'https://www.china-emu.cn/Trains/Model/Detail-21001-101-S.html',
    'CRH1 B': 'https://www.china-emu.cn/Trains/Model/Detail-21003-101-S.html',
    'CRH1 E': 'https://www.china-emu.cn/Trains/Model/Detail-21004-102-S.html',
    'CRH2 A': 'https://www.china-emu.cn/Trains/Model/Detail-22001-101-S.html',
    'CRH2 B': 'https://www.china-emu.cn/Trains/Model/Detail-22004-101-S.html',
    'CRH2 E': 'https://www.china-emu.cn/Trains/Model/Detail-22010-102-S.html',
    'CRH2 C': 'https://www.china-emu.cn/Trains/Model/Detail-22006-101-S.html',
    'CRH3 C': 'https://www.china-emu.cn/Trains/Model/Detail-23011-101-S.html',
    'CRH3 A': 'https://www.china-emu.cn/Trains/Model/Detail-23002-101-S.html',
    'CRH5 A': 'https://www.china-emu.cn/Trains/Model/Detail-25001-101-S.html',
    'CRH5 G': 'https://www.china-emu.cn/Trains/Model/Detail-25004-101-S.html',
    'CRH5 E': 'https://www.china-emu.cn/Trains/Model/Detail-25002-102-S.html',
    'CRH6 A': 'https://www.china-emu.cn/Trains/Model/Detail-26001-201-S.html',
  };

  static const _silhouettePath = 'assets/images/silhouette.png';

  String _photoPath(String key) => 'assets/images/models/${key.replaceAll(' ', '_')}.jpg';

  Widget _buildModelGrid(
    List<_ModelEntry> allModels,
    Set<String> collectedKeys,
    ColorScheme cs,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: allModels.length,
      itemBuilder: (_, index) {
        final model = allModels[index];
        final isCollected = collectedKeys.contains(model.key);
        return _buildModelCard(model, isCollected, cs);
      },
    );
  }

  Widget _buildModelCard(_ModelEntry model, bool isCollected, ColorScheme cs) {
    final onColor = isCollected ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    return Card(
      color: isCollected ? cs.primaryContainer : cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCollected ? cs.outline : cs.outlineVariant,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _onModelTap(model),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: Image.asset(
                    _photoPath(model.key),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Icon(
                      isCollected
                          ? Icons.directions_train
                          : Icons.directions_train_outlined,
                      size: 36,
                      color: onColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                model.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCollected ? FontWeight.w700 : FontWeight.w500,
                  color: onColor,
                ),
              ),
              Text(
                model.categoryLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: onColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onModelTap(_ModelEntry model) async {
    final url = _modelUrls[model.key];
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  List<_ModelEntry> _buildAllModelList(TrainHierarchy hierarchy) {
    final entries = <_ModelEntry>[];
    for (final cat in hierarchy.availableCategories) {
      for (final platform in cat.platforms.values) {
        if (platform.series.isNotEmpty) {
          for (final series in platform.series.values) {
            final key = '${platform.key} ${series.key}';
            entries.add(
              _ModelEntry(
                key: key,
                label: series.label,
                categoryLabel: cat.label,
              ),
            );
          }
        } else {
          entries.add(
            _ModelEntry(
              key: platform.key,
              label: platform.label,
              categoryLabel: cat.label,
            ),
          );
        }
      }
    }
    return entries;
  }

  String _buildModelKey(Trip t) {
    final parts = <String>[];
    if (t.trainPlatformKey != null) parts.add(t.trainPlatformKey!);
    if (t.trainSeriesKey != null) parts.add(t.trainSeriesKey!);
    return parts.join(' ');
  }
}

class _ModelEntry {
  final String key;
  final String label;
  final String categoryLabel;

  const _ModelEntry({
    required this.key,
    required this.label,
    required this.categoryLabel,
  });
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
