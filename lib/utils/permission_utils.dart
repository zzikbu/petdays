import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/widgets/show_custom_dialog.dart';

class PermissionUtils {
  static Future<bool> checkPhotoPermission(BuildContext context) async {
    PermissionStatus status = await Permission.photos.status;

    if (!status.isGranted) {
      if (status.isDenied) {
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        if (context.mounted) {
          showCustomDialog(
            context: context,
            title: '사진 접근 권한 필요',
            message: status.isPermanentlyDenied
                ? '설정에서 사진 접근 권한을 허용해주세요.'
                : '사진 업로드를 위해 사진 접근 권한이 필요합니다.',
            onConfirm: () {
              if (status.isPermanentlyDenied) {
                openAppSettings();
              }
              Navigator.pop(context);
            },
          );
        }
        return false;
      }
    }

    return true;
  }

  static Future<bool> checkLocationPermission(BuildContext context) async {
    // 위치 서비스 활성화 확인
    bool serviceEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;
    if (!serviceEnabled) {
      if (context.mounted) {
        showCustomDialog(
          context: context,
          title: '위치 서비스 필요',
          message: '산책 기록을 위해 위치 서비스를 활성화해주세요.',
          onConfirm: () {
            openAppSettings();
            Navigator.pop(context);
          },
        );
      }
      return false;
    }

    // 위치 권한 상태 체크
    PermissionStatus status = await Permission.locationWhenInUse.status;

    // 권한이 없는 모든 경우(거부, 영구 거부 등) 처리
    if (!status.isGranted) {
      // 처음 거부 상태면 권한 요청
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      // 요청 후에도 권한이 없으면
      if (!status.isGranted) {
        if (context.mounted) {
          showCustomDialog(
            context: context,
            title: '위치 권한 필요',
            message: status.isPermanentlyDenied
                ? '산책 기록을 위해 설정에서 위치 권한을 허용해주세요.'
                : '산책 기록을 위해 위치 권한이 필요합니다.',
            onConfirm: () {
              if (status.isPermanentlyDenied) {
                openAppSettings();
              }
              Navigator.pop(context);
            },
          );
        }
        return false;
      }
    }

    return true;
  }
}
