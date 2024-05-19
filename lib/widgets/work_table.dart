import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class WorkTable extends StatelessWidget {
  const WorkTable({super.key});

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
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kGrey300Color),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('日付'),
                  Text('出勤時間'),
                  Text('退勤時間'),
                  Text('休憩時間'),
                  Text('勤務時間'),
                  Text('ステータス'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kGrey300Color),
                      ),
                      color: kGrey300Color.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('01(水)'),
                        Text('00:00'),
                        Text('00:00'),
                        Text('00:00'),
                        Text('00:00'),
                        Text('勤務'),
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
