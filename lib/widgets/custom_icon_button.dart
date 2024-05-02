import 'package:fluent_ui/fluent_ui.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Function()? onPressed;

  const CustomIconButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: iconColor,
      ),
      style: ButtonStyle(
        backgroundColor: ButtonState.all(backgroundColor),
        padding: ButtonState.all(const EdgeInsets.all(12)),
      ),
      onPressed: onPressed,
    );
  }
}
