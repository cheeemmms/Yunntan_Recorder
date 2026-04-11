import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CascadingPicker extends StatelessWidget {
  final String title;
  final List<CascadingPickerColumn> columns;
  final List<int> initialIndices;
  final void Function(List<int> indices) onConfirm;

  const CascadingPicker({
    super.key,
    required this.title,
    required this.columns,
    required this.initialIndices,
    required this.onConfirm,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<CascadingPickerColumn> columns,
    required List<int> initialIndices,
    required void Function(List<int> indices) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CascadingPicker(
        title: title,
        columns: columns,
        initialIndices: initialIndices,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controllers = List.generate(
      columns.length,
      (i) => FixedExtentScrollController(
        initialItem: initialIndices[i].clamp(0, (columns[i].items.length - 1).clamp(0, 999999)),
      ),
    );

    return Container(
      height: 300,
      color: Theme.of(context).colorScheme.surface,
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
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                FilledButton(
                  onPressed: () {
                    final indices = controllers.map((c) {
                      final item = c.selectedItem.clamp(0, 999999);
                      return item;
                    }).toList();
                    onConfirm(indices);
                    Navigator.pop(context);
                  },
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: List.generate(columns.length, (i) {
                final col = columns[i];
                return Expanded(
                  child: col.items.isEmpty
                      ? Center(
                          child: Text(
                            col.emptyHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : CupertinoPicker(
                          scrollController: controllers[i],
                          itemExtent: 36,
                          onSelectedItemChanged: (_) {},
                          children: col.items.map((item) {
                            return Center(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: item.enabled
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class CascadingPickerColumn {
  final List<CascadingPickerItem> items;
  final String emptyHint;

  const CascadingPickerColumn({
    required this.items,
    this.emptyHint = '-',
  });
}

class CascadingPickerItem {
  final String key;
  final String label;
  final bool enabled;

  const CascadingPickerItem({
    required this.key,
    required this.label,
    this.enabled = true,
  });
}
