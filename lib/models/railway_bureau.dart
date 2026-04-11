class BureauSection {
  final String name;
  final String category;

  const BureauSection({
    required this.name,
    required this.category,
  });

  factory BureauSection.fromJson(Map<String, dynamic> json) {
    return BureauSection(
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }
}

class RailwayBureau {
  final String key;
  final List<BureauSection> sections;

  const RailwayBureau({
    required this.key,
    required this.sections,
  });

  factory RailwayBureau.fromJson(String key, Map<String, dynamic> json) {
    final sectionsList = (json['sections'] as List<dynamic>)
        .map((e) => BureauSection.fromJson(e as Map<String, dynamic>))
        .toList();
    return RailwayBureau(key: key, sections: sectionsList);
  }

  List<BureauSection> get passengerSections =>
      sections.where((s) => s.category == '客运').toList();
}

class RailwayBureauData {
  final Map<String, RailwayBureau> bureaus;

  const RailwayBureauData({required this.bureaus});

  factory RailwayBureauData.fromJson(Map<String, dynamic> json) {
    final bureauMap = <String, RailwayBureau>{};
    json.forEach((key, value) {
      bureauMap[key] = RailwayBureau.fromJson(
        key,
        value as Map<String, dynamic>,
      );
    });
    return RailwayBureauData(bureaus: bureauMap);
  }

  List<RailwayBureau> get bureauList => bureaus.values.toList();

  List<String> get bureauNames => bureaus.keys.toList();

  RailwayBureau? getBureau(String key) => bureaus[key];
}
