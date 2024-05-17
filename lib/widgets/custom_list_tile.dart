import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';

class CustomListTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Function()? onTap;
  final bool isFirst;

  const CustomListTile({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.isFirst = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isFirst
              ? const Border.symmetric(
                  horizontal: BorderSide(color: kGrey300Color),
                )
              : const Border(bottom: BorderSide(color: kGrey300Color)),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: kGreyColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            icon != null ? Icon(icon) : Container(),
          ],
        ),
      ),
    );
  }
}
