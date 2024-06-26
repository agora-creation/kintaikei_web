import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class CustomCalendar extends StatelessWidget {
  final sfc.CalendarDataSource<Object?>? dataSource;
  final Function(sfc.CalendarTapDetails)? onTap;

  const CustomCalendar({
    required this.dataSource,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return sfc.SfCalendar(
      dataSource: dataSource,
      view: sfc.CalendarView.month,
      showNavigationArrow: true,
      showDatePickerButton: true,
      headerDateFormat: 'yyyy年MM月',
      onTap: onTap,
      monthViewSettings: const sfc.MonthViewSettings(
        appointmentDisplayMode: sfc.MonthAppointmentDisplayMode.appointment,
        monthCellStyle: sfc.MonthCellStyle(
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
      cellBorderColor: kGrey600Color,
    );
  }
}
