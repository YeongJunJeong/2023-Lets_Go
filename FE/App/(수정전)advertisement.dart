import 'package:flutter/material.dart';

class AdvertisementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('광고 제목'), // 여기에 광고 제목을 넣어주세요
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능 추가
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 240, // 높이를 240으로 고정
            width: MediaQuery.of(context).size.width, // 이미지 너비 조정
            child: Image.network(
              'https://source.unsplash.com/random/',
              fit: BoxFit.cover, // 이미지의 비율을 유지하며 화면에 맞춤
            ),
          ),
          SizedBox(height: 16), // 간격 조정
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '광고에 대한 이야기', // 광고에 대한 이야기 텍스트
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
