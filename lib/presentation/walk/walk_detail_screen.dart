import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/pd_content_with_title.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../domain/model/walk_model.dart';
import '../../palette.dart';
import '../../providers/walk/walk_provider.dart';
import '../../providers/walk/walk_state.dart';

class WalkDetailScreen extends StatefulWidget {
  final int index;
  final bool isFromHome;

  const WalkDetailScreen({
    super.key,
    required this.index,
    required this.isFromHome,
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

  @override
  Widget build(BuildContext context) {
    WalkModel walkModel = context.read<WalkState>().walkList[widget.index];

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
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

                    if (widget.isFromHome) {
                      context.go('/home');
                    } else {
                      context.go('/home/walk');
                    }
                  } on CustomException catch (e) {
                    showErrorDialog(context, e);
                  }
                },
              );
            },
            icon: const Icon(CupertinoIcons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            PDContentWithTitle(
              title: '함께한 반려동물',
              content: walkModel.pets.map((pet) => pet.name).join(', '),
            ),
            const SizedBox(height: 20),
            PDContentWithTitle(
              title: '날짜',
              content: _formatDate(walkModel.createdAt.toDate()),
            ),
            const SizedBox(height: 20),
            PDContentWithTitle(
              title: '시간',
              content: _formatDuration(walkModel.duration),
            ),
            const SizedBox(height: 20),
            PDContentWithTitle(
              title: '거리',
              content: '${(double.parse(walkModel.distance) / 1000).toStringAsFixed(2)}KM',
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 60),
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
    return '$hours시간 $minutes분 $seconds초';
  }
}
