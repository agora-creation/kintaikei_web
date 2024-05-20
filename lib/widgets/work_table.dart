import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/widgets/work_list.dart';

class WorkTable extends StatefulWidget {
  final DateTime searchMonth;
  final List<WorkModel> works;

  const WorkTable({
    required this.searchMonth,
    required this.works,
    super.key,
  });

  @override
  State<WorkTable> createState() => _WorkTableState();
}

class _WorkTableState extends State<WorkTable> {
  List<DateTime> days = [];

  @override
  void initState() {
    days = generateDays(widget.searchMonth);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: days.length,
                itemBuilder: (context, index) {
                  DateTime day = days[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: BorderSide(color: kGrey300Color),
                      ),
                      color: kGrey300Color.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: kMainColor,
                          radius: 24,
                          child: Text(
                            convertDateText('dd(E)', day),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              WorkList(
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
