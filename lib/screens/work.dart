import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/work.dart';
import 'package:kintaikei_web/screens/work_table.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/services/work.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_radio.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:provider/provider.dart';

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
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AddWorkDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        searchUser: searchUser,
                      ),
                    ),
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
                loginProvider: widget.loginProvider,
                homeProvider: widget.homeProvider,
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

class AddWorkDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final UserModel? searchUser;

  const AddWorkDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.searchUser,
    super.key,
  });

  @override
  State<AddWorkDialog> createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends State<AddWorkDialog> {
  DateTimePickerService pickerService = DateTimePickerService();
  UserService userService = UserService();
  List<UserModel> users = [];
  UserModel? selectedUser;
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();

  void _init() async {
    users = await userService.selectListToUserIds(
      userIds: widget.homeProvider.currentGroup?.userIds ?? [],
    );
    selectedUser = widget.searchUser;
    startedAt = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      8,
      0,
      0,
    );
    endedAt = startedAt.add(const Duration(hours: 8));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 650,
      ),
      title: const Text(
        '勤怠打刻を手入力で追加',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '勤務スタッフ',
              child: ComboBox<UserModel?>(
                isExpanded: true,
                value: selectedUser,
                items: users.map((user) {
                  return ComboBoxItem(
                    value: user,
                    child: Text(user.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUser = value;
                  });
                },
                placeholder: const Text(
                  '選択してください',
                  style: TextStyle(color: kGreyColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '出勤時間 ～ 退勤時間',
              child: DatetimeRangeForm(
                startedAt: startedAt,
                startedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: startedAt,
                  title: '出勤時間を選択',
                  onChanged: (value) {
                    setState(() {
                      startedAt = value;
                      endedAt = startedAt.add(const Duration(hours: 1));
                    });
                  },
                ),
                endedAt: endedAt,
                endedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: endedAt,
                  title: '退勤時間を選択',
                  onChanged: (value) {
                    setState(() {
                      endedAt = value;
                    });
                  },
                ),
                viewAllDay: false,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButtonSm(
          labelText: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
        CustomButtonSm(
          labelText: '上記内容で追加する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await workProvider.create(
              group: widget.homeProvider.currentGroup,
              user: selectedUser,
              startedAt: startedAt,
              endedAt: endedAt,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '勤怠打刻を追加しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
