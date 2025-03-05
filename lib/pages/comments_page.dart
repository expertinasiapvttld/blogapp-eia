import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/comment_table.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/pages/chat.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  CommentPage(this.userId, this.blog);

  final String userId;
  final Blogs blog;

  @override
  State<StatefulWidget> createState() => new _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Comment> _commentList = new List();
  bool _isLoading;
  FocusNode _commentFocus = FocusNode();
  FirebaseFirestore _database = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController =
      new TextEditingController();
  UserModel loginUser;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _database
        .collection(TABLE_COMMENT)
        .where('blogId', isEqualTo: widget.blog.id)
//        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _commentList.clear();
      data.docs.forEach((doc) {
        Comment comment = commentFromMap(doc.data());
        setState(() {
          _commentList.add(comment);
        });
      });
    });
    getUser().then((userData) {
      loginUser = userData;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(TITLE_COMMENT),
      ),
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    return new Material(
      type: MaterialType.transparency,
      child: Column(
        children: <Widget>[
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
            child: Stack(
              children: <Widget>[
                _buildListRow(),
                getCircularProgress(_isLoading),
              ],
            ),
          ),
          // This container holds the align
          Container(
              // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: buildBottomInput()))
        ],
      ),
    );
  }

  Widget buildBottomInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 10.0),
              child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(color: Colors.black, fontSize: 15.0),
                    controller: _textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your comment...',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    focusNode: _commentFocus,
                  )),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendComment(),
                color: Colors.black,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 60.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Colors.black54, width: 0.5)),
          color: Colors.white),
    );
  }

  /// build row for list
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  Widget _buildListRow() {
    if (_commentList != null && _commentList.length > 0) {
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: _commentList.length,
        itemBuilder: (BuildContext context, int index) {
          Comment comment = _commentList[index];
          return GestureDetector(
              child: SizedBox(
                width: screenWidth(context),
                child: new Card(
                  elevation: 2.0,
                  child: new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildImageContainer(comment.image),
                            Container(
                                width: (screenWidth(context) - 110),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: comment.name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: comment.comment,
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
                                              comment.createdAt),
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
              onTap: () => onItemCLick(index));
        },
      );
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
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
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              clipBehavior: Clip.hardEdge,
            ),
            margin: EdgeInsets.only(right: 10.0),
          ));
  }

  updateBlog(Blogs note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx
          .get(Firestore.instance.collection(TABLE_BLOG).document(note.id));

      await tx.update(ds.reference, blogsToMap(note));
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => setState(() {
              _textEditingController.clear();
              _isLoading = false;
            }))
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  /// handle list item click
  /// @param : clicked position
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  onItemCLick(int index) {
//    showAlertDialog(context, 'You clicked on "${_commentList[index].comment}"');
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => Chat(
//                  peerId: _commentList[index].id,
//                  peerAvatar: _commentList[index].image,
//                  name: _commentList[index].name,
//                )));
  }

  addComment(Comment commentTable) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds =
          await tx.get(Firestore.instance.collection(TABLE_COMMENT).document());
      commentTable.id = ds.documentID;
      var dataMap = commentTableToMap(commentTable);
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

  onSendComment() {
    setState(() {
      _isLoading = true;
    });
    Comment commentTable = new Comment();
    commentTable.userId = loginUser.id;
    commentTable.blogId = widget.blog.id;
    commentTable.comment = _textEditingController.text;
    commentTable.createdAt = DateTime.now().toString();
    commentTable.name = loginUser.name;
    commentTable.image = loginUser.image;
    addComment(commentTable).then((response) {
      List<String> list = new List();
      list.addAll(widget.blog.comments);
      list.add(loginUser.id);
      widget.blog.comments = list;
      updateBlog(widget.blog);
    });
  }
}
