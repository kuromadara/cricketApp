import 'dart:convert';

class MatchModel {
  final int id;
  final TeamData team1;
  final TeamData team2;
  final String? result;
  final String status;

  MatchModel({
    required this.id,
    required this.team1,
    required this.team2,
    this.result,
    required this.status,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      team1: TeamData.fromJson(json['team1']),
      team2: TeamData.fromJson(json['team2']),
      result: json['result'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'result': result,
      'status': status,
    };
  }
}

class TeamData {
  final int id;
  final String name;
  final List<int> players;

  TeamData({
    required this.id,
    required this.name,
    required this.players,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      id: json['id'],
      name: json['name'],
      players: List<int>.from(json['players'] is String
          ? jsonDecode(json['players'])
          : json['players']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players,
    };
  }
}
