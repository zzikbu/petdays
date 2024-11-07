import 'package:flutter/material.dart';
import 'package:petdays/exceptions/custom_exception.dart';

void errorDialogWidget(BuildContext context, CustomException e) {
  showDialog(
    context: context,
    barrierDismissible: false, // 확인 버튼으로만 닫을 수 있음
    builder: (context) {
      return AlertDialog(
        // 에러코드
        title: Text(e.code),
        // 에러내용
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}
