import 'package:cornstalk/router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mngaqwitlscwcardwjqo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1uZ2Fxd2l0bHNjd2NhcmR3anFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc3ODYwNDQsImV4cCI6MjA0MzM2MjA0NH0.aoWRxxyV7e-SRgC5Y4F-os41Mie87PgSyVy5ppm4SHg',
  );
  runApp(const MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter(),
      title: 'CornStalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
    );
  }
}




