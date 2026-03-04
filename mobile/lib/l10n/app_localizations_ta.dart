// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'அக்ரிபிரைஸ் AI';

  @override
  String get login => 'உள்நுழைய';

  @override
  String get register => 'பதிவு செய்ய';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get name => 'பெயர்';

  @override
  String get enterPhoneNumber => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get enterPassword => 'கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get enterName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get dontHaveAccount => 'கணக்கு இல்லையா?';

  @override
  String get alreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get signUp => 'பதிவு செய்';

  @override
  String get signIn => 'உள்நுழை';

  @override
  String get otpVerification => 'OTP சரிபார்ப்பு';

  @override
  String enterOtp(String phone) {
    return '$phone க்கு அனுப்பப்பட்ட OTP ஐ உள்ளிடவும்';
  }

  @override
  String get verify => 'சரிபார்';

  @override
  String get resendOtp => 'OTP மீண்டும் அனுப்பு';

  @override
  String get home => 'முகப்பு';

  @override
  String get dashboard => 'டாஷ்போர்டு';

  @override
  String get crops => 'பயிர்கள்';

  @override
  String get markets => 'சந்தைகள்';

  @override
  String get predictions => 'கணிப்புகள்';

  @override
  String get alerts => 'எச்சரிக்கைகள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get todayPrices => 'இன்றைய விலைகள்';

  @override
  String get priceTrend => 'விலை போக்கு';

  @override
  String pricePerKg(String price) {
    return '₹$price/கிலோ';
  }

  @override
  String get viewAll => 'அனைத்தையும் காண';

  @override
  String get seeMore => 'மேலும் பார்';

  @override
  String get cropDetails => 'பயிர் விவரங்கள்';

  @override
  String get latestPrice => 'சமீபத்திய விலை';

  @override
  String get priceHistory => 'விலை வரலாறு';

  @override
  String get last30Days => 'கடந்த 30 நாட்கள்';

  @override
  String get last90Days => 'கடந்த 90 நாட்கள்';

  @override
  String get nearbyMarkets => 'அருகிலுள்ள சந்தைகள்';

  @override
  String get allMarkets => 'அனைத்து சந்தைகள்';

  @override
  String get marketDetails => 'சந்தை விவரங்கள்';

  @override
  String get distance => 'தூரம்';

  @override
  String kmAway(String km) {
    return '$km கி.மீ. தொலைவில்';
  }

  @override
  String get searchMarkets => 'சந்தைகளைத் தேடு...';

  @override
  String get pricePrediction => 'விலை கணிப்பு';

  @override
  String get forecast => 'முன்னறிவிப்பு';

  @override
  String days(int count) {
    return '$count நாட்கள்';
  }

  @override
  String get confidence => 'நம்பகத்தன்மை';

  @override
  String get trend => 'போக்கு';

  @override
  String get trendUp => 'மேல்நோக்கி';

  @override
  String get trendDown => 'கீழ்நோக்கி';

  @override
  String get trendStable => 'நிலையானது';

  @override
  String get recommendation => 'பரிந்துரை';

  @override
  String get sell => 'விற்கவும்';

  @override
  String get wait => 'காத்திருக்கவும்';

  @override
  String get hold => 'வைத்திருக்கவும்';

  @override
  String get modelComparison => 'மாதிரி ஒப்பீடு';

  @override
  String get selectModel => 'மாதிரியைத் தேர்ந்தெடு';

  @override
  String get movingAverage => 'நகரும் சராசரி';

  @override
  String get linearRegression => 'நேரியல் பின்னடைவு';

  @override
  String get chronos => 'க்ரோனோஸ்';

  @override
  String get prophet => 'புரோபெட்';

  @override
  String get profitCalculator => 'லாப கணிப்பான்';

  @override
  String get transportCost => 'போக்குவரத்து செலவு';

  @override
  String get quantity => 'அளவு (கிலோ)';

  @override
  String get localPrice => 'உள்ளூர் விலை (₹/கிலோ)';

  @override
  String get remotePrice => 'தொலை விலை (₹/கிலோ)';

  @override
  String get distanceKm => 'தூரம் (கி.மீ)';

  @override
  String get calculate => 'கணக்கிடு';

  @override
  String get netProfit => 'நிகர லாபம்';

  @override
  String get worthTransporting => 'போக்குவரத்து செய்வது மதிப்புள்ளது!';

  @override
  String get notWorthTransporting => 'போக்குவரத்து செய்வது மதிப்பற்றது';

  @override
  String get createAlert => 'எச்சரிக்கை உருவாக்கு';

  @override
  String get editAlert => 'எச்சரிக்கை திருத்து';

  @override
  String get alertCondition => 'எச்சரிக்கை நிபந்தனை';

  @override
  String get priceAbove => 'விலை அதிகமாக';

  @override
  String get priceBelow => 'விலை குறைவாக';

  @override
  String get targetPrice => 'இலக்கு விலை';

  @override
  String get noAlerts => 'எச்சரிக்கைகள் இல்லை';

  @override
  String get noAlertsDescription =>
      'விலை உங்கள் இலக்கை அடையும்போது அறிவிப்பு பெற விலை எச்சரிக்கைகளை உருவாக்கவும்.';

  @override
  String get alertCreated => 'எச்சரிக்கை வெற்றிகரமாக உருவாக்கப்பட்டது';

  @override
  String get alertDeleted => 'எச்சரிக்கை நீக்கப்பட்டது';

  @override
  String get language => 'மொழி';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get priceAlerts => 'விலை எச்சரிக்கைகள்';

  @override
  String get clearCache => 'தற்காலிக சேமிப்பை அழி';

  @override
  String get about => 'பற்றி';

  @override
  String version(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get termsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get error => 'ஏதோ தவறு நடந்தது';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get noData => 'தரவு இல்லை';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get save => 'சேமி';

  @override
  String get delete => 'நீக்கு';

  @override
  String get confirm => 'உறுதிப்படுத்து';

  @override
  String get search => 'தேடு';

  @override
  String get refresh => 'புதுப்பி';

  @override
  String get onboardingTitle1 => 'பயிர் விலைகளை கண்காணிக்கவும்';

  @override
  String get onboardingDesc1 =>
      'தமிழ்நாடு முழுவதும் சந்தைகளிலிருந்து நிகழ்நேர விலைகளைப் பெறுங்கள்';

  @override
  String get onboardingTitle2 => 'AI கணிப்புகள்';

  @override
  String get onboardingDesc2 =>
      'எப்போது விற்பது என்று முடிவெடுக்க மேம்பட்ட ML மாதிரிகள் எதிர்கால விலைகளை கணிக்கின்றன';

  @override
  String get onboardingTitle3 => 'புத்திசாலி எச்சரிக்கைகள்';

  @override
  String get onboardingDesc3 =>
      'விலை எச்சரிக்கைகளை அமைத்து, விற்க சிறந்த நேரம் வரும்போது அறிவிப்பைப் பெறுங்கள்';

  @override
  String get getStarted => 'தொடங்கு';

  @override
  String get skip => 'தவிர்';

  @override
  String get next => 'அடுத்தது';

  @override
  String get voiceSearch => 'குரல் தேடல்';

  @override
  String get listening => 'கேட்கிறது...';

  @override
  String get speakNow => 'இப்போது பேசுங்கள்...';
}
