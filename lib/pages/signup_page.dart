import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/login_page.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/services/injector.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/navigation_helper.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  BaseAuth baseAuth = injector.get();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  SharedPreferences prefs;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String _email;
  String _name;
  String _password;
  String _errorMessage;

  bool _isIos;
  bool _isLoading;

  // Initially password is obscure
  bool _obscureText = true;

  // Check if form is valid before perform signup
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

  // Perform signup
  _validateAndSubmit() async {
    if (_validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });

      String authId = "";
      try {
        prefs = await SharedPreferences.getInstance();

        authId = await baseAuth.signUp(_email, _password);
        print('Signed up user: $authId');

        if (authId.length > 0 && authId != null) {
          baseAuth.getCurrentUser().then((response) {
            UserModel userModel = new UserModel();
            userModel.email = response.email;
            userModel.auth_id = authId;
            userModel.name = _name;
            userModel.image = '';
            userModel.about = '';
            String userDocumentID =
                FirebaseFirestore.instance.collection(TABLE_USERS).doc().id;
            userModel.id = userDocumentID;

            FirebaseFirestore.instance
                .collection(TABLE_USERS)
                .doc(userDocumentID)
                .set(userToMap(userModel))
                .then((responseData) {
              prefs.setString(USER_NAME, userModel.name);
              prefs.setString(USER_EMAIL, userModel.email);
              prefs.setString(USER_IMAGE, userModel.image);
              prefs.setString(USER_ABOUT, userModel.about);
              setState(() {
                _isLoading = false;
              });
              showAlertDialog(context, "Register Success.");
              if (_validateAndSubmit() != null) {
               NavigationHelper.pushAndRemoveUntil(context, HomePage());
              }
            });
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
       // showAlertDialog(context,e.toString());
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  Future<bool> _changeFormToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new WillPopScope(
        onWillPop: _changeFormToLoginPage,
        child: new Scaffold(
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
            )));
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
              _showNameInput(),
              _showEmailInput(),
              _showPasswordInput(),
              _showCreateAccountButton(),
              _showHaveAccountButton(),
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

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
      child: new TextFormField(
        textInputAction: TextInputAction.next,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        focusNode: _nameFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.white),
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _nameFocus, _emailFocus);
        },
        decoration: new InputDecoration(
          hintText: HINT_NAME,
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
          labelText: HINT_NAME,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.white),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.black),
          prefixIcon: new Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        validator: (value) => value.isEmpty ? ERR_MSG_EMPTY_NAME : null,
        onSaved: (value) => _name = value,
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        textInputAction: TextInputAction.next,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedErrorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            labelText: HINT_EMAIL,
            labelStyle: new TextStyle(fontSize: 17.0, color: Colors.white),
            errorStyle: new TextStyle(fontSize: 12.0, color: Colors.black),
            prefixIcon: new Icon(
              Icons.mail,
              color: Colors.white,
            )),
        validator: validateEmail,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
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
            )),
        validator: validatePassword,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showHaveAccountButton() {
    return new FlatButton(
      child: new Text.rich(
        TextSpan(
          text: LABEL_HAVE_ACCOUNT,
          style: TextStyle(
              fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.w300),
          children: <TextSpan>[
            TextSpan(
                text: TITLE_LOGIN,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600)),
            // can add more TextSpans here...
          ],
        ),
      ),
      onPressed: _changeFormToLoginPage,
    );
  }

  Widget _showCreateAccountButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(5.0, 45.0, 5.0, 0.0),
        child: SizedBox(
          height: 45.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.white,
            child: new Text(LABEL_CREATE_ACCOUNT,
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
