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
        builder: (_, _) => TrainModelPicker(
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
  late int _l1Index;
  late int _l2Index;
  late int _l3Index;
  late int _l4Index;

  late FixedExtentScrollController _l1Ctrl;
  late FixedExtentScrollController _l2Ctrl;
  late FixedExtentScrollController _l3Ctrl;
  late FixedExtentScrollController _l4Ctrl;

  List<TrainPlatform> get _platforms =>
      _categories[_l1Index].platforms.values.toList();
  List<TrainSeries> get _seriesList =>
      _platforms.isNotEmpty ? _platforms[_l2Index].series.values.toList() : <TrainSeries>[];
  List<String> get _rawVariants =>
      _seriesList.isNotEmpty ? _seriesList[_l3Index].variants : <String>[];
  List<String> get _variants => ['无', ..._rawVariants];

  @override
  void initState() {
    super.initState();
    _categories = widget.hierarchy.availableCategories;
    _l1Index = 0;
    _l2Index = 0;
    _l3Index = 0;
    _l4Index = 0;

    if (widget.initialValue != null) {
      final iv = widget.initialValue!;
      final ci = _categories.indexWhere((c) => c.key == iv.category.key);
      if (ci >= 0) {
        _l1Index = ci;
        if (iv.platform != null) {
          final pi = _platforms.indexWhere((p) => p.key == iv.platform!.key);
          if (pi >= 0) {
            _l2Index = pi;
            if (iv.series != null) {
              final si = _seriesList.indexWhere((s) => s.key == iv.series!.key);
              if (si >= 0) {
                _l3Index = si;
                if (iv.variant != null) {
                  final vi = _rawVariants.indexOf(iv.variant!);
                  if (vi >= 0) _l4Index = vi + 1;
                }
              }
            }
          }
        }
      }
    }

    _l1Ctrl = FixedExtentScrollController(initialItem: _l1Index);
    _l2Ctrl = FixedExtentScrollController(initialItem: _l2Index);
    _l3Ctrl = FixedExtentScrollController(initialItem: _l3Index);
    _l4Ctrl = FixedExtentScrollController(initialItem: _l4Index);
  }

  void _onL1Changed(int index) {
    setState(() {
      _l1Index = index;
      _l2Index = 0;
      _l3Index = 0;
      _l4Index = 0;
      _l2Ctrl.jumpToItem(0);
      _l3Ctrl.jumpToItem(0);
      _l4Ctrl.jumpToItem(0);
    });
  }

  void _onL2Changed(int index) {
    setState(() {
      _l2Index = index;
      _l3Index = 0;
      _l4Index = 0;
      _l3Ctrl.jumpToItem(0);
      _l4Ctrl.jumpToItem(0);
    });
  }

  void _onL3Changed(int index) {
    setState(() {
      _l3Index = index;
      _l4Index = 0;
      _l4Ctrl.jumpToItem(0);
    });
  }

  void _onL4Changed(int index) {
    setState(() {
      _l4Index = index;
    });
  }

  void _handleConfirm() {
    final cat = _categories[_l1Index];
    if (cat.developing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('功能开发中')),
      );
      return;
    }

    TrainPlatform? platform;
    TrainSeries? series;
    String? variant;

    if (_platforms.isNotEmpty) platform = _platforms[_l2Index];
    if (_seriesList.isNotEmpty) series = _seriesList[_l3Index];
    if (_rawVariants.isNotEmpty && _l4Index > 0) variant = _rawVariants[_l4Index - 1];

    widget.onConfirm(TrainModelPickerResult(
      category: cat,
      platform: platform,
      series: series,
      variant: variant,
    ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _l1Ctrl.dispose();
    _l2Ctrl.dispose();
    _l3Ctrl.dispose();
    _l4Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showL3 = _platforms.isNotEmpty && _seriesList.isNotEmpty;
    final showL4 = showL3 && _rawVariants.isNotEmpty;

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
                _buildWheel(theme, _l1Ctrl, _categories.map((c) => c.label).toList(), _onL1Changed),
                _buildWheel(theme, _l2Ctrl, _platforms.map((p) => p.label).toList(), _onL2Changed, emptyHint: '无平台'),
                if (showL3) _buildWheel(theme, _l3Ctrl, _seriesList.map((s) => s.label).toList(), _onL3Changed, emptyHint: '无系列'),
                if (showL4) _buildWheel(theme, _l4Ctrl, _variants, _onL4Changed, emptyHint: '无变体'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(ThemeData theme, FixedExtentScrollController ctrl, List<String> items, void Function(int) onChanged, {String emptyHint = '-'}) {
    return Expanded(
      child: items.isEmpty
          ? Center(child: Text(emptyHint, style: theme.textTheme.bodySmall))
          : CupertinoPicker.builder(
              scrollController: ctrl,
              itemExtent: 36,
              childCount: items.length,
              onSelectedItemChanged: onChanged,
              itemBuilder: (_, i) => Center(
                child: Text(items[i], style: const TextStyle(fontSize: 16)),
              ),
            ),
    );
  }
}
