import 'package:url_launcher/url_launcher.dart';

class SpotifyAuthService {
  /// Pass this during build, for example:
  /// flutter run -d chrome --dart-define=SPOTIFY_CLIENT_ID=your_client_id
  static const String clientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');

  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-read-playback-state',
    'user-read-currently-playing',
    'user-modify-playback-state',
    'streaming',
  ];

  bool get isConfigured => clientId.trim().isNotEmpty;

  Uri get redirectUri {
    final base = Uri.base;
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '${base.pathSegments.where((s) => s.isNotEmpty).join('/')}/callback',
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

  Future<void> login() async {
    if (!isConfigured) return;
    final uri = buildAuthorizeUri();
    await launchUrl(uri, webOnlyWindowName: '_self');
  }
}
