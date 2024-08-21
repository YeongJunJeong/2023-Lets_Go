// 내부 import
import 'package:go_test_ver/searchPage_info.dart';
import 'package:go_test_ver/survey_again.dart';

// 외부 import
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ChatBotApp());

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// 챗봇
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  final storage = FlutterSecureStorage();
  String? planId;
  List<Map<String, dynamic>> schedule = [];
  List<Map<String, dynamic>> savedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadSavedPlaces();
  }

  // 메시지 전달
  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('chat_messages');
    String? storedUserId = await storage.read(key: 'login_id');

    if (messagesJson != null && storedUserId != null) {
      final allMessages =
          List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
      setState(() {
        messages
            .addAll(allMessages.where((msg) => msg['user_id'] == storedUserId));
      });
    }
  }

  // 메시지 저장
  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = await storage.read(key: 'login_id');

    if (storedUserId != null) {
      final allMessages = await _loadAllMessages();
      allMessages.removeWhere((msg) => msg['user_id'] == storedUserId);
      allMessages.addAll(messages.map((msg) {
        msg['user_id'] = storedUserId;
        return msg;
      }).toList());
      prefs.setString('chat_messages', jsonEncode(allMessages));
    }
  }

  // 메시지 저장
  Future<List<Map<String, dynamic>>> _loadAllMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('chat_messages');

    if (messagesJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
    } else {
      return [];
    }
  }

  // 메시지 보내기
  Future<void> sendMessage(String message) async {
    String? token = await storage.read(key: 'login_access_token');
    String? storedUserId = await storage.read(key: 'login_id');

    if (token == null || storedUserId == null) {
      setState(() {
        messages.add(
            {'type': 'bot', 'text': '토큰을 가져오지 못했습니다', 'user_id': storedUserId});
      });
      await _saveMessages();
      return;
    }

    setState(() {
      messages.add({'type': 'user', 'text': message, 'user_id': storedUserId});
      messages.add({'type': 'loading', 'user_id': storedUserId});
    });
    await _saveMessages();
    _scrollToBottom();

    final response = await http.post(
      Uri.parse('http://43.203.61.149/plan/recommand'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: utf8.encode(jsonEncode({'user_input': message})),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          savedPlaces.clear(); // savedPlaces 리스트 초기화
          messages.removeWhere((msg) =>
              msg['type'] == 'loading' && msg['user_id'] == storedUserId);
        });

        if (responseData is List) {
          for (var item in responseData) {
            final chatResponse = item['chat_response'] as String;
            final botResponse = item['response'] != null
                ? List<String>.from(item['response'] as List<dynamic>)
                : [];

            setState(() {
              messages.add({
                'type': 'bot',
                'text': chatResponse,
                'response': botResponse,
                'user_id': storedUserId,
              });
            });

            for (var placeName in botResponse) {
              final place = placeName.split(':')[0].trim();
              await _fetchPlaceDetails(place);
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          final chatResponse = responseData['chat_response'] as String;
          final botResponse = responseData['response'] != null
              ? List<String>.from(responseData['response'] as List<dynamic>)
              : [];

          setState(() {
            messages.add({
              'type': 'bot',
              'text': chatResponse,
              'response': botResponse,
              'user_id': storedUserId,
            });
          });

          for (var placeName in botResponse) {
            final place = placeName.split(':')[0].trim();
            await _fetchPlaceDetails(place);
          }
        }
        await _saveSavedPlaces(); // savedPlaces 저장
      } catch (e) {
        setState(() {
          messages.removeWhere((msg) =>
              msg['type'] == 'loading' && msg['user_id'] == storedUserId);
          messages.add({
            'type': 'bot',
            'text': '응답을 파싱하는 데 실패했습니다: $e',
            'user_id': storedUserId
          });
        });
      }
    } else {
      setState(() {
        messages.removeWhere((msg) =>
            msg['type'] == 'loading' && msg['user_id'] == storedUserId);
        messages.add(
            {'type': 'bot', 'text': '응답을 가져오지 못했습니다', 'user_id': storedUserId});
      });
    }
    await _saveMessages();
    _scrollToBottom();
  }

  Future<void> _saveSavedPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_places', jsonEncode(savedPlaces));
  }

  Future<void> _loadSavedPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPlacesJson = prefs.getString('saved_places');
    if (savedPlacesJson != null) {
      setState(() {
        savedPlaces =
            List<Map<String, dynamic>>.from(jsonDecode(savedPlacesJson));
      });
    }
  }

  Future<void> _fetchPlaceDetails(String placeName) async {
    String? storedUserId = await storage.read(key: 'login_id');

    //print('추천: ' + placeName);
    final body = jsonEncode({'name': placeName});

    final response = await http.post(
      Uri.parse('http://43.203.61.149/place/find/'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final placesByName = responseData['places_by_name'] as List<dynamic>;

        if (placesByName.isNotEmpty) {
          final placeDetails = placesByName.first as Map<String, dynamic>;
          final placeId = placeDetails['id'].toString();
          final latitude = placeDetails['latitude'];
          final hardness = placeDetails['hardness'];

          //print('추천: ' + placeId);
          //print('위도: $latitude, 경도: $hardness'); // 추가된 정보 출력

          setState(() {
            savedPlaces.add({
              'name': placeName,
              'id': placeId,
              'latitude': latitude,
              'hardness': hardness,
              'user_id': storedUserId,
            });
          });
        }
      } catch (e) {
        setState(() {
          messages.add({
            'type': 'bot',
            'text': '장소 세부 정보를 파싱하는 데 실패했습니다: $e',
            'user_id': storedUserId
          });
        });
      }
    } else {
      setState(() {
        messages.add({
          'type': 'bot',
          'text': '장소 세부 정보를 가져오지 못했습니다',
          'user_id': storedUserId
        });
      });
    }
    await _saveMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleCreatePlan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlanCreationDialog(
          onSave: (planName) => _createPlan(planName),
        );
      },
    );
  }

  // 플랜 생성하기
  Future<void> _createPlan(String planName) async {
    String? storedUserId = await storage.read(key: 'login_id');

    if (storedUserId == null) {
      setState(() {
        messages.add({
          'type': 'bot',
          'text': '사용자 ID를 가져오지 못했습니다',
          'user_id': storedUserId
        });
      });
      await _saveMessages();
      return;
    }

    final response = await http.post(
      Uri.parse('http://43.203.61.149/plan/plan/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": planName,
        "user": storedUserId,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      planId = responseData['id'].toString();
      //print('플랜이 생성되었습니다. ID: $planId');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TravelPlanPage(
            planId: planId!,
            places: savedPlaces,
            onSaveComplete: _handleSaveComplete,
          ),
        ),
      );
    } else {
      setState(() {
        messages.add(
            {'type': 'bot', 'text': '플랜을 생성하지 못했습니다', 'user_id': storedUserId});
      });
    }
    await _saveMessages();
    _scrollToBottom();
  }

  Future<void> _handleSaveComplete() async {
    String? storedUserId = await storage.read(key: 'login_id');

    if (storedUserId == null) {
      setState(() {
        messages.add({
          'type': 'bot',
          'text': '사용자 ID를 가져오지 못했습니다',
          'user_id': storedUserId
        });
      });
      await _saveMessages();
      return;
    }
    setState(() {
      messages
          .add({'type': 'bot', 'text': '플랜을 저장했어요!', 'user_id': storedUserId});
    });
    _saveMessages();
    _scrollToBottom();
  }

  void _clearMessages() async {
    setState(() {
      messages.clear();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearMessages,
          ),
          IconButton(
            icon: Icon(Icons.settings), // 톱니바퀴 아이콘 추가
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SurveyAgainPage()), // SurveyAgainPage로 이동
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: storage.read(key: 'login_id'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final userId = snapshot.data;
          final userMessages =
              messages.where((msg) => msg['user_id'] == userId).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: userMessages.length,
                  itemBuilder: (context, index) {
                    final message = userMessages[index];
                    if (message['type'] == 'user') {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    } else if (message['type'] == 'loading') {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 6),
                              Text(''),
                            ],
                          ),
                        ),
                      );
                    } else if (message['type'] == 'place') {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 5, left: 10, top: 5),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Text(
                                      '?',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID: ${message['id']}',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      Text(
                                        message['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 5, left: 10, top: 5),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Text(
                                      '?',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['text'],
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      if (message['response'] != null)
                                        ...message['response']
                                            .map<Widget>(
                                                (item) => Text('• $item'))
                                            .toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (message['response'] != null &&
                                message['response'].isNotEmpty)
                              Center(
                                child: ElevatedButton(
                                  onPressed: _handleCreatePlan,
                                  child: Text('플랜 작성하기'),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: '대화를 입력해주세요',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PlanCreationDialog extends StatelessWidget {
  final TextEditingController planController = TextEditingController();
  final Function(String) onSave;

  PlanCreationDialog({required this.onSave});

  @override
  Widget build(BuildContext context) {
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
        controller: planController,
        decoration: InputDecoration(
          hintText: "플랜 이름을 입력하세요",
        ),
      ),
      // 취소 / 확인 버튼 UI
      actionsAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양 끝으로 정렬
      actions: [
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
            onSave(planController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class TravelPlanPage extends StatefulWidget {
  final String planId;
  final List<Map<String, dynamic>> places;
  final Function onSaveComplete;

  TravelPlanPage(
      {required this.planId,
      required this.places,
      required this.onSaveComplete});

  @override
  _TravelPlanPageState createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage> {
  late NaverMapController _mapController;
  double sheetExtent = 0.5;
  late List<Map<String, dynamic>> _places;

  @override
  void initState() {
    super.initState();
    _places = List<Map<String, dynamic>>.from(widget.places);
  }

  void _addMarkers() {
    for (var i = 0; i < _places.length; i++) {
      final marker = NMarker(
        id: _places[i]['id'].toString(),
        position: NLatLng(_places[i]['latitude'], _places[i]['hardness']),
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

  Future<void> addToPlan(String planId, String placeId) async {
    DateTime now = DateTime.now().toUtc(); // 현재 UTC 시간
    String formattedDate = now.toIso8601String(); // 현재 시간을 ISO 8601 포맷으로 변환

    final response = await http.post(
      Uri.parse('http://43.203.61.149/plan/schedule/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'start_date': formattedDate, // 현재 시간을 시작 날짜로 설정
        'end_date': formattedDate, // 현재 시간을 종료 날짜로 설정
        'place': placeId,
        'plan': planId,
      }),
    );

    if (response.statusCode == 201) {
      //print("장소 추가 성공");
    } else {
      //print("장소 추가 실패: ${response.body}");
    }
  }

  void _savePlan() async {
    for (var place in _places) {
      await addToPlan(widget.planId, place['id']);
    }
    widget.onSaveComplete();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("플랜이 성공적으로 저장되었습니다!", style: GoogleFonts.oleoScript()),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
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
                  color: Colors.grey[300], // 임시 컨테이너의 배경색
                  child: _places.isEmpty
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
                              target: NLatLng(_places[0]['latitude'],
                                  _places[0]['hardness']),
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
                    children: [
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
                              itemCount: _places.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  key: ValueKey(_places[index]['id']),
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
                                      onDoubleTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlaceDetailPage(
                                              placeDetails: _places[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        _places[index]['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    trailing: ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(Icons.drag_handle),
                                    ),
                                  ),
                                );
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1; // 새 인덱스 보정
                                  }
                                  final item = _places.removeAt(oldIndex);
                                  _places.insert(newIndex, item);
                                  _updateMarkers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _savePlan,
                          child: Text('저장 하기'),
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
}

class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> placeDetails;

  PlaceDetailPage({required this.placeDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails['name']),
      ),
      body: Center(
        child: Text('Place details for ${placeDetails['name']}'),
      ),
    );
  }
}
