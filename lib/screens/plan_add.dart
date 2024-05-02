import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/services/date_time_picker.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/datetime_range_form.dart';

class PlanAddScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final DateTime date;

  const PlanAddScreen({
    required this.loginProvider,
    required this.homeProvider,
    required this.date,
    super.key,
  });

  @override
  State<PlanAddScreen> createState() => _PlanAddScreenState();
}

class _PlanAddScreenState extends State<PlanAddScreen> {
  TextEditingController subjectController = TextEditingController();
  DateTime startedAt = DateTime.now();
  DateTime endedAt = DateTime.now();
  bool allDay = false;
  TextEditingController memoController = TextEditingController();
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
                '予定を新しく追加',
                style: TextStyle(fontSize: 16),
              ),
              CustomButtonSm(
                labelText: '入力内容を保存',
                labelColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () async {},
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
                    startedOnTap: () async =>
                        await DateTimePickerService().picker(
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
                    endedOnTap: () async =>
                        await DateTimePickerService().picker(
                      context: context,
                      init: endedAt,
                      title: '予定終了日時を選択',
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
                  header: Text('詳細設定'),
                  content: Column(
                    children: [
                      InfoLabel(
                        label: 'メモ',
                        child: CustomTextBox(
                          controller: memoController,
                          placeholder: '',
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
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