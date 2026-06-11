import 'dart:async';

import '../models/track.dart';

class MockSpotifyService {
  final List<Track> _tracks = const [
    Track(
      title: 'Forest Frequency',
      artist: 'PixelGimb Radio',
      album: 'Moss & Vinyl',
      albumArtUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600&auto=format&fit=crop',
      isPlaying: true,
    ),
    Track(
      title: 'CRT Night Drive',
      artist: 'Tekdev Labs',
      album: 'Arcade Woods',
      albumArtUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&auto=format&fit=crop',
      isPlaying: true,
    ),
    Track(
      title: 'Blocky Stardust',
      artist: '8 Bit Garden',
      album: 'Overworld Tape',
      albumArtUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop',
      isPlaying: true,
    ),
  ];

  int _index = 0;

  Track get current => _tracks[_index];
  Track get nextTrack => _tracks[(_index + 1) % _tracks.length];

  Future<Track> next() async {
    _index = (_index + 1) % _tracks.length;
    return current;
  }

  Future<Track> previous() async {
    _index = (_index - 1) % _tracks.length;
    if (_index < 0) _index = _tracks.length - 1;
    return current;
  }

  Future<void> preloadNextImage(void Function(String url) preload) async {
    preload(nextTrack.albumArtUrl);
  }
}
