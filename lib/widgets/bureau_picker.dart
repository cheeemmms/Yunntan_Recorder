import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/railway_bureau.dart';

class BureauPickerResult {
  final String bureauKey;
  final BureauSection section;

  const BureauPickerResult({
    required this.bureauKey,
    required this.section,
  });
}

class BureauPicker extends StatefulWidget {
  final RailwayBureauData data;
  final BureauPickerResult? initialValue;
  final void Function(BureauPickerResult result) onConfirm;

  const BureauPicker({
    super.key,
    required this.data,
    this.initialValue,
    required this.onConfirm,
  });

  static void show({
    required BuildContext context,
    required RailwayBureauData data,
    BureauPickerResult? initialValue,
    required void Function(BureauPickerResult result) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BureauPicker(
        data: data,
        initialValue: initialValue,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<BureauPicker> createState() => _BureauPickerState();
}

class _BureauPickerState extends State<BureauPicker> {
  late List<RailwayBureau> _bureaus;
  int _l1 = 0;
  int _l2 = 0;

  List<BureauSection> get _sections => _bureaus[_l1].passengerSections;

  @override
  void initState() {
    super.initState();
    _bureaus = widget.data.bureauList;

    if (widget.initialValue != null) {
      final iv = widget.initialValue!;
      final bi = _bureaus.indexWhere((b) => b.key == iv.bureauKey);
      if (bi >= 0) {
        _l1 = bi;
        final si = _sections.indexWhere((s) => s.name == iv.section.name);
        if (si >= 0) _l2 = si;
      }
    }
  }

  void _handleConfirm() {
    final bureau = _bureaus[_l1];
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该局暂无客运段数据')),
      );
      return;
    }
    widget.onConfirm(BureauPickerResult(
      bureauKey: bureau.key,
      section: _sections[_l2],
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 280,
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
                Text('选择乘务担当', style: theme.textTheme.titleMedium),
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
                  items: _bureaus.map((b) => b.key).toList(),
                  selectedIndex: _l1,
                  onChanged: (i) => setState(() {
                    _l1 = i;
                    _l2 = 0;
                  }),
                ),
                _buildWheel(
                  items: _sections.map((s) => s.name).toList(),
                  selectedIndex: _sections.isEmpty ? -1 : _l2,
                  emptyHint: '无客运段',
                  onChanged: (i) => setState(() {
                    _l2 = i;
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
