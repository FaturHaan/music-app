import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';

import '../data/sources/source_aggregator.dart';

class SearchProvider extends ChangeNotifier {
  final SongRepository _songRepository;
  final SourceAggregator _sourceAggregator;

  SearchProvider(this._songRepository, this._sourceAggregator);

  String _query = '';
  List<SongModel> _results = [];
  bool _isSearching = false;
  Timer? _debounce;

  String get query => _query;
  List<SongModel> get results => _results;
  bool get isSearching => _isSearching;
  bool get hasQuery => _query.isNotEmpty;

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _query = query;

    if (query.isEmpty) {
      _results = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Search local database
      final localResults = await _songRepository.searchSongs(query);
      
      // Search online sources in parallel
      final onlineResults = await _sourceAggregator.searchAll(query);

      // Combine results (Local first, then online)
      _results = [...localResults, ...onlineResults];
    } catch (e) {
      debugPrint('Search failed: $e');
      _results = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _isSearching = false;
    notifyListeners();
  }
}
