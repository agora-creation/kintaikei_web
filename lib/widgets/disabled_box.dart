import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class DisabledBox extends StatelessWidget {
  final String value;

  const DisabledBox(
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kGrey300Color,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Text(value),
    );
  }
}
