class Sector {
  final String code;
  final String name;

  const Sector({required this.code, required this.name});

  String get displayName => '$name ($code)';

  // List of all available sectors
  static const List<Sector> allSectors = [
    Sector(code: '001', name: 'Head Quarters'),
    Sector(code: '002', name: 'Agriculture'),
    Sector(code: '003', name: 'Education'),
    Sector(code: '004', name: 'Health'),
    Sector(code: '005', name: 'Youth'),
    Sector(code: '006', name: 'Fisheries'),
    Sector(code: '007', name: 'Labour'),
    Sector(code: '008', name: 'Forest'),
    Sector(code: '000', name: 'Other'),
  ];

  // Get sector by code
  static Sector? getByCode(String code) {
    try {
      return allSectors.firstWhere((sector) => sector.code == code);
    } catch (e) {
      return null;
    }
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  factory Sector.fromJson(Map<String, dynamic> json) {
    return Sector(code: json['code'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sector && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
