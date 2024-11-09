import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/components/error_dialog_widget.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/medical_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/medical/medical_provider.dart';
import 'package:petdays/providers/medical/medical_state.dart';
import 'package:petdays/providers/pet/pet_state.dart';
import 'package:petdays/screens/medical/medical_detail_screen.dart';
import 'package:petdays/screens/select_pet_screen.dart';
import 'package:provider/provider.dart';

class MedicalHomeScreen extends StatefulWidget {
  const MedicalHomeScreen({super.key});

  @override
  State<MedicalHomeScreen> createState() => _MedicalHomeScreenState();
}

class _MedicalHomeScreenState extends State<MedicalHomeScreen>
    with AutomaticKeepAliveClientMixin<MedicalHomeScreen> {
  late final MedicalProvider medicalProvider;

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    medicalProvider = context.read<MedicalProvider>();
    _getMedicalList();
  }

  void _getMedicalList() {
    String uid = context.read<User>().uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await medicalProvider.getMedicalList(uid: uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    MedicalState medicalState = context.watch<MedicalState>();
    List<MedicalModel> medicalList = medicalState.medicalList;

    if (medicalState.medicalStatus == MedicalStatus.fetching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "진료기록",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Palette.black,
            letterSpacing: -0.5,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: GestureDetector(
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => SearchScreen()),
        //         );
        //       },
        //       child: SvgPicture.asset('assets/icons/ic_magnifier.svg'),
        //     ),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        // 새로고침
        color: Palette.subGreen,
        backgroundColor: Palette.white,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1)); // 딜레이 추가
          _getMedicalList();
        },
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: medicalList.length,
            itemBuilder: (context, index) {
              final medical = medicalList[index]; // medical 변수로 빼기

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MedicalDetailScreen(index: index)),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      height: 110,
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.black.withOpacity(0.05),
                            offset: Offset(8, 8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                // 사진
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Palette.lightGray,
                                      width: 0.4,
                                    ),
                                    image: DecorationImage(
                                      image: ExtendedNetworkImageProvider(
                                        medical.pet.image,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),

                                // 이름
                                Text(
                                  medical.pet.name,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Palette.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 8),

                                // 방문날짜
                                Text(
                                  medical.visitDate,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Palette.mediumGray,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),

                            // 이유
                            Text(
                              medical.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Palette.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 메모가 있을 경우 아이콘 표시
                    if (medical.note.isNotEmpty)
                      Positioned(
                        top: 10,
                        right: 16,
                        child: Icon(Icons.sticky_note_2_outlined),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.read<PetState>().petList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return CustomDialog(
                  title: '진료기록',
                  message: '반려동물을 추가해주세요.',
                  hasCancelButton: false,
                  onConfirm: () => Navigator.pop(context),
                );
              },
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPetScreen(isMedical: true),
              ),
            );
          }
        },
        backgroundColor: Palette.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.edit,
          color: Palette.white,
        ),
      ),
    );
  }
}
