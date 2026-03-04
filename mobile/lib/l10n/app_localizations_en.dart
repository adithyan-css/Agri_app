// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgriPrice AI';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get enterName => 'Enter your name';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String enterOtp(String phone) {
    return 'Enter the OTP sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get crops => 'Crops';

  @override
  String get markets => 'Markets';

  @override
  String get predictions => 'Predictions';

  @override
  String get alerts => 'Alerts';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get todayPrices => 'Today\'s Prices';

  @override
  String get priceTrend => 'Price Trend';

  @override
  String pricePerKg(String price) {
    return '₹$price/kg';
  }

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get cropDetails => 'Crop Details';

  @override
  String get latestPrice => 'Latest Price';

  @override
  String get priceHistory => 'Price History';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get nearbyMarkets => 'Nearby Markets';

  @override
  String get allMarkets => 'All Markets';

  @override
  String get marketDetails => 'Market Details';

  @override
  String get distance => 'Distance';

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String get searchMarkets => 'Search markets...';

  @override
  String get pricePrediction => 'Price Prediction';

  @override
  String get forecast => 'Forecast';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get confidence => 'Confidence';

  @override
  String get trend => 'Trend';

  @override
  String get trendUp => 'Upward';

  @override
  String get trendDown => 'Downward';

  @override
  String get trendStable => 'Stable';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get sell => 'Sell';

  @override
  String get wait => 'Wait';

  @override
  String get hold => 'Hold';

  @override
  String get modelComparison => 'Model Comparison';

  @override
  String get selectModel => 'Select Model';

  @override
  String get movingAverage => 'Moving Average';

  @override
  String get linearRegression => 'Linear Regression';

  @override
  String get chronos => 'Chronos';

  @override
  String get prophet => 'Prophet';

  @override
  String get profitCalculator => 'Profit Calculator';

  @override
  String get transportCost => 'Transport Cost';

  @override
  String get quantity => 'Quantity (kg)';

  @override
  String get localPrice => 'Local Price (₹/kg)';

  @override
  String get remotePrice => 'Remote Price (₹/kg)';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String get calculate => 'Calculate';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get worthTransporting => 'Worth Transporting!';

  @override
  String get notWorthTransporting => 'Not Worth Transporting';

  @override
  String get createAlert => 'Create Alert';

  @override
  String get editAlert => 'Edit Alert';

  @override
  String get alertCondition => 'Alert Condition';

  @override
  String get priceAbove => 'Price Above';

  @override
  String get priceBelow => 'Price Below';

  @override
  String get targetPrice => 'Target Price';

  @override
  String get noAlerts => 'No alerts yet';

  @override
  String get noAlertsDescription =>
      'Create price alerts to get notified when prices reach your target.';

  @override
  String get alertCreated => 'Alert created successfully';

  @override
  String get alertDeleted => 'Alert deleted';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get notifications => 'Notifications';

  @override
  String get priceAlerts => 'Price Alerts';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data available';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get onboardingTitle1 => 'Track Crop Prices';

  @override
  String get onboardingDesc1 =>
      'Get real-time prices from markets across Tamil Nadu';

  @override
  String get onboardingTitle2 => 'AI Predictions';

  @override
  String get onboardingDesc2 =>
      'Advanced ML models predict future prices to help you decide when to sell';

  @override
  String get onboardingTitle3 => 'Smart Alerts';

  @override
  String get onboardingDesc3 =>
      'Set price alerts and get notified when the best time to sell arrives';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get voiceSearch => 'Voice Search';

  @override
  String get listening => 'Listening...';

  @override
  String get speakNow => 'Speak now...';
}
