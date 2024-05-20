import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/services/work.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/work_table.dart';

class WorkScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const WorkScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  WorkService workService = WorkService();
  DateTime searchMonth = DateTime.now();
  UserModel? searchUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomButtonSm(
                    icon: FluentIcons.table,
                    labelText: convertDateText('yyyy年MM月', searchMonth),
                    labelColor: kWhiteColor,
                    backgroundColor: kCyanColor,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  CustomButtonSm(
                    icon: FluentIcons.contact,
                    labelText: 'スタッフ選択',
                    labelColor: kWhiteColor,
                    backgroundColor: kCyanColor,
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                children: [
                  CustomButtonSm(
                    icon: FluentIcons.download,
                    labelText: 'CSVをダウンロード',
                    labelColor: kWhiteColor,
                    backgroundColor: kGreenColor,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  CustomButtonSm(
                    icon: FluentIcons.add,
                    labelText: '手入力で追加',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: workService.streamList(
              companyId: widget.loginProvider.company?.id,
              groupId: widget.homeProvider.currentGroup?.id,
              searchMonth: searchMonth,
              searchUser: searchUser,
            ),
            builder: (context, snapshot) {
              List<WorkModel> works = workService.convertList(snapshot);
              return WorkTable(
                searchMonth: searchMonth,
                works: works,
              );
            },
          ),
        ],
      ),
    );
  }
}
