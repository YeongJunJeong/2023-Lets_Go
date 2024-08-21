import 'package:flutter/material.dart';
import 'package:go_test_ver/searchPage_info.dart';

// 1. 동산계곡 정보
Map<String, dynamic> place1 = {
  "id": 157, // 사용
  "name": "동산계곡", // 사용
  "image": "/media/image/%EB%8F%99%EC%82%B0%EA%B3%84%EA%B3%A1.jpg", // 사용 X?
  "classification": "폭포/계곡", // 사용
  "parking": true, // 사용
  "info": "폭포/계곡", // 사용
  "call": "054-380-6544", // 사용
  "hardness": 128.6683791,
  "latitude": 36.0416996,
  "tag": [
    // 사용
    {"name": "#나들이"},
    {"name": "#물놀이"},
    {"name": "#차박"},
  ],
  "time": "체류시간 1시간", // 사용
};

// 2. 스파밸리 정보
Map<String, dynamic> place2 = {
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

// 3. 대구수목원 정보
Map<String, dynamic> place3 = {
  "id": 412, // 사용
  "name": "대구수목원", // 사용
  "image":
      "/media/image/%EB%8C%80%EA%B5%AC%EC%88%98%EB%AA%A9%EC%9B%90.jpg", // 사용 X?
  "classification": "휴양림/수목원", // 사용
  "parking": true, // 사용
  "info": "쓰레기 매립장을 생태적 식물공간으로 복원", // 사용
  "call": "053-803-7270", // 사용
  "hardness": 128.521057,
  "latitude": 35.8004111,
  "tag": [
    // 사용
    {"name": "#걷기좋은"},
    {"name": "#국화꽃"},
    {"name": "#나들이"},
    {"name": "#단풍명소"},
    {"name": "#맨발걷기"},
    {"name": "#산책로"},
    {"name": "#억새밭"},
    {"name": "#잔디마당"},
    {"name": "#포토존"},
  ],
  "time": "체류시간 2시간이상", // 사용
};

class AdvertisementPage_1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('여름철 시원하게 보내기'), // AppBar 제목 설정
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로가기 기능
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.white, // 여기서 배경색을 흰색으로 설정
          child: SingleChildScrollView(
            // 스크롤 가능한 뷰
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 600, // 높이
                  width: double.infinity, // 옆으로 확장
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/advertisement_1.png'),
                      fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 합니다.
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    ' " 여름철 시원하게 보내기 " ', // 상단 텍스트
                    style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                  ),
                ),
                SizedBox(height: 50),
                // 1. 시원한 계곡 : 동산계곡
                // 1.1) 소제목
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Travel TIP 1. 시원한 계곡', // 세부 섹션 제목
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                // 1.2) 이미지
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    height: 500, // 높이 조정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                      color: Colors.white, // 배경색을 흰색으로 설정
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/advertisement_1.1.png'), // 이미지 경로
                        fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                      ),
                    ),
                  ),
                ),
                // 1.3) 내용 1
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '올 여름휴가는 어디로 떠나시나요?\n\n휴가철이 다가오면서 어떻게 휴가를 보낼지 고민이시다면, 시원한 계곡은 어떠세요?\n\n가볼까의 첫 번째 추천은 계곡이에요!\n',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 1.4) 간격
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // 1.5) 내용 2
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '"팔공산 동산 계곡"은 대구 군위에 위치하고 있으며, 근처에 숙소와 펜션 그리고 캠핑장이 많아요!\n\n또한, 팔공산 계곡의 대표적인 장소로 대구와 가깝다는 장점도 있어요\n\n친한 지인들 또는 가족들과 함께 무더위를 시원하게 보내버리는건 어떤까요?',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 1.6) 장소 바로가기 버튼
                Padding(
                  padding: const EdgeInsets.all(30.0),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0), // 버튼의 높이 증가
                    ),
                    child: Text('동산 계곡 상세보기', style: TextStyle(fontSize: 22)),
                  ),
                ),
                SizedBox(height: 50),
                Divider(),
                SizedBox(height: 50),
                // 2. 실내 데이트 : 스파밸리
                // 2.1) 소제목
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Travel TIP 2. 실내 데이트', // 세부 섹션 제목
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                // 2.2) 이미지
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    height: 500, // 높이 조정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                      color: Colors.white, // 배경색을 흰색으로 설정
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/advertisement_1.2.png'), // 이미지 경로
                        fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                      ),
                    ),
                  ),
                ),
                // 2.3) 내용 1
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '다양한 슬라이드와 파도풀이 존재하는 워터파크는 어떤가요?\n\n어린이와 어른 모두 만족해하는 스파밸리!\n\n한 번 알아볼까요?\n',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 2.4) 간격
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // 2.5) 내용 2
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '"스파밸리"는 대구 달성군 가창면에 있어요!\n\n내부에는 다양한 놀이시설과 맛있는 푸드코트 그리고 물놀이 용품점이 존재하여 여름을 시원하게 보낼 수 있어요!\n\n근처에 동물원도 있으니 아이들과 함께 방문하여 좋은 추억을 만들어보아요!',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 2.6) 장소 바로가기 버튼
                Padding(
                  padding: const EdgeInsets.all(30.0),
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
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    child: Text('스파밸리 상세보기', style: TextStyle(fontSize: 22)),
                  ),
                ),
                SizedBox(height: 50),
                Divider(),
                SizedBox(height: 50),
                // 3. 대구 수목원
                // 3.1) 소제목
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Travel TIP 3. 수목원', // 세부 섹션 제목
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                // 3.2) 이미지
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    height: 500, // 높이 조정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
                      color: Colors.white, // 배경색을 흰색으로 설정
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/advertisement_1.3.png'), // 이미지 경로
                        fit: BoxFit.cover, // 이미지가 컨테이너 영역을 꽉 채우도록 설정
                      ),
                    ),
                  ),
                ),
                // 3.3) 내용 1
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '도심에서 멀리 떨어져 자연을 느껴보세요!\n\n무료 입장으로 멋진 정원을 즐길 수 있는 "대구 수목원"! 가볼까요?',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 3.4) 간격
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0), // 위 아래 패딩 조정
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 첫 번째와 두 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                      SizedBox(width: 20), // 두 번째와 세 번째 점 사이 간격
                      Text('•',
                          style: TextStyle(fontSize: 50, color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // 3.5) 내용 2
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    '"대구 수목원"은 계절마다 다른 느낌을 주어 인근 주민들에게도 인기가 많답니다!\n\n특히, 여름에는 자연의 청량함과 싱그러움을 느낄 수 있어요!\n\n아이들에게 자연의 아름다움과 신비함을 알려줄 수 있는 대구 수목원으로 가보아요!',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                // 3.6) 장소 바로가기 버튼
                Padding(
                  padding: const EdgeInsets.all(30.0),
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
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    child: Text('대구 수목원 상세보기', style: TextStyle(fontSize: 22)),
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                //SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
