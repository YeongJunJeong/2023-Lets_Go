import 'package:flutter/material.dart';
import 'package:go_test_ver/searchPage_info.dart';

// API 사용
// 각 장소 데이터 불러온 후 저장
// 1. 이월드
Map<String, dynamic> place1 = {
  "id": 358, // 사용
  "name": "이월드", // 사용
  "image": "/media/image/%EC%9D%B4%EC%9B%94%EB%93%9C.jpg", // 사용 X?
  "classification": "기타유원시설업", // 사용
  "parking": true, // 사용
  "info": "남녀노소 누구나 즐길 수 있는 놀이기구, 전시. 예술공간, 깔끔한 식당.", // 사용
  "call": "070-7549-8112", // 사용
  "hardness": 128.5658028,
  "latitude": 35.85347913,
  "tag": [
    // 사용
    {"name": "#눈썰매"},
    {"name": "#대구갈만한곳"},
    {"name": "#대구여행"},
    {"name": "#대구이월드"},
    {"name": "#벚꽃명소"},
    {"name": "#아이와놀자"},
    {"name": "#아이와함께"},
    {"name": "#제로페이"},
    {"name": "#카카오페이"},
    {"name": "#포토존"},
    {"name": "#핑크뮬리명소"},
  ],
  "time": "체류시간 2시간이상", // 사용
};

// 2. 송해 공원 둘레길
Map<String, dynamic> place2 = {
  "id": 250, // 사용
  "name": "송해공원 둘레길", // 사용
  "image":
      "/media/image/%EC%86%A1%ED%95%B4%EA%B3%B5%EC%9B%90_%EB%91%98%EB%A0%88%EA%B8%B8.jpg", // 사용 X?
  "classification": "관광지", // 사용
  "parking": true, // 사용
  "info": "관광지", // 사용
  "call": "-", // 사용
  "hardness": 128.4801515,
  "latitude": 35.7804052,
  "tag": [
    // 사용
    {"name": "#걷기좋은"},
    {"name": "#벚꽃명소"},
    {"name": "#포토존"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

// 3. 앞산 공원
Map<String, dynamic> place3 = {
  "id": 292, // 사용
  "name": "앞산공원", // 사용
  "image": "/media/image/%EC%95%9E%EC%82%B0%EA%B3%B5%EC%9B%90.jpg", // 사용 X?
  "classification": "관광지", // 사용
  "parking": true, // 사용
  "info": "도심에서 4.5㎞이내에 위치하여 시민들의 접근이 용이하고 자연경관이 수려하고 산림이 울창", // 사용
  "call": "053-625-0967", // 사용
  "hardness": 128.5891677,
  "latitude": 35.8287144,
  "tag": [
    // 사용
    {"name": "#걷기좋은"},
    {"name": "#나들이"},
    {"name": "#단풍명소"},
    {"name": "#산책로"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

class AdvertisementPage_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('여름철 시원하게 보내기'), // AppBar 제목 설정
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로가기 기능
        ),
      ),
      body: SingleChildScrollView(
        // 스크롤 가능한 뷰
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 350, // 높이
              width: double.infinity, // 옆으로 확장
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/advertisement_2.png'),
                  fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 합니다.
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '인기 관광지', // 상단 텍스트
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // 텍스트를 중앙 정렬
              ),
            ),
            SizedBox(height: 20),
            // 1. 시원한 계곡 : 동산계곡
            // 1.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 1. 이월드', // 세부 섹션 제목
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // 1.2) 이미지
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 180, // 높이 조정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                  color: Colors.white, // 배경색을 흰색으로 설정
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/advertisement_2.1.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 1.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '환상과 동심이 있는 놀이공원은 어떤가요?\n\n이월드에서는 매 계절마다 예쁜 꽃들로 꾸며놓아요! 일행과 함께 꽃과 폭포 그리고 포토존에서 좋은 추억을 남겨보아요!\n\n그리고 밤에는 아름다운 야경과 퍼레이드가 열리는 것으로 유명하답니다!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 1.4) 간격
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            ),
            // 1.5) 내용 2
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '혹시 놀이공원에서 열심히 놀다보면, 어느샌가 시간이 훌쩍 지나가고 배가 고프시지는 않나요?\n\n이월드에서는 카니발 푸드코트를 비롯해 다양한 간식과 음료를 판매하고 있어요!\n\n좋은 사람과 함께 이월드에서 예쁜 추억을 남겨보아요~',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 1.6) 장소 바로가기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 여기서 item은 현재 표시된 결과 목록에서 선택된 항목입니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaceDetailPage(placeDetails: place1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // 버튼의 텍스트 색상
                ),
                child: Text('이월드 상세보기'),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            // 2. 실내 데이트 : 스파밸리
            // 2.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 2. 송해 공원', // 세부 섹션 제목
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // 2.2) 이미지
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 180, // 높이 조정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                  color: Colors.white, // 배경색을 흰색으로 설정
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/advertisement_2.2.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 2.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '산과 호수 위에 있는 송해 공원을 소개합니다!\n\n도심에서 떨어져 있어 자연에 집중할 수 있으며, 넓은 주차장으로 차를 끌고 가기 좋아요!\n\n여름의 푸른 하늘과 나무들이 반사된 강과\n싱그러운 자연의 향기를 느껴보세요~',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 2.4) 간격
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            ),
            // 2.5) 내용 2
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '낮에는 가볍게 산책하거나 자전거를 타면서 여유를 즐겨보세요!\n\n산책길에 예쁜 포토존도 준비되어 있으니,\n사진도 많이 찍어보아요~\n\n특히, 밤에는 예쁜 조명이 켜진 호수 위를 걸어 다니면서 시원한 여름을 보내는건 어때요?\n호수에 비친 조명이 아름다워요!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 2.6) 장소 바로가기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 여기서 item은 현재 표시된 결과 목록에서 선택된 항목입니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaceDetailPage(placeDetails: place2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // 버튼의 텍스트 색상
                ),
                child: Text('송해 공원 상세보기'),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            // 3. 대구 수목원
            // 3.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 3. 앞산 공원', // 세부 섹션 제목
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // 3.2) 이미지
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 180, // 높이 조정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                  color: Colors.white, // 배경색을 흰색으로 설정
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/advertisement_2.3.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 3.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '가족과 함께 여유로운 시간을 보내시는걸 원하나요?\n\n그렇다면, 앞산 공원을 소개합니다!\n\n주변에 분위기 좋은 식당과 카페가 많은 앞산에서 자연과 함께 여유를 즐겨보아요!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 3.4) 간격
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                  Text('•', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            ),
            // 3.5) 내용 2
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '낮에는 앞산의 자연을 구경하면서 주변을 여유롭게 둘러보세요~\n\n그리고, 밤에는 케이블카로 대구 시내 전체를 한 번 구경해보세요! 새로운 느낌을 겪어보고 싶다면, 앞산 공원과 전망대를 추천합니다!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // 3.6) 장소 바로가기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 여기서 item은 현재 표시된 결과 목록에서 선택된 항목입니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaceDetailPage(placeDetails: place3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // 버튼의 텍스트 색상
                ),
                child: Text('앞산 공원 상세보기'),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            //SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
