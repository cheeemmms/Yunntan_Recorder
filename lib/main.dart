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
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(tripListProvider.notifier).seedTestData();
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('生成 100 条测试数据'),
                  ),
                ],
              ),
            );
          }
          final sorted = List<Trip>.from(trips)
            ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
          final filtered = _hasActiveFilter ? _applyFilters(sorted) : sorted;

          final currentIds = filtered.map((t) => t.id).toSet();
          _cardKeys.removeWhere((id, _) => !currentIds.contains(id));

          return Column(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _filterExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _filterExpanded
                    ? _buildFilterPanel(theme, sorted)
                    : const SizedBox.shrink(),
                secondChild: const SizedBox.shrink(),
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
                            onDelete: () => _confirmDelete(context, ref, trip),
                          );
                        },
                      ),
              ),
            ],
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
          _buildFilterChip<int>(
            label: '年份',
            values: _filterYears,
            itemLabel: (y) => '$y',
            onClear: () => setState(() => _filterYears.clear()),
            onTap: () => _showMultiSelectBottomSheet<int>(
              context: context,
              title: '选择年份',
              items: years,
              selectedValues: _filterYears,
              itemLabel: (y) => '$y',
              onConfirm: (selected) => setState(() => _filterYears = selected),
            ),
          ),
          _buildCascadingFilterChip(
            categoryPlatformMap: categoryPlatformMap,
            categories: categories,
          ),
          _buildFilterChip<String>(
            label: '席位类型',
            values: _filterSeats,
            itemLabel: (s) => s,
            onClear: () => setState(() => _filterSeats.clear()),
            onTap: () => _showMultiSelectBottomSheet<String>(
              context: context,
              title: '选择席位类型',
              items: seats,
              selectedValues: _filterSeats,
              itemLabel: (s) => s,
              onConfirm: (selected) => setState(() => _filterSeats = selected),
            ),
          ),
          _buildFilterChip<String>(
            label: '局段',
            values: _filterBureaus,
            itemLabel: (b) => b,
            onClear: () => setState(() => _filterBureaus.clear()),
            onTap: () => _showMultiSelectBottomSheet<String>(
              context: context,
              title: '选择局段',
              items: bureaus,
              selectedValues: _filterBureaus,
              itemLabel: (b) => b,
              onConfirm: (selected) =>
                  setState(() => _filterBureaus = selected),
            ),
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

  Widget _buildFilterChip<T>({
    required String label,
    required Set<T> values,
    required String Function(T) itemLabel,
    required VoidCallback onClear,
    required VoidCallback onTap,
  }) {
    final hasSelection = values.isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    return InputChip(
      selected: hasSelection,
      label: Text(hasSelection ? '$label(${values.length})' : label),
      onPressed: onTap,
      onDeleted: hasSelection ? onClear : null,
      selectedColor: cs.primaryContainer,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: hasSelection ? cs.outline : cs.outlineVariant),
      labelStyle: TextStyle(color: cs.onSurface),
    );
  }

  Widget _buildCascadingFilterChip({
    required List<String> categories,
    required Map<String, Set<String>> categoryPlatformMap,
  }) {
    final hasSelection =
        _filterCategories.isNotEmpty || _filterPlatforms.isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    return InputChip(
      selected: hasSelection,
      label: Text(
        hasSelection
            ? '车底型号(${_filterCategories.length + _filterPlatforms.length})'
            : '车底型号',
      ),
      onPressed: () => _showCascadingBottomSheet(
        context: context,
        categories: categories,
        categoryPlatformMap: categoryPlatformMap,
      ),
      onDeleted: hasSelection
          ? () => setState(() {
              _filterCategories.clear();
              _filterPlatforms.clear();
            })
          : null,
      selectedColor: cs.primaryContainer,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: hasSelection ? cs.outline : cs.outlineVariant),
      labelStyle: TextStyle(color: cs.onSurface),
    );
  }

  void _showMultiSelectBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Set<T> selectedValues,
    required String Function(T) itemLabel,
    required void Function(Set<T>) onConfirm,
  }) {
    final tempSelected = Set<T>.from(selectedValues);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(ctx).textTheme.titleMedium,
                          ),
                        ),
                        if (tempSelected.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                setModalState(() => tempSelected.clear()),
                            child: const Text('清除'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final isSelected = tempSelected.contains(item);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(itemLabel(item)),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                tempSelected.add(item);
                              } else {
                                tempSelected.remove(item);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          onConfirm(tempSelected);
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCascadingBottomSheet({
    required BuildContext context,
    required List<String> categories,
    required Map<String, Set<String>> categoryPlatformMap,
  }) {
    final tempCategories = Set<String>.from(_filterCategories);
    final tempPlatforms = Set<String>.from(_filterPlatforms);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '选择车底型号',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (tempCategories.isNotEmpty ||
                            tempPlatforms.isNotEmpty)
                          TextButton(
                            onPressed: () => setModalState(() {
                              tempCategories.clear();
                              tempPlatforms.clear();
                            }),
                            child: const Text('清除'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (_, index) {
                        final cat = categories[index];
                        final catSelected = tempCategories.contains(cat);
                        final platforms =
                            categoryPlatformMap[cat]?.toList() ?? [];
                        platforms.sort();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              value: catSelected,
                              title: Text(
                                cat,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    tempCategories.add(cat);
                                  } else {
                                    tempCategories.remove(cat);
                                    tempPlatforms.removeWhere(
                                      (p) => platforms.contains(p),
                                    );
                                  }
                                });
                              },
                            ),
                            if (catSelected && platforms.isNotEmpty)
                              ...platforms.map(
                                (plat) => Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: CheckboxListTile(
                                    value: tempPlatforms.contains(plat),
                                    title: Text(
                                      plat,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    dense: true,
                                    onChanged: (checked) {
                                      setModalState(() {
                                        if (checked == true) {
                                          tempPlatforms.add(plat);
                                        } else {
                                          tempPlatforms.remove(plat);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _filterCategories = tempCategories;
                            _filterPlatforms = tempPlatforms;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
