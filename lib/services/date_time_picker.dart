import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class DateTimePickerService {
  Future boardPicker({
    required BuildContext context,
    required DateTime init,
    required String title,
    required Function(DateTime) onChanged,
  }) async {
    await showBoardDateTimePicker(
      isDismissible: false,
      context: context,
      pickerType: DateTimePickerType.datetime,
      initialDate: init,
      options: BoardDateTimeOptions(
        languages: const BoardPickerLanguages.ja(),
        showDateButton: false,
        boardTitle: title,
      ),
      radius: 8,
      onChanged: onChanged,
    );
  }

  Future<DateTime?> monthPicker({
    required BuildContext context,
    required DateTime initialDate,
  }) async {
    await showMonthPicker(
      context: context,
    );
  }

  // Future<DateTime?> monthPicker({
  //   required BuildContext context,
  //   DateTime? value,
  //   DateTime? endValue,
  // }) async {
  //   List<DateTime?>? results = await showCalendarDatePicker2Dialog(
  //     context: context,
  //     config: CalendarDatePicker2WithActionButtonsConfig(
  //       calendarType: CalendarDatePicker2Type.range,
  //       firstDate: kFirstDate,
  //       lastDate: kLastDate,
  //     ),
  //     dialogSize: const Size(325, 400),
  //     value: [startValue, endValue],
  //     borderRadius: BorderRadius.circular(8),
  //     dialogBackgroundColor: kWhiteColor,
  //   );
  //   return results;
  // }
}
