import 'package:flutter/material.dart';
import 'package:go_test_ver/searchPage_info.dart';

// 1. 화원유원지 정보
Map<String, dynamic> place1 = {
  "id": 439, // 사용
  "name": "화원유원지", // 사용
  "image":
      "/media/image/%ED%99%94%EC%9B%90%EC%9C%A0%EC%9B%90%EC%A7%80.jpg", // 사용 X?
  "classification": "일반유원지/일반놀이공원", // 사용
  "parking": true, // 사용
  "info": "낙동강의 푸른 물과 백사장, 그리고 깎아지른 절벽 등이 조화를 이룬다.", // 사용
  "call": "053-659-4465", // 사용
  "hardness": 128.4804381,
  "latitude": 35.81207318,
  "tag": [
    // 사용
    {"name": "#벚꽃명소"},
    {"name": "#산책로"},
    {"name": "#아이와놀자"},
    {"name": "#유람선"},
    {"name": "#이동약자접근"},
    {"name": "#일출명소"},
    {"name": "#차박"},
    {"name": "#캠핑장"},
    {"name": "#포토존"},
    {"name": "#해바라기"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

// 2. 대구 근대화 골목 정보
Map<String, dynamic> place2 = {
  "id": 295, // 사용
  "name": "대구근대화골목", // 사용
  "image":
      "/media/image/%EB%8C%80%EA%B5%AC%EA%B7%BC%EB%8C%80%ED%99%94%EA%B3%A8%EB%AA%A9.jpg", // 사용 X?
  "classification": "유명관광지", // 사용
  "parking": true, // 사용
  "info": "유명관광지", // 사용
  "call": "-", // 사용
  "hardness": 128.590996,
  "latitude": 35.8654283,
  "tag": [
    // 사용
    {"name": "#산책로"},
  ],
  "time": "체류시간 2시간", // 사용
};

// 3. 김광석 다시 그리기 길 정보
Map<String, dynamic> place3 = {
  "id": 246, // 사용
  "name": "김광석다시그리기길", // 사용
  "image":
      "/media/image/%EA%B9%80%EA%B4%91%EC%84%9D%EB%8B%A4%EC%8B%9C%EA%B7%B8%EB%A6%AC%EA%B8%B0%EA%B8%B8.jpg", // 사용 X?
  "classification": "일반유원지/일반놀이공원", // 사용
  "parking": true, // 사용
  "info": "김광석의 삶과 음악을 테마로 조성한 벽화거리", // 사용
  "call": "-", // 사용
  "hardness": 128.6069438,
  "latitude": 35.86035154,
  "tag": [
    // 사용
    {"name": "#나들이"},
    {"name": "#산책로"},
    {"name": "#포토존"},
  ],
  "time": "체류시간 1시간 30분 ~ 2시간", // 사용
};

class AdvertisementPage_3 extends StatelessWidget {
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
                  image: AssetImage('assets/images/advertisement_3.png'),
                  fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 합니다.
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '최근 떠오르는 장소', // 상단 텍스트
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // 텍스트를 중앙 정렬
              ),
            ),
            SizedBox(height: 20),
            // 1. 화원유원지
            // 1.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 1. 화원유원지', // 세부 섹션 제목
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
                        'assets/images/advertisement_3.1.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 1.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '전망대와 산책로 그리고 작은 동물원이 있는 장소는 어떤가요?\n\n그렇다면, 화원유원지를 추천해드립니다!\n\n특히, 최초의 피아노와 관련되어 있어 피아노 조형물이 눈에 띄어요!',
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
                '화원유원지에서는 특별한 유람선을 탈 수 있는데요, 11시부터 한 시간 간격으로 정각마다 출발합니다!\n\n40분 동안의 특별한 경험으로 추억을 보내보세요!',
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
                child: Text('화원유원지 상세보기'),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            // 2. 대구 근대화 골목
            // 2.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 2. 대구 근대화 골목', // 세부 섹션 제목
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
                        'assets/images/advertisement_3.2.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 2.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '시대의 흔적이 남아있는 장소는 언제나 가슴을 뛰게합니다!\n\n대구 근대 골목은 오래된 근대식 건물과 옛 관청을 직접 볼 수 있습니다.\n\n이 안에서 과거의 향수를 느끼며, 돌아다녀보세요!',
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
                '국채보상운동의 거장 서상돈 고택과 시인 이상화 고택을 넘어 의학 박물관을 걷다 보면, 골목의 근대화 벽화를 볼 수 있어요!\n\n또한, 예쁜 가게와 시장도 있으니 시대를 즐겨보시는건 어때요?',
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
                child: Text('대구 근대화 골목 상세보기'),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            // 3. 김광석 다시 그리기 길
            // 3.1) 소제목
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Travel 3. 김광석 다시 그리기 길', // 세부 섹션 제목
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // 3.2) 이미지
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
                        'assets/images/advertisement_3.3.png'), // 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                  ),
                ),
              ),
            ),
            // 3.3) 내용 1
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '김광석님을 아시나요?\n\n대구에서 유명한 거리 중 하나로 명곡과 기타 조형물로 거리의 입구를 알려주고 있어요!\n\n아기자기한 물건을 파는 소품샵과 기타 키링 그리고 예쁜 벽화로 특별하게 꾸민 거리를 즐겨보세요~',
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
                '어린이와 청년 그리고 어르신들 모두 함께 즐길 수 있는 김광석 거리에서 추억을 공유하며 노래를 들어보는건 어떤가요?\n\n야외공연으로 거리를 음악으로 가득 채운 김광석 다시 그리기 길을 추천합니다!',
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
                child: Text('김광석 다시 그리기 길 상세보기'),
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
