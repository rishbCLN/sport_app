import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

/// Firebase configuration - Update this with your Firebase config
// TODO: Configure Firebase setup
// firebase_options.dart should be generated using FlutterFire CLI:
// flutterfire configure --project=<project-id>

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for premium black theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  // Uncomment and update with your Firebase configuration
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider can be added later when providers are needed
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => YourProvider()),
    //   ],
    //   child: MaterialApp(...),
    // );
    
    return MaterialApp(
      title: 'VIT Sports App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always use premium dark theme
      home: const HomeScreen(),
    );
  }
}
