import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class DataColumn extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;

  const DataColumn(
    this.label, {
    this.labelColor = kBlackColor,
    this.backgroundColor = Colors.transparent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(color: labelColor),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
