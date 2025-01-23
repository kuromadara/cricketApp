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
  bool _isLoading = false;

  ApiCallStatus get apiStatus => _apiStatus;
  String? get stadiumImageUrl => _stadiumImageUrl;
  MatchModel? _selectedMatch;

  List<StadiumModel> _stadiums = [];

  List<StadiumModel> get stadiums => _stadiums;

  Future<void> submitStadiumImage(
      {required int cricketMatchId,
      required String stadiumName,
      required FormData imageData}) async {
    try {
      final formData = FormData.fromMap({
        'cricket_match_id': cricketMatchId.toString(),
        'stadium_name': stadiumName,
        'image': imageData.files.first.value,
      });

      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response = await ApiBaseHelper.postMultipart(
        '${dotenv.env['AUTH_APP']}stadiums',
        formData,
      );

      if (response.statusCode == 201) {
        _apiStatus = ApiCallStatus.success;
        _stadiumImageUrl = response.data['data']['image_url'];
        PLog.info('Stadium image submitted successfully');
      } else {
        _apiStatus = ApiCallStatus.error;
        PLog.error(
            'Failed to submit stadium image. Response: ${response.data}');
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

  Future<void> fetchStadiums() async {
    if (_isLoading || _apiStatus == ApiCallStatus.success) return;
    _isLoading = true;
    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      final response =
          await ApiBaseHelper.get('${dotenv.env['AUTH_APP']}stadiums');

      if (response.statusCode == 200) {
        final List<dynamic> stadiumsJson = response.data['data'];
        _stadiums =
            stadiumsJson.map((json) => StadiumModel.fromJson(json)).toList();
        _apiStatus = ApiCallStatus.success;
      } else {
        PLog.error('Failed to fetch stadiums. Response: ${response.data}');
        _apiStatus = ApiCallStatus.error;
      }
    } catch (e) {
      PLog.error('Error fetching stadiums: $e');
      _apiStatus = ApiCallStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getStadiumImageUrl(String imagePath) {
    final url = '${dotenv.env['RESOURCE_APP']}/$imagePath';
    return url;
  }
}
