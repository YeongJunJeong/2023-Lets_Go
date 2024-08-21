import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 별점 선택
import 'package:intl/intl.dart'; // YY/MM/DD

class KakaoShareManager {
  // 5-1. 카카오톡 설치 여부 확인
  Future<bool> isKakaotalkInstalled() async {
    bool isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();
    return isKakaoTalkSharingAvailable;
  }

  // 5-2. 카카오톡 링크 공유
  void shareMyCode(
      String placeName, String placeDescription, String imageUrl) async {
    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();

    // 카카오톡 공유하기 템플릿 생성
    var template = FeedTemplate(
      content: Content(
        title: placeName,
        description: placeDescription,
        imageUrl: Uri.parse(imageUrl),
        link: Link(
          webUrl: Uri.parse('https://developers.kakao.com'),
          mobileWebUrl: Uri.parse('https://developers.kakao.com'),
        ),
      ),
    );

    // 설치 여부에 따른 로직 분기
    if (isKakaoTalkSharingAvailable) {
      // 카카오톡 O
      Uri uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡 공유 완료');
    } else {
      // 카카오톡 X
      Uri shareUrl =
          await WebSharerClient.instance.makeDefaultUrl(template: template);
      await launchBrowserTab(shareUrl, popupOpen: true);
    }
  }
}

class SearchPage2 extends StatefulWidget {
  final Map<String, dynamic> placeData;

  SearchPage2({required this.placeData});

  @override
  _SearchPage2State createState() => _SearchPage2State();
}

class _SearchPage2State extends State<SearchPage2> {
  final storage = FlutterSecureStorage();
  bool isFavorited = false; // 찜하기 상태를 초기화 (기본값은 false)
  KakaoShareManager kakaoShareManager = KakaoShareManager();

  @override
  void initState() {
    super.initState();
    // 좋아요 상태 업데이트
    updateFavoriteStatus();
  }

  void updateFavoriteStatus() async {
    bool favorited =
        await fetchUserLikePlace(widget.placeData['places_by_name'][0]['name']);
    setState(() {
      isFavorited = favorited;
    });
  }

  // API 1. 사용자의 찜하기 API
  Future<void> fetchLikePlace(context, String placeName) async {
    String? userId = await storage.read(key: "login_id");
    String? userAccessToken = await storage.read(key: "login_access_token");

    final url = Uri.parse('http://43.203.61.149/user/likeplace/'); // API 엔드포인트
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
      body: jsonEncode({'like': userId, 'name': placeName}),
    );

    if (response.statusCode == 202) {
      isFavorited = true;
      print("좋아요 버튼 누르기 성공");
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

    final url = Uri.parse(
        'http://43.203.61.149/user/${userId}/delLike/${placeId}'); // API 엔드포인트
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $userAccessToken',
        "content-type": "application/json"
      },
      body: jsonEncode({'userId': userId, 'placeId': placeId}),
    );

    if (response.statusCode == 204) {
      print("찜목록 삭제");
      isFavorited = false;
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

  @override
  Widget build(BuildContext context) {
    var placeDetails = widget.placeData['places_by_name'][0];

    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails['name'], style: GoogleFonts.oleoScript()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  'http://43.203.61.149${placeDetails['image']}', // 사진 주소
                  width: double.infinity,
                  height: 200,
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
                      fetchDislikePlace(context, placeDetails['name']);
                    } else {
                      fetchDislikePlace(context, placeDetails['id']);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isFavorited ? Colors.red : null,
                      ),
                      SizedBox(height: 4),
                      Text('찜하기', style: GoogleFonts.oleoScript(fontSize: 12))
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    kakaoShareManager.shareMyCode(
                      placeDetails['name'],
                      placeDetails['info'],
                      'http://43.203.61.149${placeDetails['image']}',
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.share, size: 24),
                      SizedBox(height: 4),
                      Text('공유', style: GoogleFonts.oleoScript(fontSize: 12))
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // 실선 표시
            Divider(thickness: 1),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '분류',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  placeDetails['classification'],
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주차 여부',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  placeDetails['parking'] ? '가능' : '불가능',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '평균 체류 시간',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  placeDetails['time'],
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자세한 정보',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  placeDetails['info'],
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전화번호',
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  placeDetails['call'],
                  style: GoogleFonts.oleoScript(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('태그',
                style: GoogleFonts.oleoScript(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: placeDetails['tag']
                  .map<Widget>((tag) => Chip(
                        label: Text(tag['name'],
                            style: GoogleFonts.oleoScript(color: Colors.white)),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            // 네이버 지도 추가
            Container(
              height: 200,
              child: NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(
                        placeDetails['latitude'], placeDetails['hardness']),
                    zoom: 17,
                  ),
                ),
                onMapReady: (controller) {
                  final marker = NMarker(
                    id: "test",
                    position: NLatLng(
                        placeDetails['latitude'], placeDetails['hardness']),
                  );
                  controller.addOverlay(marker);
                },
              ),
            ),
            SizedBox(height: 20),
            // 리뷰 표시
            Divider(thickness: 1),
            SizedBox(height: 10),
            Text('리뷰',
                style: GoogleFonts.oleoScript(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            placeDetails['reviews'].isNotEmpty
                ? Column(
                    children: placeDetails['reviews']
                        .map<Widget>((review) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                    Text(
                                        '${review['writer']} | ${DateFormat('yyyy/MM/dd').format(DateTime.parse(review['created_at']))}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                    SizedBox(height: 10),
                                    Text(
                                      review['content'],
                                      style: TextStyle(
                                          fontSize: 16, fontFamily: 'Roboto'),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  )
                : Text('리뷰가 없습니다.',
                    style: GoogleFonts.oleoScript(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
