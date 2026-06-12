import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyAuthService {
  /// Pass this during build, for example:
  /// flutter run -d chrome --dart-define=SPOTIFY_CLIENT_ID=your_client_id
  static const String clientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');

  static const String productionRedirectUri =
      'https://winnersamurai6064.github.io/PixelGimb/callback';

  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-read-playback-state',
    'user-read-currently-playing',
    'user-modify-playback-state',
    'streaming',
  ];

  bool get isConfigured => clientId.trim().isNotEmpty;

  /// Keep this exact for GitHub Pages. Spotify rejects redirect URIs that do
  /// not exactly match the dashboard allowlist.
  Uri get redirectUri {
    if (kReleaseMode) return Uri.parse(productionRedirectUri);

    final base = Uri.base;
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/callback',
    );
  }

  Uri buildAuthorizeUri() {
    return Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri.toString(),
      'scope': scopes.join(' '),
      'show_dialog': 'true',
    });
  }

  String? readAuthorizationCodeFromUrl() {
    final code = Uri.base.queryParameters['code'];
    if (code == null || code.trim().isEmpty) return null;
    return code;
  }

  Future<void> login() async {
    if (!isConfigured) return;
    final uri = buildAuthorizeUri();
    await launchUrl(uri, webOnlyWindowName: '_self');
  }
}
