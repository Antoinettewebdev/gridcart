import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_shell.dart';
import 'onboarding_screen.dart';

const String _prefOnboardingDone = 'onboarding_complete';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _onboardingComplete = prefs.getBool(_prefOnboardingDone) ?? false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOnboardingDone, true);
    if (!mounted) return;
    setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_onboardingComplete!) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return MainShell(
      isDarkMode: widget.isDarkMode,
      onThemeToggle: widget.onThemeToggle,
    );
  }
}
