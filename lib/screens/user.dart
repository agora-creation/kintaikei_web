import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';

class UserScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const UserScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(16),
    );
  }
}
