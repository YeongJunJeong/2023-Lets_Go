// 로딩 텍스트 페이지
import 'package:flutter/material.dart';

// import : 로딩 애니메이션 패키지
import 'dart:async'; // ?
import 'package:animated_text_kit/animated_text_kit.dart'; // import : 로딩 텍스트 애니메이션
import 'package:google_fonts/google_fonts.dart'; // import : google 폰트

// import : 로그인 페이지로 이어짐
import 'package:go_test_ver/login.dart';

// 1. 로딩 페이지 (메인 페이지)
class LoadingTextPage extends StatefulWidget {
  @override
  LoadingTextPageState createState() => LoadingTextPageState();
}

// 로딩 페이지 상태
class LoadingTextPageState extends State<LoadingTextPage> {
  @override
  void initState() {
    super.initState();
    // 시간 설정
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildSizedBox(),
      ),
    );
  }

  SizedBox buildSizedBox() {
    // style: GoogleFonts.oleoScript(fontSize: 36),
    return SizedBox(
    width: 250.0,
    // 글자 가운데로 모으고 싶은데
    child: DefaultTextStyle(
      style: GoogleFonts.oleoScript(
        color: Colors.black,
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      child: Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            '여행 ?',
            textStyle: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          TyperAnimatedText(
            '여행 가볼까 ?',
            textStyle: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          
          /*
          ScaleAnimatedText(
            '여행 가볼까',
            textStyle: TextStyle(fontSize: 70.0, fontFamily: 'Canterbury'),
          ),*/
        ],
      ),
    )
    ),
    );
  }
}
