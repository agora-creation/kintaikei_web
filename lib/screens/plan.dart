import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/plan_timeline.dart';
import 'package:kintaikei_web/widgets/custom_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const PlanScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  List<sfc.Appointment> appointments = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(8),
      child: CustomCalendar(
        dataSource: _DataSource(appointments),
        onTap: (sfc.CalendarTapDetails details) {
          Navigator.push(
            context,
            FluentPageRoute(
              builder: (context) => PlanTimelineScreen(
                loginProvider: widget.loginProvider,
                homeProvider: widget.homeProvider,
                date: details.date ?? DateTime.now(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataSource extends sfc.CalendarDataSource {
  _DataSource(List<sfc.Appointment> source) {
    appointments = source;
  }
}
