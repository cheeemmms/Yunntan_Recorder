import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/railway_bureau.dart';
import '../models/train_hierarchy.dart';
import '../models/trip.dart';
import '../providers/train_data_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/bureau_picker.dart';
import '../widgets/train_model_picker.dart';

class EntryPage extends ConsumerStatefulWidget {
  final Trip? trip;

  const EntryPage({super.key, this.trip});

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
  DateTime? _arrivalTime;
  bool _initDone = false;

  bool get _isEditing => widget.trip != null && widget.trip!.id > 0;

  static const _seatCategories = ['坐席', '卧席'];
  static const _allSeatTypes = {
    '坐席': ['无座', '硬座', '软座', '二等座', '一等座', '商务座'],
    '卧席': ['硬卧', '软卧', '二等卧', '一等卧', '高级软卧'],
  };

  bool get _isCoach => _trainModel?.category.type == 'Coach';
  bool get _isEMU => _trainModel?.category.type == 'EMU';

  List<String> _filteredSeatTypes(String category) {
    final all = _allSeatTypes[category]!;
    if (_trainModel == null || _isCoach) return all;
    if (_isEMU)
      return all.where((t) => !{'硬座', '软座', '硬卧', '软卧'}.contains(t)).toList();
    return all;
  }

  String _inferTrainType(String trainNo) {
    if (trainNo.isEmpty) return '';
    final first = trainNo[0].toUpperCase();
    const map = {
      'G': '高速动车',
      'D': '动车',
      'C': '城际',
      'Z': '直达',
      'T': '特快',
      'K': '快速',
      'Y': '旅游',
      'S': '市郊',
    };
    return map[first] ?? '其他';
  }

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    if (trip != null) {
      _trainNoCtrl.text = trip.trainNo;
      _boardStationCtrl.text = trip.boardStation;
      _alightStationCtrl.text = trip.alightStation;
      _originStationCtrl.text = trip.originStation;
      _destStationCtrl.text = trip.destStation;
      _departureTime = trip.departureTime;
      _arrivalTime = trip.arrivalTime;
      _priceCtrl.text = trip.price > 0
          ? trip.price.toStringAsFixed(
              trip.price.truncateToDouble() == trip.price ? 0 : 2,
            )
          : '';
      _seatCategory = trip.seatCategory;
      _seatType = trip.seatType;
      _remarksCtrl.text = trip.remarks;
    }
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

    if (_isEditing &&
        !_initDone &&
        hierarchyAsync.hasValue &&
        bureauAsync.hasValue) {
      _initDone = true;
      final trip = widget.trip!;
      final hierarchy = hierarchyAsync.value!;
      final bureauData = bureauAsync.value!;

      final category = hierarchy.getCategory(trip.trainCategoryKey);
      if (category != null) {
        TrainPlatform? platform;
        TrainSeries? series;
        if (trip.trainPlatformKey != null) {
          platform = category.platforms[trip.trainPlatformKey];
        }
        if (platform != null && trip.trainSeriesKey != null) {
          series = platform.series[trip.trainSeriesKey];
        }
        if (series != null || platform != null) {
          _trainModel = TrainModelPickerResult(
            category: category,
            platform: platform,
            series: series,
            variant: trip.trainVariant,
          );
        }
      }

      if (trip.bureauKey != null) {
        final bureau = bureauData.getBureau(trip.bureauKey!);
        if (bureau != null && trip.sectionName != null) {
          final section = bureau.passengerSections
              .cast<BureauSection?>()
              .firstWhere(
                (s) => s?.name == trip.sectionName,
                orElse: () => null,
              );
          if (section != null) {
            _bureau = BureauPickerResult(
              bureauKey: trip.bureauKey!,
              section: section,
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑运转' : '录入运转')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(theme, '基本信息', [
              _buildTextField(
                '车次',
                _trainNoCtrl,
                hint: '如 G1',
                suffix: trainType.isNotEmpty
                    ? Chip(
                        label: Text(
                          trainType,
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      '乘车站',
                      _boardStationCtrl,
                      hint: '上车站',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 20),
                  ),
                  Expanded(
                    child: _buildTextField(
                      '到达站',
                      _alightStationCtrl,
                      hint: '下车站',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      '始发站',
                      _originStationCtrl,
                      hint: '全程起点',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 20),
                  ),
                  Expanded(
                    child: _buildTextField(
                      '终到站',
                      _destStationCtrl,
                      hint: '全程终点',
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '运转详情', [
              _buildTimeField(theme),
              const SizedBox(height: 12),
              _buildArrivalTimeField(theme),
              const SizedBox(height: 12),
              _buildTextField(
                '票价（元）',
                _priceCtrl,
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '车型与担当', [
              hierarchyAsync.when(
                data: (hierarchy) => _buildPickerField(
                  theme,
                  '车底型号',
                  _trainModel?.displayLabel ?? '请选择',
                  () => TrainModelPicker.show(
                    context: context,
                    hierarchy: hierarchy,
                    initialValue: _trainModel,
                    onConfirm: (r) => setState(() {
                      _trainModel = r;
                      final valid = _filteredSeatTypes(_seatCategory);
                      if (!valid.contains(_seatType)) {
                        _seatType = valid.first;
                      }
                    }),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => const Text('加载失败'),
              ),
              const SizedBox(height: 12),
              bureauAsync.when(
                data: (bureau) => _buildPickerField(
                  theme,
                  '乘务担当',
                  _bureau != null
                      ? '${_bureau!.bureauKey} ${_bureau!.section.name}'
                      : '请选择',
                  () => BureauPicker.show(
                    context: context,
                    data: bureau,
                    initialValue: _bureau,
                    onConfirm: (r) => setState(() => _bureau = r),
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => const Text('加载失败'),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '席位', [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      theme,
                      '类别',
                      _seatCategory,
                      _seatCategories,
                      (v) {
                        setState(() {
                          _seatCategory = v!;
                          _seatType = _filteredSeatTypes(_seatCategory).first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      theme,
                      '类型',
                      _seatType,
                      _filteredSeatTypes(_seatCategory),
                      (v) {
                        setState(() => _seatType = v!);
                      },
                      key: ValueKey(
                        'seat_${_trainModel?.category.type ?? 'none'}_${_seatCategory}_${_filteredSeatTypes(_seatCategory).length}',
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(theme, '备注', [
              TextField(
                controller: _remarksCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '自由记录...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (_trainNoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请输入车次')));
                    return;
                  }

                  final trip = Trip(
                    id: _isEditing ? widget.trip!.id : 0,
                    trainNo: _trainNoCtrl.text.trim(),
                    boardStation: _boardStationCtrl.text.trim(),
                    alightStation: _alightStationCtrl.text.trim(),
                    originStation: _originStationCtrl.text.trim(),
                    destStation: _destStationCtrl.text.trim(),
                    departureTime: _departureTime,
                    arrivalTime: _arrivalTime,
                    price: double.tryParse(_priceCtrl.text) ?? 0,
                    trainCategoryKey:
                        _trainModel?.category.key ??
                        (_isEditing ? widget.trip!.trainCategoryKey : ''),
                    trainPlatformKey:
                        _trainModel?.platform?.key ??
                        (_isEditing ? widget.trip!.trainPlatformKey : null),
                    trainSeriesKey:
                        _trainModel?.series?.key ??
                        (_isEditing ? widget.trip!.trainSeriesKey : null),
                    trainVariant:
                        _trainModel?.variant ??
                        (_isEditing ? widget.trip!.trainVariant : null),
                    bureauKey:
                        _bureau?.bureauKey ??
                        (_isEditing ? widget.trip!.bureauKey : null),
                    sectionName:
                        _bureau?.section.name ??
                        (_isEditing ? widget.trip!.sectionName : null),
                    seatCategory: _seatCategory,
                    seatType: _seatType,
                    trainType: _inferTrainType(_trainNoCtrl.text.trim()),
                    remarks: _remarksCtrl.text.trim(),
                  );

                  if (_isEditing) {
                    await ref.read(tripListProvider.notifier).updateTrip(trip);
                  } else {
                    await ref.read(tripListProvider.notifier).addTrip(trip);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isEditing ? '更新成功' : '保存成功')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(_isEditing ? '更新' : '保存'),
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
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
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

  Widget _buildPickerField(
    ThemeData theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
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
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
                picked.year,
                picked.month,
                picked.day,
                time.hour,
                time.minute,
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
            Text(
              '${_departureTime.year}-${_departureTime.month.toString().padLeft(2, '0')}-${_departureTime.day.toString().padLeft(2, '0')} ${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodyLarge,
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalTimeField(ThemeData theme) {
    final hasArrival = _arrivalTime != null;
    final displayText = hasArrival
        ? '${_arrivalTime!.year}-${_arrivalTime!.month.toString().padLeft(2, '0')}-${_arrivalTime!.day.toString().padLeft(2, '0')} ${_arrivalTime!.hour.toString().padLeft(2, '0')}:${_arrivalTime!.minute.toString().padLeft(2, '0')}'
        : '未填写';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _arrivalTime ?? _departureTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_arrivalTime ?? _departureTime),
          );
          if (time != null) {
            setState(() {
              _arrivalTime = DateTime(
                picked.year,
                picked.month,
                picked.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '到达时间',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: hasArrival ? null : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasArrival)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _arrivalTime = null),
                  ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    ThemeData theme,
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged, {
    Key? key,
  }) {
    return DropdownButtonFormField<String>(
      key: key,
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
