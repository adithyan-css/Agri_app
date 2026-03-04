import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agri_app/firebase_options.dart';
import 'package:agri_app/config/theme.dart';
import 'package:agri_app/config/routes.dart';
import 'package:agri_app/l10n/l10n.dart';
import 'package:agri_app/l10n/app_localizations.dart';
import 'package:agri_app/presentation/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AgriPriceApp()));
}

class AgriPriceApp extends ConsumerWidget {
  const AgriPriceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'AgriPrice AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
