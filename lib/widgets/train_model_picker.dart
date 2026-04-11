import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/train_hierarchy.dart';

class TrainModelPickerResult {
  final TrainCategory category;
  final TrainPlatform? platform;
  final TrainSeries? series;
  final String? variant;

  const TrainModelPickerResult({
    required this.category,
    this.platform,
    this.series,
    this.variant,
  });

  String get displayLabel {
    if (series != null && variant != null && variant!.isNotEmpty) {
      return '${series!.label}-${variant!}';
    }
    if (series != null) return series!.label;
    if (platform != null) return platform!.label;
    return category.label;
  }
}

class TrainModelPicker extends StatefulWidget {
  final TrainHierarchy hierarchy;
  final TrainModelPickerResult? initialValue;
  final void Function(TrainModelPickerResult result) onConfirm;

  const TrainModelPicker({
    super.key,
    required this.hierarchy,
    this.initialValue,
    required this.onConfirm,
  });

  static void show({
    required BuildContext context,
    required TrainHierarchy hierarchy,
    TrainModelPickerResult? initialValue,
    required void Function(TrainModelPickerResult result) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, __) => TrainModelPicker(
          hierarchy: hierarchy,
          initialValue: initialValue,
          onConfirm: onConfirm,
        ),
      ),
    );
  }

  @override
  State<TrainModelPicker> createState() => _TrainModelPickerState();
}

class _TrainModelPickerState extends State<TrainModelPicker> {
  late List<TrainCategory> _categories;
  int _l1 = 0;
  int _l2 = 0;
  int _l3 = 0;
  int _l4 = 0;

  List<TrainPlatform> get _platforms =>
      _categories[_l1].platforms.values.toList();
  List<TrainSeries> get _series =>
      _platforms.isNotEmpty ? _platforms[_l2].series.values.toList() : <TrainSeries>[];
  List<String> get _rawVariants =>
      _series.isNotEmpty ? _series[_l3].variants : <String>[];
  List<String> get _variantItems => ['无', ..._rawVariants];

  bool get _showL3 => _platforms.isNotEmpty && _series.isNotEmpty;
  bool get _showL4 => _showL3 && _rawVariants.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _categories = widget.hierarchy.availableCategories;

    if (widget.initialValue != null) {
      final iv = widget.initialValue!;
      final ci = _categories.indexWhere((c) => c.key == iv.category.key);
      if (ci >= 0) {
        _l1 = ci;
        if (iv.platform != null) {
          final pi = _platforms.indexWhere((p) => p.key == iv.platform!.key);
          if (pi >= 0) {
            _l2 = pi;
            if (iv.series != null) {
              final si = _series.indexWhere((s) => s.key == iv.series!.key);
              if (si >= 0) {
                _l3 = si;
                if (iv.variant != null) {
                  final vi = _rawVariants.indexOf(iv.variant!);
                  if (vi >= 0) _l4 = vi + 1;
                }
              }
            }
          }
        }
      }
    }
  }

  void _handleConfirm() {
    final cat = _categories[_l1];
    if (cat.developing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('功能开发中')),
      );
      return;
    }

    TrainPlatform? platform;
    TrainSeries? series;
    String? variant;

    if (_platforms.isNotEmpty) platform = _platforms[_l2];
    if (_series.isNotEmpty) series = _series[_l3];
    if (_rawVariants.isNotEmpty && _l4 > 0) variant = _rawVariants[_l4 - 1];

    widget.onConfirm(TrainModelPickerResult(
      category: cat,
      platform: platform,
      series: series,
      variant: variant,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 320,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                Text('选择车型', style: theme.textTheme.titleMedium),
                FilledButton(
                  onPressed: _handleConfirm,
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _buildWheel(
                  items: _categories.map((c) => c.label).toList(),
                  selectedIndex: _l1,
                  onChanged: (i) => setState(() {
                    _l1 = i;
                    _l2 = 0;
                    _l3 = 0;
                    _l4 = 0;
                  }),
                ),
                _buildWheel(
                  items: _platforms.map((p) => p.label).toList(),
                  selectedIndex: _platforms.isEmpty ? -1 : _l2,
                  emptyHint: '无平台',
                  onChanged: (i) => setState(() {
                    _l2 = i;
                    _l3 = 0;
                    _l4 = 0;
                  }),
                ),
                if (_showL3)
                  _buildWheel(
                    items: _series.map((s) => s.label).toList(),
                    selectedIndex: _l3,
                    onChanged: (i) => setState(() {
                      _l3 = i;
                      _l4 = 0;
                    }),
                  ),
                if (_showL4)
                  _buildWheel(
                    items: _variantItems,
                    selectedIndex: _l4,
                    onChanged: (i) => setState(() {
                      _l4 = i;
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required List<String> items,
    required int selectedIndex,
    required void Function(int) onChanged,
    String emptyHint = '-',
  }) {
    if (items.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(emptyHint, style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    final safeIndex = selectedIndex.clamp(0, items.length - 1);

    return Expanded(
      child: CupertinoPicker(
        key: ValueKey(items.hashCode),
        itemExtent: 36,
        scrollController: FixedExtentScrollController(initialItem: safeIndex),
        onSelectedItemChanged: onChanged,
        children: items.map((item) => Center(
          child: Text(item, style: const TextStyle(fontSize: 16)),
        )).toList(),
      ),
    );
  }
}
