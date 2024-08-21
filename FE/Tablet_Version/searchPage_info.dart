import 'dart:ffi';

// 외부 import
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_test_ver/map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 별점 선택
import 'package:intl/intl.dart'; // YY/MM/DD

void main() {
  KakaoSdk.init(
    nativeAppKey: '21ec99e3bdf6dcb0e2d4e1eaba24cd9d',
    javaScriptAppKey: 'd33777b631cfbe4c9534dc2340196a1b',
  );
}

String formatTags(List<dynamic> tags) {
  return tags.map((tag) => tag['name']).join(' ');
}

class KakaoShareManager {
// 5-1. 카카오톡 설치 여부 확인
  Future<bool> isKakaotalkInstalled() async {
    bool isKakaoTalkSharingAvatilable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();
    return isKakaoTalkSharingAvatilable;
  }

  // 5-2. 카카오톡 링크 공유
  void shareMyCode(Map<String, dynamic> placeDetails) async {
    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();

    // 태그 리스트를 문자열로 변환
    String tags = formatTags(placeDetails['tag'] ?? []);

    // 카카오톡 공유하기 탬플릿 생성
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: placeDetails['classification'] ?? '분류 없음',
        description: tags.isNotEmpty ? tags : '태그 없음',
        imageUrl: Uri.parse('http://43.203.61.149${placeDetails['image']}' ??
            'https://example.com/default.png'),
        link: Link(
            webUrl: Uri.parse('https://developers.kakao.com'),
            mobileWebUrl: Uri.parse('https://developers.kakao.com')),
      ),
      itemContent: ItemContent(
        profileText: placeDetails['name'] ?? '이름 없음',
        profileImageUrl: Uri.parse(
            'http://43.203.61.149${placeDetails['image']}' ??
                'https://example.com/default.png'),
        titleImageUrl: Uri.parse(
            'http://43.203.61.149${placeDetails['image']}' ??
                'https://example.com/default.png'),
        titleImageText: placeDetails['info'] ?? '분류 없음',
        titleImageCategory: placeDetails['call'] ?? '분류 없음',
      ),
      // social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
      buttons: [
        Button(
          title: '웹으로 보기',
          link: Link(
            webUrl: Uri.parse('https: //developers.kakao.com'),
            mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
          ),
        ),
        Button(
          title: '앱으로보기',
          link: Link(
            androidExecutionParams: {'key1': 'value1', 'key2': 'value2'},
            iosExecutionParams: {'key1': 'value1', 'key2': 'value2'},
          ),
        ),
      ],
    );

    // 설치 여부에 따른 로직 분기
    if (isKakaoTalkSharingAvailable) {
      // 카카오톡 O
      Uri uri = await ShareClient.instance.shareDefault(template: defaultFeed);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡 공유 완료');
    } else {
      // 카카오톡 X
      Uri shareUrl =
          await WebSharerClient.instance.makeDefaultUrl(template: defaultFeed);
      await launchBrowserTab(shareUrl, popupOpen: true);
    }
  }
}

class PlaceDetailPage extends StatefulWidget {
  final Map<String, dynamic> placeDetails;
  PlaceDetailPage({Key? key, required this.placeDetails}) : super(key: key);
  @override
  PlaceDetailPageState createState() => PlaceDetailPageState();
}

class PlaceDetailPageState extends State<PlaceDetailPage> {
  String? userId_global = ""; // 사용자 ID 데이터
  KakaoShareManager kakaoShareManager = KakaoShareManager();
  final storage = FlutterSecureStorage();
  bool isFavorited = false; // 찜하기 상태를 초기화 (기본값은 false)
  Future<Map<String, dynamic>>? reviewData; // nullable 타입으로 선언
  List<Map<String, dynamic>> userPlans = []; // 2. 플랜 정보

  // 처음 한 번
  void initState() {
    super.initState();
    // 좋아요 상태 업데이트
    updateFavoriteStatus();
    reviewData = fetchReviewData(widget.placeDetails['id']); // 리뷰 데이터 불러오기
  }

  void updateFavoriteStatus() async {
    userId_global = await storage.read(key: "login_id"); // 불러오기
    bool favorited = await fetchUserLikePlace(widget.placeDetails['name']);
    setState(() {
      isFavorited = favorited;
    });
    // 2. 플랜 데이터 가져오기
    fetchPlansForUser().then((plans) {
      setState(() {
        userPlans = plans;
      });
    }).catchError((error) {
      print(error);
    });
  }

  // API 1. 사용자의 찜하기 API
  Future<void> fetchLikePlace(context, String placeName) async {
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    // print("userId : " + (userId ?? "Unknown"));
    // print("Token : " + (userAccessToken ?? "Unknown"));

    final url = Uri.parse('http://43.203.61.149/user/likeplace/'); // API 엔드포인트
    final response = await http.post(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
      body: jsonEncode({'like': userId, 'name': placeName}),
    );

    if (response.statusCode == 202) {
      setState(() {
        isFavorited = true;
      });
      print("좋아요 버튼 누르기 성공");
      print(isFavorited);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("찜하기 성공", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("찜하기 실패: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("서버가 불안정합니다. 다시 시도해주세요.", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // API 1.2 사용자의 찜하기 해제 API
  Future<void> fetchDislikePlace(context, int placeId) async {
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    // print("userId : " + (userId ?? "Unknown"));
    // print("Token : " + (userAccessToken ?? "Unknown"));

    final url = Uri.parse(
        'http://43.203.61.149/user/${userId}/delLike/${placeId}'); // API 엔드포인트
    final response = await http.delete(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
      body: jsonEncode({'userId': userId, 'placeId': placeId}),
    );

    // print(placeId);
    if (response.statusCode == 204) {
      print("찜목록 삭제");
      setState(() {
        isFavorited = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("찜하기 취소", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 76, 83, 175),
        ),
      );
    } else {
      print("찜하기 취소 실패: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("서버가 불안정합니다. 다시 시도해주세요.", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // API 1.3 사용자 찜목록 보기
  Future<bool> fetchUserLikePlace(String placeName) async {
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    final url =
        Uri.parse('http://43.203.61.149/user/like/${userId}'); // API 엔드포인트
    final response = await http.get(
      url,
      // 헤더에 Authorization 추가해서 access Token값 넣기
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      var decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedData); // 응답 데이터를 리스트로 디코딩
      if (data.isNotEmpty) {
        for (var item in data) {
          if (item['name'] == placeName) {
            return true; // 일치하는 항목이 있으면 true 반환
          }
        }
      } else {
        print('데이터가 없습니다.');
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
    return false; // 일치하는 항목이 없거나 배열이 비어있으면
  }

  // API 2. 사용자의 플랜 목록을 가져오는 API 함수
  Future<List<Map<String, dynamic>>> fetchPlansForUser() async {
    String? userId = await storage.read(key: "login_id");

    final response = await http.get(
      Uri.parse('http://43.203.61.149/plan/plan/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      print("responseData : " + responseData.toString());

      List<Map<String, dynamic>> userPlans = [];
      for (var plan in responseData) {
        if (plan['user'].toString() == userId) {
          userPlans.add(plan);
        }
      }
      return userPlans;
    } else {
      throw Exception('Failed to load plans');
    }
  }

  // API 3. 플랜에 장소 추가 API 함수
  Future<void> addToPlan(context, String planId, String placeId) async {
    DateTime now = DateTime.now().toUtc(); // 현재 UTC 시간
    String formattedDate = now.toIso8601String(); // 현재 시간을 ISO 8601 포맷으로 변환

    final response = await http.post(
      Uri.parse('http://43.203.61.149/plan/schedule/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'start_date': "2024-05-13T07:04:12.958Z", // 현재 시간을 시작 날짜로 설정
        'end_date': "2024-05-13T07:04:12.958Z", // 현재 시간을 종료 날짜로 설정
        'place': placeId,
        'plan': planId,
      }),
    );

    print("addToPlan() 호출");
    print(response.statusCode);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("플랜 추가하기 성공", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      print("장소 추가 성공");
    } else {
      print("장소 추가 실패: ${response.body}");
    }
  }

  // API 4. 리뷰 작성
  Future<void> fetchReview(
      context, String content, int score, int place) async {
    String? userId = await storage.read(key: "login_id");

    final response = await http.post(
      Uri.parse('http://43.203.61.149/place/review/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'content': content, // 리뷰 내용
        'score': score, // 리뷰 점수
        'place': place, // 장소
        'writer': userId,
      }),
    );

    if (response.statusCode == 201) {
      print("리뷰 작성 성공");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("리뷰 작성하기 성공", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 76, 83, 175),
        ),
      );
      fetchReviewData(place);

      print("리뷰 작성 이후 성공");
    } else {
      print("리뷰 작성 실패: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("서버가 불안정합니다. 다시 시도해주세요.", style: GoogleFonts.oleoScript()),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // API 5. 링크 공유
  // -> class KakaoShareManager 사용

  // API 6. 리뷰 데이터 가져오기
  Future<Map<String, dynamic>> fetchReviewData(int placeId) async {
    String? userAccessToken = await storage.read(key: "login_access_token");

    final url = Uri.parse('http://43.203.61.149/place/review/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
    );

    // print("리뷰 데이터 가져오기 실행중");
    if (response.statusCode == 200) {
      var decodedResponse = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedResponse);

      // placeId의 리뷰만을 찾기
      List<dynamic> relevantReviews =
          data.where((review) => review['place'] == placeId).toList();

      print("리뷰 데이터 불러오기 성공");
      print(relevantReviews);

      return {
        'count': relevantReviews.length,
        'reviews': relevantReviews,
      };
    } else {
      throw Exception("리뷰 데이터 불러오기 실패: ${response.statusCode}");
    }
  }

  // API 7. 새 플랜 작성하기
  Future<void> _showAddPlanDialog() async {
    TextEditingController _planNameController = TextEditingController();

    // 이후에 UI 수정
    return showDialog<void>(
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
                    print("플랜 생성 성공");
                  }).catchError((error) {
                    print(error);
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
        "user": userId_global,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 데이터가 생성되면 UI 업데이트 또는 알림
      print('Plan created successfully.');
    } else {
      // 실패 처리
      print('Failed to create plan. Error: ${response.body}');
    }
  }

  String formatDateTime(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('yyyy/MM/dd').format(parsedDate); // "연도/월/일" 형식
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tagWidgets = widget.placeDetails['tag']
        .map<Widget>((tag) => Chip(
              label: Text(
                tag['name'],
                style: GoogleFonts.oleoScript(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ))
        .toList();

    var imageUrl = widget.placeDetails['image'] != null
        ? 'http://43.203.61.149${widget.placeDetails['image']}' // 사진 주소
        : 'https://via.placeholder.com/80';

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.placeDetails['name'], style: GoogleFonts.oleoScript()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: reviewData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              var reviews = snapshot.data!['reviews'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 500,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (isFavorited) {
                            fetchDislikePlace(
                                context, widget.placeDetails['id']);
                          } else {
                            fetchLikePlace(
                                context, widget.placeDetails['name']);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 24,
                              color: isFavorited ? Colors.red : null,
                            ),
                            SizedBox(height: 4),
                            Text('찜하기',
                                style: GoogleFonts.oleoScript(fontSize: 12))
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          try {
                            List<Map<String, dynamic>> plans =
                                await fetchPlansForUser();
                            String selectedPlanId = await _showPlanSelector(
                                context, plans); // 사용자가 플랜을 선택하게 하는 UI
                            if (selectedPlanId.isNotEmpty) {
                              String placeId =
                                  widget.placeDetails['id'].toString();
                              await addToPlan(context, selectedPlanId, placeId);
                            }
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add_circle_outline, size: 24),
                            SizedBox(height: 4),
                            Text('플랜 추가',
                                style: GoogleFonts.oleoScript(fontSize: 12))
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          print('리뷰 작성 버튼 클릭');
                          try {
                            await showReviewDialog(
                                context,
                                widget
                                    .placeDetails['id']); // 사용자가 플랜을 선택하게 하는 UI
                            // 리뷰 데이터 전송
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.edit, size: 24),
                            SizedBox(height: 4),
                            Text('리뷰 작성',
                                style: GoogleFonts.oleoScript(fontSize: 12))
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('공유 버튼 클릭');
                          kakaoShareManager.shareMyCode(widget.placeDetails);
                          // API 추가 (2) :  ??? / ???
                          // 공유하기 기능 수행
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.share, size: 24),
                            SizedBox(height: 4),
                            Text('공유',
                                style: GoogleFonts.oleoScript(fontSize: 12))
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // 실선 표시
                  Divider(thickness: 1),
                  SizedBox(height: 20),
                  // 1. 분류
                  _buildDetailItem('분류', widget.placeDetails['classification']),
                  SizedBox(height: 40),
                  // 2. 주차 여부
                  _buildDetailItem(
                      '주차 여부', widget.placeDetails['parking'] ? '가능' : '불가능'),
                  SizedBox(height: 40),
                  // 3. 평균 체류 시간
                  _buildDetailItem('평균 체류 시간', widget.placeDetails['time']),
                  SizedBox(height: 40),
                  // 4. 자세한 정보
                  _buildDetailItem('자세한 정보', widget.placeDetails['info']),
                  SizedBox(height: 40),
                  // 5. 전화번호
                  _buildDetailItem('전화번호', widget.placeDetails['call']),
                  SizedBox(height: 40),
                  // 6. 태그 정보
                  Text(
                    '태그',
                    style: GoogleFonts.oleoScript(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: tagWidgets,
                  ),
                  SizedBox(height: 40),
                  // 7. 네이버 지도 추가
                  Text(
                    '지도',
                    style: GoogleFonts.oleoScript(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 500,
                    // 네이버 지도
                    child: NaverMap(
                      // 옵션들
                      options: NaverMapViewOptions(
                        // 1) 처음 시작 위치
                        initialCameraPosition: NCameraPosition(
                          target: NLatLng(widget.placeDetails['latitude'],
                              widget.placeDetails['hardness']),
                          zoom: 17,
                        ),
                        locationButtonEnable: true, // 옵션 2. 현재 위치 버튼 표시 여부 설정
                        scaleBarEnable: true, // 옵션 3. 축적 바 (활성화)
                      ),
                      // 2) 지도 준비될 때
                      onMapReady: (controller) {
                        final marker = NMarker(
                          id: "test",
                          position: NLatLng(widget.placeDetails['latitude'],
                              widget.placeDetails['hardness']),
                        );
                        controller.addOverlay(marker);
                      },
                      // 지도를 클릭했을 때
                      onMapTapped: (NPoint point, NLatLng latLng) {
                        print("지도 클릭");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapTest(
                                widget.placeDetails['latitude'],
                                widget.placeDetails['hardness']),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // 실선 표시
                  // 실선 표시
                  Divider(thickness: 1),
                  SizedBox(height: 10),
                  // 리뷰 UI 추가할 곳
                  Text(
                    // '전체 리뷰 개수 넣는 곳',
                    '전체 ${reviews.length} 리뷰',
                    style: GoogleFonts.oleoScript(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // 7. 리뷰 내용
                  Container(
                    height: 350, // 고정된 높이를 가진 컨테이너
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        var review = reviews[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. 점수 (리뷰 점수를 표시하는 로우)
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star,
                                      color: index < review['score']
                                          ? Colors.amber
                                          : Colors.grey,
                                      size: 20,
                                    );
                                  }),
                                ),
                                SizedBox(height: 8),
                                // 2. 리뷰 작성자와 날짜
                                Text(
                                  '${review['writer']} | ${formatDateTime(review['created_at'])}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                // 3. 리뷰 내용
                                Text(
                                  review['content'],
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: 'Roboto'),
                                  overflow:
                                      TextOverflow.ellipsis, // 너무 긴 텍스트 처리
                                  maxLines: 3, // 최대 줄 수 제한
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              GoogleFonts.oleoScript(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          content,
          style: GoogleFonts.oleoScript(fontSize: 16),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // 리뷰 팝업 UI
  Future<Map<String, dynamic>?> showReviewDialog(
      BuildContext context, int placeId) async {
    final TextEditingController _contentController = TextEditingController();
    double _currentRating = 0;
    bool _ratingSelected = false; // 별점이 한 번이라도 선택되었는지 추적

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(30),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('리뷰 작성', style: GoogleFonts.oleoScript(fontSize: 30)),
                SizedBox(height: 40),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    _currentRating = rating;
                    _ratingSelected = true; // 별점이 한 번이라도 선택되면 true로 설정
                  },
                ),
                SizedBox(height: 60),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: '리뷰 내용',
                    labelStyle: TextStyle(
                      fontSize: 20.0, // 원하는 크기로 설정
                    ),
                    hintText: '리뷰 내용을 작성하세요',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: Text('취소', style: GoogleFonts.oleoScript()),
                      onPressed: () {
                        _contentController.dispose();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('작성 완료', style: GoogleFonts.oleoScript()),
                      onPressed: () async {
                        if (!_ratingSelected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("별점을 선택해주세요."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        if (_contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("리뷰 내용을 입력해주세요."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        // fetchReview
                        try {
                          await fetchReview(
                            context,
                            _contentController.text,
                            _currentRating.toInt(),
                            placeId,
                          );
                          print("리뷰 작성 나오기 성공");
                        } catch (e) {
                          // 리뷰 오류
                          print("리뷰 작성 중 오류 발생: ${e.toString()}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("리뷰 작성 중 오류가 발생했습니다."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; // 에러 발생시 더 이상 진행하지 않음
                        }
                        print("Navigator 실행 전");
                        // 리뷰 작성 성공 후에 데이터를 반환하고 UI를 닫음
                        Navigator.of(context).pop({
                          'score': _currentRating.toInt(),
                          'content': _contentController.text,
                        });
                        print("Navigator 실행 후");

                        print("dispose 실행 전");
                        // _contentController.dispose();
                        print("dispose 실행 후");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 플랜 선택 UI
  Future<String> _showPlanSelector(
      BuildContext context, List<Map<String, dynamic>> plans) async {
    if (plans.isEmpty) {
      // fontStyle: GoogleFonts.oleoScript(),
      // 계획이 없을 경우 사용자에게 알림
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
              '사용 가능한 플랜이 없습니다.',
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
                    '새로운 플랜 만들기',
                    style: GoogleFonts.oleoScript(
                      color: Colors.white, // 폰트 색상을 흰색으로 설정
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 151, 133, 182), // 버튼 배경 색상을 deepPurple로 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // 버튼 모서리 둥글게
                    ),
                  ),
                  onPressed: () async {
                    // 여기 문제
                    // 그렇다면, 바로 플랜 생성하는 API를 가져온다면?
                    await _showAddPlanDialog();
                    Navigator.of(context).pop();
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyPage(userId_global!)), // 다음 화면으로 이동
                    );
                    */
                  },
                ),
              ),
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
      return '';
    } else {
      final selectedPlanId = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              '플랜을 선택하세요',
              style: GoogleFonts.oleoScript(fontSize: 28.0), // 제목 크기 키우기
            ),
            children: [
              Divider(), // 구분선 추가
              ...plans.map((Map<String, dynamic> plan) {
                return SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(context, plan['id'].toString()),
                  child: Text(
                    plan['name'],
                    style:
                        GoogleFonts.oleoScript(fontSize: 18.0), // 자식 텍스트 크기 키우기
                  ),
                );
              }).toList(),
            ],
          );
        },
      );
      return selectedPlanId ?? ''; // Null일 경우 빈 문자열 반환
    }
  }
}
