import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/services/services.dart';
import 'package:cricket/models/models.dart';

class LoginController extends ChangeNotifier {
  ApiCallStatus _apiStatus = ApiCallStatus.success;
  String? _email;
  String? _password;
  bool _obscurePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  ApiCallStatus get apiStatus => _apiStatus;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setEmail(String? value) {
    _email = value;
  }

  void setPassword(String? value) {
    _password = value;
  }

  Future<LoginResult> login() async {
    _apiStatus = ApiCallStatus.loading;
    notifyListeners();

    try {
      final response = await ApiBaseHelper.post(
        '${dotenv.env['AUTH_APP']}${dotenv.env['LOGIN']}',
        FormData.fromMap({
          'email': _email,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);

        await SessionManagerServcie().saveAuthToken(token);
        await SessionManagerServcie().saveUserData(user);

        _apiStatus = ApiCallStatus.success;
        notifyListeners();
        return LoginResult.success(user);
      } else {
        _apiStatus = ApiCallStatus.error;
        notifyListeners();
        return LoginResult.error('Login failed');
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
          errorMessage = "Invalid Credentials";
          break;
        case DioExceptionType.connectionTimeout:
          _apiStatus = ApiCallStatus.networkError;
          errorMessage = "Connection Timeout.";
          break;
        default:
          _apiStatus = ApiCallStatus.error;
      }

      _apiStatus = ApiCallStatus.success;
      notifyListeners();
      return LoginResult.error(errorMessage);
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final User? user;

  LoginResult.success(this.user)
      : success = true,
        message = 'Login successful';

  LoginResult.error(this.message)
      : success = false,
        user = null;
}
