import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class DisabledBox extends StatelessWidget {
  final String value;
  final Color? labelColor;
  final Color? backgroundColor;

  const DisabledBox(
    this.value, {
    this.labelColor = kBlackColor,
    this.backgroundColor = kGrey300Color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Text(
        value,
        style: TextStyle(color: labelColor),
      ),
    );
  }
}
