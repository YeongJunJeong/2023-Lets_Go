import 'package:flutter/material.dart'; #설문조사

void main() {
  runApp(SurveyApp());
}

class SurveyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyScreen(),
    );
  }
}

class SurveyScreen extends StatefulWidget {
  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _selectedOption = 3; // 자연<->도시 선택을 위한 변수
  int _selectedTravelOption = 3; // 숙박<->당일치기 선택을 위한 변수

  // 점수 매핑
  Map<int, int> _scoreMap = {
    0: 0,
    1: 1,
    2: 3,
    3: 5,
    4: 7,
    5: 9,
    6: 10,
  };

  // 숙박<->당일치기 점수 매핑
  Map<int, int> _travelScoreMap = {
    0: 0,
    1: 1,
    2: 3,
    3: 5,
    4: 7,
    5: 9,
    6: 10,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 자연<->도시 선택 섹션
            buildOptionSection(
              '자연',
              '도시',
              _selectedOption,
              7,
              (index) {
                setState(() {
                  _selectedOption = index;
                });
              },
            ),
            SizedBox(height: 40),
            // 숙박<->당일치기 선택 섹션
            buildOptionSection(
              '숙박',
              '당일치기',
              _selectedTravelOption,
              3,
              (index) {
                setState(() {
                  _selectedTravelOption = index;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 선택된 점수 출력
                int? selectedScore = _scoreMap[_selectedOption];
                int? selectedTravelScore =
                    _travelScoreMap[_selectedTravelOption];
                print('Selected nature-city score: $selectedScore');
                print('Selected stay-day trip score: $selectedTravelScore');
              },
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionSection(String leftText, String rightText,
      int selectedOption, int optionsCount, void Function(int) onTap) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            optionsCount,
            (index) => GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedOption == index
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftText, style: TextStyle(fontSize: 16)),
            Text(rightText, style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
