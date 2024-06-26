import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:kintaikei_web/services/date_machine_util.dart';

void showMessage(BuildContext context, String msg, bool success) {
  displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: Text(msg),
      severity:
          success == true ? InfoBarSeverity.success : InfoBarSeverity.error,
    );
  });
}

String convertDateText(String format, DateTime? date) {
  String ret = '';
  if (date != null) {
    ret = DateFormat(format, 'ja').format(date);
  }
  return ret;
}

String convertTimeText(String time) {
  List<String> times = time.split(':');
  return '${int.parse(times.first)}時間${int.parse(times.last)}分';
}

String generatePassword(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charsLength = chars.length;
  final units = List.generate(
    length,
    (index) {
      final n = Random().nextInt(charsLength);
      return chars.codeUnitAt(n);
    },
  );
  return String.fromCharCodes(units);
}

String twoDigits(int n) => n.toString().padLeft(2, '0');

DateTime rebuildDate({
  required DateTime? date,
  required DateTime? time,
}) {
  DateTime ret = DateTime.now();
  if (date != null && time != null) {
    String date0 = convertDateText('yyyy-MM-dd', date);
    String time0 = '${convertDateText('HH:mm', time)}:00.000';
    ret = DateTime.parse('$date0 $time0');
  }
  return ret;
}

DateTime rebuildTime({
  required BuildContext context,
  required DateTime? date,
  required String? time,
}) {
  DateTime ret = DateTime.now();
  if (date != null && time != null) {
    String date0 = convertDateText('yyyy-MM-dd', date);
    String time0 = '${time.padLeft(5, '0')}:00.000';
    ret = DateTime.parse('$date0 $time0');
  }
  return ret;
}

List<int> timeToInt(DateTime? dateTime) {
  List<int> ret = [0, 0];
  if (dateTime != null) {
    String h = convertDateText('H', dateTime);
    String m = convertDateText('m', dateTime);
    ret = [int.parse(h), int.parse(m)];
  }
  return ret;
}

String addTime(String left, String right) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  List<String> lefts = left.split(':');
  List<String> rights = right.split(':');
  double hm = (int.parse(lefts.last) + int.parse(rights.last)) / 60;
  int m = (int.parse(lefts.last) + int.parse(rights.last)) % 60;
  int h = (int.parse(lefts.first) + int.parse(rights.first)) + hm.toInt();
  if (h.toString().length == 1) {
    return '${twoDigits(h)}:${twoDigits(m)}';
  } else {
    return '$h:${twoDigits(m)}';
  }
}

String subTime(String left, String right) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  List<String> lefts = left.split(':');
  List<String> rights = right.split(':');
  // 時 → 分
  int leftM = (int.parse(lefts.first) * 60) + int.parse(lefts.last);
  int rightM = (int.parse(rights.first) * 60) + int.parse(rights.last);
  // 分で引き算
  int diffM = leftM - rightM;
  // 分 → 時
  double h = diffM / 60;
  int m = diffM % 60;
  return '${twoDigits(h.toInt())}:${twoDigits(m)}';
}

Timestamp convertTimestamp(DateTime date, bool end) {
  String dateTime = '${convertDateText('yyyy-MM-dd', date)} 00:00:00.000';
  if (end) {
    dateTime = '${convertDateText('yyyy-MM-dd', date)} 23:59:59.999';
  }
  return Timestamp.fromMillisecondsSinceEpoch(
    DateTime.parse(dateTime).millisecondsSinceEpoch,
  );
}

List<DateTime> generateDays(DateTime month) {
  List<DateTime> ret = [];
  Map<String, String> map = DateMachineUtilService.getMonthDate(month, 0);
  DateTime start = DateTime.parse('${map['start']}');
  DateTime end = DateTime.parse('${map['end']}');
  for (int i = 0; i <= end.difference(start).inDays; i++) {
    ret.add(start.add(Duration(days: i)));
  }
  return ret;
}
