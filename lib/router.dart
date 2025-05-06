import 'package:cornstalk/pages/home_page.dart';
import 'package:cornstalk/pages/profile.dart';
import 'package:cornstalk/pages/sign_in.dart';
import 'package:cornstalk/pages/splash_screen.dart';
import 'package:cornstalk/pages/display_result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
GoRouter goRouter(){
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/',
      builder:  (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },),
      GoRoute(path: '/home',
      builder: (context, state){
        return const HomePage();
      }),
      GoRoute(path: '/auth',
      builder: (context, state) {
        return const SignIn();
      },),
      GoRoute(path: '/profile',
      builder: (context, state){
        return const Profile();
      },
      ),
      GoRoute(path: '/display_result',
      builder: (context, state){
        return const DisplayResult();
      },
      )
    ]
  );
}