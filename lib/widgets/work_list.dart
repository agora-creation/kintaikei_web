import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/work.dart';

class WorkList extends StatelessWidget {
  final WorkModel work;
  final Function() onPressed;

  const WorkList({
    required this.work,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(work.startedTime()),
          Text(work.endedTime()),
          Text(work.breakTime()),
          Text(work.totalTime()),
          const Text('勤務'),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
