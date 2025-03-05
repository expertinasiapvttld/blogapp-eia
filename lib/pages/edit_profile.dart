import 'dart:io';

import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EditProfilePage extends StatefulWidget {
  final FirebaseStorage storage =
      // ignore: deprecated_member_use
      FirebaseStorage(storageBucket: 'gs://blogs-5f5f9.appspot.com');

  @override
  State<StatefulWidget> createState() => new EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // Initial form is login form
  SharedPreferences prefs;
  final _formKey = new GlobalKey<FormState>();

  bool _autoValidate = false;
  String _name;
  String _about;

  bool _isLoading;
  FocusNode _emailFocus = FocusNode();
  FocusNode _nameFocus = FocusNode();
  FocusNode _aboutFocus = FocusNode();
  UserModel loginUser;

  File fileToUpload;

  Future<File> _imageFile;

  @override
  void initState() {
    _isLoading = false;
    fileToUpload = null;
    super.initState();
    getUser().then((userData) {
      setState(() {
        loginUser = userData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: new AppBar(
        title: new Text("Edit Profile"),
        actions: <Widget>[
          new FlatButton(
            child: Text('Save',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                )),
            onPressed: () {
              _onSaveClick();
            },
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showBody(),
          getCircularProgress(_isLoading),
        ],
      ),
    );
  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(15.0),
        child: new Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildImageContainer(loginUser.image),
                _showUploadPicButton(),
                _showEmailInput(),
                _showNameInput(),
                _showAboutInput(),
              ],
            )));
  }

  /// build image widget if image is available
  /// @imagePath : server imagePath
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  Widget _buildImageContainer(String imagePath) {
    if (fileToUpload == null) {
      print('Live path $imagePath');
      return ((imagePath == null || imagePath.isEmpty)
          ? Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.account_circle,
                size: 150.0,
                color: Colors.deepOrange,
              ))
          : Container(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) =>  Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                    ),
                    width: 150.0,
                    height: 150.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: imagePath,
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(100.0)),
                clipBehavior: Clip.hardEdge,
              ),
            ));
    } else {
      return Material(
        child: Image.file(
          fileToUpload,
          width: 150.0,
          height: 150.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(150.0)),
        clipBehavior: Clip.hardEdge,
      );
    }
  }

  Widget _showUploadPicButton() {
    return new Padding(
      padding: EdgeInsets.all(2.0),
      child: new Column(
        children: <Widget>[
          new FlatButton(
            child: new Text('Change Photo',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w300,
                  fontSize: 18.0,
                )),
            onPressed: () {
              _mediaOptionsAlert();
            },
          ),
        ],
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
      child: new TextFormField(
        enabled: false,
        initialValue: loginUser.email,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: _emailFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.grey),
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _emailFocus, _nameFocus);
        },
        decoration: new InputDecoration(
          hintText: HINT_EMAIL,
          hintStyle: new TextStyle(fontSize: 17.0, color: Colors.grey),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.grey)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          labelText: HINT_EMAIL,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.grey),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.red),
          prefixIcon: const Icon(
            Icons.mail,
            size: 24,
            color: Colors.grey,
          ),
        ),
        validator: validateEmail,
      ),
    );
  }

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 0.0),
      child: new TextFormField(
        initialValue: loginUser.name,
        maxLines: 1,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: _nameFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.black87),
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _nameFocus, _aboutFocus);
        },
        decoration: new InputDecoration(
          hintText: HINT_NAME,
          hintStyle: new TextStyle(fontSize: 17.0, color: Colors.grey),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.black87)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          labelText: HINT_NAME,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.black87),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.red),
          prefixIcon: const Icon(
            Icons.person,
            size: 24,
            color: Colors.black87,
          ),
        ),
        validator: validateEmptyText,
        onSaved: (value) => _name = value,
      ),
    );
  }

  Widget _showAboutInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 0.0),
      child: new TextFormField(
        initialValue: loginUser.about,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        textInputAction: TextInputAction.done,
        autofocus: false,
        focusNode: _aboutFocus,
        style: new TextStyle(fontSize: 17.0, color: Colors.black87),
        onFieldSubmitted: (term) {
          _aboutFocus.unfocus();
          _onSaveClick();
        },
        decoration: new InputDecoration(
          hintText: HINT_ABOUT,
          hintStyle: new TextStyle(fontSize: 17.0, color: Colors.grey),
          focusedBorder: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.black87)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          labelText: HINT_ABOUT,
          labelStyle: new TextStyle(fontSize: 17.0, color: Colors.black87),
          errorStyle: new TextStyle(fontSize: 12.0, color: Colors.red),
          prefixIcon: const Icon(
            Icons.speaker_notes,
            color: Colors.black87,
            size: 24,
          ),
        ),
        validator: (value) => value.isEmpty ? null : null,
        onSaved: (value) => _about = value,
      ),
    );
  }

  Future<void> _mediaOptionsAlert() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              TITLE_CHOOSE,
              style: TextStyle(fontSize: 20.0, color: Colors.deepOrange),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, LABEL_CAMERA);
                },
                child: const Text(
                  LABEL_CAMERA,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w300),
                ),
              ),
              new Padding(padding: EdgeInsets.all(3.0)),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, LABEL_GALLERY);
                },
                child: const Text(
                  LABEL_GALLERY,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ],
          );
        })) {
      case LABEL_CAMERA:
        _onCameraClick(ImageSource.camera);
        break;
      case LABEL_GALLERY:
        _onCameraClick(ImageSource.gallery);
        break;
    }
  }

  Future _onCameraClick(ImageSource source) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: source);
      getFileImage();
    });
  }

  void getFileImage() async {
    var dir = await path_provider.getTemporaryDirectory();

    _imageFile.then((file) async {
      final String uuid = Uuid().v1();
      var targetPath = dir.absolute.path + "/$uuid.jpeg";
      var imgFile = await testCompressAndGetFile(file, targetPath);
      print("File Path : " + imgFile.path);
      setState(() {
        fileToUpload = imgFile;
      });
    });
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print("testCompressAndGetFile");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80, /*
      minWidth: 720,
      minHeight: 1280,*/
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentNode, FocusNode nextFocus) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool _validateAndSubmit() {
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

  void _onSaveClick() {
    setState(() {
      _isLoading = true;
    });
    print('Save click');
    if (_validateAndSubmit()) {
      print('Save click -- valid');
      if (fileToUpload != null) {
//        _uploadFile(fileToUpload);
      } else {
        updateUser(loginUser);
      }
    } else {
      print('Save click -- invalid');
    }
  }

  Future<void> _uploadFile(file) async {
    String fileName = 'user_${Uuid().v1()}';
    final Reference reference =
        widget.storage.ref().child(TABLE_USER_IMAGE).child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      loginUser.image = downloadUrl;
      updateUser(loginUser);
    }, onError: (err) {
      print(err);
    });
  }

  updateUser(UserModel user) async {
    prefs = await SharedPreferences.getInstance();
    if (_name.isNotEmpty) {
      user.name = _name;
    }
    if (_about.isNotEmpty) {
      user.about = _about;
    }

    FirebaseFirestore.instance
        .collection(TABLE_USERS)
        .doc(user.id)
        .update(userToMap(user))
        .then((data) {
      print('Save Success');
      prefs.setString(USER_NAME, user.name);
      prefs.setString(USER_IMAGE, user.image);
      prefs.setString(USER_ABOUT, user.about);
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
    });

//    prefs = await SharedPreferences.getInstance();
//    final TransactionHandler updateTransaction = (Transaction tx) async {
//      final DocumentSnapshot ds = await tx
//          .get(Firestore.instance.collection(TABLE_USERS).document(user.id));
//
//      await tx.update(ds.reference, userToMap(user));
//      return {'updated': true};
//    };
//
//    return Firestore.instance
//        .runTransaction(updateTransaction)
//        .then((result) => setState(() {
//              _isLoading = false;
//              prefs.setString(USER_NAME, user.name);
//              prefs.setString(USER_IMAGE, user.image);
//              prefs.setString(USER_ABOUT, user.about);
//              Navigator.pop(context);
//            }))
//        .catchError((error) {
//      print('error: $error');
//      return false;
//    });
  }
}
