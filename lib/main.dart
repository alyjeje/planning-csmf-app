import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/api_service.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase (commenté tant que pas configuré)
  // await Firebase.initializeApp();
  
  // Initialiser les préférences
  final prefsService = PreferencesService();
  await prefsService.init();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<PreferencesService>.value(value: prefsService),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: const CSMFApp(),
    ),
  );
}

class CSMFApp extends StatelessWidget {
  const CSMFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSMF Planning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: CSMFColors.bleuPrimaire,
          secondary: CSMFColors.jaune,
          tertiary: CSMFColors.bleuSecondaire,
          primaryContainer: CSMFColors.jauneClair,
          onPrimaryContainer: CSMFColors.bleuPrimaire,
          surface: Colors.white,
          onSurface: Colors.grey[900]!,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: CSMFColors.bleuPrimaire,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: CSMFColors.jaune,
          foregroundColor: CSMFColors.bleuPrimaire,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: CSMFColors.jaune,
          backgroundColor: Colors.white,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: CSMFColors.bleuPrimaire,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return TextStyle(color: Colors.grey[600], fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: CSMFColors.bleuPrimaire);
            }
            return IconThemeData(color: Colors.grey[600]);
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: CSMFColors.jaune,
          secondary: CSMFColors.bleuSecondaire,
          tertiary: CSMFColors.bleuPrimaire,
          surface: const Color(0xFF1A1A2E),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: CSMFColors.jaune,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
