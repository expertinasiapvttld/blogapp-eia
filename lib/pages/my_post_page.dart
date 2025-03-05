import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/comment_table.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/pages/chat.dart';
import 'package:blog_app/pages/write_blog.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyPostPage extends StatefulWidget {
  MyPostPage(this.userId);

  final String userId;

  @override
  State<StatefulWidget> createState() => new MyPostPageState();
}

class MyPostPageState extends State<MyPostPage> {
  List<Blogs> _savedBlogsList = new List();
  List<Blogs> _publishBlogsList = new List();
  FirebaseFirestore _database = FirebaseFirestore.instance;

  bool _isLoading;
  UserModel loginUser;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getUser().then((userData) {
      loginUser = userData;
    });
    getSavedBlogsList();
    getPublishedBlogList();
  }

  getSavedBlogsList() {
    _database
        .collection(TABLE_BLOG)
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _savedBlogsList.clear();
      data.docs.forEach((doc) {
        Blogs blogs = fromJson(doc.data());
        setState(() {
          _savedBlogsList.add(blogs);
        });
      });
    });
  }

  getPublishedBlogList() {
    _database
        .collection(TABLE_BLOG)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _publishBlogsList.clear();
      data.docs.forEach((doc) {
        Blogs blogs = fromJson(doc.data());
        setState(() {
          _publishBlogsList.add(blogs);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: AppBar(
          title: new Text(TITLE_MY_POST),
          bottom: TabBar(
              labelStyle:
                  new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.5, color: Colors.white),
                  insets: EdgeInsets.symmetric(horizontal: 16.0)),
              tabs: [
                Tab(
                  text: 'Saved',
                ),
                Tab(
                  text: 'Published',
                ),
              ]),
        ),
        body: _bodyWidget(),
      ),
    );
  }

  Widget _bodyWidget() {
    return new TabBarView(children: [
      _contentSavedPost(),
      _contentPublishedPost(),
    ]);
  }

  Widget _contentSavedPost() {
    return new Stack(
      children: <Widget>[
        _savedListWidget(),
        getCircularProgress(_isLoading),
      ],
    );
  }

  /// build row for list
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  Widget _savedListWidget() {
    if (_savedBlogsList != null && _savedBlogsList.length > 0) {
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: _savedBlogsList.length,
        itemBuilder: (BuildContext context, int index) {
          Blogs blogs = _savedBlogsList[index];
          return GestureDetector(
              child: new Slidable(
                actionPane: SlidableDrawerActionPane(),
                //delegate: new SlidableDrawerDelegate(),
                actionExtentRatio: 0.25,
                child: SizedBox(
                  width: screenWidth(context),
                  child: new Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildImageContainer(blogs.image),
                              Container(
                                  width: (screenWidth(context) - 110),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: blogs.title,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 5.0),
                                        child: RichText(
                                          maxLines: 3,
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: blogs.description,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, top: 5.0),
                                          child: Text(
                                            getFormattedDateTime(
                                                blogs.createdAt),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                                fontStyle: FontStyle.italic),
                                          ))
                                    ],
                                  ))
                            ])),
                  ),
                ),
                secondaryActions: <Widget>[
                  new IconSlideAction(
                    caption: 'Publish',
                    color: Colors.green,
                    icon: Icons.publish,
                    onTap: () => showSnackBar(context, 'Edit'),
                  ),
                  new IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.edit,
                    onTap: () => showSnackBar(context, 'Edit'),
                  ),
                  new IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => showSnackBar(context, 'Delete'),
                  ),
                ],
              ),
              onTap: () => onItemCLick(index));
        },
      );
    } else {
      return Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "You don't have any saved blogs.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          new Padding(padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0)),
          new RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WriteBlog(userId: loginUser.id)),
              );
            },
            textColor: Colors.white,
            color: Colors.deepOrange,
            padding: EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0),
            child: new Text(
              CREATE_BLOG,
              style: TextStyle(fontSize: 17.0),
            ),
          ),
        ],
      ));
    }
  }

  /// build image widget if image is available
  /// @imagePath : server imagePath
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  Widget _buildImageContainer(String imagePath) {
    return ((imagePath == null || imagePath.isEmpty)
        ? Container(
            margin: EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.account_circle,
              size: 60.0,
              color: Colors.grey,
            ))
        : Container(
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) =>   Container(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ),
                  width: 60.0,
                  height: 60.0,
                  padding: EdgeInsets.all(15.0),
                ),
                imageUrl: imagePath,
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              clipBehavior: Clip.hardEdge,
            ),
            margin: EdgeInsets.only(right: 10.0),
          ));
  }

  Widget _contentPublishedPost() {
    if (_publishBlogsList != null && _publishBlogsList.length > 0) {
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: _publishBlogsList.length,
        itemBuilder: (BuildContext context, int index) {
          Blogs blogs = _publishBlogsList[index];
          return GestureDetector(
              child: new Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: SizedBox(
                  width: screenWidth(context),
                  child: new Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildImageContainer(blogs.image),
                              Container(
                                  width: (screenWidth(context) - 110),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: blogs.title,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 5.0),
                                        child: RichText(
                                          maxLines: 2,
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: blogs.description,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, top: 5.0),
                                          child: Text(
                                            getFormattedDateTime(
                                                blogs.createdAt),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                                fontStyle: FontStyle.italic),
                                          ))
                                    ],
                                  ))
                            ])),
                  ),
                ),
                secondaryActions: <Widget>[
                  new IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.edit,
                    onTap: () => openEditBlog(blogs),
                  ),
                  new IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => deleteEditBlog(blogs),
                  ),
                ],
              ),
              onTap: () => onItemCLick(index));
        },
      );
    } else {
      return Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "You don't have any published blogs.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          new Padding(padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0)),
          new RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WriteBlog(userId: loginUser.id)),
              );
            },
            textColor: Colors.white,
            color: Colors.deepOrange,
            padding: EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0),
            child: new Text(
              CREATE_BLOG,
              style: TextStyle(fontSize: 17.0),
            ),
          ),
        ],
      ));
    }
  }

  void deleteEditBlog(Blogs blogs) {
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
                  setState(() {
                    _isLoading = true;
                  });
                  Firestore.instance
                      .collection(TABLE_BLOG)
                      .document(blogs.id)
                      .delete()
                      .then((result) {
                    print('Blog Deleted Successfully.');
                    setState(() {
                      _isLoading = false;
                    });
                  });
                },
              ),
            ],
          );
        });
  }

  void openEditBlog(Blogs blogs) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WriteBlog(
                userId: loginUser.id,
                blogs: blogs,
              )),
    );
  }
}

void onItemCLick(int index) {}
