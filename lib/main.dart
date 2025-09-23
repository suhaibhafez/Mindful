import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mindful/screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A), // dark navy blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1B263B), // Deep blue-grey
          secondary: Color(0xFF415A77), // Muted steel blue

          surface: Color(0xFF1B263B),
          onPrimary: Colors.white,
          onSecondary: Colors.white,

          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B263B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF415A77),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white70),

          labelStyle: const TextStyle(
            color: Color.fromARGB(110, 255, 255, 255),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF778DA9),
            overlayColor: Colors.transparent,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF415A77),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white.withAlpha(12),
          elevation: 4,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Colors.grey[800]?.withAlpha(
              200,
            ), // Dark semi-transparent background
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          waitDuration: const Duration(
            milliseconds: 500,
          ), // Delay before showing tooltip
          showDuration: const Duration(
            seconds: 3,
          ), // How long tooltip stays visible
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          preferBelow: false, // Tooltip appears below the widget if possible
          verticalOffset: -100,
          // Distance from the widget
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF778DA9); // Light steel blue when selected
            }
            return const Color(
              0xFF415A77,
            ); // Muted steel blue when not selected
          }),
          checkColor: WidgetStateProperty.all(
            const Color.fromARGB(250, 78, 75, 75),
          ), // checkmark color
          overlayColor: WidgetStateProperty.all(
            Colors.white24,
          ), // ripple color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: const BorderSide(
            color: Color.fromARGB(50, 255, 255, 255),
            width: 1.5,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            foregroundColor: Colors.white,
            side: const BorderSide(
              width: 0.3,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const Mainscreen();
        }
        return const AuthScreen();
      },
    );
  }
}
