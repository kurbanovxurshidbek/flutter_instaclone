class Post {
  String uid = "";
  String fullname = "";
  String img_user = "";

  String id = "";
  String img_post = "";
  String caption = "";
  String date = "";
  bool liked = false;

  bool mine = false;

  Post(this.caption, this.img_post);

  Post.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullname = json['fullname'],
        img_user = json['img_user'],
        img_post = json['img_post'],
        id = json['id'],
        caption = json['caption'],
        date = json['date'],
        liked = json['liked'];

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'fullname': fullname,
    'img_user': img_user,
    'id': id,
    'img_post': img_post,
    'caption': caption,
    'date': date,
    'liked': liked,
  };
}
