// 회원가입 페이지
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_test_ver/login.dart';
import 'package:go_test_ver/signUp.dart';

// import :
import 'package:google_fonts/google_fonts.dart'; // google 폰트
import 'package:email_validator/email_validator.dart'; // 이메일 유효성 라이브러리
import 'dart:convert'; // API 호출
import 'package:http/http.dart' as http; // API 호출 2

// 회원 가입 API (1) : 데이터 저장
class signUpAPI {
  String? userEmail;
  String? userName;
  String? userId;
  String? userPassword;
  String? userPasswordCheck;

  signUpAPI(
      {this.userEmail,
      this.userName,
      this.userId,
      this.userPassword,
      this.userPasswordCheck});

  signUpAPI.fromJson(Map<String, dynamic> json) {
    userEmail = json['userEmail'];
    userName = json['userName'];
    userId = json['userId'];
    userPassword = json['userPassword'];
    userPasswordCheck = json['userPasswordCheck'];
  }

  Map<String, dynamic> toJson() {
    // 토큰 또는 (String)아이디 / 이메일로 구분?
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userEmail'] = this.userEmail;
    data['userName'] = this.userName;
    data['userId'] = this.userId;
    data['userPassword'] = this.userPassword;
    data['userPasswordCheck'] = this.userPasswordCheck;
    return data;
  }
}

// 회원 가입 API (2) : 데이터 저장 변수 호출 및 API 연결, 매개변수 필수
Future<void> fetchsignUpAPI(email, name, id, password, passwordcheck) async {
  // 데이터 저장 변수 : signUpAPI
  final signUpUser = signUpAPI(
    userEmail: email,
    userName: name,
    userId: id,
    userPassword: password,
    userPasswordCheck: passwordcheck,
  );

  // API 연결
  final response = await http.post(
    Uri.parse('http://43.203.61.149/user/signup/'),
    headers: {"Accept": "application/json"},
    body: signUpUser.toJson(),
  );

  // 회원가입 처리 과정
  // 오류 200 : 미연결
  // 오류 400 : 데이터 처리 오류
  // 201 : 성공
  if (response.statusCode == 201) {
    // 회원가입 성공 시의 처리
    print('회원가입 성공');
    return; // 반환값이 없을 경우 void 반환
  } else if (response.statusCode == 500) {
    final snackBar = SnackBar(content: Text("중복된 ID입니다."));
  } else {
    // 회원가입 실패 시의 처리
    final snackBar = SnackBar(content: Text("회원가입에 실패하였습니다."));
    // throw Exception('회원가입 실패: ${response.statusCode}');
  }
}

void main() {
  runApp(MyApp());
}

// 시작
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up',
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  // Stateful : 유저 화면에도 정보 반영
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

// 회원가입 페이지
class _SignUpPageState extends State<SignUpPage> {
  // Form Key
  final formKey = GlobalKey<FormState>(); // formKey 정의
  bool isOk = false; // 회원가입 조건 충족 변수

  // 변수
  String role = ""; // 사용자 OR 관리자
  String userEmail = "";
  String userName = "";
  String userId = "";
  String userPassword = "";
  String userPasswordCheck = "";

  // 인증
  void tryValidation() {
    final isValid = formKey.currentState!.validate(); // 인증된 상태 여부 확인

    if (isValid) {
      // 인증 완료
      formKey.currentState!.save();
      isOk = true; // 승인
    } else {
      // 인증 실패
      isOk = false; // 거부
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar : Appbar
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar의 배경색을 흰색으로 설정
        elevation: 0, // 그림자 제거
        // 뒤로가기 버튼
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 현재 페이지를 스택에서 제거하여 이전 페이지로 이동
          },
        ),
        title: SizedBox.shrink(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          // 여기서 배경색을 흰색으로 설정
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. 회원가입 위 글자 삽입
                    SizedBox(height: 20),
                    Text(
                      // 글자 및 폰트, 크기 수정
                      'Let\'s go?',
                      style: GoogleFonts.oleoScript(fontSize: 36),
                    ),
                    // 2. 이메일 인증
                    SizedBox(height: 20),
                    TextFormField(
                      maxLength: 30, // 글자수 제한
                      validator: (value) {
                        if (value!.isEmpty || value.length < 2) {
                          // 이메일 입력란이 비어있으면 '이메일을 입력해주세요' 리턴
                          return "이메일을 입력해주세요";
                        } else if (!EmailValidator.validate(value.toString())) {
                          // 입력값이 이메일 형식에 맞지 않으면 '이메일 형식을 맞춰주세요를 리턴
                          return "이메일 형식을 맞춰주세요";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) async {
                        // 이메일 저장
                        userEmail = value!;
                      },
                      onChanged: (value) {
                        userEmail = value;
                      },
                      // obscureText: true, // *로 표시 설정/해제
                      decoration: InputDecoration(
                        labelText: '이메일 입력',
                        border: OutlineInputBorder(),
                      ),
                      key: const ValueKey(1), // 이메일 오류
                    ),
                    // 3. 이름 입력칸
                    SizedBox(height: 20),
                    TextFormField(
                      maxLength: 15, // 글자수 제한
                      validator: (value) {
                        if (value!.isEmpty) {
                          // 이름 입력란이 비어 있을 때
                          return "이름을 입력해주세요.\n영어 또는 한글만 지원합니다.";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        // 이름 저장
                        userName = value!;
                      },
                      onChanged: (value) {
                        userName = value;
                      },
                      inputFormatters: [
                        // 한글 입력만 제한
                        FilteringTextInputFormatter(
                          RegExp('[a-z A-Z ㄱ-ㅎ|가-힣|·|：]'),
                          allow: true,
                        )
                      ],
                      decoration: InputDecoration(
                        labelText: '이름',
                        border: OutlineInputBorder(),
                      ),
                      key: const ValueKey(2), // 이름 오류
                    ),
                    // 4. ID 입력칸
                    SizedBox(height: 20),
                    TextFormField(
                      maxLength: 15, // 글자수 제한
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          // ID 입력란이 비어 있거나, ID가 설정해둔 자릿수 미만이면, '최소 6자리로 ID를 설정해주세요' 리턴
                          return "최소 6자리로 아이디를 설정해주세요";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        // Id 저장
                        userId = value!;
                      },
                      onChanged: (value) {
                        userId = value;
                      },
                      decoration: InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                      key: const ValueKey(3), // ID 오류
                    ),
                    // 5. PW 입력칸
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
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                      key: const ValueKey(4), // PW 오류
                    ),
                    // 6. 비밀번호 재입력
                    SizedBox(height: 20),
                    TextFormField(
                      maxLength: 15, // 글자수 제한
                      validator: (value) {
                        if (value!.isEmpty ||
                            value.length < 6 ||
                            value != userPassword) {
                          return '비밀번호를 다시 확인해주세요.';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        userPasswordCheck = value!;
                      },
                      onChanged: (value) {
                        userPasswordCheck = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호 재입력',
                        border: OutlineInputBorder(),
                      ),
                      key: const ValueKey(5), // PW 확인 오류
                    ),
                    // 7. 회원가입 버튼
                    SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          tryValidation(); // 인증 진행
                          // 이메일 패스워드 확인
                          if (userEmail != '' &&
                              userName != '' &&
                              userId != '' &&
                              userPassword != '' &&
                              userPasswordCheck != '' &&
                              isOk == true) {
                            await fetchsignUpAPI(userEmail, userName, userId,
                                userPassword, userPasswordCheck);
                            // 팝업창 띄우기
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // 외곽을 더 둥글게 만들기
                                  ),
                                  backgroundColor:
                                      Colors.white, // 팝업창 배경색을 흰색으로 설정
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 30.0, 20.0, 30.0), // 컨텐트 패딩 조정
                                  content: Text(
                                    '회원가입에 성공하였습니다!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.oleoScript(
                                      // Google Fonts 폰트 스타일 사용
                                      color: Colors.black,
                                      fontSize: 16.0, // 폰트 크기를 20.0으로 설정
                                    ),
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.center, // 버튼을 중간에 위치시킴
                                  buttonPadding: EdgeInsets.fromLTRB(
                                      5, 5, 5, 2.0), // 버튼 패딩 조정
                                  actions: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 1.0), // 양옆 간격 조정
                                      width: double.infinity, // 버튼의 너비를 확장
                                      child: TextButton(
                                        child: Text(
                                          '확인',
                                          style: GoogleFonts.oleoScript(
                                            color:
                                                Colors.white, // 폰트 색상을 흰색으로 설정
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors
                                              .deepPurple, // 버튼 배경 색상을 deepPurple로 설정
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // 버튼 모서리 둥글게
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
                            ).then((value) {
                              // 확인 버튼을 누른 후에 로그인 페이지로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            });
                          }
                          // 실패 오류 메시지 출력
                          else {}
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    // 빈 공간 추가
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
