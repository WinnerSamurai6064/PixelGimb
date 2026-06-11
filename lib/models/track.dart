class Track {
  final String title;
  final String artist;
  final String album;
  final String albumArtUrl;
  final bool isPlaying;

  const Track({
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtUrl,
    required this.isPlaying,
  });

  Track copyWith({
    String? title,
    String? artist,
    String? album,
    String? albumArtUrl,
    bool? isPlaying,
  }) {
    return Track(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
