import 'package:fluent_ui/fluent_ui.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Function()? onPressed;

  const CustomButton({
    required this.label,
    required this.labelColor,
    required this.backgroundColor,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: ButtonState.all(backgroundColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
