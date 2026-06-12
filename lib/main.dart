import 'package:flutter/material.dart';

import 'assets/pixel_assets.dart';
import 'models/track.dart';
import 'services/mock_spotify_service.dart';
import 'services/spotify_auth_service.dart';
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
        sliderTheme: SliderThemeData(
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.26),
          thumbColor: Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.10),
        ),
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
  final SpotifyAuthService _spotifyAuth = SpotifyAuthService();
  late Track _track;
  bool _isTransitioning = false;
  bool _isPlaying = true;
  bool _crtEnabled = true;
  double _progress = 0.11;

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
      _progress = 0.02;
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
      _progress = 0.02;
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

  Future<void> _loginSpotify() async {
    if (!_spotifyAuth.isConfigured) {
      _showSetupMessage();
      return;
    }
    await _spotifyAuth.login();
  }

  void _showSetupMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add SPOTIFY_CLIENT_ID with --dart-define before login.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isShort = height < 760;
          final recordSize = (width * 0.74).clamp(220.0, isShort ? 270.0 : 330.0);

          return Stack(
            children: [
              const _PlayerBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, isShort ? 10 : 18, 18, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OfficialHeader(
                            track: _track,
                            onSpotifyLogin: _loginSpotify,
                            onToggleCrt: _toggleCrt,
                          ),
                          SizedBox(height: isShort ? 10 : 16),
                          _SeekBar(
                            value: _progress,
                            onChanged: (value) => setState(() => _progress = value),
                          ),
                          SizedBox(height: isShort ? 10 : 18),
                          Expanded(
                            child: Center(
                              child: SpinningRecord(
                                albumArtUrl: _track.albumArtUrl,
                                isPlaying: _isPlaying,
                                isTransitioning: _isTransitioning,
                                size: recordSize,
                              ),
                            ),
                          ),
                          SizedBox(height: isShort ? 8 : 14),
                          _OfficialControls(
                            isPlaying: _isPlaying,
                            onPrevious: _previousTrack,
                            onPlayPause: _togglePlay,
                            onNext: _nextTrack,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              CrtOverlay(enabled: _crtEnabled, opacity: 0.10),
            ],
          );
        },
      ),
    );
  }
}

class _OfficialHeader extends StatelessWidget {
  final Track track;
  final VoidCallback onSpotifyLogin;
  final VoidCallback onToggleCrt;

  const _OfficialHeader({
    required this.track,
    required this.onSpotifyLogin,
    required this.onToggleCrt,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 390 ? 30.0 : 38.0;
    final actionSize = width < 390 ? 48.0 : 58.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: width < 390 ? 16 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _SmallAssetButton(assetKey: 'spotify', size: actionSize, tooltip: 'Login with Spotify', onTap: onSpotifyLogin),
        const SizedBox(width: 8),
        _SmallAssetButton(assetKey: 'sliders', size: actionSize, tooltip: 'Toggle CRT', onTap: onToggleCrt),
      ],
    );
  }
}

class _SmallAssetButton extends StatelessWidget {
  final String assetKey;
  final double size;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallAssetButton({
    required this.assetKey,
    required this.size,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: PixelAssetImage(PixelAssets.icon(assetKey)),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _SeekBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.clamp(0, 1),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                _formatDuration(Duration(seconds: (value * 161).round())),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '-${_formatDuration(Duration(seconds: ((1 - value) * 161).round()))}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _OfficialControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const _OfficialControls({
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = width < 390 ? 52.0 : 62.0;
    final mid = width < 390 ? 58.0 : 68.0;
    final play = width < 390 ? 80.0 : 92.0;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 390,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PixelIconButton(assetKey: 'shuffle', onPressed: () {}, size: side),
              PixelIconButton(assetKey: 'previous', onPressed: onPrevious, size: mid),
              PixelIconButton(
                assetKey: isPlaying ? 'pause' : 'play',
                onPressed: onPlayPause,
                size: play,
              ),
              PixelIconButton(assetKey: 'next', onPressed: onNext, size: mid),
              PixelIconButton(assetKey: 'repeat', onPressed: () {}, size: side),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerBackground extends StatelessWidget {
  const _PlayerBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B5A62),
            Color(0xFF473940),
            Color(0xFF16100F),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _SubtleTexturePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SubtleTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.014);
    const step = 16.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
