import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart'; // 1. Added for permissions

// Screens & Services
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart'; 
import 'screens/auth/signup_screen.dart'; 
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/sms_service.dart'; // 2. Import your service

// Providers
import 'providers/auth_provider.dart';

void main() async {
  // 3. Ensure Flutter bindings are initialized for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Request SMS and Battery permissions
  await _initializePermissionsAndServices();

  runApp(
    const ProviderScope(
      child: KesTrackerApp(),
    ),
  );
}

Future<void> _initializePermissionsAndServices() async {
  // Request SMS permission
  final smsStatus = await Permission.sms.request();
  
  // Request Battery Optimization bypass (Crucial for background automation)
  // This prevents Android from killing the SMS listener when the phone is idle
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }

  if (smsStatus.isGranted) {
    // 5. Start the M-Pesa listener
    await SmsService.initialize();
    print("SMS Listener Initialized");
  } else {
    print("SMS Permission Denied - Automation will not work");
  }
}

class KesTrackerApp extends ConsumerWidget { 
  const KesTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'KES Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00C853), 
          error: const Color(0xFFFF9100),     
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      // Logic: Start at Splash to allow the AuthProvider to load the token
      home: authState.token != null 
          ? const DashboardScreen() 
          : const SplashScreen(), 
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}