import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/widgets/custom_icon_button.dart';

class ApplyScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const ApplyScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              CustomIconButton(
                icon: FluentIcons.add,
                iconColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
