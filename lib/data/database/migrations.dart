import 'package:sqflite/sqflite.dart';

class Migrations {
  Migrations._();

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateV1toV2(db);
    }
  }

  /// Migration v1 → v2: Add online streaming columns to songs table
  static Future<void> _migrateV1toV2(Database db) async {
    await db.execute("ALTER TABLE songs ADD COLUMN source TEXT DEFAULT 'local'");
    await db.execute('ALTER TABLE songs ADD COLUMN source_id TEXT');
    await db.execute('ALTER TABLE songs ADD COLUMN stream_url TEXT');
    await db.execute('ALTER TABLE songs ADD COLUMN thumbnail_url TEXT');

    // Add indexes for the new columns
    await db.execute('CREATE INDEX IF NOT EXISTS idx_songs_source ON songs(source)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_songs_source_id ON songs(source_id)');
  }
}
