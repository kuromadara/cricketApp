import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/services/services.dart';
import 'package:pretty_logger/pretty_logger.dart';

class MatchController extends ChangeNotifier {
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  List<MatchModel> _matches = [];
  MatchModel? _selectedMatch;

  ApiCallStatus get apiStatus => _apiStatus;
  List<MatchModel> get matches => _matches;
  MatchModel? get selectedMatch => _selectedMatch;

  Future<void> fetchPendingMatches() async {
    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response = await ApiBaseHelper.get(
        '${dotenv.env['AUTH_APP']}matches?status=pending',
      );

      if (response != null) {
       

        if (response.statusCode == 200) {
      final data = response.data['data']; // Extract the 'data' key which contains the list of matches
        // Ensure data is a List before processing
        // if (data is List) {
          _matches = (data as List).map((matchJson) => MatchModel.fromJson(matchJson)).toList();
          // _matches =
          //     data.map((matchJson) => MatchModel.fromJson(matchJson)).toList();

          _apiStatus =
              _matches.isNotEmpty ? ApiCallStatus.success : ApiCallStatus.empty;
        } else {
          // Handle unexpected response structure
          
          _apiStatus = ApiCallStatus.error;
        }
      } else {
        _apiStatus = ApiCallStatus.error;
      }
      notifyListeners();
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (e) {
      print('Error: $e');
      _apiStatus = ApiCallStatus.error;
      notifyListeners();
    }
  }

  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        _apiStatus = ApiCallStatus.networkError;
        break;
      case DioExceptionType.badResponse:
        _apiStatus = ApiCallStatus.empty;
        break;
      default:
        _apiStatus = ApiCallStatus.error;
    }
    notifyListeners();
  }

  Future<void> submitMatchDetails(Map<String, dynamic> matchDetails) async {
    try {
      // Convert numeric values to strings
      final formattedMatchDetails = {
        'cricket_match_id': matchDetails['cricket_match_id'].toString(),
        'player_id': matchDetails['player_id'].toString(),
        'score': matchDetails['score'].toString(),
        'wickets': matchDetails['wickets'].toString(),
        'ball': matchDetails['ball'].toString(),
        'runs': matchDetails['runs'].toString(),
        'extras': matchDetails['extras'].toString(),
        'status': matchDetails['status'],
      };

      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response = await ApiBaseHelper.post(
        '${dotenv.env['AUTH_APP']}match-details',
        formattedMatchDetails,
      );

      if (response.statusCode == 200) {
        _apiStatus = ApiCallStatus.success;
        // Optional: You might want to update the matches list or perform additional actions
        PLog.info('Match details submitted successfully: $formattedMatchDetails');
      } else {
        _apiStatus = ApiCallStatus.error;
        PLog.error('Failed to submit match details. Response: ${response.data}');
        throw Exception('Failed to submit match details');
      }
      notifyListeners();
    } on DioException catch (error) {
      _apiStatus = ApiCallStatus.error;
      // PrettyLogger.error('Dio Error submitting match details: ${error.response?.data}');
      _handleDioError(error);
      rethrow;
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      PLog.error('Error submitting match details: $e');
      notifyListeners();
      rethrow;
    }
  }

  void setSelectedMatch(MatchModel? match) {
    _selectedMatch = match;
    notifyListeners();
  }
}
