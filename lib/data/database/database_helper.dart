import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import 'migrations.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        title TEXT NOT NULL,
        artist TEXT DEFAULT 'Unknown Artist',
        album TEXT DEFAULT 'Unknown Album',
        duration_ms INTEGER NOT NULL,
        cover_art_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        date_added TEXT NOT NULL,
        source TEXT DEFAULT 'local',
        source_id TEXT,
        stream_url TEXT,
        thumbnail_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date_created TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs (
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        PRIMARY KEY (playlist_id, song_id)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_songs_title ON songs(title)');
    await db.execute('CREATE INDEX idx_songs_artist ON songs(artist)');
    await db.execute('CREATE INDEX idx_songs_favorite ON songs(is_favorite)');
    await db.execute('CREATE INDEX idx_songs_source ON songs(source)');
    await db.execute('CREATE INDEX idx_songs_source_id ON songs(source_id)');
    await db.execute('CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await Migrations.migrate(db, oldVersion, newVersion);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
