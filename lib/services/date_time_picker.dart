import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
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
    return await showMonthPicker(
      context: context,
      initialDate: initialDate,
      headerColor: kMainColor,
      headerTextColor: kWhiteColor,
      selectedMonthBackgroundColor: kMainColor,
      selectedMonthTextColor: kWhiteColor,
      unselectedMonthTextColor: kBlackColor,
      backgroundColor: kWhiteColor,
      roundedCornersRadius: 8,
    );
  }
}
