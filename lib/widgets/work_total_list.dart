import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class WorkTotalList extends StatelessWidget {
  final int totalDays;
  final String totalTime;

  const WorkTotalList({
    required this.totalDays,
    required this.totalTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: kGrey300Color),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(150),
              1: IntrinsicColumnWidth(),
            },
            border: const TableBorder(
              left: BorderSide(color: kGrey300Color),
              verticalInside: BorderSide(color: kGrey300Color),
              horizontalInside: BorderSide(color: kGrey300Color),
            ),
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '合計勤務日数',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      totalDays.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '合計勤務時間',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      totalTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
