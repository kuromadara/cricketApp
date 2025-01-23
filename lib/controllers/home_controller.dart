import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/services/services.dart';

class HomeController extends ChangeNotifier {
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  User? _user;

  ApiCallStatus get apiStatus => _apiStatus;
  User? get user => _user;

  void setInitialUser(User? initialUser) async {
    if (initialUser != null) {
      _user = initialUser;
      _apiStatus = ApiCallStatus.success;
      notifyListeners();
    } else {
      await checkSession();
    }
  }

  Future<void> checkSession() async {
    // try {
      bool hasSession = await SessionManagerServcie().hasSession();

      if (!hasSession) {
        _apiStatus = ApiCallStatus.empty;
        notifyListeners();
        return;
      }

      try {
        await ApiBaseHelper.get(
            '${dotenv.env['AUTH_APP']}${dotenv.env['CHECK_AUTH']}');
            _apiStatus = ApiCallStatus.success;
            PLog.info("User data is not null");
            notifyListeners();
      } on DioException catch (error) {
        PLog.info("DioException occurred: ${error.type}");
        PLog.info("Error message: ${error.message}");
        PLog.info("Error response: ${error.response?.data}");
        PLog.info("Status code: ${error.response?.statusCode}");
        PLog.info("Im here");
        
        switch (error.type) {
          case DioExceptionType.connectionError:
            _apiStatus = ApiCallStatus.networkError;
            await SessionManagerServcie().deleteSession();
            notifyListeners();
            break;
          case DioExceptionType.badResponse:
            _apiStatus = ApiCallStatus.empty;
            await SessionManagerServcie().deleteSession();
            notifyListeners();
            break;
          default:
            _apiStatus = ApiCallStatus.error;
            await SessionManagerServcie().deleteSession();
            notifyListeners();
        }
        notifyListeners();
        return;
      }

      final userData = await SessionManagerServcie().getUserData();
      PLog.info("User data: $userData");
      if (userData != null) {
        _user = userData;
        _apiStatus = ApiCallStatus.success;
      } else {
        PLog.info("User data is null");
        _apiStatus = ApiCallStatus.empty;
      }
      notifyListeners();
    // } catch (e) {
    //   PLog.info("Error in catch: $e");
    //   _apiStatus = ApiCallStatus.error;
    //   notifyListeners();
    // }
  }

  Future<LogoutResult> logout() async {
    _apiStatus = ApiCallStatus.loading;
    notifyListeners();

    try {
      final response = await ApiBaseHelper.post(
          '${dotenv.env['AUTH_APP']}${dotenv.env['LOGOUT']}', {});

      if (response.statusCode == 200) {
        String successMessage =
            response.data['message'] ?? 'Logged out successfully';
        await SessionManagerServcie().deleteSession();
        return LogoutResult.success(successMessage);
      } else {
        _apiStatus = ApiCallStatus.error;
        notifyListeners();
        return LogoutResult.error('Logout failed');
      }
    } on DioException catch (error) {
      PLog.info("DioException occurred: ${error.type}");
      PLog.info("Error message: ${error.message}");
      PLog.info("Error response: ${error.response?.data}");
      PLog.info("Status code: ${error.response?.statusCode}");
      
      String errorMessage = 'An error occurred during logout';

      switch (error.type) {
        case DioExceptionType.connectionError:
          _apiStatus = ApiCallStatus.networkError;
          break;
        case DioExceptionType.badResponse:
          _apiStatus = ApiCallStatus.error;
          await SessionManagerServcie().deleteSession();
          break;
        default:
          _apiStatus = ApiCallStatus.error;
      }
      notifyListeners();
      return LogoutResult.error(errorMessage);
    }
  }
}

class LogoutResult {
  final bool success;
  final String message;

  LogoutResult.success(this.message) : success = true;
  LogoutResult.error(this.message) : success = false;
}
