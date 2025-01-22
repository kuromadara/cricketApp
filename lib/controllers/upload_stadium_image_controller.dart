import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/services/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadStadiumImageController extends ChangeNotifier {
  MatchModel? selectedMatch;
  List<MatchModel> matches = [];
  MatchController matchController;

  UploadStadiumImageController() : matchController = MatchController() {
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    await matchController.fetchPendingMatches();
    matches = matchController.matches;
    notifyListeners();
  }

  void setSelectedMatch(MatchModel? match) {
    selectedMatch = match;
    notifyListeners();
  }

  Future<void> submitStadiumImage({
    required String cricketMatchId, 
    required String stadiumName, 
    required FormData imageData
  }) async {
    try {
      // Prepare the form data
      final formData = FormData.fromMap({
        'cricket_match_id': cricketMatchId,
        'stadium_name': stadiumName,
        'image': imageData.files.first.value,
      });

      // Call the API to submit the stadium image
      final response = await ApiBaseHelper.postMultipart(
        '${dotenv.env['AUTH_APP']}stadiums',
        formData,
      );
      // Handle success or failure
      if (response.statusCode == 201) {
        // Handle success
        notifyListeners();
      } else {
        throw Exception('Failed to upload image: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
