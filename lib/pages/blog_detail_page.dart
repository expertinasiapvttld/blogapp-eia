import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BlogDetailPage extends StatefulWidget {
  BlogDetailPage(this.userId, this.blog);
  final String userId;
  final Blogs blog;

  @override
  State<StatefulWidget> createState() => new BlogDetailPageState();
}

class BlogDetailPageState extends State<BlogDetailPage> {
  // Initial form is login form

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: new AppBar(
        title: new Text(widget.blog.blogger_name),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showBody(),
        ],
      ),
    );
  }

  Widget _showBody() {
    return new Container(
      padding: EdgeInsets.all(25.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showBlogImage(),
          _showBlogTitle(),
          _showBlogDescription(),
        ],
      ),
    );
  }

  Widget _showBlogImage() {
    if (widget.blog.image.isEmpty) {
      return new Container();
    } else {
      return Container(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) =>Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
              width: screenWidth(context),
              height: 150.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
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
            imageUrl: widget.blog.image,
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

  Widget _showBlogTitle() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Container(
        child: new Text(
          widget.blog.title,
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 25.0,
              color: Colors.deepOrange,
              wordSpacing: 0.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _showBlogDescription() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new Container(
        child: new Text(
          widget.blog.description,
          style: new TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
              wordSpacing: 0.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
