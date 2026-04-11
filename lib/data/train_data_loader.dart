import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/railway_bureau.dart';
import '../models/train_hierarchy.dart';

class TrainDataLoader {
  static const String _hierarchyPath = 'assets/data/train_hierarchy.json';
  static const String _bureauPath = 'assets/data/railway_bureau.json';

  Future<TrainHierarchy> loadTrainHierarchy() async {
    final jsonStr = await rootBundle.loadString(_hierarchyPath);
    final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
    return TrainHierarchy.fromJson(jsonData);
  }

  Future<RailwayBureauData> loadRailwayBureau() async {
    final jsonStr = await rootBundle.loadString(_bureauPath);
    final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
    return RailwayBureauData.fromJson(jsonData);
  }

  Future<({TrainHierarchy hierarchy, RailwayBureauData bureau})> loadAll() async {
    final results = await Future.wait([
      loadTrainHierarchy(),
      loadRailwayBureau(),
    ]);
    return (
      hierarchy: results[0] as TrainHierarchy,
      bureau: results[1] as RailwayBureauData,
    );
  }
}
