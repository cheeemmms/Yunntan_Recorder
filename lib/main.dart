import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/achievement_page.dart';
import 'pages/entry_page.dart';
import 'models/trip.dart';
import 'providers/trip_provider.dart';
import 'widgets/trip_card.dart';

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
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EntryPage()),
              ),
              child: const Icon(Icons.add),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('运转记录')),
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
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final trip = sorted[index];
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
                  MaterialPageRoute(builder: (_) => EntryPage(trip: trip)),
                ),
                onDelete: () => _confirmDelete(context, ref, trip),
              );
            },
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
