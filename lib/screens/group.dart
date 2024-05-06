import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/link_text.dart';

class GroupScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const GroupScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
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
              CustomButtonSm(
                icon: FluentIcons.save,
                labelText: '下記内容で保存する',
                labelColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          InfoLabel(
            label: 'グループ名',
            child: CustomTextBox(
              controller: TextEditingController(),
              placeholder: '',
              keyboardType: TextInputType.text,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          InfoLabel(
            label: 'ログインID',
            child: CustomTextBox(
              controller: TextEditingController(),
              placeholder: '',
              keyboardType: TextInputType.text,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          InfoLabel(
            label: 'パスワード',
            child: CustomTextBox(
              controller: TextEditingController(),
              placeholder: '',
              keyboardType: TextInputType.text,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 16),
          LinkText(
            label: 'このグループを削除する',
            color: kRedColor,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
