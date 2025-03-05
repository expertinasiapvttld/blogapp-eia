import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/like_table.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikesPage extends StatefulWidget {
  LikesPage(this.userId, this.blog);

  final String userId;
  final Blogs blog;

  @override
  State<StatefulWidget> createState() => new _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  List<LikeTable> _likesList = new List();
  bool _isLoading;
  FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _database
        .collection(TABLE_LIKE)
        .where('blogId', isEqualTo: widget.blog.id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _likesList.clear();
      data.docs.forEach((doc) {
        LikeTable like = likeFromMap(doc.data());
        setState(() {
          _likesList.add(like);
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(TITLE_LIKE),
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
          )
        ],
      ),
    );
  }

  /// build row for list
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  Widget _buildListRow() {
    if (_likesList != null && _likesList.length > 0) {
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: _likesList.length,
        itemBuilder: (BuildContext context, int index) {
          LikeTable like = _likesList[index];
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
                            _buildImageContainer(like.image),
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
                                                text: like.name,
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
                                        child: Text(
                                          getFormattedDateTime(like.createdAt),
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

  /// handle list item click
  /// @param : clicked position
  /// @author : Kailash
  /// @creationDate :16-Feb-2019
  onItemCLick(int index) {
    showAlertDialog(context, 'You clicked on "${_likesList[index].name}"');
  }
}
