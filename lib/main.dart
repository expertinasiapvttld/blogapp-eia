import 'package:blog_app/pages/login_page.dart';
import 'package:blog_app/pages/splash_page.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/services/injector.dart';
import 'package:blog_app/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  await Firebase.initializeApp();
  registerDependencies();
  runApp(MyApp());
}
BaseAuth baseAuth = injector.get();
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    );
  }
}
