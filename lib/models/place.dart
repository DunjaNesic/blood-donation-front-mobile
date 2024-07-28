class Place {
  final int placeID;
  final String placeName;

  Place({required this.placeID, required this.placeName});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeID: json['placeID'] ?? 0,
      placeName: json['placeName'],
    );
  }

  @override
  String toString() {
    return placeName;
  }

}
