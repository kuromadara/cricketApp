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
  List<Player> _selectedPlayers = [];

  List<Player> get players => _players;
  ApiCallStatus get apiStatus => _apiStatus;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  bool get hasMore => _currentPage < _lastPage;
  bool get hasPrevious => _currentPage > 1;
  bool get isLoadingMore => _isLoadingMore;
  List<Player> get selectedPlayers => _selectedPlayers;

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
          _players.addAll(newPlayers);
        } else {
          _players.insertAll(0, newPlayers);
        }

        _currentPage = data['meta']['current_page'];
        _lastPage = data['meta']['last_page'];
        _perPage = data['meta']['per_page'];

        if (page == 1 || _apiStatus == ApiCallStatus.loading) {
          _apiStatus =
              _players.isEmpty ? ApiCallStatus.empty : ApiCallStatus.success;
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

  Future<void> fetchPlayersByIds(List<int> playerIds) async {
    _selectedPlayers.clear();

    if (playerIds.isEmpty) {
      debugPrint('No player IDs provided');
      _apiStatus = ApiCallStatus.empty;
      notifyListeners();
      return;
    }

    try {
      _apiStatus = ApiCallStatus.loading;
      notifyListeners();

      debugPrint('Fetching players with IDs: $playerIds');

      final response = await ApiBaseHelper.get(
        '${dotenv.env['AUTH_APP']}players',
        params: {
          'ids': playerIds.join(','),
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['data'] is List) {
          _selectedPlayers = (data['data'] as List)
              .map((item) {
                try {
                  return Player.fromJson(item);
                } catch (e) {
                  debugPrint('Error parsing player: $e');
                  return null;
                }
              })
              .whereType<Player>()
              .toList();

          debugPrint('Fetched players count: ${_selectedPlayers.length}');

          _apiStatus = _selectedPlayers.isEmpty
              ? ApiCallStatus.empty
              : ApiCallStatus.success;
        } else {
          debugPrint('Invalid response data format');
          _apiStatus = ApiCallStatus.error;
        }
      } else {
        debugPrint('Server returned an error status');
        _apiStatus = ApiCallStatus.error;
      }
    } on DioException catch (error) {
      _apiStatus = ApiCallStatus.error;
      debugPrint('DioException fetching players by IDs: ${error.message}');
      debugPrint('Error response: ${error.response?.data}');
    } catch (e) {
      _apiStatus = ApiCallStatus.error;
      debugPrint('Unexpected error fetching players: $e');
    } finally {
      notifyListeners();
    }
  }
}
