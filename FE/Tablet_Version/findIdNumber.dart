// 계정 찾기 페이지 - 휴대폰 번호
import 'package:flutter/material.dart';

// import : google 폰트
import 'package:google_fonts/google_fonts.dart';

class FindIdNumberPage extends StatefulWidget {
  @override
  FindIdNumberPageState createState() => FindIdNumberPageState();
}

// 계정 찾기 페이지 코드
class FindIdNumberPageState extends State<FindIdNumberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 뒤로가기 버튼
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 현재 페이지를 스택에서 제거하여 이전 페이지로 이동
          },
        ),
        title: SizedBox.shrink(),
      ),
      // body
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // (1) children 으로 묶기
          children: [
            // 1. 아이디 찾기 문구
            SizedBox(height: 20),
            Text(
              // 글자 및 폰트, 크기 수정
              'Let\'s go?',
              style: GoogleFonts.oleoScript(fontSize: 36),
            ),
            // 2. 휴대폰 인증 방법 (1)
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // !! 통신사 PASS로 찾기 UI 넣기
                  print("통신사 PASS");
                },
                // !! 버튼 글자 수정
                child: Text(
                  '통신사 PASS',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            // 3. 휴대폰 인증 방법 (2)
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // !! SMS 문자 인증으로 찾기 UI 넣기
                  print("SMS 문자 인증");
                },
                // !! 버튼 글자 수정
                child: Text(
                  'SMS 문자 인증',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ], // children 끝
        ),
      ),
    );
  }
}
