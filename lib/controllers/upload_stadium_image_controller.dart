import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/services/services.dart';
import 'package:cricket/common/common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadStadiumImageController extends ChangeNotifier {
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  MatchModel? selectedMatch;
  List<MatchModel> matches = [];
  MatchController matchController;

  ApiCallStatus get apiStatus => _apiStatus;

  UploadStadiumImageController() : matchController = MatchController() {
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      await matchController.fetchPendingMatches();
      matches = matchController.matches;
      _apiStatus = ApiCallStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  void setSelectedMatch(MatchModel? match) {
    selectedMatch = match;
    notifyListeners();
  }

  Future<UploadResult> submitStadiumImage(
      {required String cricketMatchId,
      required String stadiumName,
      required FormData imageData}) async {
    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final formData = FormData.fromMap({
        'cricket_match_id': cricketMatchId,
        'stadium_name': stadiumName,
        'image': imageData.files.first.value,
      });

      final response = await ApiBaseHelper.postMultipart(
        '${dotenv.env['AUTH_APP']}stadiums',
        formData,
      );

      if (response.statusCode == 201) {
        _apiStatus = ApiCallStatus.success;
        notifyListeners();
        return UploadResult(
            success: true, message: 'Stadium image uploaded successfully');
      } else {
        throw Exception('Failed to upload image: ${response.data}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return UploadResult(
          success: false, message: 'Failed to upload image: ${e.message}');
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      notifyListeners();
      return UploadResult(
          success: false, message: 'Failed to upload image: $e');
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
}

class UploadResult {
  final bool success;
  final String message;

  UploadResult({required this.success, required this.message});
}
