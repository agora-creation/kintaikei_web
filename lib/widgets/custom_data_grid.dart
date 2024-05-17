import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomDataGrid extends StatelessWidget {
  final DataGridSource source;
  final List<GridColumn> columns;

  const CustomDataGrid({
    required this.source,
    required this.columns,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: const SfDataGridThemeData(
        gridLineColor: kGrey300Color,
      ),
      child: SfDataGrid(
        source: source,
        onQueryRowHeight: (details) {
          return details.getIntrinsicRowHeight(details.rowIndex);
        },
        columns: columns,
        columnWidthMode: ColumnWidthMode.fill,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
      ),
    );
  }
}
