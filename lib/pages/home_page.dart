import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/like_table.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/pages/profile_page.dart';
import 'package:blog_app/pages/write_blog.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';

import 'blog_detail_page.dart';
import 'comments_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key,  })
      : super(key: key);


  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Blogs> _blogList = new List();
  bool _isLoading = false;
  FirebaseFirestore _database = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UserModel loginUser;
  ScrollController _hideButtonController;
  bool _isVisible;

  @override
  void initState() {
    super.initState();
    getBlogsData();
    getUser().then((userData) {
      loginUser = userData;
      _database
          .collection(TABLE_MESSAGE)
          .where('idFrom', isEqualTo: loginUser.id)
          .where('idTo', isEqualTo: loginUser.id)
          .snapshots()
          .listen((data) {
        print('message ${data.docs.length}');
      });
    });
    setScrollListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// used to sign out user from Firebase
  /// @author : Kailash
  /// @creationDate :5-Feb-2019
  /*_signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }*/

  _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WriteBlog(userId: loginUser.id)),
    );

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(TITLE_HOME),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: _openProfile,
              iconSize: 26,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            _buildListRow(),
            getCircularProgress(_isLoading),
          ],
        ),
        floatingActionButton: new Opacity(
            opacity: _isVisible ? 1.0 : 0.0,
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WriteBlog(userId: loginUser.id)),
                );
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            )));
  }

  static String isNullOrEmptyText(String value) {
    if (value == null || value.length == 0)
      return '';
    else
      return value;
  }

  /// build row for list
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  Widget _buildListRow() {
    if (_blogList != null && _blogList.length > 0) {
      return new ListView.builder(
        controller: _hideButtonController,
        shrinkWrap: true,
        itemCount: _blogList.length,
        itemBuilder: (BuildContext context, int index) {
          Blogs blog = _blogList[index];
          bool isLike = false;
          for (var userId in blog.likes) {
            if (userId == loginUser.id) {
              isLike = true;
              break;
            }
          }
          return GestureDetector(
              child: SizedBox(
                width: screenWidth(context),
                child: new Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  elevation: 2.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildImageContainer(blog.image),
                      new Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: blog.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: blog.description,
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 2.0),
                        child: Text(
                          'Blogger - ' + isNullOrEmptyText(blog.blogger_name),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 8.0, bottom: 6.0),
                        child: Text(
                          getFormattedDateTime(blog.createdAt),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      new Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.only(right: 5.0),
                                      child: IconButton(
                                        icon: (isLike
                                            ? Icon(Icons.favorite)
                                            : Icon(Icons.favorite_border)),
                                        color: Colors.red[500],
                                        onPressed: () =>
                                            _toggleLike(isLike, blog),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 18,
                                      child: Container(
                                        child: new GestureDetector(
                                          child: Text(
                                              blog.likes.length.toString()),
                                          onTap: () => _openLikesPage(blog),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.only(right: 5.0),
                                      child: IconButton(
                                        icon: Icon(Icons.comment),
                                        color: Colors.red[500],
                                        onPressed: () => _openCommentPage(blog),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 18,
                                      child: Container(
                                          child: new GestureDetector(
                                        child: Text(
                                            blog.comments.length.toString()),
                                        onTap: () => _openCommentPage(blog),
                                      )),
                                    )
                                  ],
                                )),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(0),
                                  child: IconButton(
                                    icon: Icon(Icons.share),
                                    color: Colors.red[500],
                                    onPressed: () => _shareBlog(blog),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              onTap: () => onItemCLick(blog));
        },
      );
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0),
      ));
    }
  }

  _toggleLike(bool isLike, Blogs blogs) {
    setState(() {
      _isLoading = true;
    });
    if (!isLike) {
      LikeTable likeTable = new LikeTable();
      likeTable.userId = loginUser.id;
      likeTable.blogId = blogs.id;
      likeTable.createdAt = DateTime.now().toString();
      likeTable.name = loginUser.name;
      likeTable.image = loginUser.image;
      addLike(likeTable).then((response) {
        List<String> list = new List();
        list.addAll(blogs.likes);
        list.add(loginUser.id);
        blogs.likes = list;
        updateBlog(blogs);
      });
    } else {
      _deleteLike(blogs);
    }
  }

  addLike(LikeTable likeTable) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(FirebaseFirestore.instance.collection(TABLE_LIKE).doc());
      likeTable.id = ds.id;
      var dataMap = likeTableToMap(likeTable);
      await tx.set(ds.reference, dataMap);
      return dataMap;
    };

    return FirebaseFirestore.instance.runTransaction(createTransaction).then((mapData) {
      return fromJson(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }

  updateBlog(Blogs note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx
          .get(FirebaseFirestore.instance.collection(TABLE_BLOG).doc(note.id));

      await tx.update(ds.reference, blogsToMap(note));
      return {'updated': true};
    };

    return FirebaseFirestore.instance
        .runTransaction(updateTransaction)
        .then((result) => setState(() {
              _isLoading = false;
            }))
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  _deleteLike(Blogs blogs) {
    _database
        .collection(TABLE_LIKE)
        .where("userId", isEqualTo: loginUser.id)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
      List<String> list = new List();
      list.addAll(blogs.likes);
      // remove like object to list
      list.remove(loginUser.id);
      // set like object to blogs
      blogs.likes = list;
      updateBlog(blogs);
    }).catchError((e) {
      print(e);
    });
  }

  /// build image widget if image is available
  /// @imagePath : server imagePath
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  Widget _buildImageContainer(String imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return new Container();
    } else {
     return Container(
       child: Material(
         child: CachedNetworkImage(
           placeholder: (context, url) =>  Container(
             child: CircularProgressIndicator(
               valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
             ),
             width: screenWidth(context),
             height: 150.0,
             padding: EdgeInsets.all(70.0),
             decoration: BoxDecoration(
               color: greyColor2,
               borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(8.0),
                   topRight: Radius.circular(8.0)),
             ),
           ),
           errorWidget: (context, url, error) => Material(
             child: Image.asset(
               'assests/img_not_available.jpeg',
               width: screenWidth(context),
               height: 150.0,
               fit: BoxFit.cover,
             ),
             borderRadius: BorderRadius.only(
                 topLeft: Radius.circular(8.0),
                 topRight: Radius.circular(8.0)),
             clipBehavior: Clip.hardEdge,
           ),
           imageUrl: imagePath,
           width: screenWidth(context),
           height: 150.0,
           fit: BoxFit.cover,
         ),
         borderRadius: BorderRadius.only(
             topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
         clipBehavior: Clip.hardEdge,
         elevation: 1.0,
       ),
     );
    }
  }

  /// handle list item click
  /// @param : clicked position
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  onItemCLick(Blogs blogs) {
    //showAlertDialog(context, 'You clicked on "${_blogList[index].title}"');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlogDetailPage(loginUser.id, blogs),
        ));
  }

  _openCommentPage(Blogs blogs) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommentPage(loginUser.id, blogs),
        ));
  }

  _shareBlog(Blogs blog) {
    Share.share(blog.description);
  }

  _openLikesPage(Blogs blog) {
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//          builder: (context) => LikesPage(loginUser.id, blog),
//        ));
  }

  void setScrollListener() {
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
          print("**** $_isVisible up");
        });
      }
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
          print("**** $_isVisible down");
        });
      }
    });
  }

  void getBlogsData() {
    _isLoading = true;
    _database
        .collection(TABLE_BLOG)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _blogList.clear();
      data.docs.forEach((doc) {
        Blogs blogs = fromJson(doc.data());
        setState(() {
          _blogList.add(blogs);
        });
      });
    });
  }
}
