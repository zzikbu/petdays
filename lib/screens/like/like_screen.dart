import 'package:flutter/material.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/providers/like/like_provider.dart';
import 'package:pet_log/providers/like/like_state.dart';
import 'package:provider/provider.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen>
    with AutomaticKeepAliveClientMixin<LikeScreen> {
  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true; // AutomaticKeepAliveClientMixin

  late final LikeProvider likeProvider;

  void _getLikeList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await likeProvider.getLikeList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    likeProvider = context.read<LikeProvider>();
    _getLikeList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final likeState = context.watch<LikeState>();
    List<DiaryModel> likeList = likeState.likeList;

    print(likeList);

    return const Placeholder();
  }
}
