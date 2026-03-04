class AppAssets {
  // Images
  static const String splashBg = 'assets/images/splash_bg.png';
  static const String logo = 'assets/images/logo.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String farmBg = 'assets/images/farm_bg.png';

  // Icons
  static const String tomatoIcon = 'assets/icons/tomato.png';
  static const String onionIcon = 'assets/icons/onion.png';
  static const String potatoIcon = 'assets/icons/potato.png';
  static const String riceIcon = 'assets/icons/rice.png';
  static const String wheatIcon = 'assets/icons/wheat.png';

  /// Crop icon mapping by crop name (English, lowercase)
  static String cropIcon(String cropNameEn) {
    switch (cropNameEn.toLowerCase()) {
      case 'tomato':
        return tomatoIcon;
      case 'onion':
        return onionIcon;
      case 'potato':
        return potatoIcon;
      case 'rice':
        return riceIcon;
      case 'wheat':
        return wheatIcon;
      default:
        return tomatoIcon;
    }
  }
}
