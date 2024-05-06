import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/plan_shift.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/plan_shift.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/services/plan_shift.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:kintaikei_web/widgets/link_text.dart';
import 'package:kintaikei_web/widgets/repeat_select_form.dart';
import 'package:provider/provider.dart';

class PlanShiftModScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planShiftId;
  final DateTime selectedDate;

  const PlanShiftModScreen({
    required this.loginProvider,
    required this.homeProvider,
    required this.planShiftId,
    required this.selectedDate,
    super.key,
  });

  @override
  State<PlanShiftModScreen> createState() => _PlanShiftModScreenState();
}

class _PlanShiftModScreenState extends State<PlanShiftModScreen> {
  PlanShiftService planShiftService = PlanShiftService();
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
                '勤務予定を編集',
                style: TextStyle(fontSize: 16),
              ),
              CustomButtonSm(
                labelText: '下記内容を保存する',
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
                const SizedBox(height: 16),
                LinkText(
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
              ],
            ),
          ),
        ),
      ),
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
