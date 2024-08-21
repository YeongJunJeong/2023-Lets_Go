// 비밀번호 찾기 페이지
import 'package:flutter/material.dart';

// import : google 폰트
import 'package:google_fonts/google_fonts.dart';

class FindPwPage extends StatefulWidget {
  @override
  FindPwPageState createState() => FindPwPageState();
}

// 비밀번호 찾기 페이지
class FindPwPageState extends State<FindPwPage> {
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
            // 1. 비밀번호 찾기 문구
            SizedBox(height: 20),
            Text(
              // 글자 및 폰트, 크기 수정
              'Let\'s go?',
              style: GoogleFonts.oleoScript(fontSize: 36),
            ),
            // 2. 비밀번호 찾는 방법 버튼 (1)
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  //
                  print("휴대폰 번호로 비밀번호 찾기 이동");
                },
                child: Text(
                  '휴대폰 번호로 비밀번호 찾기',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            // 3. 비밀번호 찾는 방법 버튼 (2)
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  //
                  print("이메일 주소로 비밀번호 찾기 이동");
                },
                child: Text(
                  '이메일 주소로 비밀번호 찾기',
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
