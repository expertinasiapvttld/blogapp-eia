import 'package:blog_app/pages/forgot_password_page.dart';
import 'package:blog_app/main.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/signup_page.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/navigation_helper.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);



  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
  FocusNode _passwordFocus = FocusNode();

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
      String userId = "";
      try {
        prefs = await SharedPreferences.getInstance();
        userId = await baseAuth.signIn(_email, _password);
        print('Singed In  user: $userId');
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          FirebaseFirestore.instance
              .collection(TABLE_USERS)
              .where("auth_id", isEqualTo: userId)
              .snapshots()
              .listen((data) {
            UserModel userModel = userFromJson(data.docs[0].data());
            prefs.setString(USER_ID, userModel.id);
            prefs.setString(AUTH_ID, userModel.auth_id);
            prefs.setString(USER_NAME, userModel.name);
            prefs.setString(USER_EMAIL, userModel.email);
            prefs.setString(USER_IMAGE, userModel.image);
            prefs.setString(USER_ABOUT, userModel.about);
            //showAlertDialog(context, "Login Successfully.");
            if (_validateAndSubmit != null) {
              NavigationHelper.pushAndRemoveUntil(context, HomePage());
            }
          });
        }
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

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );

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
              _showEmailInput(),
              _showPasswordInput(),
              _showForgotPassword(),
              _showLoginButton(),
              _showCreateAccountButton(),
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
      tag: 'icon',
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
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _emailFocus, _passwordFocus);
        },
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

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: new TextFormField(
        textInputAction: TextInputAction.done,
        maxLines: 1,
        obscureText: _obscureText,
        autofocus: false,
        focusNode: _passwordFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.white),
        onFieldSubmitted: (term) {
          _passwordFocus.unfocus();
          _validateAndSubmit();
        },
        decoration: new InputDecoration(
          hintText: HINT_PASSWORD,
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
          labelText: HINT_PASSWORD,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.white),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.black),
          prefixIcon: new Icon(
            Icons.lock,
            color: Colors.white,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(
                () {
                  _obscureText ? _obscureText = false : _obscureText = true;
                },
              );
            },
          ),
        ),
        validator: validatePassword,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showForgotPassword() {
    return new FlatButton(
      padding: EdgeInsets.fromLTRB(0.0, 25.0, 10.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(LABEL_FORGOT_PASSWORD,
            textAlign: TextAlign.right,
            style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
                color: Colors.yellow,
                fontStyle: FontStyle.italic)),
      ),
      onPressed: _changeFormToForgotPassword,
    );
  }

  Widget _showCreateAccountButton() {
    return new FlatButton(
      padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
      child: new Text.rich(
        TextSpan(
          text: LABEL_CREATE_AN_ACCOUNT,
          style: TextStyle(
              fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.w300),
          children: <TextSpan>[
            TextSpan(
                text: LABEL_CREATE_ACCOUNT,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600)),
            // can add more TextSpans here...
          ],
        ),
      ),
      onPressed: _changeFormToSignUp,
    );
  }

  Widget _showLoginButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
        child: SizedBox(
          height: 45.0,
          child: new RaisedButton(
            elevation: 3.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white,
            child: new Text(TITLE_LOGIN,
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

  void _changeFormToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }
}
