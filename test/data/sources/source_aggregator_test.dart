import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/models/song_model.dart';
import 'package:music_app/data/sources/music_source.dart';
import 'package:music_app/data/sources/source_aggregator.dart';

class MockMusicSource implements MusicSource {
  final String _sourceName;
  final List<SongModel> _results;
  final String? _streamUrl;
  final bool _shouldThrow;

  MockMusicSource(this._sourceName, this._results, {String? streamUrl, bool shouldThrow = false})
      : _streamUrl = streamUrl,
        _shouldThrow = shouldThrow;

  @override
  String get sourceName => _sourceName;

  @override
  Future<List<SongModel>> search(String query, {int limit = 20}) async {
    if (_shouldThrow) throw Exception('Search failed');
    return _results;
  }

  @override
  Future<String?> getStreamUrl(String sourceId) async {
    if (_shouldThrow) throw Exception('Get stream URL failed');
    return _streamUrl;
  }
}

void main() {
  late SongModel songA;
  late SongModel songB;
  late SongModel songA_duplicate;

  setUp(() {
    songA = SongModel(
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      album: 'Divide',
      durationMs: 233000,
      filePath: '',
      dateAdded: DateTime.now(),
      source: 'Source1',
      sourceId: '1',
    );

    songB = SongModel(
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      album: 'After Hours',
      durationMs: 200000,
      filePath: '',
      dateAdded: DateTime.now(),
      source: 'Source2',
      sourceId: '2',
    );

    songA_duplicate = SongModel(
      title: 'Shape of You (Official Video)',
      artist: 'Ed Sheeran ',
      album: 'Unknown',
      durationMs: 235000,
      filePath: '',
      dateAdded: DateTime.now(),
      source: 'Source2',
      sourceId: '3',
    );
  });

  group('SourceAggregator Tests', () {
    test('searchAll combines results from multiple sources', () async {
      final source1 = MockMusicSource('Source1', [songA]);
      final source2 = MockMusicSource('Source2', [songB]);
      final aggregator = SourceAggregator([source1, source2]);

      final results = await aggregator.searchAll('query');

      expect(results.length, 2);
      expect(results.contains(songA), true);
      expect(results.contains(songB), true);
    });

    test('searchAll deduplicates results correctly', () async {
      // songA and songA_duplicate should be considered duplicates
      final source1 = MockMusicSource('Source1', [songA]);
      final source2 = MockMusicSource('Source2', [songA_duplicate, songB]);
      final aggregator = SourceAggregator([source1, source2]);

      final results = await aggregator.searchAll('query');

      expect(results.length, 2); // songA and songB
      expect(results.contains(songA), true);
      expect(results.contains(songB), true);
      expect(results.contains(songA_duplicate), false); // Was deduplicated
    });

    test('searchAll handles errors gracefully', () async {
      final source1 = MockMusicSource('Source1', [songA]);
      final sourceError = MockMusicSource('SourceError', [], shouldThrow: true);
      final aggregator = SourceAggregator([source1, sourceError]);

      final results = await aggregator.searchAll('query');

      // Should still return results from source1 even if sourceError throws
      expect(results.length, 1);
      expect(results.first, songA);
    });

    test('getStreamUrl routes to correct source', () async {
      final source1 = MockMusicSource('Source1', [], streamUrl: 'url1');
      final source2 = MockMusicSource('Source2', [], streamUrl: 'url2');
      final aggregator = SourceAggregator([source1, source2]);

      final url = await aggregator.getStreamUrl('Source2', 'id');
      expect(url, 'url2');
    });

    test('getStreamUrl returns null if source not found', () async {
      final source1 = MockMusicSource('Source1', [], streamUrl: 'url1');
      final aggregator = SourceAggregator([source1]);

      final url = await aggregator.getStreamUrl('UnknownSource', 'id');
      expect(url, isNull);
    });
  });
}
