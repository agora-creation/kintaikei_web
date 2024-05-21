import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/plan.dart';
import 'package:kintaikei_web/models/plan_shift.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/plan_shift.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/services/plan.dart';
import 'package:kintaikei_web/services/plan_shift.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_checkbox.dart';
import 'package:kintaikei_web/widgets/custom_shift.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';
import 'package:kintaikei_web/widgets/link_text.dart';
import 'package:kintaikei_web/widgets/repeat_select_form.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanShiftScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const PlanShiftScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<PlanShiftScreen> createState() => _PlanShiftScreenState();
}

class _PlanShiftScreenState extends State<PlanShiftScreen> {
  PlanService planService = PlanService();
  PlanShiftService planShiftService = PlanShiftService();
  UserService userService = UserService();
  List<UserModel> users = [];
  List<sfc.CalendarResource> resourceColl = [];

  void _init() async {
    users = await userService.selectListToUserIds(
      userIds: widget.homeProvider.currentGroup?.userIds ?? [],
    );
    if (users.isNotEmpty) {
      for (UserModel user in users) {
        resourceColl.add(sfc.CalendarResource(
          displayName: user.name,
          id: user.id,
          color: kGrey300Color,
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var streamPlan = planService.streamList(
      companyId: widget.loginProvider.company?.id,
      groupId: widget.homeProvider.currentGroup?.id,
    );
    var streamPlanShift = planShiftService.streamList(
      companyId: widget.loginProvider.company?.id,
      groupId: widget.homeProvider.currentGroup?.id,
    );
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(16),
      child: StreamBuilder2<QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>>(
        streams: StreamTuple2(streamPlan!, streamPlanShift!),
        builder: (context, snapshot) {
          List<sfc.Appointment> source = planService.convertListAppointment(
            snapshot.snapshot1,
            shift: true,
            users: users,
          );
          if (snapshot.snapshot2.hasData) {
            source.addAll(planShiftService.convertListAppointment(
              snapshot.snapshot2,
            ));
          }
          return CustomShift(
            dataSource: _ShiftDataSource(source, resourceColl),
            onTap: (sfc.CalendarTapDetails details) {
              sfc.CalendarElement element = details.targetElement;
              switch (element) {
                case sfc.CalendarElement.appointment:
                case sfc.CalendarElement.agenda:
                  sfc.Appointment appointmentDetails = details.appointments![0];
                  String type = appointmentDetails.notes ?? '';
                  if (type == 'plan') {
                    showDialog(
                      context: context,
                      builder: (context) => PlanDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        planId: '${appointmentDetails.id}',
                      ),
                    );
                  } else if (type == 'planShift') {
                    showDialog(
                      context: context,
                      builder: (context) => ModPlanShiftDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        planShiftId: '${appointmentDetails.id}',
                        selectedDate: details.date ?? DateTime.now(),
                      ),
                    );
                  }
                  break;
                case sfc.CalendarElement.calendarCell:
                  final userId = details.resource?.id;
                  if (userId == null) return;
                  showDialog(
                    context: context,
                    builder: (context) => AddPlanShiftDialog(
                      loginProvider: widget.loginProvider,
                      homeProvider: widget.homeProvider,
                      users: users,
                      userId: '$userId',
                      selectedDate: details.date ?? DateTime.now(),
                    ),
                  );
                  break;
                default:
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

class _ShiftDataSource extends sfc.CalendarDataSource {
  _ShiftDataSource(
    List<sfc.Appointment> source,
    List<sfc.CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }
}

class PlanDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planId;

  const PlanDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planId,
    super.key,
  });

  @override
  State<PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<PlanDialog> {
  PlanService planService = PlanService();
  PlanModel? plan;

  void _init() async {
    PlanModel? tmpPlan = await planService.selectDataToId(id: widget.planId);
    if (tmpPlan == null) {
      if (!mounted) return;
      showMessage(context, '予定データの取得に失敗しました', false);
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    plan = tmpPlan;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: plan?.color,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                plan?.subject ?? '',
                style: const TextStyle(color: kWhiteColor),
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '予定期間',
              child: DisabledBox(
                '${convertDateText('yyyy/MM/dd HH:mm', plan?.startedAt)}〜${convertDateText('yyyy/MM/dd HH:mm', plan?.endedAt)}',
              ),
            ),
          ],
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

class AddPlanShiftDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final List<UserModel> users;
  final String userId;
  final DateTime selectedDate;

  const AddPlanShiftDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.users,
    required this.userId,
    required this.selectedDate,
    super.key,
  });

  @override
  State<AddPlanShiftDialog> createState() => _AddPlanShiftDialogState();
}

class _AddPlanShiftDialogState extends State<AddPlanShiftDialog> {
  DateTimePickerService pickerService = DateTimePickerService();
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
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 650,
      ),
      title: const Text(
        '勤務予定を新しく追加',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                startedOnTap: () async => await pickerService.boardPicker(
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
                endedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: endedAt,
                  title: '勤務予定終了日時を選択',
                  onChanged: (value) {
                    setState(() {
                      endedAt = value;
                    });
                  },
                ),
                viewAllDay: true,
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
                          child:
                              value == 0 ? const Text('無効') : Text('$value分前'),
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
    );
  }
}

class ModPlanShiftDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planShiftId;
  final DateTime selectedDate;

  const ModPlanShiftDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planShiftId,
    required this.selectedDate,
    super.key,
  });

  @override
  State<ModPlanShiftDialog> createState() => _ModPlanShiftDialogState();
}

class _ModPlanShiftDialogState extends State<ModPlanShiftDialog> {
  PlanShiftService planShiftService = PlanShiftService();
  DateTimePickerService pickerService = DateTimePickerService();
  PlanShiftModel? planShift;
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool allDay = false;
  bool repeat = false;
  String repeatInterval = kRepeatIntervals.first;
  List<String> repeatWeeks = [];
  int alertMinute = kAlertMinutes[1];

  void _init() async {
    PlanShiftModel? tmpPlanShift = await planShiftService.selectDataToId(
      id: widget.planShiftId,
    );
    if (tmpPlanShift == null) {
      if (!mounted) return;
      showMessage(context, '勤務予定データの取得に失敗しました', false);
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    planShift = tmpPlanShift;
    startedAt = tmpPlanShift.startedAt;
    endedAt = tmpPlanShift.endedAt;
    allDay = tmpPlanShift.allDay;
    repeat = tmpPlanShift.repeat;
    repeatInterval = tmpPlanShift.repeatInterval;
    repeatWeeks = tmpPlanShift.repeatWeeks;
    alertMinute = tmpPlanShift.alertMinute;
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
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 650,
      ),
      title: const Text(
        '勤務予定を編集',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '働くスタッフ',
              child: Container(
                color: kGrey300Color,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Text(planShift?.userName ?? ''),
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '働く時間帯を設定',
              child: DatetimeRangeForm(
                startedAt: startedAt,
                startedOnTap: () async => await pickerService.boardPicker(
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
                endedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: endedAt,
                  title: '勤務予定終了日時を選択',
                  onChanged: (value) {
                    setState(() {
                      endedAt = value;
                    });
                  },
                ),
                viewAllDay: true,
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
                          child:
                              value == 0 ? const Text('無効') : Text('$value分前'),
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: LinkText(
                label: 'この勤務予定を削除する',
                color: kRedColor,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => DelPlanShiftDialog(
                    loginProvider: widget.loginProvider,
                    homeProvider: widget.homeProvider,
                    planShift: planShift,
                    selectedDate: widget.selectedDate,
                  ),
                ),
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
          labelText: '上記内容で保存する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await planShiftProvider.update(
              id: widget.planShiftId,
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
            showMessage(context, '勤務予定を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class DelPlanShiftDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final PlanShiftModel? planShift;
  final DateTime selectedDate;

  const DelPlanShiftDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planShift,
    required this.selectedDate,
    super.key,
  });

  @override
  State<DelPlanShiftDialog> createState() => _DelPlanShiftDialogState();
}

class _DelPlanShiftDialogState extends State<DelPlanShiftDialog> {
  bool isAllDelete = false;

  @override
  Widget build(BuildContext context) {
    final planShiftProvider = Provider.of<PlanShiftProvider>(context);
    return ContentDialog(
      title: const Text(
        '勤務予定を削除',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.planShift?.repeat == true
              ? [
                  const Text('以下の削除タイプを選んでください。'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RadioButton(
                      checked: isAllDelete == false,
                      onChanged: (value) {
                        setState(() {
                          isAllDelete = false;
                        });
                      },
                      content: Text(
                        '${convertDateText('yyyy年MM月dd日', widget.selectedDate)}分の勤務予定のみ削除',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RadioButton(
                      checked: isAllDelete == true,
                      onChanged: (value) {
                        setState(() {
                          isAllDelete = true;
                        });
                      },
                      content: const Text('すべての繰り返し勤務予定を削除'),
                    ),
                  ),
                ]
              : [
                  const Text('この勤務予定を削除しますか？'),
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
          labelText: '削除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await planShiftProvider.delete(
              planShift: widget.planShift,
              isAllDelete: isAllDelete,
              date: widget.selectedDate,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '勤務予定を削除しました', true);
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
