class SongModel {
  final int? id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? coverArtPath;
  final bool isFavorite;
  final DateTime dateAdded;
  final String source;
  final String? sourceId;
  final String? streamUrl;
  final String? thumbnailUrl;

  const SongModel({
    this.id,
    required this.filePath,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    required this.durationMs,
    this.coverArtPath,
    this.isFavorite = false,
    required this.dateAdded,
    this.source = 'local',
    this.sourceId,
    this.streamUrl,
    this.thumbnailUrl,
  });

  /// Whether this song is from an online source
  bool get isOnline => source != 'local';

  /// Whether this song is from local storage
  bool get isLocal => source == 'local';

  /// Best available cover image: local file path or network URL
  String? get bestCoverArt => coverArtPath ?? thumbnailUrl;

  SongModel copyWith({
    int? id,
    String? filePath,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? coverArtPath,
    bool? isFavorite,
    DateTime? dateAdded,
    String? source,
    String? sourceId,
    String? streamUrl,
    String? thumbnailUrl,
  }) {
    return SongModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'title': title,
      'artist': artist,
      'album': album,
      'duration_ms': durationMs,
      'cover_art_path': coverArtPath,
      'is_favorite': isFavorite ? 1 : 0,
      'date_added': dateAdded.toIso8601String(),
      'source': source,
      'source_id': sourceId,
      'stream_url': streamUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int?,
      filePath: map['file_path'] as String? ?? '',
      title: map['title'] as String,
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      durationMs: map['duration_ms'] as int,
      coverArtPath: map['cover_art_path'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      dateAdded: DateTime.parse(map['date_added'] as String),
      source: map['source'] as String? ?? 'local',
      sourceId: map['source_id'] as String?,
      streamUrl: map['stream_url'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel &&
          runtimeType == other.runtimeType &&
          ((id != null && other.id != null && id == other.id) ||
           (sourceId != null && other.sourceId != null &&
            source == other.source && sourceId == other.sourceId));

  @override
  int get hashCode => id?.hashCode ?? (source.hashCode ^ sourceId.hashCode);

  @override
  String toString() =>
      'SongModel(id: $id, title: $title, artist: $artist, source: $source)';
}
