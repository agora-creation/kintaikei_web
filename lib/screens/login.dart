import 'package:flutter/material.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/home.dart';
import 'package:kintaikei_web/widgets/custom_button.dart';
import 'package:kintaikei_web/widgets/custom_text_form_field.dart';
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
    return Scaffold(
      body: Center(
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
                    CustomTextFormField(
                      controller: loginIdController,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      label: 'ログインID',
                      color: kBlackColor,
                      prefix: Icons.business,
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: passwordController,
                      obscureText: obscureText,
                      textInputType: TextInputType.visiblePassword,
                      maxLines: 1,
                      label: 'パスワード',
                      color: kBlackColor,
                      prefix: Icons.password,
                      suffix:
                          obscureText ? Icons.visibility_off : Icons.visibility,
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    loginIdController.text != '' &&
                            passwordController.text != ''
                        ? CustomButton(
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
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          )
                        : const CustomButton(
                            label: 'ログイン',
                            labelColor: kWhiteColor,
                            backgroundColor: kGreyColor,
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
