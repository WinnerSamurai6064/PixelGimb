import 'package:flutter/material.dart';

import 'assets/pixel_assets.dart';
import 'models/track.dart';
import 'services/mock_spotify_service.dart';
import 'widgets/crt_overlay.dart';
import 'widgets/pixel_asset_image.dart';
import 'widgets/pixel_icon_button.dart';
import 'widgets/spinning_record.dart';

void main() {
  runApp(const PixelGimbApp());
}

class PixelGimbApp extends StatelessWidget {
  const PixelGimbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PixelGimb',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B08),
        fontFamily: 'monospace',
      ),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final MockSpotifyService _spotify = MockSpotifyService();
  late Track _track;
  bool _isTransitioning = false;
  bool _isPlaying = true;
  bool _crtEnabled = true;

  @override
  void initState() {
    super.initState();
    _track = _spotify.current;
  }

  Future<void> _preloadNext() async {
    await _spotify.preloadNextImage((url) {
      precacheImage(NetworkImage(url), context);
    });
  }

  Future<void> _nextTrack() async {
    await _preloadNext();
    setState(() => _isTransitioning = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final next = await _spotify.next();
    if (!mounted) return;
    setState(() {
      _track = next.copyWith(isPlaying: _isPlaying);
      _isTransitioning = false;
    });
  }

  Future<void> _previousTrack() async {
    setState(() => _isTransitioning = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final previous = await _spotify.previous();
    if (!mounted) return;
    setState(() {
      _track = previous.copyWith(isPlaying: _isPlaying);
      _isTransitioning = false;
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _track = _track.copyWith(isPlaying: _isPlaying);
    });
  }

  void _toggleCrt() {
    setState(() => _crtEnabled = !_crtEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final recordSize = width < 420 ? width * 0.78 : 350.0;

    return Scaffold(
      body: Stack(
        children: [
          const _PixelBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    children: [
                      _TopBar(onToggleCrt: _toggleCrt),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const _StatusPill(),
                              const SizedBox(height: 22),
                              SpinningRecord(
                                albumArtUrl: _track.albumArtUrl,
                                isPlaying: _isPlaying,
                                isTransitioning: _isTransitioning,
                                size: recordSize,
                              ),
                              const SizedBox(height: 22),
                              _TrackCard(track: _track),
                              const SizedBox(height: 20),
                              _Controls(
                                isPlaying: _isPlaying,
                                onPrevious: _previousTrack,
                                onPlayPause: _togglePlay,
                                onNext: _nextTrack,
                              ),
                              const SizedBox(height: 16),
                              const _SpotifyNotice(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CrtOverlay(enabled: _crtEnabled),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onToggleCrt;

  const _TopBar({required this.onToggleCrt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PixelAssetImage(PixelAssets.icon('spotify'), width: 54, height: 54),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PixelGimb',
                style: TextStyle(
                  color: Color(0xFFFFE2A3),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'CRT pixel music player',
                style: TextStyle(color: Color(0xFF92B86A), fontSize: 12),
              ),
            ],
          ),
        ),
        PixelIconButton(
          assetKey: 'sliders',
          size: 48,
          tooltip: 'Toggle CRT overlay',
          onPressed: onToggleCrt,
        ),
        PixelIconButton(
          assetKey: 'settings',
          size: 48,
          tooltip: 'Settings',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12180F).withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF8F5B24), width: 1.5),
      ),
      child: const Text(
        'WEB PROTOTYPE • SPOTIFY READY • PREMIUM CONTROLS LATER',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFFFD37A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final Track track;

  const _TrackCard({required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14100B).withOpacity(0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF533B1D), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            track.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE2A3),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            track.artist,
            style: const TextStyle(color: Color(0xFF9ED56A), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            track.album,
            style: const TextStyle(color: Color(0xFFBBA579), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const _Controls({
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PixelIconButton(assetKey: 'shuffle', onPressed: () {}, size: 62),
        PixelIconButton(assetKey: 'previous', onPressed: onPrevious, size: 74),
        PixelIconButton(
          assetKey: isPlaying ? 'pause' : 'play',
          onPressed: onPlayPause,
          size: 88,
        ),
        PixelIconButton(assetKey: 'next', onPressed: onNext, size: 74),
        PixelIconButton(assetKey: 'repeat', onPressed: () {}, size: 62),
      ],
    );
  }
}

class _SpotifyNotice extends StatelessWidget {
  const _SpotifyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C120A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF274D1D)),
      ),
      child: const Text(
        'Next step: replace mock tracks with Spotify OAuth + current playback. Premium accounts get playback controls where Spotify allows it; non-premium users stay display-only/safe.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFC4D6B0), height: 1.4, fontSize: 12),
      ),
    );
  }
}

class _PixelBackground extends StatelessWidget {
  const _PixelBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            Color(0xFF1C2C16),
            Color(0xFF0C0F0A),
            Color(0xFF050604),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridNoisePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.018);
    const step = 18.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
