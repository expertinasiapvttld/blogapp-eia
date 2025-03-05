import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/pages/about_page.dart';
import 'package:blog_app/pages/edit_profile.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/my_post_page.dart';
import 'package:blog_app/pages/users_list.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/navigation_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  ProfilePage({Key key, this.userId,})
      : super(key: key);





  @override
  State<StatefulWidget> createState() => new ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  // Initial form is login form

  bool _isIos;
  bool _isLoading;
  UserModel loginUser;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    getUser().then((userData) {
      setState(() {
        loginUser = userData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new WillPopScope(
        onWillPop: goToHomePage,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: new AppBar(
            title: new Text("Profile"),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => goToHomePage(),
            ),
          ),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showBody(),
              getCircularProgress(_isLoading),
            ],
          ),
        ));
  }

  Future<bool> goToHomePage() {
   NavigationHelper.navigate(context, HomePage());
  }

  _signOut() async {
//    try {
//      await widget.signOut();
//      widget.onSignedOut();
//    } catch (e) {
//      print(e);
//    }
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(15.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildImageContainer(),
            _showUserInfo(),
            _showAboutData(),
            //_showCountData(),
            _showOptionsContainer(),
          ],
        ));
  }

  /// build image widget if image is available
  /// @imagePath : server imagePath
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  Widget _buildImageContainer() {
    if (loginUser == null) {
      return Container(
          margin: EdgeInsets.only(right: 10.0),
          child: Icon(
            Icons.account_circle,
            size: 150.0,
            color: Colors.deepOrange,
          ));
    } else if (loginUser.image.isEmpty) {
      return Container(
          margin: EdgeInsets.only(right: 10.0),
          child: Icon(
            Icons.account_circle,
            size: 150.0,
            color: Colors.deepOrange,
          ));
    } else {
      return Container(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
              width: 150.0,
              height: 150.0,
              padding: EdgeInsets.all(15.0),
            ),
            imageUrl: loginUser.image,
            width: 150.0,
            height: 150.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
          clipBehavior: Clip.hardEdge,
        ),
      );
    }
  }

  Widget _showUserInfo() {
    return new Padding(
      padding: EdgeInsets.all(10.0),
      child: new Column(
        children: <Widget>[
          new Text(loginUser == null ? '' : loginUser.name,
              textScaleFactor: 1.5,
              style: new TextStyle(
                color: Colors.black87,
                fontSize: 15.0,
              )),
          new Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0)),
          new Text(loginUser == null ? '' : loginUser.email,
              textScaleFactor: 1.5,
              style: new TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.black45,
                fontSize: 12.0,
              )),
        ],
      ),
    );
  }

  Widget _showAboutData() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 10.0),
      child: new Text(loginUser == null ? '' : loginUser.about,
          style: new TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontWeight: FontWeight.w300)),
    );
  }

  Widget _showCountData() {
    return new Padding(
      padding: EdgeInsets.all(20.0),
      child: new Row(
        children: <Widget>[
          new Container(
            width: 130,
            child: FlatButton(
              onPressed: () => {},
              color: Colors.transparent,
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Text("85",
                      maxLines: 1,
                      style: new TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 30.0,
                      )),
                  new Padding(padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0)),
                  Text("Published",
                      style: new TextStyle(
                        color: Colors.black45,
                        fontSize: 16.0,
                      ))
                ],
              ),
            ),
          ),
          new Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)),
          new Container(
            width: 130,
            child: FlatButton(
              onPressed: () => {},
              color: Colors.transparent,
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Text("100",
                      maxLines: 1,
                      style: new TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 30.0,
                      )),
                  new Padding(padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0)),
                  Text("Saved",
                      style: new TextStyle(
                        color: Colors.black45,
                        fontSize: 16.0,
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop!
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
    getUser().then((userData) {
      setState(() {
        loginUser = userData;
      });
    });
  }

  Widget _showOptionsContainer() {
    return new Padding(
      padding: EdgeInsets.all(2.0),
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Padding(padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0)),
            new FlatButton(
              child: SizedBox(
                  width: double.infinity,
                  child: new Row(
                    children: <Widget>[
                      Text('Edit Profile',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w300,
                            fontSize: 18.0,
                          )),
                    ],
                  )),
              onPressed: () {
                _navigateAndDisplaySelection(context);
              },
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
              child: new Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
            new FlatButton(
              child: SizedBox(
                width: double.infinity,
                child: Text('My Posts',
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                      fontSize: 18.0,
                    )),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPostPage(loginUser.id)),
                );
              },
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
              child: new Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
            new FlatButton(
              child: SizedBox(
                width: double.infinity,
                child: Text('Conversation',
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                      fontSize: 20.0,
                    )),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UsersListPage(currentUserId: loginUser.id)),
                );
              },
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
              child: new Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
            new FlatButton(
              child: SizedBox(
                width: double.infinity,
                child: Text('About Us',
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                      fontSize: 20.0,
                    )),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
              child: new Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
            new FlatButton(
              child: SizedBox(
                width: double.infinity,
                child: Text('Logout',
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                    )),
              ),
              onPressed: () => _logoutConfirmAlert(),
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutConfirmAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Alert"),
            content: new Text("Are you sure you want to logout?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog

              new FlatButton(
                child: new Text(
                  "NO",
                  style:
                      new TextStyle(fontSize: 14.0, color: Colors.deepOrange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  "YES",
                  style:
                      new TextStyle(fontSize: 14.0, color: Colors.deepOrange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _signOut();
                },
              ),
            ],
          );
        });
  }
}
