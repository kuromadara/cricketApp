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

  /// Set the initial user for the home screen.
  ///
  /// If the user is not null, it will set the user and the api status to success.
  /// If the user is null, it will check the session and set the api status accordingly.
  ///
  void setInitialUser(User? initialUser) async {
    if (initialUser != null) {
      _user = initialUser;
      _apiStatus = ApiCallStatus.success;
      notifyListeners();
    } else {
      await checkSession();
    }
  }

  /// Checks the current session status.
  ///
  /// This function first verifies if there is a session available locally.
  /// If a session is not available, it sets the API status to empty and exits.
  ///
  /// If a session is available, it performs a server-side authentication check.
  /// In case of a connection error or a bad response from the server, it deletes
  /// the session and updates the API status accordingly.
  ///
  /// If the session is valid, it retrieves user data from secure storage and
  /// updates the user information and API status to success. If any user data
  /// is missing, it sets the API status to empty.
  ///
  /// In the event of any other errors, it sets the API status to error.
  Future<void> checkSession() async {
    try {
      bool hasSession = await SessionManagerServcie().hasSession();

      // check with server if session is availablile if not logout and go to login screen

      if (!hasSession) {
        _apiStatus = ApiCallStatus.empty;
        notifyListeners();
        return;
      }

      try {
        await ApiBaseHelper.get(
            '${dotenv.env['AUTH_APP']}${dotenv.env['CHECK_AUTH']}');
      } on DioException catch (error) {
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

      // Get user data from secure storage
      final userData = await SessionManagerServcie().getUserData();
      
      if (userData != null) {
        _user = userData;
        _apiStatus = ApiCallStatus.success;
      } else {
        _apiStatus = ApiCallStatus.empty;
      }
      notifyListeners();
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      notifyListeners();
    }
  }

  /// Logs out the user and clears the session.
  ///
  /// Returns a [LogoutResult] with a success message if the logout is successful,
  /// or an error message if the logout fails.
  ///
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
