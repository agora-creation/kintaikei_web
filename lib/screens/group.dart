import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_list_tile.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomListTile(
            label: 'グループ名',
            value: widget.homeProvider.currentGroup?.name ?? '',
            icon: FluentIcons.edit,
            onTap: () {},
          ),
          CustomListTile(
            label: 'ログインID',
            value: widget.homeProvider.currentGroup?.loginId ?? '',
            isFirst: false,
          ),
          CustomListTile(
            label: 'パスワード',
            value: '********',
            icon: FluentIcons.edit,
            onTap: () {},
            isFirst: false,
          ),
          const SizedBox(height: 16),
          LinkText(
            label: 'このグループを削除',
            color: kRedColor,
            onTap: () => showDialog(
              context: context,
              builder: (context) => DelGroupDialog(
                loginProvider: widget.loginProvider,
                homeProvider: widget.homeProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DelGroupDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const DelGroupDialog({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<DelGroupDialog> createState() => _DelGroupDialogState();
}

class _DelGroupDialogState extends State<DelGroupDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'グループを削除',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('以下のグループを削除しますか？'),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'グループ名',
              child: DisabledBox(widget.homeProvider.currentGroup?.name ?? ''),
            ),
          ],
        ),
      ),
      actions: [
        CustomButtonSm(
          labelText: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
        CustomButtonSm(
          labelText: '削除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            // await widget.loginProvider.logout();
            // if (!mounted) return;
            // Navigator.pushReplacement(
            //   context,
            //   FluentPageRoute(
            //     builder: (context) => const LoginScreen(),
            //   ),
            // );
          },
        ),
      ],
    );
  }
}
