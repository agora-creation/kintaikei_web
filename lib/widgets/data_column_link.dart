import 'package:fluent_ui/fluent_ui.dart';

class DataColumnLink extends StatelessWidget {
  final String label;
  final Color color;
  final Alignment alignment;
  final Function()? onTap;

  const DataColumnLink({
    required this.label,
    required this.color,
    this.alignment = Alignment.centerLeft,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: alignment,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color),
            ),
          ),
          child: Text(
            label,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: color),
          ),
        ),
      ),
    );
  }
}
