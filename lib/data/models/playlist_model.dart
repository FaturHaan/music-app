import 'song_model.dart';

class PlaylistModel {
  final int? id;
  final String name;
  final DateTime dateCreated;
  final List<SongModel> songs;

  const PlaylistModel({
    this.id,
    required this.name,
    required this.dateCreated,
    this.songs = const [],
  });

  PlaylistModel copyWith({
    int? id,
    String? name,
    DateTime? dateCreated,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateCreated: dateCreated ?? this.dateCreated,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'date_created': dateCreated.toIso8601String(),
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map, [List<SongModel>? songs]) {
    return PlaylistModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      dateCreated: DateTime.parse(map['date_created'] as String),
      songs: songs ?? const [],
    );
  }

  int get songCount => songs.length;

  String? get coverArtPath {
    for (final song in songs) {
      if (song.coverArtPath != null) return song.coverArtPath;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlaylistModel(id: $id, name: $name, songs: ${songs.length})';
}
