import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  SharedPreferences prefs;

  final _formKey = new GlobalKey<FormState>();

  bool _autoValidate = false;
  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form

  bool _isIos;
  bool _isLoading;

  // Initially password is obscure
  bool _obscureText = true;

  FocusNode _emailFocus = FocusNode();

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      _autoValidate = true;
    });
    return false;
  }

  // Perform login or signup
  _validateAndSubmit() async {
    if (_validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        FirebaseAuth.instance
            .sendPasswordResetEmail(email: _email)
            .then((result) {
          setState(() {
            _email = "";
            _isLoading = false;
          });
          showSuccessAlert(
              "Email has been send to reset password. Please check inbox or spam folder");
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else {
            _errorMessage = e.message;
          }
        });
        showAlertDialog(context, _errorMessage);
      }
    }
  }

  showSuccessAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        backgroundColor: Colors.deepOrange,
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/bg_blog.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              _showBody(),
              getCircularProgress(_isLoading),
            ],
          ),
        ));
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(25.0),
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showTitleText(),
              _showEmailInput(),
              _showSubmitButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.white,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(

      tag:'tagImage',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/icon_white.png'),
        ),
      ),
    );
  }

  Widget _showTitleText() {
    return new Hero(
      tag: 'icon',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20.0,
              color: Colors.yellow,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 65.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: _emailFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.white),
        onFieldSubmitted: (term) {},
        decoration: new InputDecoration(
          hintText: HINT_EMAIL,
          hintStyle: new TextStyle(fontSize: 17.0, color: Colors.white54),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.white)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          labelText: HINT_EMAIL,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.white),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.black),
          prefixIcon: const Icon(
            Icons.mail,
            color: Colors.white,
          ),
        ),
        validator: validateEmail,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showSubmitButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(5.0, 40.0, 5.0, 0.0),
        child: SizedBox(
          height: 45.0,
          child: new RaisedButton(
            elevation: 3.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white,
            child: new Text(TITLE_SUBMIT,
                style: new TextStyle(fontSize: 20.0, color: Colors.deepOrange)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentNode, FocusNode nextFocus) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
