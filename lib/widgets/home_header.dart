import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/company.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_icon_button.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';

class HomeHeader extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const HomeHeader({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  void _init() async {
    await widget.homeProvider.init(
      widget.loginProvider.groups.first,
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.loginProvider.company?.name ?? '',
                style: const TextStyle(
                  color: kWhiteColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ComboBox<CompanyGroupModel>(
                  value: widget.homeProvider.currentGroup,
                  items: widget.loginProvider.groups.map((e) {
                    return ComboBoxItem(
                      value: e,
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.homeProvider.currentGroupChange(value);
                  },
                  popupColor: kWhiteColor,
                ),
              ),
              const SizedBox(width: 2),
              CustomIconButton(
                icon: FluentIcons.settings,
                iconColor: kWhiteColor,
                backgroundColor: kGreyColor,
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ModGroupDialog(
                    loginProvider: widget.loginProvider,
                    homeProvider: widget.homeProvider,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              CustomIconButton(
                icon: FluentIcons.add,
                iconColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AddGroupDialog(
                    loginProvider: widget.loginProvider,
                    homeProvider: widget.homeProvider,
                  ),
                ),
              ),
            ],
          ),
          CustomButtonSm(
            icon: FluentIcons.emi,
            labelText: '会社情報',
            labelColor: kBlackColor,
            backgroundColor: kWhiteColor,
            onPressed: () => Navigator.push(
              context,
              FluentPageRoute(
                builder: (context) => CompanyScreen(
                  loginProvider: widget.loginProvider,
                  homeProvider: widget.homeProvider,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddGroupDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const AddGroupDialog({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'グループを追加',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: 'グループ名',
              child: CustomTextBox(
                controller: nameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'ログインID',
              child: DisabledBox(
                '${widget.loginProvider.company?.loginId}-${widget.loginProvider.groups.length}',
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'パスワード',
              child: CustomTextBox(
                controller: passwordController,
                placeholder: '',
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                obscureText: true,
              ),
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
          labelText: '上記内容で追加する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.homeProvider.groupCreate(
              company: widget.loginProvider.company,
              name: nameController.text,
              index: widget.loginProvider.groups.length,
              password: passwordController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await widget.loginProvider.reloadData();
            widget.homeProvider.currentGroupChange(
              widget.loginProvider.groups.last,
            );
            if (!mounted) return;
            showMessage(context, 'グループを追加しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ModGroupDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const ModGroupDialog({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<ModGroupDialog> createState() => _ModGroupDialogState();
}

class _ModGroupDialogState extends State<ModGroupDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.homeProvider.currentGroup?.name ?? '';
    passwordController.text = widget.homeProvider.currentGroup?.password ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'グループ情報を編集',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: 'グループ名',
              child: CustomTextBox(
                controller: nameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'ログインID',
              child: DisabledBox(
                '${widget.homeProvider.currentGroup?.loginId}',
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'パスワード',
              child: CustomTextBox(
                controller: passwordController,
                placeholder: '',
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                obscureText: true,
              ),
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
          labelText: '上記内容で保存する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.homeProvider.groupUpdate(
              group: widget.homeProvider.currentGroup,
              name: nameController.text,
              password: passwordController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await widget.loginProvider.reloadData();
            widget.homeProvider.currentGroupChange(
              widget.homeProvider.currentGroup,
            );
            if (!mounted) return;
            showMessage(context, 'グループ情報を変更しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
