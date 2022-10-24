import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:instaclone/services/file_service.dart';

import '../model/post_model.dart';

class MyUploadPage extends StatefulWidget {
  final PageController? pageController;

  const MyUploadPage({Key? key, this.pageController}) : super(key: key);

  @override
  State<MyUploadPage> createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading = false;
  var captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  _uploadNewPost() {
    String caption = captionController.text.toString().trim();
    if (caption.isEmpty) return;
    if (_image == null) return;
    _apiPostImage();
  }

  void _apiPostImage(){
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(_image!).then((downloadUrl) => {
      _resPostImage(downloadUrl),
    });
  }

  void _resPostImage(String downloadUrl){
    String caption = captionController.text.toString().trim();
    Post post = Post(caption, downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost(Post post)async{
    // Post to posts
    Post posted = await DBService.storePost(post);
    // Post to feeds
    DBService.storeFeed(posted).then((value) => {
      _moveToFeed(),
    });
  }

  _moveToFeed() {
    setState(() {
      isLoading = false;
    });
    captionController.text = "";
    _image = null;
    widget.pageController!.animateToPage(
        0, duration: Duration(microseconds: 200), curve: Curves.easeIn);
  }

  _imgFromGallery() async {
    XFile? image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromCamera() async {
    XFile? image =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = File(image!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Pick Photo'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Upload",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _uploadNewPost();
              },
              icon: Icon(
                Icons.drive_folder_upload,
                color: Color.fromRGBO(193, 53, 132, 1),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery
                            .of(context)
                            .size
                            .width,
                        color: Colors.grey.withOpacity(0.4),
                        child: _image == null
                            ? Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                            : Stack(
                          children: [
                            Image.file(
                              _image!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black12,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _image = null;
                                      });
                                    },
                                    icon: Icon(Icons.highlight_remove),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: TextField(
                        controller: captionController,
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            hintText: "Caption",
                            hintStyle:
                            TextStyle(fontSize: 17, color: Colors.black38)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : SizedBox.shrink(),
          ],
        ));
  }
}
