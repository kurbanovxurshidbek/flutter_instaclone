import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/model/member_model.dart';
import 'package:instaclone/pages/signin_page.dart';
import 'package:instaclone/services/auth_service.dart';
import 'package:instaclone/services/db_service.dart';

import '../services/utils_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static final String id = "signup_page";

  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var isLoading = false;
  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cpasswordController = TextEditingController();

  _doSignUp() async{
    String fullname = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword = cpasswordController.text.toString().trim();

    if (fullname.isEmpty || email.isEmpty || password.isEmpty) return;

    if (cpassword != password) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }
    setState(() {
      isLoading = true;
    });
    var response = await AuthService.signUpUser(fullname, email, password);
    Member member = Member(fullname, email);
    DBService.storeMember(member).then((value) => {
      storeMemberToDB(member),
    });
  }

  void storeMemberToDB(Member member) {
    setState(() {
      isLoading = false;
    });
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  _callSignInPage() {
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(193, 53, 132, 1),
                  Color.fromRGBO(131, 58, 180, 1),
                ]),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Instagram",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontFamily: "Billabong"),
                      ),

                      //#fullname
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7)),
                        child: TextField(
                          controller: fullnameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Fullname",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 17, color: Colors.white54)),
                        ),
                      ),

                      //#email
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7)),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Email",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 17, color: Colors.white54)),
                        ),
                      ),

                      //#password
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7)),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 17, color: Colors.white54)),
                        ),
                      ),

                      //#cpassword
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7)),
                        child: TextField(
                          controller: cpasswordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Confirm Password",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 17, color: Colors.white54)),
                        ),
                      ),

                      //#signin
                      GestureDetector(
                        onTap: () {
                          _doSignUp();
                        },
                        child: Container(
                            margin: EdgeInsets.only(top: 10),
                            height: 50,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(7)),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            )),
                      ),
                    ],
                  )),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              _callSignInPage();
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox.shrink(),
            ],
          )),
    );
  }
}
