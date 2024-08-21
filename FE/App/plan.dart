import 'package:flutter/material.dart';

// 장소 정보를 담을 클래스
class Place {
  DateTime startTime;
  DateTime endTime;
  String name;
  String image;
  String classification;

  Place({
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.image,
    required this.classification,
  });
}

class PlanPage extends StatefulWidget {
  final String access;
  final String refresh;

  PlanPage(this.access, this.refresh);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  List<Place> places = []; // 장소 목록

  @override
  void initState() {
    super.initState();
    print("PlanPage access: ${widget.access}");
    print("PlanPage refresh: ${widget.refresh}");
  }

  // 장소 추가 페이지로 이동
  void _navigateToAddPlace() {
    // 여기서 검색 페이지로 이동하는 로직을 구현하세요.
  }

  // 장소 삭제
  void _removePlace(int index) {
    setState(() {
      places.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('플랜 생성'),
      ),
      body: Column(
        children: [
          // 플랜 제목, 날짜 등의 입력 필드 구성
          // 장소 목록을 나열하는 리스트
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return ListTile(
                  title: Text(place.name),
                  subtitle: Text(
                      '${place.startTime} - ${place.endTime}, 분류: ${place.classification}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removePlace(index),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToAddPlace,
            child: Text('장소 추가'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // 글자색
            ),
          ),
          // 저장하기 버튼
          ElevatedButton(
            onPressed: () {
              // 저장 로직 구현
            },
            child: Text('저장하기'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // 글자색
            ),
          ),
        ],
      ),
    );
  }
}
