class TrainSeries {
  final String key;
  final String label;
  final bool selectable;
  final List<String> variants;

  const TrainSeries({
    required this.key,
    required this.label,
    required this.selectable,
    required this.variants,
  });

  factory TrainSeries.fromJson(String key, Map<String, dynamic> json) {
    return TrainSeries(
      key: key,
      label: json['label'] as String,
      selectable: json['selectable'] as bool? ?? false,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class TrainPlatform {
  final String key;
  final String label;
  final Map<String, TrainSeries> series;

  const TrainPlatform({
    required this.key,
    required this.label,
    required this.series,
  });

  factory TrainPlatform.fromJson(String key, Map<String, dynamic> json) {
    final seriesMap = <String, TrainSeries>{};
    final seriesJson = json['series'] as Map<String, dynamic>? ?? {};
    seriesJson.forEach((seriesKey, seriesValue) {
      seriesMap[seriesKey] = TrainSeries.fromJson(
        seriesKey,
        seriesValue as Map<String, dynamic>,
      );
    });
    return TrainPlatform(
      key: key,
      label: json['label'] as String,
      series: seriesMap,
    );
  }
}

class TrainCategory {
  final String key;
  final String label;
  final String type;
  final bool developing;
  final Map<String, TrainPlatform> platforms;

  const TrainCategory({
    required this.key,
    required this.label,
    required this.type,
    this.developing = false,
    required this.platforms,
  });

  factory TrainCategory.fromJson(String key, Map<String, dynamic> json) {
    final platformMap = <String, TrainPlatform>{};
    final platformsJson = json['platforms'] as Map<String, dynamic>? ?? {};
    platformsJson.forEach((platformKey, platformValue) {
      platformMap[platformKey] = TrainPlatform.fromJson(
        platformKey,
        platformValue as Map<String, dynamic>,
      );
    });
    return TrainCategory(
      key: key,
      label: json['label'] as String,
      type: json['type'] as String,
      developing: json['developing'] as bool? ?? false,
      platforms: platformMap,
    );
  }
}

class TrainHierarchy {
  final Map<String, TrainCategory> categories;

  const TrainHierarchy({required this.categories});

  factory TrainHierarchy.fromJson(Map<String, dynamic> json) {
    final categoryMap = <String, TrainCategory>{};
    json.forEach((key, value) {
      categoryMap[key] = TrainCategory.fromJson(
        key,
        value as Map<String, dynamic>,
      );
    });
    return TrainHierarchy(categories: categoryMap);
  }

  List<TrainCategory> get categoryList => categories.values.toList();

  List<TrainCategory> get availableCategories =>
      categories.values.where((c) => !c.developing).toList();

  TrainCategory? getCategory(String key) => categories[key];
}
