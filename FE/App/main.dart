// 메인 페이지
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:go_test_ver/login.dart';
import 'package:go_test_ver/mainPage.dart';

// import : 로딩 애니메이션 패키지
import 'package:flutter_spinkit/flutter_spinkit.dart'; // import : 로딩 애니메이션
import 'dart:async';
import 'package:go_test_ver/loadingText.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

// import : 로그인 페이지로 이어짐
// import 'package:go_test_ver/login.dart';

Future<void> main() async {
  KakaoSdk.init(
    nativeAppKey: '21ec99e3bdf6dcb0e2d4e1eaba24cd9d',
    javaScriptAppKey: 'd33777b631cfbe4c9534dc2340196a1b',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: 'kyr0076qg9');
  runApp(const MyApp());
}

// 로딩 페이지를 앱 시작점으로 설정.
// 로딩 시간 동안 데이터 불러오기
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 디버그 표시를 없앤다.
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // 라우트 설정
      routes: {
        '/login': (context) => LoginPage(),
        '/mainPage': (context) => MainPage(),
      },
      // 테마 설정
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoadingPage(), // 로딩 페이지를 홈으로 설정
    );
  }
}

// 1. 로딩 페이지 (메인 페이지)
class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

// 로딩 페이지 상태
class _LoadingPageState extends State<LoadingPage> {
  // 1-1. 3초 뒤 로그인 페이지로 이동
  @override
  void initState() {
    super.initState();
    // 시간 설정
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingTextPage()),
      );
    });
  }

  // 1-2. 로딩 애니메이션
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Create SpinKitPumpingHeart()
              SpinKitWave(
                // 1. 색상
                color: Colors.red,
                // 2. 크기
                size: 50.0,
                // 3. 애니메이션 시간
                duration: Duration(seconds: 2),
              ),
            ],
          )),
    );
  }
}
