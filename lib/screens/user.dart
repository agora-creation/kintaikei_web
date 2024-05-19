import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/user.dart';
import 'package:kintaikei_web/screens/user_source.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_data_grid.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/data_column.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  UserService userService = UserService();
  List<UserModel> users = [];

  void _getUsers() async {
    users = await userService.selectListToUserIds(
      userIds: widget.homeProvider.currentGroup?.userIds ?? [],
    );
    setState(() {});
  }

  @override
  void initState() {
    _getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Row(
                children: [
                  CustomButtonSm(
                    icon: FluentIcons.search,
                    labelText: 'メールアドレスから検索して加入',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AddUserEmailDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        getUsers: _getUsers,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  CustomButtonSm(
                    icon: FluentIcons.add,
                    labelText: '新規加入',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AddUserDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        getUsers: _getUsers,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomDataGrid(
              source: UserSource(
                context: context,
                users: users,
                getUsers: _getUsers,
                homeProvider: widget.homeProvider,
              ),
              columns: [
                GridColumn(
                  columnName: 'name',
                  label: const DataColumn('スタッフ名'),
                ),
                GridColumn(
                  columnName: 'email',
                  label: const DataColumn('メールアドレス'),
                ),
                GridColumn(
                  columnName: 'password',
                  label: const DataColumn('パスワード'),
                ),
                GridColumn(
                  columnName: 'edit',
                  label: const DataColumn('操作'),
                  width: 200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final Function() getUsers;

  const AddUserDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.getUsers,
    super.key,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ContentDialog(
      title: const Text(
        'スタッフの新規加入',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: 'スタッフ名',
              child: CustomTextBox(
                controller: nameController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'メールアドレス',
              child: CustomTextBox(
                controller: emailController,
                placeholder: '',
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'パスワード',
              child: CustomTextBox(
                controller: passwordController,
                placeholder: '',
                keyboardType: TextInputType.text,
                maxLines: 1,
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
          labelText: '上記内容で加入する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await userProvider.create(
              group: widget.homeProvider.currentGroup,
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await widget.getUsers();
            if (!mounted) return;
            showMessage(context, 'スタッフを新規加入しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class AddUserEmailDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final Function() getUsers;

  const AddUserEmailDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.getUsers,
    super.key,
  });

  @override
  State<AddUserEmailDialog> createState() => _AddUserEmailDialogState();
}

class _AddUserEmailDialogState extends State<AddUserEmailDialog> {
  UserService userService = UserService();
  TextEditingController emailController = TextEditingController();
  UserModel? user;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ContentDialog(
      title: const Text(
        'メールアドレスから検索して加入',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user == null
                ? InfoLabel(
                    label: 'メールアドレス',
                    child: CustomTextBox(
                      controller: emailController,
                      placeholder: '',
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                    ),
                  )
                : Column(
                    children: [
                      const Text('以下のスタッフを加入させますか？'),
                      const SizedBox(height: 8),
                      InfoLabel(
                        label: 'スタッフ名',
                        child: DisabledBox(user?.name ?? ''),
                      ),
                      const SizedBox(height: 8),
                      InfoLabel(
                        label: 'メールアドレス',
                        child: DisabledBox(user?.email ?? ''),
                      ),
                      const SizedBox(height: 8),
                      InfoLabel(
                        label: 'パスワード',
                        child: DisabledBox(user?.password ?? ''),
                      ),
                    ],
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
        user == null
            ? CustomButtonSm(
                labelText: '検索する',
                labelColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () async {
                  UserModel? tmpUser = await userService.selectToEmail(
                    email: emailController.text,
                  );
                  if (tmpUser != null) {
                    setState(() {
                      user = tmpUser;
                    });
                  } else {
                    if (!mounted) return;
                    showMessage(context, 'スタッフが見つかりませんでした', false);
                    return;
                  }
                },
              )
            : CustomButtonSm(
                labelText: '加入させる',
                labelColor: kWhiteColor,
                backgroundColor: kBlueColor,
                onPressed: () async {
                  String? error = await userProvider.groupIn(
                    group: widget.homeProvider.currentGroup,
                    user: user,
                  );
                  if (error != null) {
                    if (!mounted) return;
                    showMessage(context, error, false);
                    return;
                  }
                  await widget.getUsers();
                  if (!mounted) return;
                  showMessage(context, 'スタッフを加入させました', true);
                  Navigator.pop(context);
                },
              ),
      ],
    );
  }
}
