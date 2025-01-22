import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/services/services.dart';
import 'package:cricket/models/models.dart';
import 'package:pretty_logger/pretty_logger.dart';

class StadiumImageController extends ChangeNotifier {
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  String? _stadiumImageUrl;

  ApiCallStatus get apiStatus => _apiStatus;
  String? get stadiumImageUrl => _stadiumImageUrl;
  MatchModel? _selectedMatch;

  Future<void> submitStadiumImage({
    required int cricketMatchId, 
    required String stadiumName, 
    required FormData imageData
  }) async {
    try {
      // Prepare the form data
      final formData = FormData.fromMap({
        'cricket_match_id': cricketMatchId.toString(),
        'stadium_name': stadiumName,
        'image': imageData.files.first,
      });

      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response = await ApiBaseHelper.post(
        '${dotenv.env['AUTH_APP']}stadiums',
        formData,
      );

      if (response.statusCode == 201) {
        _apiStatus = ApiCallStatus.success;
        _stadiumImageUrl = response.data['data']['image_url'];
        PLog.info('Stadium image submitted successfully');
      } else {
        _apiStatus = ApiCallStatus.error;
        PLog.error('Failed to submit stadium image. Response: ${response.data}');
        throw Exception('Failed to submit stadium image');
      }
      notifyListeners();
    } on DioException catch (error) {
      _apiStatus = ApiCallStatus.error;
      _handleDioError(error);
      rethrow;
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      PLog.error('Error submitting stadium image: $e');
      notifyListeners();
      rethrow;
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

  

  // Reset the controller state
  void reset() {
    _apiStatus = ApiCallStatus.loading;
    _stadiumImageUrl = null;
    notifyListeners();
  }
}