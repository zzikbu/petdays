import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/walk/walk_provider.dart';
import 'package:provider/provider.dart';

class WalkMapScreen extends StatefulWidget {
  WalkMapScreen({super.key});

  @override
  State<WalkMapScreen> createState() => _WalkMapScreenState();
}

class _WalkMapScreenState extends State<WalkMapScreen>
    with WidgetsBindingObserver {
  /// Properties
  late StreamSubscription<Position> _positionStreamSubscription;
  GoogleMapController? _mapController;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '00:00:00';

  // 경로 추적을 위한 변수
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routeCoordinates = [];

  final CameraPosition initialPosition = CameraPosition(
    target: LatLng(
      37.5214,
      126.9246,
    ),
    zoom: 20,
  );

  // 타이머 시작 함수
  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final milliseconds = _stopwatch.elapsedMilliseconds;
      final hours = (milliseconds / (1000 * 60 * 60)).floor();
      final minutes = ((milliseconds / (1000 * 60)) % 60).floor();
      final seconds = ((milliseconds / 1000) % 60).floor();

      setState(() {
        _elapsedTime = '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

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

  Future<Uint8List?> _captureAndSaveMap() async {
    // if (_routeCoordinates.isEmpty) return;

    // 모든 경로 포인트를 포함하는 bounds 계산
    double minLat = _routeCoordinates.first.latitude;
    double maxLat = _routeCoordinates.first.latitude;
    double minLng = _routeCoordinates.first.longitude;
    double maxLng = _routeCoordinates.first.longitude;

    for (LatLng point in _routeCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // bounds에 padding 추가
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.001, minLng - 0.001),
      northeast: LatLng(maxLat + 0.001, maxLng + 0.001),
    );

    // 카메라 이동
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );

    // 약간의 딜레이를 주어 카메라 이동이 완료되길 기다림
    await Future.delayed(const Duration(milliseconds: 2500));

    // 지도 캡처
    final Uint8List? imageBytes = await _mapController?.takeSnapshot();

    if (imageBytes != null) {
      return imageBytes;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 상태 관찰자 등록
    _startLocationUpdates();
    _startTimer(); // 타이머 시작
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 관찰자 제거
    _stopwatch.stop();
    _timer.cancel();
    _positionStreamSubscription.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 백그라운드로 갈 때도 타이머 유지
    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갈 때
        break;
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때
        break;
      default:
        break;
    }
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
                polylines: _polylines,
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
                            _elapsedTime,
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
                            final double distance = _calculateTotalDistance();
                            final int minutes = _stopwatch.elapsed.inMinutes;

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  title: '산책 종료',
                                  message: minutes < 5
                                      ? '총 ${(distance / 1000).toStringAsFixed(2)}km\n5분 미만 산책은 저장되지 않습니다.\n종료하시겠습니까?'
                                      : '총 ${(distance / 1000).toStringAsFixed(2)}km\n산책을 종료하시겠습니까?',
                                  onConfirm: () async {
                                    if (minutes >= 0) {
                                      // 5분 이상일 때만 저장
                                      try {
                                        // 위치 업데이트 일시 중지
                                        _positionStreamSubscription.pause();

                                        // 지도 캡처
                                        final Uint8List? imageBytes =
                                            await _captureAndSaveMap();

                                        if (imageBytes != null) {
                                          // Provider를 통해 데이터 업로드
                                          await context
                                              .read<WalkProvider>()
                                              .uploadWalk(
                                                mapImage: imageBytes,
                                                distance: distance
                                                    .toString(), // 미터 단위로 저장
                                                duration:
                                                    _elapsedTime, // HH:MM:SS 형식
                                                petId:
                                                    '1a5d8c40-9616-11ef-a41d-6fb9902ca267',
                                              );

                                          // 성공시 화면 닫기
                                          Navigator.pop(context); // 다이얼로그 닫기
                                          Navigator.pop(context); // 지도 화면 닫기
                                        }
                                      } on CustomException catch (e) {
                                        // 에러 처리
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.message)),
                                        );
                                      }
                                    } else {
                                      Navigator.pop(context); // 5분 미만일 경우 그냥 닫기
                                    }
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
