class Location {
  int? idLocation;
  String? locationName;
  String? lat;
  String? lng;

  Location.fromJsonMap(Map<String, dynamic> map)
      : idLocation = map["idLocation"],
        locationName = map["locationName"],
        lat = map["lat"],
        lng = map["lng"];
}
