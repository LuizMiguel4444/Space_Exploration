class NasaImage {
  final String title;
  final String description;
  final String imageUrl;
  final String date;

  NasaImage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
  });

  factory NasaImage.fromJson(Map<String, dynamic> json) {
    return NasaImage(
      title: json['title'] ?? 'No title',
      description: json['explanation'] ?? 'No description',
      imageUrl: json['hdurl'] ?? '',
      date: json['date'] ?? 'No date',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'hdurl': imageUrl,
      'explanation': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasaImage &&
      other.imageUrl == imageUrl &&
      other.title == title &&
      other.date == date &&
      other.description == description;
  }

  @override
  int get hashCode {
    return imageUrl.hashCode ^
      title.hashCode ^
      date.hashCode ^
      description.hashCode;
  }
}
