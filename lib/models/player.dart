class Player {
  final int id;
  final String name;
  final int age;
  final int totalScoreYearly;
  final int totalScoreDaily;
  final String bestPerformance;
  final int wickets;

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.totalScoreYearly,
    required this.totalScoreDaily,
    required this.bestPerformance,
    required this.wickets,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      age: int.parse(json['age']),
      totalScoreYearly: int.parse(json['total_score_yearly']),
      totalScoreDaily: int.parse(json['total_score_daily']),
      bestPerformance: json['best_performance'],
      wickets: int.parse(json['wickets']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age.toString(),
      'total_score_yearly': totalScoreYearly.toString(),
      'total_score_daily': totalScoreDaily.toString(),
      'best_performance': bestPerformance,
      'wickets': wickets.toString(),
    };
  }
}
