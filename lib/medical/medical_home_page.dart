import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/medical_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/medical/medical_provider.dart';
import 'package:pet_log/providers/medical/medical_state.dart';
import 'package:pet_log/search/search_page.dart';
import 'package:pet_log/select_pet_page.dart';
import 'package:provider/provider.dart';

import '../dummy.dart';
import 'medical_detail_page.dart';

class MedicalHomePage extends StatefulWidget {
  const MedicalHomePage({super.key});

  @override
  State<MedicalHomePage> createState() => _MedicalHomePageState();
}

class _MedicalHomePageState extends State<MedicalHomePage>
    with AutomaticKeepAliveClientMixin<MedicalHomePage> {
  late final MedicalProvider medicalProvider;

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    medicalProvider = context.read<MedicalProvider>();
    _getFeedList();
  }

  void _getFeedList() {
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: SvgPicture.asset('assets/icons/ic_magnifier.svg'),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: medicalList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalDetailPage()),
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
                      // border: Border.all(
                      //   color: Palette.feedBorder,
                      //   width: 1,
                      // ),
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
                                        medicalList[index].pet.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),

                              // 이름
                              Text(
                                medicalList[index].pet.name,
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
                                medicalList[index].visitDate,
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
                            medicalList[index].reason,
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
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Text(
                      '*',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Palette.black,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectPetPage(isMedical: true),
            ),
          );
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
