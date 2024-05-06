import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/user_source.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_data_grid.dart';
import 'package:kintaikei_web/widgets/data_column.dart';
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
      padding: const EdgeInsets.all(8),
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
                    icon: FluentIcons.profile_search,
                    labelText: 'メールアドレスから加入',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  CustomButtonSm(
                    icon: FluentIcons.add,
                    labelText: '新規加入',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomDataGrid(
              source: UserSource(
                context: context,
                users: users,
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
