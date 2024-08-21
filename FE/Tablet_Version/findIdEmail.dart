// 계정 찾기 페이지 - 이메일
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class FindIdEmailPage extends StatefulWidget {
  @override
  FindIdEmailPageState createState() => FindIdEmailPageState();
}

class FindIdEmailPageState extends State<FindIdEmailPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();

  bool _isEmailSent = false;
  bool _isCodeVerified = false;

  String _emailVerificationCode = "aaaaaa";

  void _sendEmailVerificationCode() {
    setState(() {
      _isEmailSent = true;
    });
  }

  void _verifyCode(String enteredCode, String correctCode) {
    if (enteredCode == correctCode) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // 외곽을 더 둥글게 만들기
            ),
            backgroundColor: Colors.white, // 팝업창 배경색을 흰색으로 설정
            contentPadding:
                EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0), // 컨텐트 패딩 조정
            content: Text(
              '해당 이메일로 메일을 보냈습니다!',
              textAlign: TextAlign.center,
              style: GoogleFonts.oleoScript(
                // Google Fonts 폰트 스타일 사용
                color: Colors.black,
                fontSize: 16.0, // 폰트 크기를 20.0으로 설정
              ),
            ),
            actionsAlignment: MainAxisAlignment.center, // 버튼을 중간에 위치시킴
            buttonPadding: EdgeInsets.fromLTRB(5, 5, 5, 2.0), // 버튼 패딩 조정
            actions: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0), // 양옆 간격 조정
                width: double.infinity, // 버튼의 너비를 확장
                child: TextButton(
                  child: Text(
                    '확인',
                    style: GoogleFonts.oleoScript(
                      color: Colors.white, // 폰트 색상을 흰색으로 설정
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple, // 버튼 배경 색상을 deepPurple로 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // 버튼 모서리 둥글게
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      );
      setState(() {
        _isCodeVerified = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("인증 실패")),
            content: Text("인증 코드가 올바르지 않습니다."),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("확인"),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("계정 찾기"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "이메일 주소",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmailVerificationCode,
              child: Text("이메일에 인증코드 보내기"),
            ),
            if (_isEmailSent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: "인증 코드",
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _verifyCode(_verificationCodeController.text,
                          _emailVerificationCode);
                    },
                    child: Text("인증하기"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
