/// Central asset registry for PixelGimb.
///
/// IMPORTANT:
/// All PNG files stay inside `assets/icons/`.
/// Code separates record assets from normal icons by filename convention:
/// - record assets start with `record_`
/// - UI/control assets do not start with `record_`
class PixelAssets {
  static const String folder = 'assets/icons';

  static const Map<String, String> icons = {
    'play': '$folder/play.png',
    'pause': '$folder/pause.png',
    'previous': '$folder/previous.png',
    'next': '$folder/next.png',
    'shuffle': '$folder/shuffle.png',
    'repeat': '$folder/repeat.png',
    'settings': '$folder/settings.png',
    'sliders': '$folder/sliders.png',
    'profile': '$folder/profile.png',
    'spotify': '$folder/spotify.png',
  };

  static const Map<String, String> records = {
    'empty': '$folder/record_empty.png',
    'label': '$folder/record_label.png',
    'groove': '$folder/record_groove.png',
    'spin01': '$folder/record_spin_01.png',
    'spin02': '$folder/record_spin_02.png',
    'flipTransition': '$folder/record_flip_transition.png',
    'swap': '$folder/record_swap.png',
  };

  static String icon(String key) {
    final path = icons[key];
    if (path == null) {
      throw ArgumentError('Unknown icon asset key: $key');
    }
    return path;
  }

  static String record(String key) {
    final path = records[key];
    if (path == null) {
      throw ArgumentError('Unknown record asset key: $key');
    }
    return path;
  }

  static bool isRecordFilename(String filename) => filename.startsWith('record_');
  static bool isIconFilename(String filename) => !isRecordFilename(filename);
}
