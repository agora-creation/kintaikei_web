import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/home.dart';
import 'package:kintaikei_web/widgets/custom_button.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return ScaffoldPage(
      content: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Column(
                children: [
                  Text(
                    '勤怠計',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    '勤怠打刻サービス : 管理画面',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kGrey300Color),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextBox(
                      controller: loginIdController,
                      placeholder: 'ログインID',
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    CustomTextBox(
                      controller: passwordController,
                      placeholder: 'パスワード',
                      keyboardType: TextInputType.visiblePassword,
                      maxLines: 1,
                      obscureText: obscureText,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'ログイン',
                      labelColor: kWhiteColor,
                      backgroundColor: kBlueColor,
                      onPressed: () async {
                        String? error = await loginProvider.login(
                          loginId: loginIdController.text,
                          password: passwordController.text,
                        );
                        if (error != null) {
                          if (!mounted) return;
                          showMessage(context, error, false);
                          return;
                        }
                        await loginProvider.reloadData();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          FluentPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
