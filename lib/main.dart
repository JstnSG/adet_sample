import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black87,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnim;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    controller.forward();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final logged = await AuthService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            logged ? const DashboardScreen() : const Login(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Auth App",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Secure. Simple. Fast.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 32),
        child: Center(
          child: Text(
            "v1.0.0",
            style: TextStyle(
              fontSize: 11,
              color: Colors.black26,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
