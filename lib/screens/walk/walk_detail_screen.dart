import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/w_detail_info_with_title.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/walk_model.dart';
import '../../palette.dart';
import '../../providers/walk/walk_provider.dart';
import '../../providers/walk/walk_state.dart';

class WalkDetailScreen extends StatefulWidget {
  final int index;

  const WalkDetailScreen({
    super.key,
    required this.index,
  });

  @override
  State<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends State<WalkDetailScreen> {
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${_getDayOfWeek(date.weekday)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '월요일';
      case 2:
        return '화요일';
      case 3:
        return '수요일';
      case 4:
        return '목요일';
      case 5:
        return '금요일';
      case 6:
        return '토요일';
      case 7:
        return '일요일';
      default:
        return '';
    }
  }

  void _deleteWalk() async {
    try {
      // await _walkProvider.deleteWalk(context.read<WalkState>().walkList[widget.index].walkId);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('산책 기록 삭제 실패: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WalkModel walkModel = context.read<WalkState>().walkList[widget.index];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showCustomDialog(
                context: context,
                title: '산책기록 삭제',
                message: '산책기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                onConfirm: () async {
                  try {
                    await context.read<WalkProvider>().deleteWalk(walkModel: walkModel);

                    Navigator.pop(context);
                    Navigator.pop(context);
                  } on CustomException catch (e) {
                    showErrorDialog(context, e);
                  }
                },
              );
            },
            icon: Icon(CupertinoIcons.delete),
          ),
        ],
      ),
      backgroundColor: Palette.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            DetailInfoWithTitleWidget(
              title: '함께한 반려동물',
              content: walkModel.pets.map((pet) => pet.name).join(', '),
            ),
            SizedBox(height: 20),
            DetailInfoWithTitleWidget(
              title: '날짜',
              content: _formatDate(walkModel.createdAt.toDate()),
            ),
            SizedBox(height: 20),
            DetailInfoWithTitleWidget(
              title: '시간',
              content: _formatDuration(walkModel.duration),
            ),
            SizedBox(height: 20),
            DetailInfoWithTitleWidget(
              title: '거리',
              content: '${(double.parse(walkModel.distance) / 1000).toStringAsFixed(2)}KM',
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              height: 400,
              width: double.infinity,
              child: Image.network(
                walkModel.mapImageUrl,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  String _formatDuration(String duration) {
    final parts = duration.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return '${hours}시간 ${minutes}분 ${seconds}초';
  }
}
