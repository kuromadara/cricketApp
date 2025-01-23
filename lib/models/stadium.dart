class StadiumModel {
  final int id;
  final String stadiumName;
  final String image;

  StadiumModel(
      {required this.id, required this.stadiumName, required this.image});

  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    return StadiumModel(
      id: json['id'],
      stadiumName: json['stadium_name'],
      image: json['image'],
    );
  }
}
