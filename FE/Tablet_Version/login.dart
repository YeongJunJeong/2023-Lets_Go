// 로그인 페이지
import 'dart:io';

import 'package:flutter/material.dart';

// import : 순서대로 메인페이지/회원가입/아이디 찾기/비밀번호 찾기 페이지로 이어짐
import 'package:go_test_ver/mainPage.dart'; // mainPage.dart 파일 import
import 'package:go_test_ver/signUp.dart'; // signUp.dart 파일 import
import 'package:go_test_ver/findId.dart'; // findId.dart 파일 import
import 'package:go_test_ver/findPw.dart'; // findPw.dart 파일 import

// import : google 폰트
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // API 호출 : 디코딩
import 'package:http/http.dart' as http; // API 호출 2
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장
import 'package:geolocator/geolocator.dart'; // 실시간 위치 정보

void main() {
  runApp(MyApp());
}

// Login API(1): 데이터 저장
class loginAPI {
  String? userId;
  String? userPassword;

  loginAPI({this.userId, this.userPassword});

  loginAPI.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userPassword = json['userPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userPassword'] = this.userPassword;
    return data;
  }
}

// Login API(2) : 함수 호출 및 API URL 연결
Future<void> fetchloginAPI(id, password, context) async {
  // 데이터 저장 변수 : signUpAPI
  final signUpUser = loginAPI(
    userId: id,
    userPassword: password,
  );

  // API 연결
  final response = await http.post(
    Uri.parse('http://43.203.61.149/user/login/'),
    headers: {"Accept": "application/json"},
    body: signUpUser.toJson(),
  );

  // Token 데이터 저장소 생성 및 초기화
  final storage = new FlutterSecureStorage();
  dynamic storage_user_id = ""; // storage에 userid 저장
  dynamic storage_user_access_token = ''; // storage에 access_token 저장
  dynamic storage_user_refresh_token = ''; // storage에 refresh_token 저장

  // _asyncMethod 함수 생성 : 데이터 있는지 확인하는 함수
  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    storage_user_id = await storage.read(key: 'login_id');
    storage_user_access_token = await storage.read(key: 'login_access_token');
    storage_user_refresh_token = await storage.read(key: 'login_refresh_token');
  }

  //flutter_secure_storage 사용을 위한 초기화 작업
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _asyncMethod();
  });

  // 로그인 처리 과정
  // 200 : 로그인 성공
  // 오류 400 : 데이터 처리 오류
  // 로그인 성공 & 실패
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse =
        jsonDecode(response.body); // JSON 데이터 피싱
    // 응답 메시지 디코드
    String message = jsonResponse['message']; // 응답 메시지 확인
    // 응답 메시지 == "login success"
    if (message == "login success") {
      // Toekn을 디코드 후 저장
      String access = jsonResponse['token']['access'];
      String refresh = jsonResponse['token']['refresh'];

      // storage에 저장 (1) - userID
      await storage.write(
        key: 'login_id',
        value: id, // userId
      );

      // storage에 저장 (2) - user_access_token
      await storage.write(
        key: 'login_access_token',
        value: access, // access Token
      );

      // storage에 저장 (3) - user_refresh_token
      await storage.write(
        key: 'login_refresh_token',
        value: refresh, // refresh Token
      );

      // 로그인 성공
      // userInfo == (access) Token
      if (storage_user_access_token != null ||
          storage_user_refresh_token != null ||
          storage_user_id != null) {
        String? val1 = await storage.read(key: "login_id");
        String? val2 = await storage.read(key: "login_access_token");
        String? val3 = await storage.read(key: "login_refresh_token");

        // 메인 페이지로 이동
        //print("로그인 성공: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("로그인 성공", style: GoogleFonts.oleoScript()),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()), // 다음 화면으로 이동
        );
      } // 로그인 실패
      else {
        //print("로그인 또는 Token 인증에 실패했습니다.: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("로그인 또는 Token 인증에 실패했습니다.",
                style: GoogleFonts.oleoScript()),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      //print("로그인에 실패하셨습니다.: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("로그인에 실패하셨습니다.", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else if (response.statusCode == 400) {
    // 로그인 실패 : 아이디, 비밀번호 일치 X
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("회원 정보가 없습니다.", style: GoogleFonts.oleoScript()),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  } else {}
}

class LoginPage extends StatefulWidget {
  // StatefulWidget : User 정보 반영하기 위해
  @override
  LoginPageState createState() => LoginPageState();
}

// 로그인 페이지
class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>(); // formKey 정의
  DateTime? lastPressed; // 뒤로가기 2번 누르도록

  // 변수
  String userId = "";
  String userPassword = "";

// FocusNode 추가
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar : 제목 삭제함
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar의 배경색을 흰색으로 설정
        elevation: 0, // 그림자 제거
      ),
      // body
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 여백
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                  ),
                  // 1. 로그인 위 글자 삽입함 : Let's go?
                  Text(
                    'Let\'s go?', // 폰트는 나중에 통일하기
                    style: GoogleFonts.oleoScript(fontSize: 50),
                  ),
                  // 2. ID 입력칸 : 관리자 == admin // ID 입력칸
                  SizedBox(height: 150),
                  TextFormField(
                    maxLength: 15, // 글자수 제한
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        // ID 입력란이 비어 있거나, ID가 설정해둔 자릿수 미만이면, '아이디를 입력해주세요' 리턴
                        return "아이디를 입력해주세요";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      // ID 저장(1)
                      userId = value!;
                    },
                    onChanged: (value) {
                      // ID 저장(2)
                      userId = value;
                    },
                    key: const ValueKey(1), // ID 오류
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintText: '아이디',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next, // Tab 키 설정
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  // 3. PW 입력칸 : 관리자 == 1234 // PW 입력칸 안 넣었음
                  SizedBox(height: 20),
                  TextFormField(
                    maxLength: 15, // 글자수 제한
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        // 비밀번호 입력란이 비어 있거나, 비밀번호가 설정해둔 자릿수 미만이면, '최소 6자리로 비밀번호를 설정해주세요' 리턴
                        return "최소 6자리로 비밀번호를 설정해주세요";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      userPassword = value!;
                    },
                    onChanged: (value) {
                      userPassword = value;
                    },
                    obscureText: true,
                    key: const ValueKey(2),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintText: '비밀번호',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                    ),
                    focusNode: _passwordFocusNode, // 포커스 노드 설정
                    textInputAction: TextInputAction.done, // Enter 키 설정
                    onFieldSubmitted: (_) async {
                      if (userId != '' && userPassword != '') {
                        await fetchloginAPI(
                            userId, userPassword, context); // loginAPI 시도
                      } else {
                        final snackBar = SnackBar(
                          content: Text('아이디와 비밀번호를 입력해주세요.',
                              style: GoogleFonts.oleoScript()),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                  // 4. 로그인 버튼
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60, // 로그인 버튼 높이 조정
                    child: ElevatedButton(
                      onPressed: () async {
                        // tryValidation(); // 인증 진행
                        if (userId != '' && userPassword != '') {
                          await fetchloginAPI(
                              userId, userPassword, context); // loginAPI 시도
                        } else {
                          final snackBar = SnackBar(
                            content: Text('아이디와 비밀번호를 입력해주세요.',
                                style: GoogleFonts.oleoScript()),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 테두리를 둥글게 설정
                        ),
                        elevation: 4, // 그림자 추가
                        backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  // 5. 회원가입 버튼
                  SizedBox(height: 20), // 간격 조정
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // 회원가입 버튼 : 왼쪽과 오른쪽으로 정렬
                    children: [
                      Flexible(
                        child: SizedBox(
                          // 회원가입 버튼 크기 조정
                          width: 140, // 버튼 너비 조정
                          height: 40, // 버튼 높이 조정
                          child: ElevatedButton(
                            onPressed: () {
                              // 회원가입 버튼 눌렀을 때의 동작 추가
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // 버튼 배경색 투명하게 설정
                              elevation: 0, // 그림자 없애기
                            ),
                            child: Text(
                              '회원가입',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center, // 텍스트 가운데 정렬
                            ),
                          ),
                        ),
                      ),
                      // 6. 계정 찾기 버튼
                      Flexible(
                        child: SizedBox(
                          // 계정 찾기 버튼 크기 조정
                          width: 140, // 버튼 너비 조정
                          height: 40, // 버튼 높이 조정
                          child: ElevatedButton(
                            onPressed: () {
                              // 계정 찾기 버튼 눌렀을 때의 동작 추가
                              // 계정 찾기 페이지 생성 후 페이지 이동

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FindIdPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // 버튼 배경색 투명하게 설정
                              elevation: 0, // 그림자 없애기
                            ),
                            child: Text(
                              '계정 찾기',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center, // 텍스트 가운데 정렬
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: SizedBox(
                          // 7. 비밀번호 찾기 버튼
                          width: 140, // 버튼 너비 조정
                          height: 40, // 버튼 높이 조정
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FindPwPage()),
                              );
                              // 비밀번호 찾기 버튼 눌렀을 때의 동작 추가
                              // 비밀번호 찾기 페이지 생성 후 페이지 이동
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // 버튼 배경색 투명하게 설정
                              elevation: 0, // 그림자 없애기
                            ),
                            child: Text(
                              '비밀번호 찾기',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center, // 텍스트 가운데 정렬
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
      // WillPopScope를 사용하여 뒤로 가기 이벤트를 감지
      backgroundColor: Colors.white,
      bottomNavigationBar: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
              lastPressed == null ||
                  now.difference(lastPressed!) > Duration(seconds: 2);

          if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
            lastPressed = DateTime.now();

            // 사용자에게 경고를 주는 Snackbar 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('한 번 더 뒤로가기 버튼을 누를 시 앱이 꺼집니다.'),
                duration: Duration(seconds: 2),
              ),
            );

            return false; // 뒤로 가기 이벤트를 막습니다
          }

          return true; // 뒤로 가기 이벤트를 허용하여 앱을 종료합니다
        },
        child: SizedBox(),
      ),
    );
  }
}
