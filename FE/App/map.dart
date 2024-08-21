// 내부 import
import 'package:flutter/material.dart';

// 외부 import
import 'dart:async';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapTest extends StatefulWidget {
  final double lat;
  final double lon;

  MapTest(this.lat, this.lon);
  @override
  MapTestState createState() => MapTestState();
}

class MapTestState extends State<MapTest> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      // 옵션 :
      options: NaverMapViewOptions(
        // 옵션 1. 첫 로딩시 카메라 포지션 지정
        initialCameraPosition: NCameraPosition(
          target: NLatLng(widget.lat, widget.lon), // 위도 + 경도
          zoom: 16,
        ),
        locationButtonEnable: true, // 옵션 2. 현재 위치 버튼 표시 여부 설정
        scaleBarEnable: true, // 옵션 3. 축적 바 (활성화)
        rotationGesturesEnable: true, // 옵션 4. 제스처 - 회전 (활성화)
        scrollGesturesEnable: true, // 옵션 5. 제스처 - 스크롤 (활성화)
        zoomGesturesEnable: true, // 옵션 6. 제스처 - 줌 (활성화)
        scrollGesturesFriction: 0.3, // 옵션 7. 스크롤 마찰계수
        zoomGesturesFriction: 0.3, // 옵션 8. 줌 마찰계수
      ),
      // 지도가 준비되었을 때
      onMapReady: (controller) {
        final marker = NMarker(
          id: "test",
          position: NLatLng(widget.lat, widget.lon),
        );
        controller.addOverlay(marker);
      },
    );
  }
}
