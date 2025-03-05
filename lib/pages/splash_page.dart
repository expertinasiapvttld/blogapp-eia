import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/login_page.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/services/injector.dart';
import 'package:blog_app/utils/navigation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  BaseAuth baseAuth = injector.get();
  @override
  void initState() {
    super.initState();
    // FirebaseAuth.instance
    //     .authStateChanges()
    //     .listen((User user) {
    //   if (user == null) {
    //     print('User is currently signed out!');
    //   } else {
    //     print('User is signed in!');
    //   }
    // });

    if (baseAuth.getCurrentUser() != null) {
      baseAuth.getCurrentUser().then((user) {
        setState(() {
          if (user != null && user.uid!=null) {
            NavigationHelper.pushAndRemoveUntil(context, HomePage());
          }else{
            NavigationHelper.pushAndRemoveUntil(context, LoginPage());
          }
        });
      });
    } else {
      NavigationHelper.pushAndRemoveUntil(context, LoginPage());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}