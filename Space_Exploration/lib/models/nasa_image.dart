class NasaImage {
  final String title;
  final String description;
  final String imageUrlHD;
  final String imageUrl;
  final String date;

  NasaImage({
    required this.title,
    required this.description,
    required this.imageUrlHD,
    required this.imageUrl,
    required this.date,
  });

  factory NasaImage.fromJson(Map<String, dynamic> json) {
    return NasaImage(
      title: json['title'] ?? 'No title',
      description: json['explanation'] ?? 'No description',
      imageUrlHD: json['hdurl'] ?? '',
      imageUrl: json['url'] ?? '',
      date: json['date'] ?? 'No date',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'hdurl': imageUrlHD,
      'url': imageUrl,
      'explanation': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NasaImage &&
      other.imageUrlHD == imageUrlHD &&
      other.imageUrl == imageUrl &&
      other.title == title &&
      other.date == date &&
      other.description == description;
  }

  @override
  int get hashCode {
    return imageUrlHD.hashCode ^
      imageUrl.hashCode ^
      title.hashCode ^
      date.hashCode ^
      description.hashCode;
  }
}
