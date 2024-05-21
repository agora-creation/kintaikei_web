import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/widgets/work_list.dart';
import 'package:kintaikei_web/widgets/work_total_list.dart';

class WorkTable extends StatefulWidget {
  final List<DateTime> days;
  final List<WorkModel> works;

  const WorkTable({
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
                                onPressed: () {},
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
