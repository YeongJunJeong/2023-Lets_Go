// 내부 import
import 'package:go_test_ver/homeScreen.dart';
import 'package:go_test_ver/login.dart';
import 'package:go_test_ver/postCard.dart';
import 'package:go_test_ver/searchPage.dart';
import 'package:go_test_ver/chatBot.dart';
import 'package:go_test_ver/survey.dart';
import 'package:go_test_ver/myPage.dart';

// 외부 import
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 패키지를 가져옵니다.
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장
import 'package:http/http.dart' as http; // API 사용
import 'dart:convert'; // API 호출 : 디코딩

// 1. 메인 페이지에서 userName을 마이 페이지에게 넘겨주는 방식은?
// 2. userSurvey를 검사해서 null이면은 설문조사 안 한 것.
// 2.1 null일 때, (post) /survey/enroll 사용해서 입력..?
// 2.2 제출을 눌렀을 때에, mainPage로 이동하게끔

String userName = "";
dynamic userSurvey = "";

// 메인 페이지
// 이후에 mainpage.dart 파일 만들어서 옮기기.
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

// 메인페이지 코드
class _MainPageState extends State<MainPage> {
  //데이터를 이전 페이지에서 전달 받은 정보를 저장하기 위한 변수
  static final storage = FlutterSecureStorage();

  int _selectedIndex = 0;

  // pages 선언
  List<Widget> pages = [];

  // 하단 네비게이션 바
  List<BottomNavigationBarItem> bottomItems = [
    // 1. 메인 페이지 : 라벨, 아이콘
    BottomNavigationBarItem(
      label: 'Home',
      icon: Icon(Icons.home),
    ),
    // 2. 검색 페이지 : 라벨, 아이콘
    BottomNavigationBarItem(
      label: '검색',
      icon: Icon(Icons.search),
    ),
    // 3. 챗봇 페이지 : 라벨, 페이지
    BottomNavigationBarItem(
      label: '챗봇',
      icon: Icon(Icons.question_answer),
    ),

    // 4. 마이 페이지 : 라벨, 페이지
    BottomNavigationBarItem(
      label: '내 정보',
      icon: Icon(Icons.person),
    ),
  ];

  // USER 정보 얻는 API
  Future<void> fetchUserInfo() async {
    // storage 생성
    final storage = new FlutterSecureStorage();

    // login때 저장한 storage 값 읽어오기
    /*
    // if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
    */
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");
    String? userRefreshToken = await storage.read(key: "login_refresh_token");

    print("MainPage userId : " + (userId ?? "Unknown"));
    print("MainPage access Token : " + (userAccessToken ?? "Unknown"));
    print("MainPage refresh Token : " + (userRefreshToken ?? "Unknown"));

    // url에 "userId" + "access Token" 넣기
    final url =
        Uri.parse('http://43.203.61.149/user/list/$userId'); // API 엔드포인트
    final response = await http.get(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
      },
    );

    if (response.statusCode == 200) {
      // 요청이 성공적으로 완료됨
      // response body 전체 응답 받기
      print("MyPage User 정보 받음: ${response.body}");
      var responseData = json.decode(response.body);

      // 데이터 선택해서 저장
      setState(() {
        userName = responseData['userName'];
        userSurvey = responseData['survey'];

        pages = [
          HomeScreen(), // 여기에 필요한 Token 전달
          SearchPage(), // 여기에 필요한 Token 전달
          userSurvey == null || userSurvey == "null"
              ? SurveyPage(userSurvey)
              : ChatBotApp(),
          MyPage(userName), // 여기에 필요한 Token 전달
        ];
      });
    } else {
      print("Failed to load user details");
    }
    // 상태 업데이트
    setState(() {});
  }

  // 유저 정보 가져오는 API 사용 - <Future> fetchUserInfo
  void initState() {
    super.initState();
    fetchUserInfo(); // 사용
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0, // 제목과 아이콘 사이의 공간을 제거
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Row 내 요소들을 가운데 정렬
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(left: 50.0), // 오른쪽에서 20만큼 떨어짐
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Let\'s go?',
                      style: GoogleFonts.oleoScript(fontSize: 36),
                    ),
                  ),
                ),
                // 로그아웃 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0), // 오른쪽에서 20만큼 떨어짐
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app), // 열려 있는 문 아이콘
                      onPressed: () {
                        logoutFunction(context); // 로그아웃 함수 호출
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 하단 네비게이션 바 UI
          // 색상 및 크기
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey.withOpacity(.60),
            selectedFontSize: 14,
            unselectedFontSize: 10,
            currentIndex: _selectedIndex,

            showSelectedLabels: false, //아이콘 밑 글씨 삭제
            showUnselectedLabels: false,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: bottomItems,
          ),
          // 하단에서 선택된 페이지 보여줌
          body: pages.isEmpty
              ? CircularProgressIndicator() // fetch에서 pages가 만들어질 때까지, 대기중(데이터 로딩 중) 표시
              : pages[_selectedIndex], // 선택된 인덱스의 페이지 표시
        ));
  }

  void logoutFunction(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}
