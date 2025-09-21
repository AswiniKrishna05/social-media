import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/mock_data_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/post_viewmodel.dart';
import 'viewmodels/api_post_viewmodel.dart';
import 'viewmodels/instagram_viewmodel.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/feed_screen.dart';
import 'views/home/api_feed_screen.dart';
import 'views/home/instagram_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  // Initialize mock data for demonstration
  // await MockDataService.initializeMockData();
  
  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PostViewModel()),
        ChangeNotifierProvider(create: (_) => ApiPostViewModel()),
        ChangeNotifierProvider(create: (_) => InstagramViewModel()),
      ],
      child: MaterialApp(
        title: 'Social Media Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/feed': (context) => const FeedScreen(),
          // '/api-feed': (context) => const ApiFeedScreen(),
          '/instagram-feed': (context) => const InstagramFeedScreen(),
        },
      ),
    );
  }
}
