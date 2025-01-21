import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/services/services.dart';

class PlayersController extends ChangeNotifier {
  List<Player> _players = [];
  ApiCallStatus _apiStatus = ApiCallStatus.loading;
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  bool _isLoadingMore = false;

  List<Player> get players => _players;
  ApiCallStatus get apiStatus => _apiStatus;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  bool get hasMore => _currentPage < _lastPage;
  bool get hasPrevious => _currentPage > 1;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchPlayers({int? page}) async {
    try {
      if (page == 1) {
        _apiStatus = ApiCallStatus.loading;
        notifyListeners();
      } else {
        _isLoadingMore = true;
        notifyListeners();
      }

      final response = await ApiBaseHelper.get(
        '${dotenv.env['AUTH_APP']}players',
        params: {
          'page': page ?? _currentPage,
          'per_page': _perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (page == 1) {
          _players.clear();
        }

        final newPlayers = (data['data'] as List)
            .map((item) => Player.fromJson(item))
            .toList();

        if (page == null || page == _currentPage) {
          _players.addAll(newPlayers);
        } else if (page > _currentPage) {
          // Adding to end
          _players.addAll(newPlayers);
        } else {
          // Adding to beginning
          _players.insertAll(0, newPlayers);
        }

        _currentPage = data['meta']['current_page'];
        _lastPage = data['meta']['last_page'];
        _perPage = data['meta']['per_page'];

        // Only update status to success/empty if this is initial load or refresh
        if (page == 1 || _apiStatus == ApiCallStatus.loading) {
          _apiStatus = _players.isEmpty ? ApiCallStatus.empty : ApiCallStatus.success;
        }
      } else {
        if (page == 1) {
          _apiStatus = ApiCallStatus.error;
        }
      }
    } on DioException catch (error) {
      String errorMessage = 'An error occurred';

      if (page == 1) {
        switch (error.type) {
          case DioExceptionType.connectionError:
            _apiStatus = ApiCallStatus.error;
            errorMessage = "No Internet connection or server is not reachable.";
            break;
          case DioExceptionType.badResponse:
            _apiStatus = ApiCallStatus.empty;
            errorMessage = "Failed to load players";
            break;
          case DioExceptionType.connectionTimeout:
            _apiStatus = ApiCallStatus.networkError;
            errorMessage = "Connection Timeout.";
            break;
          default:
            _apiStatus = ApiCallStatus.error;
        }
      }
      debugPrint('Error fetching players: $errorMessage');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!_isLoadingMore && hasMore) {
      await fetchPlayers(page: _currentPage + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (!_isLoadingMore && hasPrevious) {
      await fetchPlayers(page: _currentPage - 1);
    }
  }

  Future<void> refreshPlayers() async {
    _currentPage = 1;
    await fetchPlayers(page: 1);
  }
}
