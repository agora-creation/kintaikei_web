import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/work_table.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/services/work.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_radio.dart';

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
  DateTimePickerService pickerService = DateTimePickerService();
  DateTime searchMonth = DateTime.now();
  UserModel? searchUser;
  List<DateTime> days = [];

  void _changeMonth(DateTime value) {
    searchMonth = value;
    days = generateDays(searchMonth);
    setState(() {});
  }

  void _changeUser(UserModel value) {
    searchUser = value;
    setState(() {});
  }

  @override
  void initState() {
    _changeMonth(searchMonth);
    super.initState();
  }

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
                    onPressed: () async {
                      DateTime? selected = await pickerService.monthPicker(
                        context: context,
                        initialDate: searchMonth,
                      );
                      if (selected == null) return;
                      _changeMonth(selected);
                    },
                  ),
                  const SizedBox(width: 4),
                  CustomButtonSm(
                    icon: FluentIcons.contact,
                    labelText:
                        searchUser == null ? 'スタッフで検索' : '${searchUser?.name}',
                    labelColor: kWhiteColor,
                    backgroundColor: kCyanColor,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => SearchUserDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        searchUser: searchUser,
                        changeUser: _changeUser,
                      ),
                    ),
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
                days: days,
                works: works,
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchUserDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final UserModel? searchUser;
  final Function(UserModel) changeUser;

  const SearchUserDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.searchUser,
    required this.changeUser,
    super.key,
  });

  @override
  State<SearchUserDialog> createState() => _SearchUserDialogState();
}

class _SearchUserDialogState extends State<SearchUserDialog> {
  UserService userService = UserService();
  List<UserModel> users = [];

  void _init() async {
    users = await userService.selectListToUserIds(
      userIds: widget.homeProvider.currentGroup?.userIds ?? [],
    );
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'スタッフで検索',
        style: TextStyle(fontSize: 18),
      ),
      content: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kGrey300Color),
        ),
        height: 300,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserModel user = users[index];
            return CustomRadio(
              label: user.name,
              checked: widget.searchUser?.id == user.id,
              onChanged: (value) {
                widget.changeUser(user);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        CustomButtonSm(
          labelText: '閉じる',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
