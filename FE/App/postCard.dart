// 내부 import
import 'package:go_test_ver/advertisement_2.dart';
import 'package:go_test_ver/advertisement_3.dart';
import 'package:go_test_ver/map.dart';
import 'package:go_test_ver/searchPage.dart';
import 'package:go_test_ver/searchPage_info.dart';
import 'advertisement_1.dart'; // 광고 창
// import 'package:go_test_ver/recommand.dart';

// 외부 import
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:http/http.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 패키지를 가져옵니다.
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; // 튜토리얼 패키지
import 'package:http/http.dart' as http; // API 사용
import 'dart:convert'; // API 호출 : 디코딩
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장

import 'package:flutter_naver_map/flutter_naver_map.dart';

// 1. 스파밸리 정보
Map<String, dynamic> place1 = {
  "id": 196, // 사용
  "name": "스파밸리", // 사용
  "image": "/media/image/%EC%8A%A4%ED%8C%8C%EB%B0%B8%EB%A6%AC.jpg", // 사용 X?
  "classification": "기타유원시설업", // 사용
  "parking": true, // 사용
  "info": "겨울 온천수로 즐기는 워터파크 스파밸리!", // 사용
  "call": "1688-8511", // 사용
  "hardness": 128.635446,
  "latitude": 35.7880646,
  "tag": [
    // 사용
    {"name": "#물놀이"},
    {"name": "#아이와놀자"},
    {"name": "#제로페이"},
    {"name": "#카카오페이"},
  ],
  "time": "체류시간 2시간이상", // 사용
};

// 2. 고산골 공룡공원 정보
Map<String, dynamic> place2 = {
  "id": 254, // 사용
  "name": "고산골 공룡공원", // 사용
  "image":
      "/media/image/%EA%B3%A0%EC%82%B0%EA%B3%A8_%EA%B3%B5%EB%A3%A1%EA%B3%B5%EC%9B%90.jpg", // 사용 X?
  "classification": "관광지", // 사용
  "parking": true, // 사용
  "info": "고산골 일대 1억년 전 중생대 백악기의 흔적을 볼 수 있는 곳", // 사용
  "call": "053-664-2782", // 사용
  "hardness": 128.6037566,
  "latitude": 35.8294673,
  "tag": [
    // 사용
    {"name": "#단풍명소"},
    {"name": "#산책로"},
    {"name": "#아이와놀자"},
    {"name": "#포토존"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

// 3. 동촌파크광장놀이공원
Map<String, dynamic> place3 = {
  "id": 168, // 사용
  "name": "동촌파크광장놀이공원", // 사용
  "image":
      "/media/image/%EB%8F%99%EC%B4%8C%ED%8C%8C%ED%81%AC%EA%B4%91%EC%9E%A5%EB%86%80%EC%9D%B4%EA%B3%B5%EC%9B%90.jpg",
  "classification": "일반유원지/일반놀이공원", // 사용
  "parking": true, // 사용
  "info": "테마공원/유원지", // 사용
  "call": "-", // 사용
  "hardness": 128.6535591,
  "latitude": 35.87874477,
  "tag": [
    // 사용
    {"name": "#아이와놀자"},
    {"name": "#포토존"},
  ],
  "time": "체류시간 2시간이상", // 사용
};

// 4. 앞산전망대 정보
Map<String, dynamic> place4 = {
  "id": 326, // 사용
  "name": "앞산전망대", // 사용
  "image":
      "/media/image/%EC%95%9E%EC%82%B0%EC%A0%84%EB%A7%9D%EB%8C%80.jpg", // 사용 X?
  "classification": "관광지", // 사용
  "parking": true, // 사용
  "info": "한국관광 100선 선정, 대구시가지 전경을 한눈에 내려다볼 수 있는 대표 야간관광지", // 사용
  "call": "053-803-5450", // 사용
  "hardness": 128.5794424,
  "latitude": 35.8247849,
  "tag": [
    // 사용
    {"name": "#나들이"},
    {"name": "#벚꽃명소"},
    {"name": "#일출명소"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

// 5. 용문폭포 정보
Map<String, dynamic> place5 = {
  "id": 403, // 사용
  "name": "용문폭포", // 사용
  "image": "/media/image/%EC%9A%A9%EB%AC%B8%ED%8F%AD%ED%8F%AC.jpg", // 사용 X?
  "classification": "폭포/계곡", // 사용
  "parking": true, // 사용
  "info": "폭포/계곡", // 사용
  "call": "-", // 사용
  "hardness": 128.5279518,
  "latitude": 35.78181812,
  "tag": [
    // 사용
    {"name": "#물놀이"},
    {"name": "#산책로"},
  ],
  "time": "체류시간 1시간", // 사용
};

class PostCard extends StatefulWidget {
  /*
  // 랜덤 장소
  final Map<String, dynamic> place1;
  final Map<String, dynamic> place2;
  final Map<String, dynamic> place3;
  final Map<String, dynamic> place4;
  final Map<String, dynamic> place5;
  */
  final String lat; // 위도 데이터 저장
  final String lon; // 경도 데이터 저장
  final Map<String, dynamic> weatherData; // 날씨 데이터 저장 1
  final int number; // 날씨 데이터 저장 2

  PostCard({
    Key? key,
    required this.lat,
    required this.lon,
    required this.weatherData,
    required this.number,
    /*
    required this.place1,
    required this.place2,
    required this.place3,
    required this.place4,
    required this.place5,
    */
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

// 밑에있는 페이지 컨트롤에 필요함, 따로 호출하지 않음 메인 페이지의 사진이 @초 마다 지나간다는 걸 컨트롤 할 때
class _PostCardState extends State<PostCard> {
  final storage = FlutterSecureStorage(); // Local 내부 저장소 사용
  PageController _pageController = PageController(); // 이미지 컨트롤 타이머
  Timer? _timer;
  double _currentPage = 0;

  // 페이지 이동 시간
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.page == _pageController.initialPage + 2) {
        _pageController.animateToPage(
          _pageController.initialPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  late TutorialCoachMark tutorialCoachMark; // 생성
  GlobalKey keyButton1 = GlobalKey(); // 여행 정보 튜토리얼
  GlobalKey keyButton1_1 = GlobalKey(); // 여행 정보 튜토리얼
  GlobalKey keyButton2 = GlobalKey(); // 챗봇 추천 튜토리얼
  GlobalKey keyButton3 = GlobalKey(); // 플랜 작성 튜토리얼
  GlobalKey keyButton4 = GlobalKey(); // 링크 공유 튜토리얼

  // 제공하는 서비스 - 클릭 이벤트 코드
  void onServiceTap(int index) {
    // index에 따라서 발동
    List<TargetFocus> targets = _createTargets(index);

    // 튜토리얼 UI
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Color.fromARGB(255, 72, 22, 78),
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
    tutorialCoachMark.show(context: context);
    print('Service $index clicked');
  }

  // 제공하는 서비스 - Text 수정
  final List<String> serviceTitles = [
    '여행 정보\n( Click! )',
    '챗봇 추천\n( Click! )',
    '플랜 작성\n( Click! )',
    '장소 저장\n( Click! )',
  ];

  // 튜토리얼 & 가이드라인
  List<TargetFocus> _createTargets(int index) {
    List<TargetFocus> targets = []; // target[] 생성
    if (index == 0) {
      // Scrollable.ensureBisible(
      //  _widgetKey.currentcontext!,
      //  duration: Durtaion(milliseconds: 300), // 동작 시간
      //  curve: Cureves.easeInOut, // 효과?
      //  aligmnet: 0 // Widget을 스크롤의 어느 위치에 보여줄지
      //  // 0.5 : 위아래 살짝 보임, 1.0 : 아래 X, 위 많이 보임
      // )
      // 타겟 1
      targets.add(
        TargetFocus(
          identify: "Target 1",
          keyTarget: keyButton1,
          // 내용
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "여행 정보",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 25.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "다양한 방식을 통해 여행지 정보를 얻을 수 있습니다!\n\n1. 메인 배너 광고\n\n2. 장소 검색\n\n3. 지도 검색",
                          style: TextStyle(color: Colors.black, fontSize: 15.0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
      // 타겟 이어서 작성 =
    }
    if (index == 1) {
      // 타겟 2
      targets.add(
        TargetFocus(
          identify: "Target 2",
          keyTarget: keyButton2,
          // 내용
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경
                    borderRadius: BorderRadius.circular(15.0), // 둥근 테두리
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "챗봇 추천",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 검은색 글씨
                            fontSize: 25.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "아래 네비게이션 바의 채팅 아이콘을 누르면, 챗봇이 맞춤형 장소를 추천해줍니다!",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0), // 검은색 글씨
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    if (index == 2) {
      // 타겟 3
      targets.add(
        TargetFocus(
          identify: "Target 3",
          keyTarget: keyButton3,
          // 내용
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경
                    borderRadius: BorderRadius.circular(15.0), // 둥근 테두리
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "플랜 작성",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 검은색 글씨
                            fontSize: 25.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "챗봇을 통해 플랜을 저장할 수 있고, 플랜을 직접 만들 수도 있어요!",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0), // 검은색 글씨
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    if (index == 3) {
      // 타겟 4
      targets.add(
        TargetFocus(
          identify: "Target 4",
          keyTarget: keyButton4,
          // 내용
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경
                    borderRadius: BorderRadius.circular(15.0), // 둥근 테두리
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "장소 저장",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 검은색 글씨
                            fontSize: 25.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "더 많은 장소를 한 번에 보고 싶을 때에는 추천 장소를 찜하여 한 번에 볼 수 있어요!",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0), // 검은색 글씨
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    return targets;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  /*
  Future<String> getAddress(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=AIzaSyAYSmSk0dKqVRjel99PQMKZuSIUN2zn8fE'),
    );

    // print(response.statusCode);
    print("위치 : ");
    print(jsonDecode(response.body)['results'][0]['formatted_address']);
    return jsonDecode(response.body)['results'][0]['formatted_address'];
  }
  */

  @override
  Widget build(BuildContext context) {
    final double latitude = double.parse(widget.lat);
    final double longitude = double.parse(widget.lon);

    int conditionId = widget.weatherData['conditionId'] ?? 0;
    String temperature =
        widget.weatherData['temperature']?.toString() ?? 'unknown';
    String temperature_min =
        widget.weatherData['temperature_min']?.toString() ?? 'unknown';
    String temperature_max =
        widget.weatherData['temperature_max']?.toString() ?? 'unknown';
    String humidity = widget.weatherData['humidity']?.toString() ?? 'unknown';
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 1. 움직이는 캐러셀
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 2.0, // 가로 길이
              child: Stack(
                alignment: Alignment.bottomCenter, // 인디케이터
                children: [
                  Container(
                    height: 240,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        print('Page changed to: $page');
                      },
                      itemCount: 3,
                      itemBuilder: (context, position) {
                        // 1. 여름철 시원하게 보내기 광고
                        if (position == 0) {
                          return GestureDetector(
                            onTap: () {
                              // 첫 번째 광고 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdvertisementPage_1(),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 2.0,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/advertisement_1.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center, // 텍스트 위치
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(0.4), // 불투명도 조절
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // 광고 1번 텍스트
                                  child: Text(
                                    '여름철 시원하게 보내기',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // 2. 인기 휴양지
                        else if (position == 1) {
                          return GestureDetector(
                            onTap: () {
                              // 두 번째 광고 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdvertisementPage_2(),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 2.0,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/advertisement_2.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center, // 텍스트 위치
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(0.4), // 불투명도 조절
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // 광고 2번 텍스트
                                  child: Text(
                                    '인기 관광지',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // 3. 최근 떠오르는 장소
                        else if (position == 2) {
                          return GestureDetector(
                            onTap: () {
                              // 두 번째 광고 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdvertisementPage_3(),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 2.0,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/advertisement_3.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center, // 텍스트 위치
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(0.4), // 불투명도 조절
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '최근 떠오르는 장소',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  DotsIndicator(
                    dotsCount: 3,
                    position: _currentPage
                        .toInt(), // _currentPage(현재 페이지)를 int로 변경하고 1로
                    decorator: DotsDecorator(
                      activeColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 여백
          Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 1.5 : Text 문구
          Container(
            color: Colors.white, // 배경색을 하얀색으로 설정
            child: SizedBox(
              width: double.infinity, // 가로로 꽉 차게
              child: Center(
                // 가운데 정렬
                child: Column(
                  children: [
                    Text(
                      '가볼까가 추천하는 여행지', // 한글 제목
                      style: GoogleFonts.oleoScript(
                        fontSize: 16, // 글씨 크기 조절
                        fontWeight: FontWeight.bold, // 글씨 두껍게
                        color: Colors.black, // 글씨 색상은 검은색
                      ),
                    ),
                    SizedBox(height: 10), // 한글과 영문 제목 사이의 간격을 조정
                    Text(
                      'Go to Trip?', // 영문 제목
                      // style: GoogleFonts.oleoScript(fontSize: 36),
                      style: GoogleFonts.oleoScript(
                        fontSize: 24, // 글씨 크기 조절
                        fontWeight: FontWeight.bold, // 글씨 두껍게
                        color: Colors.black, // 글씨 색상은 검은색
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 2. 동그라미 광고판
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: 200,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6, // 원이 6개 있음
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // 1) 검색 페이지 이동
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
                      },
                      child: Container(
                        // 첫번째 원
                        width: 130, // 원의 너비
                        margin: EdgeInsets.symmetric(horizontal: 5), // 원 사이의 간격
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey, // 회색으로 채우기
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 40,
                              color: Colors.white, // 아이콘 색상
                            ),
                            SizedBox(height: 10),
                            Text(
                              '검색',
                              style: GoogleFonts.oleoScript(
                                color: Colors.white, // 텍스트 색상
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // 두 번째 원 (광고 시작)
                  else if (index == 1) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailPage(
                                placeDetails: place1), // 장소 상세보기로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: 130, // 각 원의 너비
                        margin: EdgeInsets.symmetric(
                            horizontal: 5), // 각 원 사이의 간격 조정
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'http://43.203.61.149${place1['image']}'), // 기본 이미지로 대체
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                  // 세 번째 광고
                  else if (index == 2) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailPage(
                                placeDetails: place2), // 장소 상세보기로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: 130, // 각 원의 너비
                        margin: EdgeInsets.symmetric(
                            horizontal: 5), // 각 원 사이의 간격 조정
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'http://43.203.61.149${place2['image']}'), // 기본 이미지로 대체
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                  // 네 번째 광고
                  else if (index == 3) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailPage(
                                placeDetails: place3), // 장소 상세보기로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: 130, // 각 원의 너비
                        margin: EdgeInsets.symmetric(
                            horizontal: 5), // 각 원 사이의 간격 조정
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'http://43.203.61.149${place3['image']}'), // 기본 이미지로 대체
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                  // 다섯 번째 광고
                  else if (index == 4) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailPage(
                                placeDetails: place4), // 장소 상세보기로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: 130, // 각 원의 너비
                        margin: EdgeInsets.symmetric(
                            horizontal: 5), // 각 원 사이의 간격 조정
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'http://43.203.61.149${place4['image']}'), // 기본 이미지로 대체
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                  // 여섯 번째 광고
                  else if (index == 5) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailPage(
                                placeDetails: place5), // 장소 상세보기로 이동
                          ),
                        );
                      },
                      child: Container(
                        width: 130, // 각 원의 너비
                        margin: EdgeInsets.symmetric(
                            horizontal: 5), // 각 원 사이의 간격 조정
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'http://43.203.61.149${place5['image']}'), // 기본 이미지로 대체
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 2.5 : Text 문구
          Container(
            color: Colors.white, // 배경색을 하얀색으로 설정
            child: SizedBox(
              width: double.infinity, // 가로로 꽉 차게
              child: Center(
                // 가운데 정렬
                child: Column(
                  children: [
                    Text(
                      '제공하는 서비스', // 한글 제목
                      style: GoogleFonts.oleoScript(
                        fontSize: 16, // 글씨 크기 조절
                        fontWeight: FontWeight.bold, // 글씨 두껍게
                        color: Colors.black, // 글씨 색상은 검은색
                      ),
                    ),
                    SizedBox(height: 10), // 한글과 영문 제목 사이의 간격을 조정
                    Text(
                      '가볼까?', // 영문 제목
                      style: GoogleFonts.oleoScript(
                        fontSize: 24, // 글씨 크기 조절
                        fontWeight: FontWeight.bold, // 글씨 두껍게
                        color: Colors.black, // 글씨 색상은 검은색
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 3. 제공하는 서비스
          Container(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: serviceTitles.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    key: index == 0
                        ? keyButton1
                        : index == 1
                            ? keyButton2
                            : index == 2
                                ? keyButton3
                                : keyButton4,
                    onTap: () {
                      onServiceTap(index); // 서비스 클릭 이벤트를 실행합니다.
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          serviceTitles[index], // 서비스별 고유한 텍스트
                          style: GoogleFonts.oleoScript(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 3.5 : Text 문구
          Container(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '현재 위치는?', // 제목
                      style: GoogleFonts.oleoScript(
                        fontSize: 16, // 글자 크기
                        fontWeight: FontWeight.bold, // 글자 두께
                        color: Colors.black, // 글자 색상
                      ),
                    ),
                    SizedBox(height: 10), // 제목과 아이콘 사이의 간격
                    SizedBox(height: 10), // 아이콘과 날씨 정보 사이의 간격
                    Text(
                      // '${getWeatherIcon(conditionId)}   ${widget.weatherData['temperature_min']}~${widget.weatherData['temperature_max']}°C   ${widget.weatherData['humidity']}%', // 날씨 정보
                      '${getWeatherIcon(conditionId)}   ${widget.weatherData['temperature']}°C   ${widget.weatherData['humidity']}%', // 날씨 정보
                      style: GoogleFonts.oleoScript(
                        fontSize: 24, // 글자 크기
                        fontWeight: FontWeight.bold, // 글자 두께
                        color: Colors.black, // 글자 색상
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          // 4. 현재 위치 표시
          Container(
            margin: EdgeInsets.all(8.0),
            width: double.infinity, // 필요에 따라 너비 조정
            height: 200, // 필요에 따라 높이 조정
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            // 네이버 지도 사용
            child: NaverMap(
              // 옵션 :
              options: NaverMapViewOptions(
                // 옵션 1. 첫 로딩시 카메라 포지션 지정
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(latitude, longitude), // 위도 + 경도
                  zoom: 16,
                ),
                locationButtonEnable: true, // 옵션 2. 현재 위치 버튼 표시 여부 설정
                scaleBarEnable: true, // 옵션 3. 축적 바 (활성화)
                rotationGesturesEnable: true, // 옵션 4. 제스처 - 회전 (활성화)
                scrollGesturesEnable: true, // 옵션 5. 제스처 - 스크롤 (활성화)
                zoomGesturesEnable: true, // 옵션 6. 제스처 - 줌 (활성화)
                scrollGesturesFriction: 0.3, // 옵션 7. 스크롤 마찰계수
                zoomGesturesFriction: 0.3, // 옵션 8. 줌 마찰계수
              ),
              // 지도가 준비되었을 때
              onMapReady: (controller) {
                final marker = NMarker(
                  id: "test",
                  position: NLatLng(latitude, longitude),
                );
                controller.addOverlay(marker);
              },
              // 지도를 클릭했을 때
              onMapTapped: (NPoint point, NLatLng latLng) {
                print("지도 클릭");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapTest(latitude, longitude),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          /*
          Container(
            margin: EdgeInsets.all(8.0),
            width: double.infinity, // 필요에 따라 너비 조정
            height: 200, // 필요에 따라 높이 조정
            decoration: BoxDecoration(
              color: Colors.blue[300], // 박스의 배경색 설정
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 20, // 위치 필요에 따라 조정
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "대구광역시 신당동", // 사용 가능하다면 동적 위치 데이터로 교체
                        style: GoogleFonts.oleoScript(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}
