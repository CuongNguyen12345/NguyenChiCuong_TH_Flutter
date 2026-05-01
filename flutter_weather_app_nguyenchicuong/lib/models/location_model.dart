class LocationModel {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  LocationModel({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  LocationModel copyWith({
    String? cityName,
    String? country,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return LocationModel(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_favorite': isFavorite,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      cityName: json['city_name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }
}
