import 'package:blog_app/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  // Initial form is login form

  String appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: new AppBar(
        title: new Text("About Us"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showBody(),
        ],
      ),
    );
  }

  Widget _showBody() {
    return new Container(
      padding: EdgeInsets.all(25.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showLogo(),
          _showAppName(),
          _showContent(),
          _showAppVersion(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'icon',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/icon.png'),
        ),
      ),
    );
  }

  Widget _showAppName() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Container(
        child: new Text(
          APP_NAME,
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 25.0,
              color: Colors.deepOrange,
              wordSpacing: 0.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _showContent() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new Container(
        child: new Text(
          ABOUT_BLOG_APP,
          style: new TextStyle(
              fontSize: 17.0,
              color: Colors.black87,
              wordSpacing: 0.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _showAppVersion() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new Container(
        child: new Text(
          'App Version $appVersion',
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              wordSpacing: 0.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
