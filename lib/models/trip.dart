import 'package:objectbox/objectbox.dart';

@Entity()
class Trip {
  @Id()
  int id = 0;

  String trainNo = '';
  String boardStation = '';
  String alightStation = '';
  String originStation = '';
  String destStation = '';

  @Property(type: PropertyType.date)
  DateTime departureTime = DateTime.now();

  double price = 0;

  String trainCategoryKey = '';
  String? trainPlatformKey;
  String? trainSeriesKey;
  String? trainVariant;

  String? bureauKey;
  String? sectionName;

  String seatCategory = '坐席';
  String seatType = '二等座';
  String trainType = '';
  String remarks = '';

  Trip({
    this.id = 0,
    this.trainNo = '',
    this.boardStation = '',
    this.alightStation = '',
    this.originStation = '',
    this.destStation = '',
    DateTime? departureTime,
    this.price = 0,
    this.trainCategoryKey = '',
    this.trainPlatformKey,
    this.trainSeriesKey,
    this.trainVariant,
    this.bureauKey,
    this.sectionName,
    this.seatCategory = '坐席',
    this.seatType = '二等座',
    this.trainType = '',
    this.remarks = '',
  }) : departureTime = departureTime ?? DateTime.now();
}
