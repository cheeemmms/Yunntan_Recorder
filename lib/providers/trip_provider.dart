import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/seed_data.dart';
import '../models/trip.dart';
import '../objectbox.g.dart';

final objectBoxProvider = FutureProvider<ObjectBoxInstance>((ref) async {
  return ObjectBoxInstance.create();
});

final tripListProvider = AsyncNotifierProvider<TripListNotifier, List<Trip>>(
  TripListNotifier.new,
);

class ObjectBoxInstance {
  late final Store store;

  ObjectBoxInstance._create(this.store);

  static Future<ObjectBoxInstance> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, 'train-ledger'),
    );
    return ObjectBoxInstance._create(store);
  }

  Box<Trip> get tripBox => store.box<Trip>();
}

class TripListNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final objectBoxAsync = ref.watch(objectBoxProvider);
    return objectBoxAsync.when(
      data: (ob) => ob.tripBox.getAll(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<int> addTrip(Trip trip) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    final id = objectBox.tripBox.put(trip);
    state = AsyncData(objectBox.tripBox.getAll());
    return id;
  }

  Future<bool> updateTrip(Trip trip) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    objectBox.tripBox.put(trip);
    state = AsyncData(objectBox.tripBox.getAll());
    return true;
  }

  Future<void> seedTestData() async {
    final objectBox = await ref.read(objectBoxProvider.future);
    final trips = SeedDataGenerator.generate(100);
    for (final trip in trips) {
      objectBox.tripBox.put(trip);
    }
    state = AsyncData(objectBox.tripBox.getAll());
  }

  Future<bool> deleteTrip(int id) async {
    final objectBox = await ref.read(objectBoxProvider.future);
    final success = objectBox.tripBox.remove(id);
    state = AsyncData(objectBox.tripBox.getAll());
    return success;
  }
}
