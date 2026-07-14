import '../database/database_helper.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistRepository {
  final DatabaseHelper _dbHelper;

  PlaylistRepository(this._dbHelper);

  Future<List<PlaylistModel>> getAllPlaylists() async {
    final db = await _dbHelper.database;
    final playlistMaps = await db.query('playlists', orderBy: 'date_created DESC');

    final playlists = <PlaylistModel>[];
    for (final map in playlistMaps) {
      final songs = await getPlaylistSongs(map['id'] as int);
      playlists.add(PlaylistModel.fromMap(map, songs));
    }
    return playlists;
  }

  Future<PlaylistModel?> getPlaylistById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final songs = await getPlaylistSongs(id);
      return PlaylistModel.fromMap(maps.first, songs);
    }
    return null;
  }

  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT s.* FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.song_id
      WHERE ps.playlist_id = ?
      ORDER BY ps.position ASC
    ''', [playlistId]);
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<int> createPlaylist(String name) async {
    final db = await _dbHelper.database;
    return await db.insert('playlists', {
      'name': name,
      'date_created': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePlaylistName(int playlistId, String name) async {
    final db = await _dbHelper.database;
    await db.update(
      'playlists',
      {'name': name},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final db = await _dbHelper.database;

    // Get next position
    final result = await db.rawQuery(
      'SELECT MAX(position) as max_pos FROM playlist_songs WHERE playlist_id = ?',
      [playlistId],
    );
    final nextPosition = ((result.first['max_pos'] as int?) ?? -1) + 1;

    await db.insert('playlist_songs', {
      'playlist_id': playlistId,
      'song_id': songId,
      'position': nextPosition,
    });
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (int i = 0; i < songIds.length; i++) {
      batch.update(
        'playlist_songs',
        {'position': i},
        where: 'playlist_id = ? AND song_id = ?',
        whereArgs: [playlistId, songIds[i]],
      );
    }

    await batch.commit(noResult: true);
  }
}
