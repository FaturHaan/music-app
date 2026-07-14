import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_locator.dart';
import 'app.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Load env
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Failed to load .env file, using default values.');
    }

    // Setup service locator (DI)
    await setupServiceLocator();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    runApp(MusicApp(hasSeenOnboarding: hasSeenOnboarding));
  } catch (e, stackTrace) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to initialize app:\n$e\n\n$stackTrace',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    ));
  }
}
