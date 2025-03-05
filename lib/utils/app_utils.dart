import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showToast(String message) {
//  Fluttertoast.showToast(
//      msg: message,
//      toastLength: Toast.LENGTH_SHORT,
//      gravity: ToastGravity.BOTTOM,
//      timeInSecForIos: 2,
//      backgroundColor: Colors.red,
//      textColor: Colors.white,
//      fontSize: 16.0);
}

void showSnackBar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(new SnackBar(
    content: new Text("Sending Message"),
  ));
}

Future<UserModel> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  UserModel userModel = new UserModel();
  userModel.id = prefs.getString(USER_ID) ?? '';
  userModel.auth_id = prefs.getString(AUTH_ID) ?? '';
  userModel.name = prefs.getString(USER_NAME) ?? '';
  userModel.email = prefs.getString(USER_EMAIL) ?? '';
  userModel.image = prefs.getString(USER_IMAGE) ?? '';
  userModel.about = prefs.getString(USER_ABOUT) ?? '';
  return userModel;
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

showAlertDialog(BuildContext context, String contentMsg) {
  // flutter defined function
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Alert"),
        content: new Text(contentMsg),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(
              "OK",
              style: TextStyle(color: Colors.deepOrange),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget getCircularProgress(bool _isLoading) {
  if (_isLoading) {
    return new Stack(
      children: [
        new Opacity(
          opacity: 0.3,
          child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        new Center(
          child: new CircularProgressIndicator(),
        ),
      ],
    );
  }
  return Container();
}

String validatePassword(String value) {
  if (value == null || value.isEmpty)
    return MSG_ENTER_PASSWORD;
  else if (value.length < 6)
    return MSG_INVALID_PASSWORD;
  else
    return null;
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (value == null || value.isEmpty)
    return ERR_MSG_EMPTY_EMAIL;
  else if (!regex.hasMatch(value))
    return MSG_ENTER_VALID_EMAIL;
  else
    return null;
}

String validateEmptyText(String value) {
  if (value == null || value.isEmpty)
    return MSG_ENTER_NAME;
  else
    return null;
}

String getFormattedDateTime(String dateTime) {
  DateTime todayDate = DateTime.parse(dateTime);
  print(todayDate);
  String formattedDateTime = DateFormat('dd MMM hh:mm a').format(todayDate);
  print(formattedDateTime);
  return formattedDateTime;
}
