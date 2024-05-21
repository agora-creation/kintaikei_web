import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/plan.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/plan.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/services/plan.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/custom_timeline.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:kintaikei_web/widgets/link_text.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanTimelineScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final DateTime selectedDate;

  const PlanTimelineScreen({
    required this.loginProvider,
    required this.homeProvider,
    required this.selectedDate,
    super.key,
  });

  @override
  State<PlanTimelineScreen> createState() => _PlanTimelineScreenState();
}

class _PlanTimelineScreenState extends State<PlanTimelineScreen> {
  PlanService planService = PlanService();

  @override
  Widget build(BuildContext context) {
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
              Text(
                convertDateText('yyyy年MM月dd日(E)', widget.selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              Container(),
            ],
          ),
        ),
      ),
      content: Container(
        color: kWhiteColor,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: planService.streamList(
            companyId: widget.loginProvider.company?.id,
            groupId: widget.homeProvider.currentGroup?.id,
            selectedDate: widget.selectedDate,
          ),
          builder: (context, snapshot) {
            List<sfc.Appointment> appointments =
                planService.convertListAppointment(
              snapshot,
            );
            return CustomTimeline(
              initialDisplayDate: widget.selectedDate,
              dataSource: _DataSource(appointments),
              onTap: (sfc.CalendarTapDetails details) {
                sfc.CalendarElement element = details.targetElement;
                switch (element) {
                  case sfc.CalendarElement.appointment:
                  case sfc.CalendarElement.agenda:
                    sfc.Appointment appointmentDetails =
                        details.appointments![0];
                    showDialog(
                      context: context,
                      builder: (context) => ModPlanDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        planId: '${appointmentDetails.id}',
                      ),
                    );
                    break;
                  case sfc.CalendarElement.calendarCell:
                    showDialog(
                      context: context,
                      builder: (context) => AddPlanDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        date: details.date ?? DateTime.now(),
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
      ),
    );
  }
}

class _DataSource extends sfc.CalendarDataSource {
  _DataSource(List<sfc.Appointment> source) {
    appointments = source;
  }
}

class AddPlanDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final DateTime date;

  const AddPlanDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.date,
    super.key,
  });

  @override
  State<AddPlanDialog> createState() => _AddPlanDialogState();
}

class _AddPlanDialogState extends State<AddPlanDialog> {
  DateTimePickerService pickerService = DateTimePickerService();
  TextEditingController subjectController = TextEditingController();
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool allDay = false;
  Color color = kColors.first;
  int alertMinute = kAlertMinutes[1];

  void _init() async {
    startedAt = widget.date;
    endedAt = startedAt.add(const Duration(hours: 1));
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
    final planProvider = Provider.of<PlanProvider>(context);
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 650,
      ),
      title: const Text(
        '予定を新しく追加',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '件名',
              child: CustomTextBox(
                controller: subjectController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '予定時間帯を設定',
              child: DatetimeRangeForm(
                startedAt: startedAt,
                startedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: startedAt,
                  title: '予定開始日時を選択',
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
                  title: '予定終了日時を選択',
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
                    label: '色',
                    child: ComboBox<Color>(
                      isExpanded: true,
                      value: color,
                      items: kColors.map((value) {
                        return ComboBoxItem(
                          value: value,
                          child: Container(
                            color: value,
                            height: 25,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          color = value!;
                        });
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
            String? error = await planProvider.create(
              company: widget.loginProvider.company,
              group: widget.homeProvider.currentGroup,
              subject: subjectController.text,
              startedAt: startedAt,
              endedAt: endedAt,
              allDay: allDay,
              color: color,
              alertMinute: alertMinute,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '予定を追加しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ModPlanDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planId;

  const ModPlanDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planId,
    super.key,
  });

  @override
  State<ModPlanDialog> createState() => _ModPlanDialogState();
}

class _ModPlanDialogState extends State<ModPlanDialog> {
  PlanService planService = PlanService();
  DateTimePickerService pickerService = DateTimePickerService();
  TextEditingController subjectController = TextEditingController();
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool allDay = false;
  Color color = kColors.first;
  int alertMinute = kAlertMinutes[1];

  void _init() async {
    PlanModel? plan = await planService.selectDataToId(id: widget.planId);
    if (plan == null) {
      if (!mounted) return;
      showMessage(context, '予定データの取得に失敗しました', false);
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    subjectController.text = plan.subject;
    startedAt = plan.startedAt;
    endedAt = plan.endedAt;
    allDay = plan.allDay;
    color = plan.color;
    alertMinute = plan.alertMinute;
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
    final planProvider = Provider.of<PlanProvider>(context);
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 650,
      ),
      title: const Text(
        '予定を編集',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '件名',
              child: CustomTextBox(
                controller: subjectController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '予定時間帯を設定',
              child: DatetimeRangeForm(
                startedAt: startedAt,
                startedOnTap: () async => await pickerService.boardPicker(
                  context: context,
                  init: startedAt,
                  title: '予定開始日時を選択',
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
                  title: '予定終了日時を選択',
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
                    label: '色',
                    child: ComboBox<Color>(
                      isExpanded: true,
                      value: color,
                      items: kColors.map((value) {
                        return ComboBoxItem(
                          value: value,
                          child: Container(
                            color: value,
                            height: 25,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          color = value!;
                        });
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
                label: 'この予定を削除する',
                color: kRedColor,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => DelPlanDialog(
                    loginProvider: widget.loginProvider,
                    homeProvider: widget.homeProvider,
                    planId: widget.planId,
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
            String? error = await planProvider.update(
              id: widget.planId,
              subject: subjectController.text,
              startedAt: startedAt,
              endedAt: endedAt,
              allDay: allDay,
              color: color,
              alertMinute: alertMinute,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '予定を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class DelPlanDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planId;

  const DelPlanDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planId,
    super.key,
  });

  @override
  State<DelPlanDialog> createState() => _DelPlanDialogState();
}

class _DelPlanDialogState extends State<DelPlanDialog> {
  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    return ContentDialog(
      title: const Text(
        '予定を削除',
        style: TextStyle(fontSize: 18),
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('この予定を削除しますか？'),
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
            String? error = await planProvider.delete(
              id: widget.planId,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '予定を削除しました', true);
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
