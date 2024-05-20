import 'package:fluent_ui/fluent_ui.dart';

class WorkList extends StatelessWidget {
  final Function() onPressed;

  const WorkList({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('00:00'),
          Text('00:00'),
          Text('00:00'),
          Text('00:00'),
          Text('勤務'),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
