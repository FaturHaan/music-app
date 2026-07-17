import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/providers/search_provider.dart';
import 'package:music_app/data/repositories/song_repository.dart';
import 'package:music_app/data/sources/source_aggregator.dart';
import 'package:music_app/data/models/song_model.dart';


class FakeSongRepository implements SongRepository {
  @override
  Future<List<SongModel>> searchSongs(String query) async {
    if (query == 'local') {
      return [
        SongModel(id: 1, title: 'Local Song', artist: 'Artist', album: 'Album', durationMs: 100, filePath: '', source: 'local', dateAdded: DateTime.now()),
      ];
    }
    return [];
  }
  

  @override
  Future<void> deleteSong(int id) async {}
  @override
  Future<List<SongModel>> getAllSongs() async => [];
  @override
  Future<SongModel?> getSongById(int id) async => null;
  @override
  Future<int> insertSong(SongModel song) async => 1;
  @override
  Future<void> updateSong(SongModel song) async {}
  @override
  Future<List<SongModel>> getFavoriteSongs() async => [];
  @override
  Future<List<SongModel>> getOnlineFavorites() async => [];
  @override
  Future<SongModel?> getSongByPath(String filePath) async => null;
  @override
  Future<SongModel?> getSongBySourceId(String sourceId) async => null;
  @override
  Future<int> getSongCount() async => 0;
  @override
  Future<List<SongModel>> getSongsBySource(String source) async => [];
  @override
  Future<void> toggleFavorite(int songId, bool isFavorite) async {}
}

class FakeSourceAggregator extends SourceAggregator {
  FakeSourceAggregator() : super([]);

  @override
  Future<List<SongModel>> searchAll(String query, {int limitPerSource = 15}) async {
    if (query == 'online') {
      return [
        SongModel(title: 'Online Song', artist: 'Artist', album: 'Album', durationMs: 100, filePath: '', source: 'itunes', dateAdded: DateTime.now()),
      ];
    }
    return [];
  }
}

void main() {
  late SearchProvider searchProvider;

  setUp(() {
    searchProvider = SearchProvider(FakeSongRepository(), FakeSourceAggregator());
  });

  test('Initial state is empty', () {
    expect(searchProvider.query, isEmpty);
    expect(searchProvider.results, isEmpty);
    expect(searchProvider.isSearching, isFalse);
    expect(searchProvider.hasQuery, isFalse);
  });

  test('search logic correctly aggregates local and online results (simulated delay)', () async {
    searchProvider.search('local');
    expect(searchProvider.query, isEmpty); // Debounce hasn't triggered yet

    // Wait for debounce
    await Future.delayed(const Duration(milliseconds: 600));

    expect(searchProvider.query, 'local');
    expect(searchProvider.results.length, 1);
    expect(searchProvider.results.first.title, 'Local Song');
  });

  test('clearSearch clears query and results', () async {
    searchProvider.search('local');
    await Future.delayed(const Duration(milliseconds: 600));
    expect(searchProvider.results, isNotEmpty);

    searchProvider.clearSearch();

    expect(searchProvider.query, isEmpty);
    expect(searchProvider.results, isEmpty);
  });
}
