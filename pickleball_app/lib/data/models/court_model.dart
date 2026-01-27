class CourtModel {
  final int id;
  final String name;
  final String? description;
  final double pricePerHour;
  final bool isAvailable;
  final String? imageUrl;
  final int? maxPlayers;

  const CourtModel({
    required this.id,
    required this.name,
    this.description,
    required this.pricePerHour,
    this.isAvailable = true,
    this.imageUrl,
    this.maxPlayers,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      pricePerHour:
          (json['pricePerHour'] as num?)?.toDouble() ??
          (json['price_per_hour'] as num?)?.toDouble() ??
          0,
      isAvailable:
          json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      maxPlayers: json['maxPlayers'] as int? ?? json['max_players'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'pricePerHour': pricePerHour,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
    'maxPlayers': maxPlayers,
  };
}
