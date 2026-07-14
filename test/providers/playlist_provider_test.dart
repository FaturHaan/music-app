import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/providers/playlist_provider.dart';
import 'package:music_app/data/repositories/playlist_repository.dart';
import 'package:music_app/data/models/playlist_model.dart';
import 'package:music_app/data/models/song_model.dart';

class FakePlaylistRepository implements PlaylistRepository {
  List<PlaylistModel> playlists = [];
  int idCounter = 1;

  @override
  Future<int> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: idCounter++,
      name: name,
      dateCreated: DateTime.now(),
      songs: [],
    );
    playlists.add(playlist);
    return playlist.id!;
  }

  @override
  Future<void> deletePlaylist(int id) async {
    playlists.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    return List.from(playlists);
  }

  @override
  Future<PlaylistModel?> getPlaylistById(int id) async {
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updatePlaylistName(int id, String name) async {
    final index = playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = playlists[index];
      playlists[index] = PlaylistModel(
        id: old.id,
        name: name,
        dateCreated: old.dateCreated,
        songs: old.songs,
      );
    }
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, int songId) async {}

  @override
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {}

  @override
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async => [];

  @override
  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds) async {}
}

void main() {
  late FakePlaylistRepository fakeRepository;
  late PlaylistProvider playlistProvider;

  setUp(() {
    fakeRepository = FakePlaylistRepository();
    playlistProvider = PlaylistProvider(fakeRepository);
  });

  test('Initial state should have empty playlists', () {
    expect(playlistProvider.playlists, isEmpty);
    expect(playlistProvider.isLoading, isFalse);
  });

  test('createPlaylist should add a new playlist', () async {
    await playlistProvider.createPlaylist('My First Playlist');
    expect(playlistProvider.playlists.length, 1);
    expect(playlistProvider.playlists.first.name, 'My First Playlist');
  });

  test('renamePlaylist should update playlist name', () async {
    await playlistProvider.createPlaylist('Old Name');
    final playlistId = playlistProvider.playlists.first.id!;

    await playlistProvider.renamePlaylist(playlistId, 'New Name');

    expect(playlistProvider.playlists.first.name, 'New Name');
  });

  test('deletePlaylist should remove playlist', () async {
    await playlistProvider.createPlaylist('To Be Deleted');
    expect(playlistProvider.playlists.length, 1);
    final playlistId = playlistProvider.playlists.first.id!;

    await playlistProvider.deletePlaylist(playlistId);
    expect(playlistProvider.playlists, isEmpty);
  });
}
