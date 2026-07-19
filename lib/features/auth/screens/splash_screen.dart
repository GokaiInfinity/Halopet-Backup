import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), _next);
  }

  Future<void> _next() async {
    final auth = context.read<AuthProvider>();
    await auth.restoreSession();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context,
        auth.user == null ? AppRoutes.welcome : homeForRole(auth.user!.role));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        HaloPetLogo(size: 92),
        SizedBox(height: 22),
        Text('HaloPet',
            style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.text)),
        SizedBox(height: 8),
        Text('Care for every paw', style: TextStyle(color: AppColors.muted))
      ])));
}
