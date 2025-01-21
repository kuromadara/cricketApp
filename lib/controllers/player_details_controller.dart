import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/services/services.dart';

class PlayerDetailsController extends ChangeNotifier {
  Player? _player;
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  final int playerId;

  PlayerDetailsController(this.playerId);

  Player? get player => _player;
  ApiCallStatus get apiStatus => _apiStatus;

  Future<void> fetchPlayerDetails() async {
    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response = await ApiBaseHelper.get(
        '${dotenv.env['AUTH_APP']}players/$playerId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _player = Player.fromJson(data['data']);
        _apiStatus = ApiCallStatus.success;
      } else {
        _apiStatus = ApiCallStatus.error;
      }
    } on DioException catch (error) {
      String errorMessage = 'An error occurred';

      switch (error.type) {
        case DioExceptionType.connectionError:
          _apiStatus = ApiCallStatus.error;
          errorMessage = "No Internet connection or server is not reachable.";
          break;
        case DioExceptionType.badResponse:
          _apiStatus = ApiCallStatus.empty;
          errorMessage = "Player not found";
          break;
        case DioExceptionType.connectionTimeout:
          _apiStatus = ApiCallStatus.networkError;
          errorMessage = "Connection Timeout.";
          break;
        default:
          _apiStatus = ApiCallStatus.error;
      }
      debugPrint('Error fetching player details: $errorMessage');
    } finally {
      notifyListeners();
    }
  }
}
