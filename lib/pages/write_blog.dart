import 'dart:io';

import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

class WriteBlog extends StatefulWidget {
  final String userId;
  Blogs blogs;

  WriteBlog({Key key, this.userId, this.blogs}) : super(key: key);

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://blogs-5f5f9.appspot.com');

  @override
  State<StatefulWidget> createState() => new _WriteBlogState(storage);
}

class _WriteBlogState extends State<WriteBlog> {
  final _formKey = new GlobalKey<FormState>();

  String _titleValue;
  String _contentValue;
  String _errorMessage;

  File fileToUpload;

  Future<File> _imageFile;

  bool _autoValidate = false;
  bool _isIos;
  bool _isLoading;

  FocusNode _titleFocus = FocusNode();
  FocusNode _contentFocus = FocusNode();

  FirebaseStorage storage;

  _WriteBlogState(this.storage);

  UserModel loginUser;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
    getUser().then((userData) {
      loginUser = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        backgroundColor: Colors.blueGrey[50],
        appBar: new AppBar(title: new Text(TITLE_WRITE_BLOG), actions: <Widget>[
          IconButton(
            icon: new Icon(
              Icons.photo_camera,
              color: Colors.white,
            ),
            onPressed: () => _mediaOptionsAlert(),
          ),
          IconButton(
            icon: new Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: _validateAndSubmit,
          ),
        ]),
        body: Stack(
          children: <Widget>[
            _showBody(),
            getCircularProgress(_isLoading),
          ],
        ));
  }

  /// Check if form is valid before perform save blog
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
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

  /// method used to validate and save blog
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  _validateAndSubmit() async {
    if (_validateAndSave()) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(TITLE_ALERT),
            content: new Text(MSG_SAVE_PUBLISH),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text(LABEL_SAVE),
                onPressed: () {
                  Navigator.of(context).pop();
                  invokeSaveBlogMethod(false);
                },
              ),
              new FlatButton(
                child: new Text(LABEL_SAVE_PUBLISH),
                onPressed: () {
                  Navigator.of(context).pop();
                  invokeSaveBlogMethod(true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  invokeSaveBlogMethod(bool isPublish) {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    if (fileToUpload != null) {
      _uploadFile(fileToUpload, isPublish);
    } else {
      widget.blogs != null
          ? updateBlog(widget.blogs.image, isPublish)
          : saveBlog("", isPublish);
    }
  }

  updateBlog(String url, bool isPublish) async {
    try {
      widget.blogs.description = _contentValue;
      widget.blogs.userId = loginUser.id;
      widget.blogs.title = _titleValue;
      widget.blogs.image = url;
      widget.blogs.completed = isPublish;
      widget.blogs.createdAt = DateTime.now().toString();
      widget.blogs.likes = new List();
      widget.blogs.comments = new List();
      widget.blogs.follow = new List();

      Firestore.instance
          .collection(TABLE_BLOG)
          .document(widget.blogs.id)
          .updateData(blogsToMap(widget.blogs))
          .then((data) {
        print('Save Success');
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          _isLoading = false;
        });
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

  /// method used to save blog to FireStore
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  saveBlog(String url, bool isPublish) async {
    try {
      Blogs blogs = new Blogs();
      blogs.description = _contentValue;
      blogs.userId = loginUser.id;
      blogs.title = _titleValue;
      blogs.image = url;
      blogs.completed = isPublish;
      blogs.createdAt = DateTime.now().toString();
      blogs.likes = new List();
      blogs.comments = new List();
      blogs.follow = new List();
      createNote(blogs).then((response) {
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
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

  createNote(Blogs blog) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(Firestore.instance.collection(TABLE_BLOG).document());
      blog.id = ds.documentID;
      var dataMap = blogsToMap(blog);
      await tx.set(ds.reference, dataMap);
      return dataMap;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return fromJson(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
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

  Future<void> _mediaOptionsAlert() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(TITLE_CHOOSE),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, LABEL_CAMERA);
                },
                child: const Text(LABEL_CAMERA),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, LABEL_GALLERY);
                },
                child: const Text(LABEL_GALLERY),
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

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showTitleInput(),
              _showContentInput(),
              _previewImage()
            ],
          ),
        ));
  }

  Widget _showTitleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: new TextFormField(
            initialValue: widget.blogs != null ? widget.blogs.title : '',
            maxLines: null,
            maxLength: 100,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.next,
            autofocus: false,
            focusNode: _titleFocus,
            onFieldSubmitted: (term) {
              _fieldFocusChange(context, _titleFocus, _contentFocus);
            },
            decoration: new InputDecoration(
              hintText: HINT_TITLE,
            ),
            validator: (value) => value.isEmpty ? ERR_MSG_EMPTY_TITLE : null,
            onSaved: (value) => _titleValue = value,
          )),
    );
  }

  Widget _showContentInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: new TextFormField(
            initialValue: widget.blogs != null ? widget.blogs.description : '',
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textInputAction: TextInputAction.done,
            autofocus: false,
            focusNode: _contentFocus,
            onFieldSubmitted: (term) {
              _contentFocus.unfocus();
              _validateAndSubmit();
            },
            decoration: new InputDecoration(
              hintText: HINT_CONTENT,
            ),
            validator: (value) => value.isEmpty ? ERR_MSG_EMPTY_CONTENT : null,
            onSaved: (value) => _contentValue = value,
          )),
    );
  }

  Widget _previewImage() {
    if (widget.blogs != null && widget.blogs.image.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: Container(
          child: Material(
            child: CachedNetworkImage(
              placeholder: (context, url) =>   Container(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
                width: screenWidth(context),
                height: 250.0,
              ),
              imageUrl: widget.blogs.image,
              width: screenWidth(context),
              height: 250.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: FutureBuilder<File>(
            future: _imageFile,
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return new Container(
                  width: screenWidth(context),
                  height: 250.0,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: new FileImage(snapshot.data),
                    fit: BoxFit.cover,
                  )),
                );
              } else if (snapshot.error != null) {
                return const Text(
                  ERR_MSG_IMAGE,
                  textAlign: TextAlign.center,
                );
              } else {
                return new Container();
              }
            }),
      );
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentNode, FocusNode nextFocus) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> _uploadFile(file, bool isPublish) async {
    String fileName = 'blog_${Uuid().v1()}';

    final Reference reference =
        widget.storage.ref().child(TABLE_BLOG_IMAGE).child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot storageTaskSnapshot = await uploadTask.snapshot;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//      var dowurl = downloadUrl;
//      String url = downloadUrl;
      if (widget.blogs != null) {
        updateBlog(downloadUrl, isPublish);
      } else {
        saveBlog(downloadUrl, isPublish);
      }
    }, onError: (err) {
      print(err);
    });
//    if (uploadTask.isComplete || uploadTask.isSuccessful) {
//    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
//    String url = dowurl.toString();
//    saveBlog(url, isPublish);
//    }
  }
}
