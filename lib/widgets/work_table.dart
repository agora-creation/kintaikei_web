import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';

class WorkTable extends StatefulWidget {
  final DateTime searchMonth;

  const WorkTable({
    required this.searchMonth,
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
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kGrey300Color),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Text('日付'),
                  Expanded(
                    child: Row(
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
                ],
              ),
            ),
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(convertDateText('dd (E)', day)),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('勤務'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('00:00'),
                                  const Text('勤務'),
                                ],
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
}
