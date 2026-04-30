import 'dart:math';

import '../models/trip.dart';

class SeedDataGenerator {
  static final _random = Random(42);

  static const _stations = [
    '北京', '上海虹桥', '广州南', '深圳北', '武汉', '成都东', '重庆北',
    '杭州东', '南京南', '天津西', '西安北', '长沙南', '郑州东', '济南西',
    '青岛北', '沈阳北', '大连北', '哈尔滨西', '长春西', '昆明南', '贵阳北',
    '南宁东', '福州南', '厦门北', '南昌西', '合肥南', '太原南', '石家庄',
    '兰州西', '银川', '西宁', '乌鲁木齐', '拉萨', '海口东', '北海',
    '桂林北', '张家界西', '黄山北', '苏州北', '无锡东', '常州北',
    '徐州东', '宁波', '温州南', '珠海', '香港西九龙',
  ];

  static const _gStations = [
    '北京南', '上海虹桥', '广州南', '深圳北', '武汉', '成都东',
    '杭州东', '南京南', '西安北', '长沙南', '郑州东', '济南西',
    '合肥南', '南昌西', '天津西', '昆明南', '福州南', '厦门北',
  ];

  static const _gRoutes = [
    ('北京南', '上海虹桥', 553.0), ('上海虹桥', '北京南', 553.0),
    ('广州南', '深圳北', 74.5), ('深圳北', '广州南', 74.5),
    ('武汉', '广州南', 463.5), ('广州南', '武汉', 463.5),
    ('成都东', '重庆北', 154.0), ('重庆北', '成都东', 154.0),
    ('杭州东', '南京南', 117.5), ('南京南', '杭州东', 117.5),
    ('北京南', '杭州东', 587.0), ('杭州东', '北京南', 587.0),
    ('西安北', '成都东', 350.5), ('成都东', '西安北', 350.5),
    ('上海虹桥', '武汉', 336.0), ('武汉', '上海虹桥', 336.0),
    ('郑州东', '西安北', 239.0), ('西安北', '郑州东', 239.0),
    ('济南西', '青岛北', 121.5), ('青岛北', '济南西', 121.5),
    ('合肥南', '南昌西', 316.0), ('南昌西', '合肥南', 316.0),
    ('长沙南', '昆明南', 498.5), ('昆明南', '长沙南', 498.5),
    ('天津西', '哈尔滨西', 423.5),
    ('福州南', '厦门北', 93.5), ('厦门北', '福州南', 93.5),
  ];

  static const _dRoutes = [
    ('上海虹桥', '杭州东', 73.0), ('杭州东', '上海虹桥', 73.0),
    ('武汉', '宜昌东', 108.0), ('重庆北', '成都东', 96.5),
    ('南京南', '徐州东', 149.5), ('徐州东', '南京南', 149.5),
    ('西安北', '兰州西', 174.5), ('兰州西', '西安北', 174.5),
    ('南昌西', '长沙南', 157.0), ('长沙南', '南昌西', 157.0),
    ('郑州东', '武汉', 244.0), ('武汉', '郑州东', 244.0),
    ('广州南', '桂林北', 137.5), ('桂林北', '广州南', 137.5),
    ('合肥南', '杭州东', 203.5), ('杭州东', '合肥南', 203.5),
    ('济南西', '天津西', 129.5),
    ('贵阳北', '昆明南', 212.5), ('昆明南', '贵阳北', 212.5),
  ];

  static const _cRoutes = [
    ('北京南', '天津', 54.5), ('天津', '北京南', 54.5),
    ('北京南', '武清', 38.5),
    ('广州南', '珠海', 70.0), ('珠海', '广州南', 70.0),
    ('上海虹桥', '苏州', 39.5),
    ('成都东', '绵阳', 45.0),
    ('深圳北', '惠州南', 31.0),
    ('南京南', '扬州', 37.5),
    ('海口东', '三亚', 100.0),
  ];

  static const _zRoutes = [
    ('北京西', '长沙', 189.5), ('长沙', '北京西', 189.5),
    ('北京西', '西安', 148.5), ('西安', '北京西', 148.5),
    ('上海', '北京', 177.5), ('北京', '上海', 177.5),
    ('广州', '北京西', 253.0),
    ('西安', '上海', 179.5), ('上海', '西安', 179.5),
    ('杭州', '西安', 173.5),
    ('哈尔滨西', '北京', 156.5), ('北京', '哈尔滨西', 156.5),
  ];

  static const _tRoutes = [
    ('北京西', '南昌', 173.5), ('南昌', '北京西', 173.5),
    ('上海南', '南宁', 208.0), ('南宁', '上海南', 208.0),
    ('北京西', '成都西', 224.0),
    ('西安', '青岛北', 173.5),
    ('郑州', '乌鲁木齐', 416.5),
    ('哈尔滨西', '广州', 376.5),
    ('济南', '杭州', 124.5), ('杭州', '济南', 124.5),
    ('沈阳北', '太原', 173.5),
  ];

  static const _kRoutes = [
    ('北京', '张家界', 168.5), ('张家界', '北京', 168.5),
    ('上海', '黄山', 94.5), ('黄山', '上海', 94.5),
    ('广州', '南宁', 105.0), ('南宁', '广州', 105.0),
    ('成都', '西宁', 168.5),
    ('昆明', '大理', 64.0), ('大理', '昆明', 64.0),
    ('西安', '敦煌', 148.5),
    ('北京', '包头', 89.5),
    ('重庆北', '贵阳', 51.5), ('贵阳', '重庆北', 51.5),
    ('长沙', '张家界', 83.5),
    ('兰州', '拉萨', 240.0),
    ('武汉', '十堰', 69.5),
  ];

  static const _crModels = [
    ('CR', 'CR400', 'AF', 'Z', '高速动车'),
    ('CR', 'CR400', 'AF', null, '高速动车'),
    ('CR', 'CR400', 'BF', 'Z', '高速动车'),
    ('CR', 'CR400', 'BF', null, '高速动车'),
    ('CR', 'CR300', 'AF', null, '高速动车'),
    ('CR', 'CR300', 'BF', null, '高速动车'),
  ];

  static const _crhModels = [
    ('CRH', 'CRH380', 'A', null, '高速动车'),
    ('CRH', 'CRH380', 'B', null, '高速动车'),
    ('CRH', 'CRH380', 'CL', null, '高速动车'),
    ('CRH', 'CRH380', 'D', null, '高速动车'),
    ('CRH', 'CRH1', 'A', null, '动车'),
    ('CRH', 'CRH2', 'A', null, '动车'),
    ('CRH', 'CRH2', 'C', null, '高速动车'),
    ('CRH', 'CRH3', 'C', null, '高速动车'),
    ('CRH', 'CRH5', 'A', null, '动车'),
    ('CRH', 'CRH6', 'A', null, '城际'),
  ];

  static const _coachModels = [
    ('Coach', '25G', null, null, '快速'),
    ('Coach', '25K', null, null, '特快'),
    ('Coach', '25T', null, null, '直达'),
    ('Coach', '25B', null, null, '快速'),
  ];

  static const _bureaus = [
    ('京局', '京局京段'), ('京局', '京局津段'),
    ('上局', '上局沪段'), ('上局', '上局宁段'),
    ('广铁', '广铁广段'), ('广铁', '广铁沙段'),
    ('武局', '武局武段'),
    ('郑局', '郑局郑段'),
    ('南局', '南局昌段'), ('南局', '南局福段'),
    ('哈局', '哈局哈段'),
    ('沈局', '沈局沈段'),
    ('济局', '济局济段'), ('济局', '济局青段'),
    ('太局', '太局太段'),
    ('西局', '西局西段'),
    ('呼局', '呼局包段'),
  ];

  static const _seats = ['二等座', '一等座', '商务座', '硬座', '软座', '硬卧', '软卧'];
  static const _seatCategories = ['坐席', '卧席'];

  static List<Trip> generate(int count) {
    final trips = <Trip>[];
    final baseDate = DateTime(2024, 1, 1);

    for (int i = 0; i < count; i++) {
      trips.add(_generateOne(i, baseDate));
    }

    trips.sort((a, b) => b.departureTime.compareTo(a.departureTime));
    return trips;
  }

  static Trip _generateOne(int index, DateTime baseDate) {
    final dayOffset = index * 3 + _random.nextInt(2);
    final depDate = baseDate.add(Duration(days: dayOffset));
    final hour = 6 + _random.nextInt(17);
    final minute = _random.nextInt(12) * 5;
    final departureTime = DateTime(depDate.year, depDate.month, depDate.day, hour, minute);

    String trainNo, trainType, boardStation, alightStation, origStation, destStation;
    double basePrice;
    String categoryKey, platformKey;
    String? seriesKey, variantKey;

    final selector = _random.nextInt(100);

    if (selector < 30) {
      final route = _gRoutes[_random.nextInt(_gRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = _gStations[_random.nextInt(_gStations.length)];
      destStation = _gStations[_random.nextInt(_gStations.length)];
      if (origStation == destStation) destStation = _gStations[(_gStations.indexOf(destStation) + 1) % _gStations.length];
      trainNo = 'G${_random.nextInt(999) + 1}';
      basePrice = route.$3;
      trainType = '高速动车';
      final m = _random.nextBool() ? _crModels[_random.nextInt(_crModels.length)] : _crhModels[_random.nextInt(_crhModels.length)];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else if (selector < 50) {
      final route = _dRoutes[_random.nextInt(_dRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = _gStations[_random.nextInt(_gStations.length)];
      destStation = _gStations[_random.nextInt(_gStations.length)];
      if (origStation == destStation) destStation = _gStations[(_gStations.indexOf(destStation) + 1) % _gStations.length];
      trainNo = 'D${_random.nextInt(999) + 1}';
      basePrice = route.$3;
      trainType = '动车';
      final m = _crhModels[_random.nextInt(_crhModels.length)];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else if (selector < 60) {
      final route = _cRoutes[_random.nextInt(_cRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = route.$1;
      destStation = route.$2;
      trainNo = 'C${_random.nextInt(999) + 1}';
      basePrice = route.$3;
      trainType = '城际';
      final m = _crhModels.last;
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else if (selector < 70) {
      final route = _zRoutes[_random.nextInt(_zRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = route.$1;
      destStation = route.$2;
      trainNo = 'Z${_random.nextInt(99) + 1}';
      basePrice = route.$3;
      trainType = '直达';
      final m = _coachModels[2];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else if (selector < 80) {
      final route = _tRoutes[_random.nextInt(_tRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = route.$1;
      destStation = route.$2;
      trainNo = 'T${_random.nextInt(99) + 1}';
      basePrice = route.$3;
      trainType = '特快';
      final m = _coachModels[1];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else if (selector < 95) {
      final route = _kRoutes[_random.nextInt(_kRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = route.$1;
      destStation = route.$2;
      trainNo = 'K${_random.nextInt(999) + 1}';
      basePrice = route.$3;
      trainType = '快速';
      final m = _coachModels[_random.nextInt(2)];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    } else {
      final route = _kRoutes[_random.nextInt(_kRoutes.length)];
      boardStation = route.$1;
      alightStation = route.$2;
      origStation = route.$1;
      destStation = route.$2;
      trainNo = 'Y${_random.nextInt(99) + 1}';
      basePrice = route.$3;
      trainType = '旅游';
      final m = _coachModels[_random.nextInt(3)];
      categoryKey = m.$1; platformKey = m.$2; seriesKey = m.$3; variantKey = m.$4;
    }

    final price = basePrice + _random.nextDouble() * 20 - 10;
    final bureauEntry = _bureaus[_random.nextInt(_bureaus.length)];
    final seatIdx = _random.nextInt(_seatCategories.length);
    final seatCat = _seatCategories[seatIdx];
    final seatTypes = seatCat == '坐席'
        ? ['二等座', '一等座', '商务座', '硬座', '软座', '无座']
        : ['硬卧', '软卧', '二等卧', '一等卧', '高级软卧'];
    final seatType = seatTypes[_random.nextInt(seatTypes.length)];

    final hasArrival = _random.nextInt(100) < 75;
    DateTime? arrivalTime;
    if (hasArrival) {
      final durationMin = 30 + _random.nextInt(600);
      arrivalTime = departureTime.add(Duration(minutes: durationMin));
      if (_random.nextInt(100) < 10) {
        arrivalTime = arrivalTime!.add(const Duration(days: 1));
      }
    }

    final remarks = _random.nextInt(100) < 20
        ? const ['首发体验', '周末出行', '出差', '回家', '旅游观光', '出差往返'][_random.nextInt(6)]
        : '';

    return Trip(
      id: 0,
      trainNo: trainNo,
      boardStation: boardStation,
      alightStation: alightStation,
      originStation: origStation,
      destStation: destStation,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      price: double.parse(price.toStringAsFixed(1)),
      trainCategoryKey: categoryKey,
      trainPlatformKey: platformKey,
      trainSeriesKey: seriesKey,
      trainVariant: variantKey,
      bureauKey: bureauEntry.$1,
      sectionName: bureauEntry.$2,
      seatCategory: seatCat,
      seatType: seatType,
      trainType: trainType,
      remarks: remarks,
    );
  }
}
