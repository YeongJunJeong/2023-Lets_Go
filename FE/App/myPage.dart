// 내부 import
import 'package:go_test_ver/searchPage.dart';
import 'package:go_test_ver/searchPage_info.dart';
import 'package:go_test_ver/searchPage2_info.dart';

// 외부 import
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // API 사용
import 'dart:convert'; // API 호출 : 디코딩
import 'package:intl/intl.dart'; // yyyy.mm.dd형식을 yy.mm.dd형식으로
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; // 튜토리얼 패키지

// 아직 사용 X
String? userAccessToken = "";
String? userRefreshToken = "";

class PlanDetailsPage extends StatefulWidget {
  final List<dynamic> schedule; // 스케줄 데이터 리스트를 받는다

  PlanDetailsPage({Key? key, required this.schedule}) : super(key: key);

  @override
  _PlanDetailsPageState createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  late NaverMapController _mapController;
  double sheetExtent = 0.5;

  Future<void> updatePlan(int planId, List<dynamic> updatedSchedule) async {
    final response = await http.patch(
      Uri.parse('http://43.203.61.149/plan/plan/$planId/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'schedule': updatedSchedule,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 업데이트됨
      print('Plan updated successfully.');
    } else {
      // 업데이트 실패
      print('Failed to update plan. Error: ${response.body}');
    }
  }

  Future<void> deleteScheduleFromPlan(int planId, int scheduleId) async {
    final planResponse = await http.get(
      Uri.parse('http://43.203.61.149/plan/plan/$planId/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (planResponse.statusCode == 200) {
      final planData = jsonDecode(planResponse.body);
      List<dynamic> updatedSchedule =
          List<Map<String, dynamic>>.from(planData['schedule']);
      updatedSchedule.removeWhere((schedule) => schedule['id'] == scheduleId);

      await updatePlan(planId, updatedSchedule);
    } else {
      print('Failed to fetch plan data. Error: ${planResponse.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 계획'),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child: widget.schedule.isEmpty
                      ? Center(
                          child: Text(
                            '장소 없음',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : NaverMap(
                          onMapReady: (controller) {
                            _mapController = controller;
                            _addMarkers();
                          },
                          options: NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(
                              target: NLatLng(
                                widget.schedule[0]['latitude'] ?? 0.0,
                                widget.schedule[0]['hardness'] ?? 0.0,
                              ),
                              zoom: 11,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                sheetExtent = notification.extent;
              });
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 5,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Center(
                          child: Icon(
                            Icons.drag_handle,
                            color: Color.fromARGB(255, 128, 128, 128),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: <Widget>[
                            SliverReorderableList(
                              itemCount: widget.schedule.length,
                              itemBuilder: (context, index) {
                                var item = widget.schedule[index];
                                DateTime startDate =
                                    DateTime.parse(item['start_date'] ?? '');
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd, HH:mm')
                                        .format(startDate);
                                return Card(
                                  key: ValueKey(item['id']),
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text('${index + 1}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    title: GestureDetector(
                                      child: Text(item['place'] ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    subtitle: Text("$formattedDate"),
                                    trailing: ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(Icons.drag_handle),
                                    ),
                                    onTap: () async {
                                      try {
                                        final response = await http.post(
                                          Uri.parse(
                                              'http://43.203.61.149/place/find/'),
                                          headers: {
                                            "Content-Type": "application/json"
                                          },
                                          body: jsonEncode(
                                              {"name": item['place']}),
                                        );

                                        if (response.statusCode == 200) {
                                          var data = jsonDecode(
                                              utf8.decode(response.bodyBytes));
                                          //print(data);

                                          // searchPage2.dart로 데이터 전달
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPage2(placeData: data),
                                            ),
                                          );
                                        } else {
                                          //print
                                          ('Failed to fetch place data: ${response.statusCode}');
                                        }
                                      } catch (error) {
                                        //print('Error: $error');
                                      }
                                    },
                                  ),
                                );
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item =
                                      widget.schedule.removeAt(oldIndex);
                                  widget.schedule.insert(newIndex, item);
                                  _updateMarkers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // 여기로 "장소 추가" 버튼을 추가
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 20.0),
                            textStyle: TextStyle(fontSize: 15.0),
                          ),
                          child: Text(
                            '장소 추가',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 70, 0, 0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMarkers() {
    for (var i = 0; i < widget.schedule.length; i++) {
      final marker = NMarker(
        id: widget.schedule[i]['id'].toString(),
        position: NLatLng(
            widget.schedule[i]['latitude'], widget.schedule[i]['hardness']),
        caption: NOverlayCaption(
          text: '${i + 1}',
          textSize: 15,
          color: Colors.black,
          haloColor: Colors.white,
        ),
      );
      _mapController.addOverlay(marker);
    }
  }

  void _updateMarkers() {
    _mapController.clearOverlays();
    _addMarkers();
  }
}

// 찜목록
class FavoritePlace {
  final int id; // 장소 Id
  final String name; // 장소 이름
  final String streetNameAddress; // 주소
  final String imageUrl; // 이미지 url
  final String classification; // 분류

  FavoritePlace({
    required this.id,
    required this.name,
    required this.streetNameAddress,
    required this.imageUrl,
    required this.classification,
  });

  factory FavoritePlace.fromJson(Map<String, dynamic> json) {
    return FavoritePlace(
      id: json['id'] as int? ?? 0, // 'id'가 null이면 0을 기본값으로 사용
      name: json['name'] as String? ??
          'Unknown', // 'name'이 null이면 'Unknown'을 기본값으로 사용
      streetNameAddress: json['street_name_address'] as String? ??
          'No address provided', // 주소가 null이면 기본 텍스트 제공
      imageUrl:
          json['image'] as String? ?? '', // 'image'가 null이면 빈 문자열을 기본값으로 사용
      classification: json['classification'] as String? ??
          'Unclassified', // 'classification'이 null이면 'Unclassified'를 기본값으로 사용
    );
  }
}

// 리뷰 목록
class ReviewPlace {
  final int id; // 리뷰 Id
  final String content; // 리뷰 내용
  final String? image; // 이미지 URL, null 가능
  final int score; // 리뷰 점수
  final String createdAt; // 작성 날짜
  final int place; // 장소 Id
  final String writer; // 작성자

  ReviewPlace({
    required this.id,
    required this.content,
    required this.image,
    required this.score,
    required this.createdAt,
    required this.place,
    required this.writer,
  });

  factory ReviewPlace.fromJson(Map<String, dynamic> json) {
    return ReviewPlace(
      id: json['id'] as int? ?? 0, // 'id'가 null이면 0을 기본값으로 사용
      content: json['content'] as String? ??
          'No content', // 'content'가 null이면 'No content'를 기본값으로 사용
      image: json['image'] as String?, // 'image'는 null 가능
      score: json['score'] as int? ?? 0, // 'score'가 null이면 0을 기본값으로 사용
      createdAt: json['created_at'] as String? ??
          'Unknown date', // 'created_at'이 null이면 'Unknown date'를 기본값으로 사용
      place: json['place'] as int? ?? 0, // 'place'가 null이면 0을 기본값으로 사용
      writer: json['writer'] as String? ??
          'Unknown writer', // 'writer'가 null이면 'Unknown writer'를 기본값으로 사용
    );
  }
}

// 마이 페이지 1
class MyPage extends StatefulWidget {
  String userName; // 이전 페이지에서 userName 받아와서 업로드
  MyPage(this.userName);

  @override
  MyPageState createState() => MyPageState();
}

// 마이 페이지 2
class MyPageState extends State<MyPage> {
  bool isFavoriteSelected = false;
  bool isPlanSelected = false;
  bool isReviewSelected = false;

  String userId = ""; // 사용자 ID 데이터
  String userName = ""; // 사용자 이름 정보
  final storage = FlutterSecureStorage(); // Local 내부 저장소 사용
  int viewMode = 1; // 찜목록 정렬 (1개씩, 2개씩, 3개씩)

  // User 정보
  List<FavoritePlace> userFavorite = []; // 1. 찜목록 정보
  List<Map<String, dynamic>> userPlans = []; // 2. 플랜 정보
  List<ReviewPlace> userReviews = []; // 3. 리뷰 정보
  Map<int, String> placeNamesCache = {}; // 3.1 placeId -> placeName

  // 튜토리얼
  late TutorialCoachMark tutorialCoachMark; // 생성
  GlobalKey keyButton1 = GlobalKey(); // 찜목록
  GlobalKey keyButton2 = GlobalKey(); // 플랜
  GlobalKey keyButton3 = GlobalKey(); // 리뷰

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Color.fromARGB(255, 72, 22, 78),
      textSkip: "SKIP",
      paddingFocus: 2,
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
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton1,
        shape: ShapeLightFocus.Circle,
        radius: 20, // 강조되는 원의 크기 조절
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
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
                      "찜목록",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "'찜목록'을 통해 원하는 장소를 한눈에 볼 수 있습니다!\n\n1. 원하는 장소 검색\n\n2. 장소에서 찜하기(하트) 누르기",
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
    // 플랜
    targets.add(
      TargetFocus(
        identify: "Target 2",
        keyTarget: keyButton2,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
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
                      "플랜 목록",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "'플랜'을 통해 계획표를 한눈에 볼 수 있습니다!\n\n1. 챗봇을 통해 생성\n\n2. 직접 플랜 만들고 장소 넣기\n\n3. 플랜 또는 장소를 꾹~ 누르면 삭제할 수 있어요!",
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
    // 리뷰
    targets.add(
      TargetFocus(
        identify: "Target 3",
        keyTarget: keyButton3,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
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
                      "리뷰 목록",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "'리뷰'를 통해 내가 작성한 리뷰를 한눈에 볼 수 있습니다!\n\n1. 리뷰 작성\n\n2. 리뷰 전체 보기",
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

    return targets;
  }

  @override
  void initState() {
    super.initState();

    userName = widget.userName;
    _loadUserId(); // 유저 모델 데이터 가져오기
  }

  // API 1. 사용자 찜목록 보기
  Future<List<FavoritePlace>> fetchUserLikePlace() async {
    List<FavoritePlace> favorites = [];
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    final url =
        Uri.parse('http://43.203.61.149/user/like/$userId'); // API 엔드포인트
    final response = await http.get(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "Content-Type": "application/json"
      },
    );

    // API 정상 응답
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 인코딩 명시
      // 1. 찜목록 데이터 있을 때
      if (data != null && data.isNotEmpty) {
        favorites = data
            .map<FavoritePlace>((item) => FavoritePlace.fromJson(item))
            .toList();
        //print(data);
        //print("찜목록 데이터 불러오기 성공");
      }
      // 2. 찜목록 데이터 없을 때
      else {
        return [];
      }
    } else {
      // API 호출 실패
      //print("API 호출 실패: ${response.statusCode}");
      return [];
    }
    return favorites; // FavoritePlace 리스트 반환
  }

  // API 2. User 모델 데이터 가져오기 API
  void _loadUserId() async {
    String? storedUserId = await storage.read(key: 'login_id');
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      // 1. 찜목록 데이터 가져오기
      fetchUserLikePlace().then((fetchFavorite) {
        setState(() {
          userFavorite = fetchFavorite;
        });
      }).catchError((error) {
        //print(error);
      });

      // 2. 플랜 데이터 가져오기
      fetchPlansForUser().then((plans) {
        setState(() {
          userPlans = plans;
        });
      }).catchError((error) {
        //print(error);
      });

      // 3. 리뷰 데이터 가져오기
      fetchUserReviewPlace().then((reviews) {
        setState(() {
          userReviews = reviews;
        });
      }).catchError((error) {
        //print(error);
      });
    }
  }

  // API 3. 플랜 정보 가져오기 API
  Future<List<Map<String, dynamic>>> fetchPlansForUser() async {
    final response =
        await http.get(Uri.parse('http://43.203.61.149/plan/plan/'));

    // 호출 성공 시
    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print("Response Data: $responseData");

      if (responseData is List<dynamic>) {
        List<Map<String, dynamic>> tempUserPlans = [];
        for (var plan in responseData) {
          if (plan['user'].toString() == userId) {
            print("Matching Plan ID: ${plan['id']}");
            tempUserPlans.add(plan);
          }
        }
        return tempUserPlans;
      } else {
        throw Exception('The expected structure of the response is not found.');
      }
    } else {
      throw Exception('Failed to load plans');
    }
  }

  // API 4. 사용자 리뷰 목록 보기
  Future<List<ReviewPlace>> fetchUserReviewPlace() async {
    List<ReviewPlace> reviews = [];
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    final url = Uri.parse(
        'http://43.203.61.149/user/list/$userId/reviews'); // API 엔드포인트
    final response = await http.get(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "Content-Type": "application/json"
      },
    );

    // API 정상 응답
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 인코딩 명시

      // 1. 찜목록 데이터 있을 때
      if (data != null && data.isNotEmpty) {
        reviews = data
            .map<ReviewPlace>((item) => ReviewPlace.fromJson(item))
            .toList();
        //print(data);
        //print("찜목록 데이터 불러오기 성공");
      } else {
        // 2. 찜목록 데이터 없을 때
        return [];
      }
    } else {
      // API 호출 실패
      //print("API 호출 실패: ${response.statusCode}");
      return [];
    }
    return reviews; // FavoritePlace 리스트 반환
  }

  // API 5. placeId -> placeName
  Future<String> fetchPlaceName(int placeId) async {
    if (placeNamesCache.containsKey(placeId)) {
      return placeNamesCache[placeId]!;
    }

    // 실제 API 호출
    final response = await http
        .get(Uri.parse('http://43.203.61.149/place/place/${placeId}'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final placeName = jsonResponse['name'];
      placeNamesCache[placeId] = placeName;
      return placeName;
    } else {
      throw Exception('Failed to load place name');
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      isFavoriteSelected = index == 1;
      isPlanSelected = index == 2;
      isReviewSelected = index == 3;
    });
  }

  // 버튼
  ButtonStyle _buttonStyle(bool isSelected) {
    return ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.blue : null,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // 버튼
  Widget _buttonChild(String text, bool isSelected) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  // backgroundImage: AssetImage("assets/profile_image.png"),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2. 사용자 이름 설정
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              readOnly: true,
              initialValue: userName ?? "사용자 이름", // 전역 변수 사용
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                key: keyButton1,
                child: ElevatedButton(
                  onPressed: () => _toggleSelection(1),
                  style: _buttonStyle(isFavoriteSelected),
                  child: _buttonChild("찜목록", isFavoriteSelected),
                ),
              ),
              Expanded(
                key: keyButton2,
                child: ElevatedButton(
                  onPressed: () => _toggleSelection(2),
                  style: _buttonStyle(isPlanSelected),
                  child: _buttonChild("플랜", isPlanSelected),
                ),
              ),
              Expanded(
                key: keyButton3,
                child: ElevatedButton(
                  onPressed: () => _toggleSelection(3),
                  style: _buttonStyle(isReviewSelected),
                  child: _buttonChild("리뷰", isReviewSelected),
                ),
              ),
            ],
          ),
          Expanded(
            child: _buildSelectedInfo(),
          ),
        ],
      ),
    );
  }

  // 플랜 삭제 AIP
  Future<void> deletePlan(int planId) async {
    final response = await http.delete(
      Uri.parse('http://43.203.61.149/plan/plan/$planId/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      // 성공적으로 삭제됨
      print('Plan deleted successfully.');
    } else {
      // 삭제 실패
      print('Failed to delete plan. Error: ${response.body}');
      print(planId);
    }
  }

  // 데이터 정보 불러오기
  Widget _buildSelectedInfo() {
    if (isFavoriteSelected) {
      return _buildFavoriteList();
    } else if (isPlanSelected) {
      return _buildPlanList();
    } else if (isReviewSelected) {
      return _buildReviewList();
    } else {
      return SizedBox();
    }
  }

  // 찜목록 - 정렬 아이콘
  Icon get viewModeIcon {
    if (viewMode == 1) {
      return Icon(Icons.filter_1); // Icon for 2 items per row
    } else if (viewMode == 2) {
      return Icon(Icons.filter_2); // Icon for 1 item per row
    } else {
      return Icon(Icons.filter_3); // Icon for 3 items per row
    }
  }

  // 찜목록 - 정렬 아이콘 순환
  void cycleViewMode() {
    setState(() {
      viewMode = viewMode % 3 + 1;
    });
  }

  // 찜목록 - 정렬 버튼
  Widget _buildViewModeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.view_comfy),
          onPressed: () {
            setState(() {
              viewMode = 3;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.view_day),
          onPressed: () {
            setState(() {
              viewMode = 2;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.view_list),
          onPressed: () {
            setState(() {
              viewMode = 1;
            });
          },
        ),
      ],
    );
  }

  // 리스트 1 : 찜목록 UI
  Widget _buildFavoriteList() {
    // 정렬 순환 버튼 (1개씩, 2개씩, 3개씩 보여주기)
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: viewModeIcon,
              onPressed: cycleViewMode,
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<FavoritePlace>>(
            future: fetchUserLikePlace(), // 데이터를 불러오는 Future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text(
                    "Error: ${snapshot.error?.toString() ?? 'Unknown error'}");
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: viewMode, // 열의 수는 viewMode 상태에 따라 결정
                    childAspectRatio: viewMode == 1
                        ? 2 / 1.5
                        : (viewMode == 2 ? 1 / 1.2 : 1 / 1.3),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var favorite = snapshot.data![index];
                    return GestureDetector(
                      onTap: () async {
                        print("찜목록 클릭");
                        try {
                          final response = await http.post(
                            Uri.parse('http://43.203.61.149/place/find/'),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({"name": favorite.name}),
                          );

                          if (response.statusCode == 200) {
                            var data =
                                jsonDecode(utf8.decode(response.bodyBytes));
                            print("data = ");
                            print(data);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SearchPage2(placeData: data),
                              ),
                            );
                          } else {
                            //print
                            ('Failed to fetch place data: ${response.statusCode}');
                          }
                        } catch (error) {
                          //print('Error: $error');
                        }
                      },
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15.0), // 카드 모서리를 둥글게 만듭니다.
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                      15.0)), // 이미지 위쪽 모서리를 둥글게 만듭니다.
                              child: Image.network(
                                favorite.imageUrl.isEmpty
                                    ? "https://via.placeholder.com/150"
                                    : favorite.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: viewMode == 1
                                    ? 150
                                    : (viewMode == 2
                                        ? 120
                                        : 80), // 이미지 높이를 viewMode에 따라 조정
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    favorite.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: viewMode == 1
                                            ? 18
                                            : (viewMode == 2 ? 14 : 10)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  // if (viewMode == 1 || viewMode == 2)
                                  Text(
                                    favorite
                                        .classification, // classification 추가
                                    style: TextStyle(
                                      fontSize: viewMode == 1
                                          ? 15
                                          : (viewMode == 2 ? 12 : 10),
                                      color: Colors.grey[500],
                                    ),

                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (viewMode == 1) // 1줄에 1개씩 보여질 때만 주소 보이도록
                                    Text(
                                      favorite.streetNameAddress,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "찜목록이 없습니다.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 50), // 원하는 만큼의 여백 추가
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // 리스트 2 : 플랜
  Widget _buildPlanList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: userPlans.length,
            itemBuilder: (context, index) {
              // 일정 시작일을 표시하기 위한 로직
              String formattedDate = "미정";
              if (userPlans[index]['schedule'].isNotEmpty) {
                DateTime startDate = DateTime.parse(
                    userPlans[index]['schedule'][0]['start_date']);
                formattedDate = DateFormat('yy.MM.dd').format(startDate);
              }

              var plan = userPlans[index]; // index에 해당하는 item 가져오기
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading:
                      Icon(Icons.map, color: Theme.of(context).primaryColor),
                  title: Text(plan['name'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("여행 시작일 : $formattedDate"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlanDetailsPage(schedule: plan['schedule']),
                      ),
                    );
                  },
                  onLongPress: () {
                    print('Plan ID: ${plan['id']}'); // Plan ID 출력
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('플랜 삭제'),
                          content: Text('이 플랜을 삭제하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('삭제'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await deletePlan(plan['id']);
                                fetchPlansForUser().then((plans) {
                                  setState(() {
                                    userPlans = plans;
                                  });
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: _showAddPlanDialog,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0), // 버튼 크기 조절
                    textStyle: TextStyle(fontSize: 15.0), // 텍스트 크기 조절
                  ),
                  child: Text('새 플랜 작성'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: showTutorial,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                  ),
                  child: Text('Help'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 리스트 3 : 리뷰
  Widget _buildReviewList() {
    return FutureBuilder<List<ReviewPlace>>(
      future: fetchUserReviewPlace(), // 데이터를 불러오는 Future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
              "Error: ${snapshot.error?.toString() ?? 'Unknown error'}");
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '내가 쓴 총 리뷰 ${snapshot.data!.length}개',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var review = snapshot.data![index];
                    return FutureBuilder<String>(
                      future: fetchPlaceName(review.place),
                      builder: (context, placeSnapshot) {
                        if (placeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else if (placeSnapshot.hasError) {
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Error loading place name"),
                            ),
                          );
                        } else {
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      print("리뷰 클릭");
                                      try {
                                        final response = await http.post(
                                          Uri.parse(
                                              'http://43.203.61.149/place/find/'),
                                          headers: {
                                            "Content-Type": "application/json"
                                          },
                                          body: jsonEncode(
                                              {"name": placeSnapshot.data}),
                                        );

                                        if (response.statusCode == 200) {
                                          var data = jsonDecode(
                                              utf8.decode(response.bodyBytes));
                                          print("data = ");
                                          print(data);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPage2(placeData: data),
                                            ),
                                          );
                                        } else {
                                          //print
                                          ('Failed to fetch place data: ${response.statusCode}');
                                        }
                                      } catch (error) {
                                        //print('Error: $error');
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          placeSnapshot.data!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildStarRating(review.score),
                                      SizedBox(width: 8),
                                      Text(
                                        _formatDate(review.createdAt),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    review.content,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: Text(
              "리뷰가 없습니다.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }
      },
    );
  }

  Widget _buildStarRating(int score) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < score ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.year}/${parsedDate.month}/${parsedDate.day}';
  }

  // 다이얼로그 표시 및 새 플랜 이름 입력 처리
  void _showAddPlanDialog() {
    TextEditingController _planNameController = TextEditingController();

    // 이후에 UI 수정
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
          title: Text(
            "새 플랜 이름 입력",
            textAlign: TextAlign.center,
            style: GoogleFonts.oleoScript(
              // Google Fonts 폰트 스타일 사용
              color: Colors.black,
              fontSize: 20.0, // 폰트 크기를 20.0으로 설정
            ),
          ),
          // TextField 꾸미기
          content: TextField(
            textAlign: TextAlign.center,
            style: GoogleFonts.oleoScript(
              // Google Fonts 폰트 스타일 사용
              color: Colors.black,
              fontSize: 16.0, // 폰트 크기를 20.0으로 설정
            ),
            controller: _planNameController,
            decoration: InputDecoration(
              hintText: "플랜 이름을 입력하세요",
            ),
          ),
          // 취소 / 확인 버튼 UI
          actionsAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양 끝으로 정렬
          // buttonPadding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          actions: <Widget>[
            // 1. 취소 버튼
            TextButton(
              child: Text(
                '취소',
                style: GoogleFonts.oleoScript(
                  color: Color.fromARGB(255, 124, 119, 119), // 폰트 색상을 흰색으로 설정
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 219, 217, 217),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // 2. 저장 버튼
            TextButton(
              child: Text(
                '저장',
                style: GoogleFonts.oleoScript(
                  color: Colors.white, // 폰트 색상을 흰색으로 설정
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                _createPlan(_planNameController.text).then((_) {
                  Navigator.of(context).pop();
                  // 플랜 목록 갱신
                  fetchPlansForUser().then((plans) {
                    setState(() {
                      userPlans = plans;
                    });
                    //print("플랜 생성 성공");
                  }).catchError((error) {
                    //print(error);
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  // API 호출하여 서버에 새 플랜 데이터 전송
  Future<void> _createPlan(String planName) async {
    final response = await http.post(
      Uri.parse('http://43.203.61.149/plan/plan/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": planName,
        "user": userId,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 데이터가 생성되면 UI 업데이트 또는 알림
      //print('Plan created successfully.');
    } else {
      // 실패 처리
      //print('Failed to create plan. Error: ${response.body}');
    }
  }
}
