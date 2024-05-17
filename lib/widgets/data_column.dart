import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class DataColumn extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Alignment alignment;

  const DataColumn(
    this.label, {
    this.labelColor = kBlackColor,
    this.backgroundColor = Colors.transparent,
    this.alignment = Alignment.centerLeft,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(8),
      alignment: alignment,
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
