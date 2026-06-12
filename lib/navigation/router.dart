import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/sign_translation_screen.dart';
import '../screens/speech_to_text_screen.dart';
import '../screens/mutual_communication_screen.dart';
import '../screens/learn_signs_screen.dart';
import '../screens/practice_test_screen.dart';
import '../screens/practice_selection_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/category_detail_screen.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  // Auth durumundaki değişiklikleri dinle
  refreshListenable: null, // Bu kısım main'de veya bir wrapper'da tetiklenebilir
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final isGuest = authProvider.isGuest;
    final isLoggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/signup' || 
                        state.matchedLocation == '/welcome' ||
                        state.matchedLocation == '/';

    // Kullanıcı giriş yapmamışsa ve misafir değilse, ana sayfalara gidemez
    if (!isAuthenticated && !isGuest) {
      return isLoggingIn ? null : '/welcome';
    }

    // Kullanıcı giriş yapmışsa (Gerçek kullanıcı), login/signup sayfalarına tekrar gidemez
    if (isAuthenticated && isLoggingIn && state.matchedLocation != '/') {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/sign-translation',
      name: 'sign_translation',
      builder: (context, state) => const SignTranslationScreen(),
    ),
    GoRoute(
      path: '/speech-to-text',
      name: 'speech_to_text',
      builder: (context, state) => const SpeechToTextScreen(),
    ),
    GoRoute(
      path: '/mutual-communication',
      name: 'mutual_communication',
      builder: (context, state) => const MutualCommunicationScreen(),
    ),
    GoRoute(
      path: '/learn-signs',
      name: 'learn_signs',
      builder: (context, state) => const LearnSignsScreen(),
    ),
    GoRoute(
      path: '/practice-test',
      name: 'practice_selection',
      builder: (context, state) => const PracticeSelectionScreen(),
    ),
    GoRoute(
      path: '/practice-quiz',
      name: 'practice_quiz',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['category'] ?? 'all';
        return PracticeTestScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/category-detail',
      name: 'category_detail',
      builder: (context, state) {
        final category = state.extra as Map<String, dynamic>;
        return CategoryDetailScreen(category: category);
      },
    ),
  ],
);
