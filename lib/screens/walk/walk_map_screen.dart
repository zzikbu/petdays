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
  late StreamSubscription<Position> _positionStreamSubscription;
  GoogleMapController? _mapController;

  // 경로 추적을 위한 변수
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routeCoordinates = [];

  final CameraPosition initialPosition = CameraPosition(
    target: LatLng(
      37.5214,
      126.9246,
    ),
    zoom: 16,
  );

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
      final newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        // 새로운 위치를 경로에 추가
        _routeCoordinates.add(newLatLng);

        // Polyline 업데이트
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('walking_route'),
            color: Palette.subGreen,
            width: 8,
            points: _routeCoordinates,
          ),
        );
      });

      // 카메라 이동
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newLatLng),
      );
    });
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw ('위치 서비스가 비활성화되어 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw ('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw ('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.');
    }
  }

  double _calculateTotalDistance() {
    double totalDistance = 0;

    // 최소 2개의 좌표가 있어야 거리 계산 가능
    if (_routeCoordinates.length < 2) return totalDistance;

    // 모든 연속된 좌표 쌍에 대해 거리 계산
    for (int i = 0; i < _routeCoordinates.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _routeCoordinates[i].latitude,
        _routeCoordinates[i].longitude,
        _routeCoordinates[i + 1].latitude,
        _routeCoordinates[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  @override
  void initState() {
    super.initState();
    _startLocationUpdates(); // initState에서 스트림 시작
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel(); // dispose에서 스트림 취소
    _mapController?.dispose(); // 컨트롤러도 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _checkPermission(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: initialPosition,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(left: 10, bottom: 20),
                polylines: _polylines, // 경로 표시
                onMapCreated: (GoogleMapController controller) async {
                  _mapController = controller;

                  final location = await Geolocator.getCurrentPosition();
                  final initialLatLng = LatLng(
                    location.latitude,
                    location.longitude,
                  );

                  // 초기 위치를 경로에 추가
                  setState(() {
                    _routeCoordinates.add(initialLatLng);
                  });

                  controller.animateCamera(
                    CameraUpdate.newLatLng(initialLatLng),
                  );
                },
              ),

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
                            final distance = _calculateTotalDistance();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  title: '산책 종료',
                                  message: '5분 미만 산책은 저장되지 않습니다.\n종료하시겠습니까?',
                                  onConfirm: () {
                                    print(
                                        '총 이동 거리: ${(distance / 1000).toStringAsFixed(2)}km');
                                  },
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.square),
                          color: Palette.white,
                          iconSize: 46,
                          highlightColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
