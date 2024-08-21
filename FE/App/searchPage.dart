import 'package:flutter/material.dart';

// 내부 import
import 'package:go_test_ver/searchPage_info.dart'; // 경로 설정.

// 외부 import
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Token 저장
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static final storage = FlutterSecureStorage();
  late String access;
  late String refresh;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String query = '';
  final List<String> _tags = ['#태그'];
  List<String> selectedTags = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _displayedResults = [];
  int _totalResultsCount = 0;
  bool _showMoreButton = false; // 버튼 보이지 않음
  int _displayCount = 5; // 표기 수

  Future<void> fetchSearchResult(String query, {bool fetchMore = false}) async {
    if (query.isEmpty && selectedTags.isEmpty) {
      setState(() {
        _searchResults = [];
        _displayedResults = [];
        _totalResultsCount = 0;
        _showMoreButton = false; // 검색창이 비어있을 때 더보기 버튼을 보이지 않게 수정
      });
      return;
    }

    if (!fetchMore) {
      var body = jsonEncode({
        'name': query,
        'tags': selectedTags.map((tag) => tag.replaceFirst('#', '')).toList()
      });
      final response = await http.post(
        Uri.parse('http://43.203.61.149/place/find/'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        List placesByName = data['places_by_name'];
        List placesByTag = data['places_by_tag'];

        Set<Map<String, dynamic>> matchedPlaces = {};

        placesByName.forEach((place) {
          matchedPlaces.add(place);
        });

        placesByTag.forEach((place) {
          matchedPlaces.add(place);
        });

        _searchResults = matchedPlaces.toList();
        _searchResults =
            _filterResultsByTags(_searchResults, selectedTags); // 태그로 필터링
        _totalResultsCount = _searchResults.length;
      } else {
        print('검색 실패 오류코드: ${response.statusCode}');
        _searchResults = [];
        _totalResultsCount = 0;
      }
      _displayCount = 5; // 초기 표시 아이템 수를 리셋
    } else {
      _displayCount += 5; // "더보기" 클릭 시 추가로 5개의 아이템을 표시
    }

    setState(() {
      _displayedResults = _searchResults.take(_displayCount).toList();
      _showMoreButton = _displayCount < _totalResultsCount &&
          _displayedResults.isNotEmpty &&
          (query.isNotEmpty || selectedTags.isNotEmpty);
    });
  }

  List<Map<String, dynamic>> _filterResultsByTags(
      List<Map<String, dynamic>> results, List<String> tags) {
    if (tags.isEmpty || tags.contains('#태그')) {
      return results;
    }
    List<String> cleanTags =
        tags.map((tag) => tag.replaceFirst('#', '')).toList();
    return results.where((place) {
      if (place['tag'] != null && place['tag'].isNotEmpty) {
        List<String> placeTags =
            place['tag'].map<String>((tag) => tag['name'] as String).toList();
        return cleanTags.any((tag) => placeTags.contains(tag));
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              onSubmitted: (value) => fetchSearchResult(query),
              decoration: InputDecoration(
                hintText: "Search",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: _tags.map((tag) => _buildChip(tag)).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: _displayedResults.length + (_showMoreButton ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                if (index == _displayedResults.length && _showMoreButton) {
                  return _buildMoreButton();
                }

                var item = _displayedResults[index];
                var tags = item['tag'] != null && item['tag'].isNotEmpty
                    ? item['tag'].map((tag) => tag['name']).join(' ')
                    : ' ';
                var imageUrl = item['image'] != null
                    ? 'http://43.203.61.149${item['image']}'
                    : 'https://via.placeholder.com/80';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaceDetailPage(placeDetails: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.oleoScript(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Visibility(
                                  visible: tags.isNotEmpty,
                                  child: Text(
                                    tags,
                                    style: GoogleFonts.oleoScript(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String tag) {
    return InkWell(
      onTap: () => _showTagSelectionDialog(),
      child: Chip(
        label: Text(tag),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Future<List<String>> fetchTags() async {
    final response =
        await http.get(Uri.parse('http://43.203.61.149/place/tag/'));
    if (response.statusCode == 200) {
      Map<String, dynamic> tagsJson = json
          .decode(utf8.decode(response.bodyBytes)); // utf8.decode() 사용하여 디코딩
      List<dynamic> results = tagsJson['results']; // 'results' 키의 값을 가져옴
      List<String> tags = [];
      for (var result in results) {
        tags.add('${result['name']}');
      }
      return tags;
    } else {
      throw Exception('Failed to load tags');
    }
  }

  void _showTagSelectionDialog() async {
    try {
      final allTags = await fetchTags(); // 태그를 HTTP 요청으로 가져옴
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('태그 선택'),
            content: SingleChildScrollView(
              child: ListBody(
                children: allTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return CheckboxListTile(
                    title: Text(tag),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true && !selectedTags.contains(tag)) {
                          selectedTags.add(tag);
                        } else if (value == false &&
                            selectedTags.contains(tag)) {
                          selectedTags.remove(tag);
                        }
                      });
                      Navigator.of(context).pop();
                      _showTagSelectionDialog(); // 다이얼로그를 다시 열어 업데이트된 상태를 표시
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  setState(() {
                    _tags
                      ..clear()
                      ..addAll(['#태그'] + selectedTags);
                  });
                  Navigator.of(context).pop();
                  fetchSearchResult(query); // 태그 선택 후 검색 결과 업데이트
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching tags: $e');
    }
  }

  Widget _buildMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: OutlinedButton(
          child: Text('더보기', style: GoogleFonts.oleoScript()),
          onPressed: () => fetchSearchResult(query, fetchMore: true),
        ),
      ),
    );
  }
}
