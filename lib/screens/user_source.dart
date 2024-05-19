import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/user.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_text_box.dart';
import 'package:kintaikei_web/widgets/data_column.dart';
import 'package:kintaikei_web/widgets/disabled_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserSource extends DataGridSource {
  final BuildContext context;
  final List<UserModel> users;
  final Function() getUsers;
  final HomeProvider homeProvider;

  UserSource({
    required this.context,
    required this.users,
    required this.getUsers,
    required this.homeProvider,
  }) {
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = users.map<DataGridRow>((user) {
      return DataGridRow(cells: [
        DataGridCell(
          columnName: 'id',
          value: user.id,
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = dataGridRows.indexOf(row);
    Color backgroundColor = Colors.transparent;
    if ((rowIndex % 2) == 0) {
      backgroundColor = kWhiteColor;
    }
    List<Widget> cells = [];
    UserModel user = users.singleWhere(
      (e) => e.id == '${row.getCells()[0].value}',
    );
    cells.add(DataColumn(user.name));
    cells.add(DataColumn(user.email));
    cells.add(DataColumn(user.password));
    cells.add(Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          CustomButtonSm(
            labelText: '編集',
            labelColor: kWhiteColor,
            backgroundColor: kBlueColor,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ModUserDialog(
                user: user,
                getUsers: getUsers,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CustomButtonSm(
            labelText: '脱退',
            labelColor: kWhiteColor,
            backgroundColor: kRedColor,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ExitUserDialog(
                user: user,
                getUsers: getUsers,
                homeProvider: homeProvider,
              ),
            ),
          ),
        ],
      ),
    ));
    return DataGridRowAdapter(color: backgroundColor, cells: cells);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    buildDataGridRows();
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    buildDataGridRows();
    notifyListeners();
  }

  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    Widget? widget;
    Widget buildCell(
      String value,
      EdgeInsets padding,
      Alignment alignment,
    ) {
      return Container(
        padding: padding,
        alignment: alignment,
        child: Text(value, softWrap: false),
      );
    }

    widget = buildCell(
      summaryValue,
      const EdgeInsets.all(4),
      Alignment.centerLeft,
    );
    return widget;
  }

  void updateDataSource() {
    notifyListeners();
  }
}

class ModUserDialog extends StatefulWidget {
  final UserModel user;
  final Function() getUsers;

  const ModUserDialog({
    required this.user,
    required this.getUsers,
    super.key,
  });

  @override
  State<ModUserDialog> createState() => _ModUserDialogState();
}

class _ModUserDialogState extends State<ModUserDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.user.name;
    emailController.text = widget.user.email;
    passwordController.text = widget.user.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ContentDialog(
      title: const Text(
        'スタッフ情報の編集',
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
          labelText: '上記内容で保存する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await userProvider.update(
              user: widget.user,
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
            showMessage(context, 'スタッフ情報を編集しました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ExitUserDialog extends StatefulWidget {
  final UserModel user;
  final Function() getUsers;
  final HomeProvider homeProvider;

  const ExitUserDialog({
    required this.user,
    required this.getUsers,
    required this.homeProvider,
    super.key,
  });

  @override
  State<ExitUserDialog> createState() => _ExitUserDialogState();
}

class _ExitUserDialogState extends State<ExitUserDialog> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ContentDialog(
      title: const Text(
        'スタッフの脱退',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('以下のスタッフを脱退させますか？'),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'スタッフ名',
              child: DisabledBox(widget.user.name),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'メールアドレス',
              child: DisabledBox(widget.user.email),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: 'パスワード',
              child: DisabledBox(widget.user.password),
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
          labelText: '脱退させる',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.groupExit(
              group: widget.homeProvider.currentGroup,
              user: widget.user,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await widget.getUsers();
            if (!mounted) return;
            showMessage(context, 'スタッフを脱退させました', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
