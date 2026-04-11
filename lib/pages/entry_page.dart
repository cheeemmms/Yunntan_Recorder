import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/railway_bureau.dart';
import '../models/train_hierarchy.dart';
import '../providers/train_data_provider.dart';
import '../widgets/bureau_picker.dart';
import '../widgets/train_model_picker.dart';

class EntryPage extends ConsumerStatefulWidget {
  const EntryPage({super.key});

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  final _trainNoCtrl = TextEditingController();
  final _boardStationCtrl = TextEditingController();
  final _alightStationCtrl = TextEditingController();
  final _originStationCtrl = TextEditingController();
  final _destStationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  TrainModelPickerResult? _trainModel;
  BureauPickerResult? _bureau;
  String _seatCategory = '坐席';
  String _seatType = '二等座';
  DateTime _departureTime = DateTime.now();

  static const _seatCategories = ['坐席', '卧席'];
  static const _allSeatTypes = {
    '坐席': ['无座', '硬座', '软座', '二等座', '一等座', '商务座'],
    '卧席': ['硬卧', '软卧', '二等卧', '一等卧', '高级软卧'],
  };

  bool get _isCoach => _trainModel?.category.type == 'Coach';

  List<String> _filteredSeatTypes(String category) {
    final all = _allSeatTypes[category]!;
    if (_isCoach) return all;
    return all.where((t) => !{'硬座', '软座', '硬卧', '软卧'}.contains(t)).toList();
  }

  String _inferTrainType(String trainNo) {
    if (trainNo.isEmpty) return '';
    final first = trainNo[0].toUpperCase();
    const map = {
      'G': '高速动车', 'D': '动车', 'C': '城际',
      'Z': '直达', 'T': '特快', 'K': '快速',
      'Y': '旅游', 'S': '市郊',
    };
    return map[first] ?? '其他';
  }

  @override
  void dispose() {
    _trainNoCtrl.dispose();
    _boardStationCtrl.dispose();
    _alightStationCtrl.dispose();
    _originStationCtrl.dispose();
    _destStationCtrl.dispose();
    _priceCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hierarchyAsync = ref.watch(trainHierarchyProvider);
    final bureauAsync = ref.watch(railwayBureauProvider);
    final trainType = _inferTrainType(_trainNoCtrl.text);

    return Scaffold(
      appBar: AppBar(title: const Text('录入运转')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(theme, '基本信息', [
              _buildTextField('车次', _trainNoCtrl, hint: '如 G1', suffix: trainType.isNotEmpty ? Chip(label: Text(trainType, style: const TextStyle(fontSize: 12))) : null),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildTextField('乘车站', _boardStationCtrl, hint: '上车站')),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 20)),
                Expanded(child: _buildTextField('到达站', _alightStationCtrl, hint: '下车站')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildTextField('始发站', _originStationCtrl, hint: '全程起点')),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 20)),
                Expanded(child: _buildTextField('终到站', _destStationCtrl, hint: '全程终点')),
              ]),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '运转详情', [
              _buildTimeField(theme),
              const SizedBox(height: 12),
              _buildTextField('票价（元）', _priceCtrl, hint: '0.00', keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '车型与担当', [
              hierarchyAsync.when(
                data: (hierarchy) => _buildPickerField(
                  theme, '车底型号',
                  _trainModel?.displayLabel ?? '请选择',
                  () => TrainModelPicker.show(
                    context: context,
                    hierarchy: hierarchy,
                    initialValue: _trainModel,
                    onConfirm: (r) => setState(() {
                      _trainModel = r;
                      if (!_isCoach) {
                        final valid = _filteredSeatTypes(_seatCategory);
                        if (!valid.contains(_seatType)) {
                          _seatType = valid.first;
                        }
                      }
                    }),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('加载失败'),
              ),
              const SizedBox(height: 12),
              bureauAsync.when(
                data: (bureau) => _buildPickerField(
                  theme, '乘务担当',
                  _bureau != null ? '${_bureau!.bureauKey} ${_bureau!.section.name}' : '请选择',
                  () => BureauPicker.show(
                    context: context,
                    data: bureau,
                    initialValue: _bureau,
                    onConfirm: (r) => setState(() => _bureau = r),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('加载失败'),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '席位', [
              Row(children: [
                Expanded(child: _buildDropdown(theme, '类别', _seatCategory, _seatCategories, (v) {
                  setState(() {
                    _seatCategory = v!;
                    _seatType = _filteredSeatTypes(_seatCategory).first;
                  });
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown(theme, '类型', _seatType, _filteredSeatTypes(_seatCategory), (v) {
                  setState(() => _seatType = v!);
                })),
              ]),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '备注', [
              TextField(
                controller: _remarksCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '自由记录...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('保存功能将在第6步实现')),
                  );
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {String? hint, Widget? suffix, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: suffix != null ? (_) => setState(() {}) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPickerField(ThemeData theme, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: theme.textTheme.bodyLarge),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _departureTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_departureTime),
          );
          if (time != null) {
            setState(() {
              _departureTime = DateTime(
                picked.year, picked.month, picked.day,
                time.hour, time.minute,
              );
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '出发时间',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_departureTime.year}-${_departureTime.month.toString().padLeft(2, '0')}-${_departureTime.day.toString().padLeft(2, '0')} ${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}', style: theme.textTheme.bodyLarge),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
