import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/walk/walk_provider.dart';
import 'package:petdays/providers/walk/walk_state.dart';
import 'package:provider/provider.dart';

class WalkMapScreen extends StatefulWidget {
  final List<PetModel> selectedPets;

  const WalkMapScreen({
    super.key,
    required this.selectedPets,
  });

  @override
  State<WalkMapScreen> createState() => _WalkMapScreenState();
}

class _WalkMapScreenState extends State<WalkMapScreen>
    with WidgetsBindingObserver {
  /// Properties
  bool isSubmitting = false;
  late StreamSubscription<Position> _positionStreamSubscription;
  GoogleMapController? _mapController;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '00:00:00';
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routeCoordinates = [];
  bool _isDisposed = false;

  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(37.5214, 126.9246),
    zoom: 16,
  );

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (_isDisposed) return;

    _mapController = controller;
    try {
      final location = await Geolocator.getCurrentPosition();
      final initialLatLng = LatLng(location.latitude, location.longitude);

      if (!mounted || _isDisposed) return;

      setState(() {
        _routeCoordinates.add(initialLatLng);
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(initialLatLng));
      }
    } catch (e) {
      debugPrint('Error getting initial location: $e');
    }
  }

  /// Timer Functions
  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _elapsedTime = _formatTime(_stopwatch.elapsedMilliseconds);
        });
      }
    });
  }

  String _formatTime(int milliseconds) {
    final hours = (milliseconds / (1000 * 60 * 60)).floor();
    final minutes = ((milliseconds / (1000 * 60)) % 60).floor();
    final seconds = ((milliseconds / 1000) % 60).floor();
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _handleLocationUpdate(Position position) {
    if (!_isDisposed && mounted) {
      final newLatLng = LatLng(position.latitude, position.longitude);
      _updateRouteAndPolyline(newLatLng);
      _updateCamera(newLatLng);
    }
  }

  void _updateRouteAndPolyline(LatLng newLatLng) {
    if (!_isDisposed && mounted) {
      setState(() {
        _routeCoordinates.add(newLatLng);
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
    }
  }

  void _updateCamera(LatLng position) {
    if (!_isDisposed && _mapController != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  /// Distance Calculation
  double _calculateTotalDistance() {
    if (_routeCoordinates.length < 2) return 0;

    return List.generate(
      _routeCoordinates.length - 1,
      (i) => Geolocator.distanceBetween(
        _routeCoordinates[i].latitude,
        _routeCoordinates[i].longitude,
        _routeCoordinates[i + 1].latitude,
        _routeCoordinates[i + 1].longitude,
      ),
    ).reduce((a, b) => a + b);
  }

  /// Map Capture
  Future<Uint8List?> _captureAndSaveMap() async {
    if (_routeCoordinates.isEmpty) return null;

    final bounds = _calculateMapBounds();
    await _mapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    await Future.delayed(const Duration(milliseconds: 1500));
    return await _mapController?.takeSnapshot();
  }

  LatLngBounds _calculateMapBounds() {
    var minLat = _routeCoordinates.first.latitude;
    var maxLat = _routeCoordinates.first.latitude;
    var minLng = _routeCoordinates.first.longitude;
    var maxLng = _routeCoordinates.first.longitude;

    for (var point in _routeCoordinates) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.001, minLng - 0.001),
      northeast: LatLng(maxLat + 0.001, maxLng + 0.001),
    );
  }

  /// Dialog Functions
  Future<bool> _showExitDialog() async {
    final distance = _calculateTotalDistance();
    final minutes = _stopwatch.elapsed.inMinutes;

    return await showDialog<bool>(
          context: context,
          builder: (context) => CustomDialog(
            title: '산책 종료',
            message: _getExitDialogMessage(distance, minutes),
            onConfirm: () => _handleExitConfirmation(distance, minutes),
          ),
        ) ??
        false;
  }

  String _getExitDialogMessage(double distance, int minutes) {
    final distanceKm = (distance / 1000).toStringAsFixed(2);
    return minutes < 5
        ? '총 ${distanceKm}km\n5분 미만 산책은 저장되지 않습니다.\n종료하시겠습니까?'
        : '총 ${distanceKm}km\n산책을 종료하시겠습니까?';
  }

  Future<void> _handleExitConfirmation(double distance, int minutes) async {
    if (minutes >= 0) {
      Navigator.pop(context);

      await _saveWalkData(distance);
    }
    if (mounted) {
      Navigator.of(context)
        ..pop(true)
        ..pop()
        ..pop();
    }
  }

  Future<void> _saveWalkData(double distance) async {
    try {
      _positionStreamSubscription.pause();
      final imageBytes = await _captureAndSaveMap();

      if (imageBytes != null && mounted) {
        await context.read<WalkProvider>().uploadWalk(
              mapImage: imageBytes,
              distance: distance.toString(),
              duration: _elapsedTime,
              petIds: widget.selectedPets.map((pet) => pet.petId).toList(),
            );
      }
    } on CustomException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        Navigator.pop(context, false);
      }
    }
  }

  /// Lifecycle Methods
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen(_handleLocationUpdate);
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopwatch.stop();
    _timer.cancel();
    _positionStreamSubscription.cancel();
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WalkState walkState = context.watch<WalkState>();

    bool isSubmitting = walkState.walkStatus == WalkStatus.submitting;

    return WillPopScope(
      onWillPop: _showExitDialog,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _showExitDialog,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: isSubmitting
            ? Center(child: CircularProgressIndicator(color: Palette.subGreen))
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
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
          onMapCreated: _onMapCreated,
        ),
        _buildTimerContainer(),
      ],
    );
  }

  Widget _buildTimerContainer() {
    return Positioned(
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
                  style: const TextStyle(
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
                onPressed: _showExitDialog,
                icon: const Icon(Icons.square),
                color: Palette.white,
                iconSize: 46,
                highlightColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
