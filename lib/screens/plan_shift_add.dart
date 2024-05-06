import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/plan_shift.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_checkbox.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:kintaikei_web/widgets/repeat_select_form.dart';
import 'package:provider/provider.dart';

class PlanShiftAddScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final List<UserModel> users;
  final String userId;
  final DateTime selectedDate;

  const PlanShiftAddScreen({
    required this.loginProvider,
    required this.homeProvider,
    required this.users,
    required this.userId,
    required this.selectedDate,
    super.key,
  });

  @override
  State<PlanShiftAddScreen> createState() => _PlanShiftAddScreenState();
}

class _PlanShiftAddScreenState extends State<PlanShiftAddScreen> {
  List<UserModel> selectedUsers = [];
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool allDay = false;
  bool repeat = false;
  String repeatInterval = kRepeatIntervals.first;
  List<String> repeatWeeks = [];
  int alertMinute = kAlertMinutes[1];

  void _init() async {
    selectedUsers = [widget.users.singleWhere((e) => e.id == widget.userId)];
    startedAt = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      8,
      0,
      0,
    );
    endedAt = startedAt.add(const Duration(hours: 8));
    setState(() {});
  }

  void _allDayChange(bool? value) {
    allDay = value ?? false;
    if (allDay) {
      startedAt = DateTime(
        startedAt.year,
        startedAt.month,
        startedAt.day,
        0,
        0,
        0,
      );
      endedAt = DateTime(
        endedAt.year,
        endedAt.month,
        endedAt.day,
        23,
        59,
        59,
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final planShiftProvider = Provider.of<PlanShiftProvider>(context);
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Container(
        decoration: kHeaderDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '勤務予定を新しく追加',
                style: TextStyle(fontSize: 16),
              ),
              CustomButtonSm(
                labelText: '下記内容を追加する',
                labelColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () async {
                  String? error = await planShiftProvider.create(
                    company: widget.loginProvider.company,
                    group: widget.homeProvider.currentGroup,
                    users: selectedUsers,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    allDay: allDay,
                    repeat: repeat,
                    repeatInterval: repeatInterval,
                    repeatWeeks: repeatWeeks,
                    alertMinute: alertMinute,
                  );
                  if (error != null) {
                    if (!mounted) return;
                    showMessage(context, error, false);
                    return;
                  }
                  if (!mounted) return;
                  showMessage(context, '勤務予定を追加しました', true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      content: Container(
        color: kWhiteColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 200,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: '働くスタッフを選択(複数可)',
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: kGrey300Color),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.users.length,
                      itemBuilder: (context, index) {
                        UserModel user = widget.users[index];
                        return CustomCheckbox(
                          label: user.name,
                          checked: selectedUsers.contains(user),
                          onChanged: (value) {
                            if (selectedUsers.contains(user)) {
                              selectedUsers.remove(user);
                            } else {
                              selectedUsers.add(user);
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InfoLabel(
                  label: '働く時間帯を設定',
                  child: DatetimeRangeForm(
                    startedAt: startedAt,
                    startedOnTap: () async =>
                        await DateTimePickerService().picker(
                      context: context,
                      init: startedAt,
                      title: '勤務予定開始日時を選択',
                      onChanged: (value) {
                        setState(() {
                          startedAt = value;
                          endedAt = startedAt.add(const Duration(hours: 1));
                        });
                      },
                    ),
                    endedAt: endedAt,
                    endedOnTap: () async =>
                        await DateTimePickerService().picker(
                      context: context,
                      init: endedAt,
                      title: '勤務予定終了日時を選択',
                      onChanged: (value) {
                        setState(() {
                          endedAt = value;
                        });
                      },
                    ),
                    allDay: allDay,
                    allDayOnChanged: _allDayChange,
                  ),
                ),
                const SizedBox(height: 8),
                Expander(
                  header: const Text('詳細設定'),
                  content: Column(
                    children: [
                      InfoLabel(
                        label: '繰り返し設定',
                        child: RepeatSelectForm(
                          repeat: repeat,
                          repeatOnChanged: (value) {
                            setState(() {
                              repeat = value!;
                            });
                          },
                          interval: repeatInterval,
                          intervalOnChanged: (value) {
                            setState(() {
                              repeatInterval = value;
                            });
                          },
                          weeks: repeatWeeks,
                          weeksOnChanged: (value) {
                            if (repeatWeeks.contains(value)) {
                              repeatWeeks.remove(value);
                            } else {
                              repeatWeeks.add(value);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      InfoLabel(
                        label: '事前アラート通知',
                        child: ComboBox<int>(
                          isExpanded: true,
                          value: alertMinute,
                          items: kAlertMinutes.map((value) {
                            return ComboBoxItem(
                              value: value,
                              child: value == 0
                                  ? const Text('無効')
                                  : Text('$value分前'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              alertMinute = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
