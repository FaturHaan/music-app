import '../database/database_helper.dart';
import '../models/song_model.dart';

class SongRepository {
  final DatabaseHelper _dbHelper;

  SongRepository(this._dbHelper);

  Future<List<SongModel>> getAllSongs() async {
    final db = await _dbHelper.database;
    final maps = await db.query('songs', orderBy: 'date_added DESC');
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<List<SongModel>> getFavoriteSongs() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'date_added DESC',
    );
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final db = await _dbHelper.database;
    final searchQuery = '%$query%';
    final maps = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'title ASC',
    );
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<SongModel?> getSongById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SongModel.fromMap(maps.first);
    }
    return null;
  }

  Future<SongModel?> getSongByPath(String filePath) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'file_path = ?',
      whereArgs: [filePath],
    );
    if (maps.isNotEmpty) {
      return SongModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSong(SongModel song) async {
    final db = await _dbHelper.database;
    return await db.insert('songs', song.toMap());
  }

  Future<void> updateSong(SongModel song) async {
    final db = await _dbHelper.database;
    await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<void> toggleFavorite(int songId, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      'songs',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [songId],
    );
  }

  Future<void> deleteSong(int songId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [songId],
    );
  }

  Future<List<SongModel>> getSongsBySource(String source) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'date_added DESC',
    );
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<SongModel?> getSongBySourceId(String sourceId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'source_id = ?',
      whereArgs: [sourceId],
    );
    if (maps.isNotEmpty) {
      return SongModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SongModel>> getOnlineFavorites() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'songs',
      where: 'is_favorite = ? AND source != ?',
      whereArgs: [1, 'local'],
      orderBy: 'date_added DESC',
    );
    return maps.map((map) => SongModel.fromMap(map)).toList();
  }

  Future<int> getSongCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    return result.first['count'] as int;
  }
}
