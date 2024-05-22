import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/work.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';
import 'package:kintaikei_web/widgets/link_text.dart';
import 'package:kintaikei_web/widgets/work_list.dart';
import 'package:kintaikei_web/widgets/work_total_list.dart';
import 'package:provider/provider.dart';

class WorkTable extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final List<DateTime> days;
  final List<WorkModel> works;

  const WorkTable({
    required this.loginProvider,
    required this.homeProvider,
    required this.days,
    required this.works,
    super.key,
  });

  @override
  State<WorkTable> createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  @override
  Widget build(BuildContext context) {
    Map workCount = {};
    int totalDays = 0;
    String totalTime = '00:00';
    if (widget.works.isNotEmpty) {
      for (WorkModel work in widget.works) {
        String dayKey = convertDateText(
          'yyyy-MM-dd',
          work.startedAt,
        );
        workCount[dayKey] = '';
        totalTime = addTime(totalTime, work.totalTime());
      }
      totalDays = workCount.length;
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kGrey300Color),
        ),
        child: Column(
          children: [
            _workHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.days.length,
                itemBuilder: (context, index) {
                  DateTime day = widget.days[index];
                  List<WorkModel> dayWorks = [];
                  if (widget.works.isNotEmpty) {
                    for (WorkModel work in widget.works) {
                      String dayKey = convertDateText(
                        'yyyy-MM-dd',
                        work.startedAt,
                      );
                      if (day == DateTime.parse(dayKey)) {
                        dayWorks.add(work);
                      }
                    }
                  }
                  return Container(
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: BorderSide(color: kGrey300Color),
                      ),
                      color: dayWorks.isNotEmpty
                          ? kWhiteColor
                          : kGrey300Color.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: convertDateText('E', day) == '土'
                              ? kLightBlueColor.withOpacity(0.3)
                              : convertDateText('E', day) == '日'
                                  ? kDeepOrangeColor.withOpacity(0.3)
                                  : Colors.transparent,
                          radius: 24,
                          child: Text(
                            convertDateText('dd(E)', day),
                            style: const TextStyle(
                              color: kBlackColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: dayWorks.map((work) {
                              return WorkList(
                                work: work,
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => ModWorkDialog(
                                    loginProvider: widget.loginProvider,
                                    homeProvider: widget.homeProvider,
                                    work: work,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            WorkTotalList(
              totalDays: totalDays,
              totalTime: totalTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _workHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kGrey300Color),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: kWhiteColor,
            radius: 24,
            child: Text(
              '日付',
              style: TextStyle(
                color: kBlackColor,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('出勤時間'),
                  Text('退勤時間'),
                  Text('休憩時間'),
                  Text('勤務時間'),
                  Text('ステータス'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModWorkDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final WorkModel work;

  const ModWorkDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.work,
    super.key,
  });

  @override
  State<ModWorkDialog> createState() => _ModWorkDialogState();
}

class _ModWorkDialogState extends State<ModWorkDialog> {
  DateTimePickerService pickerService = DateTimePickerService();
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();

  void _init() async {
    startedAt = widget.work.startedAt;
    endedAt = widget.work.endedAt;
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
        '勤怠打刻を編集',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: '勤務スタッフ',
              child: DisabledBox(widget.work.userName),
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: LinkText(
                label: 'この勤怠打刻を削除する',
                color: kRedColor,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => DelWorkDialog(
                    loginProvider: widget.loginProvider,
                    homeProvider: widget.homeProvider,
                    work: widget.work,
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
            String? error = await workProvider.update(
              work: widget.work,
              startedAt: startedAt,
              endedAt: endedAt,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '勤怠打刻を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class DelWorkDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final WorkModel work;

  const DelWorkDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.work,
    super.key,
  });

  @override
  State<DelWorkDialog> createState() => _DelWorkDialogState();
}

class _DelWorkDialogState extends State<DelWorkDialog> {
  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    return ContentDialog(
      title: const Text(
        '勤怠打刻を削除',
        style: TextStyle(fontSize: 18),
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('この勤怠打刻を削除しますか？'),
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
            String? error = await workProvider.delete(
              work: widget.work,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '勤怠打刻を削除しました', true);
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
