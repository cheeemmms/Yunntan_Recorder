import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/achievement_page.dart';
import 'pages/entry_page.dart';
import 'models/trip.dart';
import 'providers/trip_provider.dart';
import 'widgets/trip_card.dart';

final ValueNotifier<bool> scrollToTopNotifier = ValueNotifier(false);
final ValueNotifier<ScrollController?> homeScrollCtrlNotifier = ValueNotifier(
  null,
);

void main() {
  runApp(const ProviderScope(child: TrainLedgerApp()));
}

class TrainLedgerApp extends StatelessWidget {
  const TrainLedgerApp({super.key});

  static final _lightTheme = FlexThemeData.light(
    scheme: FlexScheme.greyLaw,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 8,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final _darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.greyLaw,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ThemeData lightTheme;
        ThemeData darkTheme;

        if (lightDynamic != null) {
          lightTheme = _lightTheme.copyWith(colorScheme: lightDynamic);
          darkTheme = _darkTheme.copyWith(
            colorScheme: darkDynamic ?? lightDynamic.harmonized(),
          );
        } else {
          lightTheme = _lightTheme;
          darkTheme = _darkTheme;
        }

        return MaterialApp(
          title: 'Train Ledger',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const MainShell(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomePage(),
    AchievementPage(),
    Center(child: Text('设置（待开发）')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: scrollToTopNotifier,
                  builder: (_, show, __) {
                    if (!show) return const SizedBox.shrink();
                    return ValueListenableBuilder<ScrollController?>(
                      valueListenable: homeScrollCtrlNotifier,
                      builder: (_, ctrl, __) {
                        if (ctrl == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FloatingActionButton.small(
                            heroTag: 'scrollToTop',
                            onPressed: () => ctrl.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: const Icon(Icons.keyboard_arrow_up),
                          ),
                        );
                      },
                    );
                  },
                ),
                FloatingActionButton(
                  heroTag: 'addTrip',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EntryPage()),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: '成就'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Map<int, GlobalKey> _cardKeys = {};
  VoidCallback? _closeCurrentSlidable;

  final ScrollController _scrollController = ScrollController();
  bool _filterExpanded = false;
  double _lastScrollOffset = 0;

  Set<int> _filterYears = {};
  Set<String> _filterCategories = {};
  Set<String> _filterPlatforms = {};
  Set<String> _filterSeats = {};
  Set<String> _filterBureaus = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeScrollCtrlNotifier.value = _scrollController;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final show = offset > 200;
    if (show != scrollToTopNotifier.value) {
      scrollToTopNotifier.value = show;
    }
    if (_filterExpanded && offset > _lastScrollOffset && offset > 0) {
      setState(() => _filterExpanded = false);
    }
    _lastScrollOffset = offset;
  }

  bool _handleOverscroll(OverscrollNotification notification) {
    if (notification.overscroll < 0 &&
        _scrollController.offset <= 0 &&
        !_filterExpanded) {
      setState(() => _filterExpanded = true);
      return true;
    }
    return false;
  }

  void _resetFilters() {
    setState(() {
      _filterYears.clear();
      _filterCategories.clear();
      _filterPlatforms.clear();
      _filterSeats.clear();
      _filterBureaus.clear();
    });
  }

  bool get _hasActiveFilter =>
      _filterYears.isNotEmpty ||
      _filterCategories.isNotEmpty ||
      _filterPlatforms.isNotEmpty ||
      _filterSeats.isNotEmpty ||
      _filterBureaus.isNotEmpty;

  List<Trip> _applyFilters(List<Trip> trips) {
    return trips.where((t) {
      if (_filterYears.isNotEmpty &&
          !_filterYears.contains(t.departureTime.year)) {
        return false;
      }
      if (_filterCategories.isNotEmpty) {
        if (!_filterCategories.contains(t.trainCategoryKey)) return false;
        if (_filterPlatforms.isNotEmpty &&
            t.trainPlatformKey != null &&
            !_filterPlatforms.contains(t.trainPlatformKey)) {
          return false;
        }
      }
      if (_filterSeats.isNotEmpty && !_filterSeats.contains(t.seatType)) {
        return false;
      }
      if (_filterBureaus.isNotEmpty &&
          t.bureauKey != null &&
          !_filterBureaus.contains(t.bureauKey)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('运转记录'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => setState(() => _filterExpanded = !_filterExpanded),
          ),
        ],
      ),
      body: tripListAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.train_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无运转记录',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击 + 开始录入运转',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          final sorted = List<Trip>.from(trips)
            ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
          final filtered = _hasActiveFilter ? _applyFilters(sorted) : sorted;

          return NotificationListener<OverscrollNotification>(
            onNotification: _handleOverscroll,
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _filterExpanded
                      ? _buildFilterPanel(theme, sorted)
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            '无匹配记录',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 88),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final trip = filtered[index];
                            _cardKeys.putIfAbsent(trip.id, () => GlobalKey());
                            return TripCard(
                              cardKey: _cardKeys[trip.id]!,
                              registerClose: (close) {
                                _closeCurrentSlidable?.call();
                                _closeCurrentSlidable = close;
                              },
                              trip: trip,
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EntryPage(trip: trip),
                                ),
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, ref, trip),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Center(
          child: Text(
            '数据库加载失败',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme, List<Trip> trips) {
    final cs = theme.colorScheme;

    final years = trips.map((t) => t.departureTime.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final categories =
        trips
            .map((t) => t.trainCategoryKey)
            .where((k) => k.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final categoryPlatformMap = <String, Set<String>>{};
    for (final t in trips) {
      if (t.trainCategoryKey.isNotEmpty && t.trainPlatformKey != null) {
        categoryPlatformMap
            .putIfAbsent(t.trainCategoryKey, () => {})
            .add(t.trainPlatformKey!);
      }
    }
    final seats =
        trips.map((t) => t.seatType).where((s) => s.isNotEmpty).toSet().toList()
          ..sort();
    final bureaus =
        trips
            .map((t) => t.bureauKey)
            .where((b) => b != null && b.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList()
          ..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          _buildFilterDropdown<int>(
            label: '年份',
            values: _filterYears,
            allItems: years,
            itemLabel: (y) => '$y',
            onToggle: (y) => setState(() {
              _filterYears.contains(y)
                  ? _filterYears.remove(y)
                  : _filterYears.add(y);
            }),
            onClear: () => setState(() => _filterYears.clear()),
            theme: theme,
          ),
          _buildCascadingFilterDropdown(
            label: '车底型号',
            categories: categories,
            categoryPlatformMap: categoryPlatformMap,
            theme: theme,
          ),
          _buildFilterDropdown<String>(
            label: '席位类型',
            values: _filterSeats,
            allItems: seats,
            itemLabel: (s) => s,
            onToggle: (s) => setState(() {
              _filterSeats.contains(s)
                  ? _filterSeats.remove(s)
                  : _filterSeats.add(s);
            }),
            onClear: () => setState(() => _filterSeats.clear()),
            theme: theme,
          ),
          _buildFilterDropdown<String>(
            label: '局段',
            values: _filterBureaus,
            allItems: bureaus,
            itemLabel: (b) => b,
            onToggle: (b) => setState(() {
              _filterBureaus.contains(b)
                  ? _filterBureaus.remove(b)
                  : _filterBureaus.add(b);
            }),
            onClear: () => setState(() => _filterBureaus.clear()),
            theme: theme,
          ),
          if (_hasActiveFilter)
            ActionChip(
              label: const Text('重置'),
              onPressed: _resetFilters,
              avatar: Icon(Icons.clear_all, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required Set<T> values,
    required List<T> allItems,
    required String Function(T) itemLabel,
    required void Function(T) onToggle,
    required VoidCallback onClear,
    required ThemeData theme,
  }) {
    final cs = theme.colorScheme;
    final hasSelection = values.isNotEmpty;

    return PopupMenuButton<T>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: const BoxConstraints(maxHeight: 360),
      onSelected: onToggle,
      itemBuilder: (context) => [
        ...allItems.map(
          (item) => PopupMenuItem<T>(
            value: item,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: values.contains(item),
                    onChanged: (_) => onToggle(item),
                  ),
                ),
                const SizedBox(width: 8),
                Text(itemLabel(item)),
              ],
            ),
          ),
        ),
        if (hasSelection)
          PopupMenuItem<T>(
            height: 36,
            child: Center(
              child: Text(
                '清除筛选',
                style: TextStyle(color: cs.primary, fontSize: 13),
              ),
            ),
            onTap: onClear,
          ),
      ],
      child: InputChip(
        selected: hasSelection,
        label: Text(hasSelection ? '$label(${values.length})' : label),
        onDeleted: hasSelection ? onClear : null,
      ),
    );
  }

  Widget _buildCascadingFilterDropdown({
    required String label,
    required List<String> categories,
    required Map<String, Set<String>> categoryPlatformMap,
    required ThemeData theme,
  }) {
    final cs = theme.colorScheme;
    final hasSelection =
        _filterCategories.isNotEmpty || _filterPlatforms.isNotEmpty;

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: const BoxConstraints(maxHeight: 400),
      onSelected: (value) {},
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        for (final cat in categories) {
          final catSelected = _filterCategories.contains(cat);
          final platforms = categoryPlatformMap[cat]?.toList() ?? [];
          platforms.sort();

          items.add(
            PopupMenuItem<String>(
              value: 'cat:$cat',
              height: 40,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: catSelected,
                      onChanged: (_) => setState(() {
                        catSelected
                            ? _filterCategories.remove(cat)
                            : _filterCategories.add(cat);
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );

          if (catSelected && platforms.isNotEmpty) {
            for (final plat in platforms) {
              items.add(
                PopupMenuItem<String>(
                  value: 'plat:$plat',
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _filterPlatforms.contains(plat),
                            onChanged: (_) => setState(() {
                              _filterPlatforms.contains(plat)
                                  ? _filterPlatforms.remove(plat)
                                  : _filterPlatforms.add(plat);
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(plat, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        }

        if (hasSelection) {
          items.add(
            PopupMenuItem<String>(
              height: 36,
              child: Center(
                child: Text(
                  '清除筛选',
                  style: TextStyle(color: cs.primary, fontSize: 13),
                ),
              ),
              onTap: () => setState(() {
                _filterCategories.clear();
                _filterPlatforms.clear();
              }),
            ),
          );
        }

        return items;
      },
      child: InputChip(
        selected: hasSelection,
        label: Text(
          hasSelection
              ? '$label(${_filterCategories.length + _filterPlatforms.length})'
              : label,
        ),
        onDeleted: hasSelection
            ? () => setState(() {
                _filterCategories.clear();
                _filterPlatforms.clear();
              })
            : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Trip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${trip.trainNo} 的运转记录吗？'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () {
              ref.read(tripListProvider.notifier).deleteTrip(trip.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已删除 ${trip.trainNo}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text('删除', style: TextStyle(color: colorScheme.onError)),
          ),
        ],
      ),
    );
  }
}
