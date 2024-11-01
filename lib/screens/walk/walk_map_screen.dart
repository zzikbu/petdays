import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/palette.dart';

class WalkMapScreen extends StatefulWidget {
  WalkMapScreen({super.key});

  @override
  State<WalkMapScreen> createState() => _WalkMapScreenState();
}

class _WalkMapScreenState extends State<WalkMapScreen> {
  /// Properties
  Position? _currentPosition;
  late StreamSubscription<Position> _positionStreamSubscription;

  final CameraPosition initialPosition =
      CameraPosition(target: LatLng(37.4866, 126.8019));

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      // _goToCurrentLocation();
    });
  }

  @override
  void initState() {
    super.initState();
    // _startLocationUpdates();
  }

  @override
  void dispose() {
    // _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(initialCameraPosition: initialPosition),
          // 타이머
          Positioned(
            left: 24,
            right: 24,
            bottom: 100,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Palette.mainGreen,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '00:00:00',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: Palette.white,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: '산책 종료',
                              message: '5분 미만 산책은 저장되지 않습니다.\n종료하시겠습니까?',
                              onConfirm: () {
                                print('삭제됨');
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.square),
                      color: Palette.white,
                      iconSize: 46,
                      highlightColor: Colors.transparent, // 꾹 눌렀을 때 애니메이션 제거
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
