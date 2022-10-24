import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/services/db_service.dart';

import '../model/post_model.dart';
import '../services/utils_service.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({Key? key}) : super(key: key);

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DBService.loadLikes().then((value) => {
          _resLoadPost(value),
        });
  }

  void _resLoadPost(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnlike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });
    DBService.likePost(post, false).then((value) => {
          _apiLoadLikes(),
        });
  }

  _dialogRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to detele this post?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        _apiLoadLikes(),
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Likes",
          style: TextStyle(
              color: Colors.black, fontFamily: 'Billabong', fontSize: 30),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return _itemOfPost(items[index]);
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          //#user info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: post.img_user.isEmpty
                          ? Image(
                              image: AssetImage("assets/images/ic_person.png"),
                              width: 40,
                              height: 40,
                            )
                          : Image.network(
                              post.img_user,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullname,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          post.date,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          _dialogRemovePost(post);
                        },
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          //#post image
          SizedBox(
            height: 8,
          ),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //#like share
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _apiPostUnlike(post);
                    },
                    icon: post.liked
                        ? Icon(
                            EvaIcons.heart,
                            color: Colors.red,
                          )
                        : Icon(
                            EvaIcons.heartOutline,
                            color: Colors.black,
                          ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      EvaIcons.shareOutline,
                    ),
                  ),
                ],
              )
            ],
          ),

          //#caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  text: "${post.caption}",
                  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
