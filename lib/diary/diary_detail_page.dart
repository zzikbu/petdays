import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../components/custom_dialog.dart';
import '../dummy.dart';
import '../palette.dart';
import 'diary_write_page.dart';

class DiaryDetailPage extends StatefulWidget {
  const DiaryDetailPage({super.key});

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool _isLike = false;
  bool _isLock = true;
  bool _myDiary = true;

  void _likeTap() {
    setState(() {
      _isLike = !_isLike;
    });
  }

  void _lockTap() {
    setState(() {
      _isLock = !_isLock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Palette.background,
        actions: [
          GestureDetector(
            onTap: () {
              if (_isLock) {
                // 비공개 -> 공개
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: '성장일기 공개',
                      message: '성장일기를 공개하면 피드에 게시됩니다.\n변경하시겠습니까?',
                      onConfirm: () {
                        _lockTap();
                      },
                    );
                  },
                );
              } else {
                // 공개 -> 비공개
                // _isLock이 false일 때 바로 _lockTap() 호출
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: '성장일기 비공개',
                      message: '성장일기를 비공개하면 피드에서 삭제됩니다.\n변경하시겠습니까?',
                      onConfirm: () {
                        _lockTap();
                      },
                    );
                  },
                );
              }
            },
            child: _isLock
                ? SvgPicture.asset('assets/icons/ic_lock.svg')
                : SvgPicture.asset('assets/icons/ic_unlock.svg'),
          ),
          SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PullDownButton(
              itemBuilder: (context) => _myDiary
                  ? [
                      PullDownMenuItem(
                        title: '수정하기',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DiaryWritePage(isEditMode: true)),
                          );
                        },
                      ),
                      PullDownMenuItem(
                        title: '삭제하기',
                        isDestructive: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: '성장일기 삭제',
                                message: '성장일기를 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                                onConfirm: () {
                                  print('삭제됨');
                                },
                              );
                            },
                          );
                        },
                      ),
                    ]
                  : [
                      PullDownMenuItem(
                        title: '신고하기',
                        onTap: () {},
                      ),
                      PullDownMenuItem(
                        title: '차단하기',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: showMenu,
                padding: EdgeInsets.zero,
                child: SvgPicture.asset('assets/icons/ic_more.svg'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                '다같이 애견카페 가서 놀은 날',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: Palette.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Palette.lightGray,
                    radius: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '팜하니',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Palette.black,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '2024.08.16 17:24',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Palette.mediumGray,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 1,
                color: Palette.lightGray,
              ),
              SizedBox(height: 16),
              Text(
                '오늘은 망고와 초코를 데리고 애견카페에 다녀왔다.\n\n두 녀석 모두 집에서만 시간을 보내다가 오랜만에 외출이라 그런지, 차에서부터 흥분된 기색이 역력했다. 카페에 도착하자마자 망고와 초코는 꼬리를 흔들며 신나게 뛰어다니기 시작했다. 넓은 마당과 다양한 놀이기구가 마련된 곳이라 두 녀석이 마음껏 뛰어놀 수 있어 나도 덩달아 기분이 좋아졌다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Palette.darkGray,
                  letterSpacing: -0.4,
                  height: 21 / 14,
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: dummyPets.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(dummyPets[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _likeTap,
                child: Container(
                  height: 42,
                  width: 116,
                  decoration: BoxDecoration(
                    color: _isLike ? Palette.darkGray : Palette.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Palette.lightGray,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 24,
                          color: _isLike ? Palette.white : Palette.lightGray,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '123',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: _isLike ? Palette.white : Palette.lightGray,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
