import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/model/member_model.dart';
import 'package:instaclone/services/auth_service.dart';

import '../model/post_model.dart';
import '../services/db_service.dart';
import '../services/file_service.dart';
import '../services/utils_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool isLoading = false;
  int axisCount = 2;
  List<Post> items = [];
  File? _image;
  String fullname = "", email = "", img_url = "";
  int count_posts = 0, count_followers = 0, count_following = 0;
  final ImagePicker _picker = ImagePicker();

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    print(image!.path.toString());
    setState(() {
      _image = File(image.path);
    });
    _apiChangePhoto();
  }

  _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    print(image!.path.toString());
    setState(() {
      _image = File(image.path);
    });
    _apiChangePhoto();
  }

  void _apiChangePhoto() {
    if (_image == null) return;
    setState(() {
      isLoading = true;
    });
    FileService.uploadUserImage(_image!).then((downloadUrl) => {
          _apiUpdateUser(downloadUrl),
        });
  }

  _apiUpdateUser(String downloadUrl) async {
    Member member = await DBService.loadMember();
    member.img_url = downloadUrl;
    await DBService.updateMember(member);
    _apiLoadMember();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Pick Photo'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Take Photo'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _apiLoadMember() {
    setState(() {
      isLoading = true;
    });
    DBService.loadMember().then((value) => {
          _showMemberInfo(value),
        });
  }

  void _showMemberInfo(Member member) {
    setState(() {
      isLoading = false;
      this.fullname = member.fullname;
      this.email = member.email;
      this.img_url = member.img_url;
      this.count_following = member.following_count;
      this.count_followers = member.followers_count;
    });
  }

  _apiLoadPosts() {
    DBService.loadPosts().then((value) => {
          _resLoadPosts(value),
        });
  }

  _resLoadPosts(List<Post> posts) {
    setState(() {
      items = posts;
      count_posts = posts.length;
    });
  }

  _dialogRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to detele this post?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        _apiLoadPosts(),
      });
    }
  }

  _dialogLogout() async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to logout?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      AuthService.signOutUser(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadMember();
    _apiLoadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Profile",
            style: TextStyle(
                color: Colors.black, fontFamily: "Billabong", fontSize: 25),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _dialogLogout();
              },
              icon: Icon(Icons.exit_to_app),
              color: Color.fromRGBO(193, 53, 132, 1),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  //#myphoto
                  GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(
                                width: 1.5,
                                color: Color.fromRGBO(193, 53, 132, 1),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: img_url == null || img_url.isEmpty
                                  ? Image(
                                      image: AssetImage(
                                          "assets/images/ic_person.png"),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      img_url,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.purple,
                                )
                              ],
                            ),
                          ),
                        ],
                      )),

                  //#myinfos
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    fullname.toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    email,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),

                  //#mycounts
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 80,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  count_posts.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "POSTS",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  count_followers.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "FOLLOWERS",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  count_following.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "FOLLOWING",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //list or grid
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  axisCount = 1;
                                });
                              },
                              icon: Icon(Icons.list_alt),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  axisCount = 2;
                                });
                              },
                              icon: Icon(Icons.grid_view),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //#myposts
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: axisCount),
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        return _itemOfPost(items[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _itemOfPost(Post post) {
    return GestureDetector(
      onLongPress: (){
        _dialogRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                width: double.infinity,
                imageUrl: post.img_post,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              post.caption,
              style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              maxLines: 2,
            )
          ],
        ),
      )
    );
  }
}
