import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/crop_detail/crop_detail_screen.dart';
import '../presentation/screens/predictions/prediction_screen.dart';
import '../presentation/screens/predictions/predictions_screen.dart';
import '../presentation/screens/markets/nearby_markets_screen.dart';
import '../presentation/screens/markets/markets_screen.dart';
import '../presentation/screens/markets/market_detail_screen.dart';
import '../presentation/screens/markets/profit_calculator_screen.dart';
import '../presentation/screens/prices/prices_screen.dart';
import '../presentation/screens/alerts/alerts_screen.dart';
import '../presentation/screens/alerts/create_alert_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/ai_analysis/ai_recommendation_screen.dart';
import '../presentation/screens/transport/available_transport_screen.dart';
import '../presentation/screens/transport/book_transport_screen.dart';
import '../presentation/screens/transport/my_bookings_screen.dart';
import '../presentation/screens/weather/weather_impact_screen.dart';

/// Routes that don't require authentication
const _publicRoutes = {'/splash', '/onboarding', '/login', '/register'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final path = state.matchedLocation;
    if (_publicRoutes.contains(path)) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/login';

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/crop-detail/:cropId',
      builder: (context, state) {
        final cropName = state.uri.queryParameters['name'] ?? 'Crop';
        return CropDetailScreen(
          cropId: state.pathParameters['cropId']!,
          cropName: cropName,
        );
      },
    ),
    GoRoute(
      path: '/markets',
      builder: (context, state) => const MarketsScreen(),
    ),
    GoRoute(
      path: '/market-detail/:marketId',
      builder: (context, state) {
        return MarketDetailScreen(
          marketId: state.pathParameters['marketId']!,
        );
      },
    ),
    GoRoute(
      path: '/nearby-markets',
      builder: (context, state) => const NearbyMarketsScreen(),
    ),
    GoRoute(
      path: '/prices',
      builder: (context, state) => const PricesScreen(),
    ),
    GoRoute(
      path: '/predictions',
      builder: (context, state) => const PredictionsScreen(),
    ),
    GoRoute(
      path: '/predictions/:cropId/:marketId',
      builder: (context, state) {
        final cropName = state.uri.queryParameters['name'] ?? 'Crop';
        return PredictionScreen(
          cropId: state.pathParameters['cropId']!,
          marketId: state.pathParameters['marketId']!,
          cropName: cropName,
        );
      },
    ),
    GoRoute(
      path: '/profit-calculator',
      builder: (context, state) => const TransportProfitScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/alerts/create',
      builder: (context, state) {
        final cropId = state.uri.queryParameters['cropId'];
        final cropName = state.uri.queryParameters['cropName'];
        return CreateAlertScreen(
          initialCropId: cropId,
          initialCropName: cropName,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/ai-analysis/:cropId/:marketId',
      builder: (context, state) {
        final cropName = state.uri.queryParameters['name'] ?? 'Crop';
        return AiRecommendationScreen(
          cropId: state.pathParameters['cropId']!,
          marketId: state.pathParameters['marketId']!,
          cropName: cropName,
        );
      },
    ),
    GoRoute(
      path: '/transport',
      builder: (context, state) => const AvailableTransportScreen(),
    ),
    GoRoute(
      path: '/transport/book',
      builder: (context, state) {
        final truckId = state.uri.queryParameters['truckId'];
        return BookTransportScreen(truckId: truckId);
      },
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/weather',
      builder: (context, state) {
        final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '');
        final lon = double.tryParse(state.uri.queryParameters['lon'] ?? '');
        final name = state.uri.queryParameters['name'];
        return WeatherImpactScreen(lat: lat, lon: lon, locationName: name);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.error}')),
  ),
);
