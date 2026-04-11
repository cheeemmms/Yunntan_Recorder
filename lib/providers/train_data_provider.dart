import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/train_data_loader.dart';
import '../models/railway_bureau.dart';
import '../models/train_hierarchy.dart';

final trainDataLoaderProvider = Provider<TrainDataLoader>((ref) {
  return TrainDataLoader();
});

final trainHierarchyProvider =
    AsyncNotifierProvider<TrainHierarchyNotifier, TrainHierarchy>(
  TrainHierarchyNotifier.new,
);

class TrainHierarchyNotifier extends AsyncNotifier<TrainHierarchy> {
  @override
  Future<TrainHierarchy> build() async {
    final loader = ref.watch(trainDataLoaderProvider);
    return loader.loadTrainHierarchy();
  }
}

final railwayBureauProvider =
    AsyncNotifierProvider<RailwayBureauNotifier, RailwayBureauData>(
  RailwayBureauNotifier.new,
);

class RailwayBureauNotifier extends AsyncNotifier<RailwayBureauData> {
  @override
  Future<RailwayBureauData> build() async {
    final loader = ref.watch(trainDataLoaderProvider);
    return loader.loadRailwayBureau();
  }
}
