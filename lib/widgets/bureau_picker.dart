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
  late int _l1Index;
  late int _l2Index;

  late FixedExtentScrollController _l1Ctrl;
  late FixedExtentScrollController _l2Ctrl;

  List<BureauSection> get _sections => _bureaus[_l1Index].passengerSections;

  @override
  void initState() {
    super.initState();
    _bureaus = widget.data.bureauList;
    _l1Index = 0;
    _l2Index = 0;

    if (widget.initialValue != null) {
      final iv = widget.initialValue!;
      final bi = _bureaus.indexWhere((b) => b.key == iv.bureauKey);
      if (bi >= 0) {
        _l1Index = bi;
        final si = _sections.indexWhere((s) => s.name == iv.section.name);
        if (si >= 0) _l2Index = si;
      }
    }

    _l1Ctrl = FixedExtentScrollController(initialItem: _l1Index);
    _l2Ctrl = FixedExtentScrollController(initialItem: _l2Index);
  }

  void _onL1Changed(int index) {
    setState(() {
      _l1Index = index;
      _l2Index = 0;
      _l2Ctrl.jumpToItem(0);
    });
  }

  void _onL2Changed(int index) {
    setState(() {
      _l2Index = index;
    });
  }

  void _handleConfirm() {
    final bureau = _bureaus[_l1Index];
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该局暂无客运段数据')),
      );
      return;
    }
    widget.onConfirm(BureauPickerResult(
      bureauKey: bureau.key,
      section: _sections[_l2Index],
    ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _l1Ctrl.dispose();
    _l2Ctrl.dispose();
    super.dispose();
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
                _buildWheel(theme, _l1Ctrl, _bureaus.map((b) => b.key).toList(), _onL1Changed),
                _buildWheel(theme, _l2Ctrl, _sections.map((s) => s.name).toList(), _onL2Changed, emptyHint: '无客运段'),
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
