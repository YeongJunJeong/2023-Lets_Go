import 'package:flutter/material.dart';

// 내부 import
import 'package:go_test_ver/mainPage.dart';

// 외부 import
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // API 사용

// 점수 매핑
Map<int, int> createScoreMap() {
  return {
    0: 0,
    1: 1,
    2: 3,
    3: 5, // Default
    4: 7,
    5: 9,
    6: 10,
  };
}

// Survey API(1): 데이터 저장
class SurveyAPI {
  String? gender;
  int? ageGrp;
  int? travelStyl1;
  int? travelStyl2;
  int? travelStyl3;
  int? travelStyl4;
  int? travelStyl5;
  int? travelStyl6;
  int? travelStyl7;
  int? travelStyl8;
  String? userId;

  SurveyAPI(
      {this.gender,
      this.ageGrp,
      this.travelStyl1,
      this.travelStyl2,
      this.travelStyl3,
      this.travelStyl4,
      this.travelStyl5,
      this.travelStyl6,
      this.travelStyl7,
      this.travelStyl8,
      this.userId});

  SurveyAPI.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    ageGrp = json['ageGrp'];
    travelStyl1 = json['travelStyl1'];
    travelStyl2 = json['travelStyl2'];
    travelStyl3 = json['travelStyl3'];
    travelStyl4 = json['travelStyl4'];
    travelStyl5 = json['travelStyl5'];
    travelStyl6 = json['travelStyl6'];
    travelStyl7 = json['travelStyl7'];
    travelStyl8 = json['travelStyl8'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gender'] = this.gender ?? "";
    data['ageGrp'] = this.ageGrp?.toString() ?? "";
    data['travelStyl1'] = this.travelStyl1?.toString() ?? "";
    data['travelStyl2'] = this.travelStyl2?.toString() ?? "";
    data['travelStyl3'] = this.travelStyl3?.toString() ?? "";
    data['travelStyl4'] = this.travelStyl4?.toString() ?? "";
    data['travelStyl5'] = this.travelStyl5?.toString() ?? "";
    data['travelStyl6'] = this.travelStyl6?.toString() ?? "";
    data['travelStyl7'] = this.travelStyl7?.toString() ?? "";
    data['travelStyl8'] = this.travelStyl8?.toString() ?? "";
    data['userId'] = this.userId ?? "";
    return data;
  }
}

// 설문조사 제출 API
Future<void> fetchSurvey(
    BuildContext context,
    String Gender,
    int Age,
    int Nature,
    int Sleep,
    int New,
    int Expensive,
    int Rest,
    int Popular,
    int J,
    int With) async {
  print("Survey API 시작");
  // storage 생성
  final storage = new FlutterSecureStorage();

  // storage 값 읽어오기
  String? userId = await storage.read(key: "login_id");
  String? userAccessToken = await storage.read(key: "login_access_token");
  String? userRefreshToken = await storage.read(key: "login_refresh_token");

  /*
    print("MainPage userId : " + (userId ?? "Unknown"));
    print("MainPage access Token : " + (userAccessToken ?? "Unknown"));
    print("MainPage refresh Token : " + (userRefreshToken ?? "Unknown"));
  */

  final surveyData = SurveyAPI(
    gender: Gender,
    ageGrp: Age,
    travelStyl1: Nature,
    travelStyl2: Sleep,
    travelStyl3: New,
    travelStyl4: Expensive,
    travelStyl5: Rest,
    travelStyl6: Popular,
    travelStyl7: J,
    travelStyl8: With,
    userId: userId,
  );

  print("API 연결 전");
  // API 연결
  final response = await http.post(
    Uri.parse('http://43.203.61.149/survey/enroll/'),
    headers: {"Accept": "application/json"},
    body: surveyData.toJson(),
  );

  print(response.statusCode);
  // 요청이 성공적으로 완료됨
  if (response.statusCode == 201) {
    // print("요청 성공");
    ScaffoldMessenger.of(context).showSnackBar(
      await SnackBar(
        content: Text("성공적으로 제출되었습니다!", style: GoogleFonts.oleoScript()),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    // 각 변수에 값 넣기
  } else {
    // 서버로부터 오류 응답을 받음
    ScaffoldMessenger.of(context).showSnackBar(
      await SnackBar(
        content: Text("알 수 없는 오류가 발생하였습니다. 다시 시도해주세요.",
            style: GoogleFonts.oleoScript()),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
  // 상태 업데이트
  setState() {}
}

class SurveyPage extends StatefulWidget {
  final String? userSurvey; // userSurvey를 위젯 내부에서 사용하기 위한 변수 선언
  SurveyPage(this.userSurvey); // 생성자를 통해 userSurvey 값을 받습니다.

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  static final storage = FlutterSecureStorage();
  late String access;
  late String refresh;

  String selectedGender = ""; // 성별(String형) : M / W
  int selectedAge = 10; // 나이(int형) : 10, 20, 30...

  int selectedNature = 3; // 1. 자연<->도시
  int selectedSleep = 3; // 2. 숙박<->당일치기
  int selectedNew = 3; // 3. 새로운 지역 <-> 익숙한 지역
  int selectedExpensive = 3; // 4. 편하고 비싼 숙소 <-> 불편하고 싼 숙소 선택
  int selectedRest = 3; // 5. 휴식 <-> 체험 선택
  int selectedPopular = 3; // 6. 잘 알려지지 않은 장소 <-> 잘 알려진 장소 선택
  int selectedJ = 3; // 7. 계힉적인 <-> 즉흥적인 선택
  int selectedPhoto = 3; // 8. 사진으로 남기기 <-> 기억으로 남기기
  int selectedWith = 3; // 9. 동반자 적음 <-> 동반자 많음

  var scoreNature = createScoreMap(); // 1. 자연<->도시
  var scoreSleep = createScoreMap(); // 2. 숙박<->당일치기
  var scoreNew = createScoreMap(); // 3. 새로운 지역 <-> 익숙한 지역
  var scoreExpensive = createScoreMap(); // 4. 편하고 비싼 숙소 <-> 불편하고 싼 숙소 선택
  var scoreRest = createScoreMap(); // 5. 휴식 <-> 체험 선택
  var scorePopular = createScoreMap(); // 6. 잘 알려지지 않은 장소 <-> 잘 알려진 장소 선택
  var scoreJ = createScoreMap(); // 7. 계힉적인 <-> 즉흥적인 선택
  var scorePhoto = createScoreMap(); // 8. 사진으로 남기기 <-> 기억으로 남기기
  var scoreWith = createScoreMap(); // 9. 동반자 적음 <-> 동반자 많음

  // 여기에 색상 배열을 정의합니다.
  List<Color> rainbowColors = [
    Color(0xFFB6E0FE), // 파스텔 파란색
    Color(0xFFB2CEFE), // 파스텔 하늘색
    Color(0xFFC2B8FE), // 파스텔 보라색
    Color(0xFFE2B0FE), // 파스텔 연보라색
    Color(0xFFFAB0FE), // 파스텔 핑크
    Color(0xFFFEB0F0), // 파스텔 핑크-보라
    Color(0xFFFEA4C0), // 파스텔 레드-핑크
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      // 스크롤 가능한 레이아웃 추가
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 성별 설문조사
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // 좌우 패딩 설정
              child: Text(
                '성별 선택',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20), // 좌우 20의 패딩 추가
              child: Container(
                color: Colors.white,
                child: Card(
                    elevation: 4,
                    color: Color(0xFFFFFFFF),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround, // 버튼을 화면 가로로 분산 배치
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.male, // 남성 아이콘
                            size: selectedGender == 'M'
                                ? 48
                                : 24, // 선택되면 아이콘 크기 증가
                            color: selectedGender == 'M'
                                ? Colors.blue
                                : Colors.grey, // 선택된 아이콘은 파란색, 그 외는 회색
                          ),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              selectedGender = 'M';
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.female, // 여성 아이콘
                            size: selectedGender == 'W'
                                ? 48
                                : 24, // 선택되면 아이콘 크기 증가
                            color: selectedGender == 'W'
                                ? Colors.pink
                                : Colors.grey, // 선택된 아이콘은 분홍색, 그 외는 회색
                          ),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              selectedGender = 'W';
                            });
                          },
                        ),
                      ],
                    )),
              ),
            ),
            // 나이 설문조사
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // 좌우 패딩 설정
              child: Text(
                '나이대 선택',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20), // 좌우 20의 패딩 추가
              child: Card(
                elevation: 4,
                color: Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Slider(
                      min: 10,
                      max: 100,
                      divisions: 9,
                      value: selectedAge.toDouble(),
                      label: selectedAge.toString(),
                      onChanged: (double newValue) {
                        setState(() {
                          selectedAge = newValue.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 60),
            // 1. 자연<->도시 (장소)
            buildOptionSection(
              '자연',
              '도시',
              selectedNature,
              7,
              (index) {
                setState(() {
                  selectedNature = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 2. 숙박<->당일치기 (기간)
            buildOptionSection(
              '숙박',
              '당일치기',
              selectedSleep,
              7,
              (index) {
                setState(() {
                  selectedSleep = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 3. 새로운 지역 <-> 익숙한 지역 (지역)
            buildOptionSection(
              '새로운 장소',
              '익숙한 장소',
              selectedNew,
              7,
              (index) {
                setState(() {
                  selectedNew = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 4. 편하고 비싼 숙소 <-> 불편하고 싼 숙소 선택 (숙소)
            buildOptionSection(
              '편하지만 비싼 숙소',
              '불편하지만 싼 숙소',
              selectedExpensive,
              7,
              (index) {
                setState(() {
                  selectedExpensive = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 5. 휴식 <-> 체험 선택 (활동)
            buildOptionSection(
              '휴식',
              '체험',
              selectedRest,
              7,
              (index) {
                setState(() {
                  selectedRest = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 6. 잘 알려지지 않은 장소 <-> 잘 알려진 장소 선택 (방문지)
            buildOptionSection(
              '구석진 장소',
              '알려진 장소',
              selectedPopular,
              7,
              (index) {
                setState(() {
                  selectedPopular = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 7. 계힉적인 <-> 즉흥적인 선택 (계획)
            buildOptionSection(
              '계획적인',
              '즉흥적인',
              selectedJ,
              7,
              (index) {
                setState(() {
                  selectedJ = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 8. 사진으로 남기기 <-> 기억으로 남기기 (사진)
            buildOptionSection(
              '사진으로 남기기',
              '기억으로 남기기',
              selectedPhoto,
              7,
              (index) {
                setState(() {
                  selectedPhoto = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 9. 동반자 적음 <-> 동반자 많음 (동반자)
            buildOptionSection(
              '동반자 적음',
              '동반자 많음',
              selectedWith,
              7,
              (index) {
                setState(() {
                  selectedWith = index;
                });
              },
            ),
            SizedBox(height: 70),
            // 10. "제출" 버튼
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20), // 좌우 20의 패딩 추가
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // 조건 : 모두 설정했을 때
                    if (selectedGender != '') {
                      fetchSurvey(
                          context,
                          selectedGender,
                          selectedAge,
                          selectedNature,
                          selectedSleep,
                          selectedNew,
                          selectedExpensive,
                          selectedRest,
                          selectedPopular,
                          selectedJ,
                          selectedWith);

                      // 비동기식 이동
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage()), // 다음 화면으로 이동
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("정보를 모두 입력해주세요.",
                              style: GoogleFonts.oleoScript()),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 테두리를 둥글게 설정
                    ),
                    elevation: 4, // 그림자 추가
                    backgroundColor: Color(0xFFFFFFFF), // 배경색을 흰색으로 설정
                  ),
                  child: Text(
                    '제출',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    ));
  }

  // 동그라미 선택하는거 크기 및 모양
  Widget buildOptionSection(String leftText, String rightText,
      int selectedOption, int optionsCount, void Function(int) onTap) {
    // 원의 크기 설정을 위한 배열
    List<double> sizes = [100, 80, 60, 40, 60, 80, 100]; // 크기를 조정합니다.

    return Column(
      children: [
        // 라벨 배치 조정
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 라벨들을 양 끝으로 분배
          children: [
            // "자연" 라벨에 대한 컨테이너, 왼쪽에서 5픽셀 떨어짐
            Container(
              margin: EdgeInsets.only(left: 20), // 왼쪽 여백 추가
              child: Text(leftText, style: TextStyle(fontSize: 22)),
            ),
            // "도시" 라벨에 대한 컨테이너, 오른쪽에서 5픽셀 떨어짐
            Container(
              margin: EdgeInsets.only(right: 20), // 오른쪽 여백 추가
              child: Text(rightText, style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
        SizedBox(height: 12), // 라벨과 원 사이의 간격 조정
        // 원들 배치
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // 공간을 더 넓게 하기 위해 변경
          children: List.generate(
            optionsCount,
            (index) => GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                width: sizes[index], // 인덱스에 따른 크기 할당
                height: sizes[index], // 인덱스에 따른 크기 할당
                margin: EdgeInsets.symmetric(horizontal: 2), // 원 사이의 간격 조절
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedOption == index
                      ? rainbowColors[index] // 선택된 옵션에 따라 색상 배열에서 색상 할당
                      : Colors.grey.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
