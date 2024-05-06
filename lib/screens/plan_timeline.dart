import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/plan_add.dart';
import 'package:kintaikei_web/screens/plan_mod.dart';
import 'package:kintaikei_web/services/plan.dart';
import 'package:kintaikei_web/widgets/custom_timeline.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanTimelineScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final DateTime selectedDate;

  const PlanTimelineScreen({
    required this.loginProvider,
    required this.homeProvider,
    required this.selectedDate,
    super.key,
  });

  @override
  State<PlanTimelineScreen> createState() => _PlanTimelineScreenState();
}

class _PlanTimelineScreenState extends State<PlanTimelineScreen> {
  PlanService planService = PlanService();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Container(
        decoration: kHeaderDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                convertDateText('yyyy年MM月dd日(E)', widget.selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              Container(),
            ],
          ),
        ),
      ),
      content: Container(
        color: kWhiteColor,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: planService.streamList(
            companyId: widget.loginProvider.company?.id,
            groupId: widget.homeProvider.currentGroup?.id,
            selectedDate: widget.selectedDate,
          ),
          builder: (context, snapshot) {
            List<sfc.Appointment> appointments =
                planService.convertListAppointment(
              snapshot,
            );
            return CustomTimeline(
              initialDisplayDate: widget.selectedDate,
              dataSource: _DataSource(appointments),
              onTap: (sfc.CalendarTapDetails details) {
                sfc.CalendarElement element = details.targetElement;
                switch (element) {
                  case sfc.CalendarElement.appointment:
                  case sfc.CalendarElement.agenda:
                    sfc.Appointment appointmentDetails =
                        details.appointments![0];
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => PlanModScreen(
                          loginProvider: widget.loginProvider,
                          homeProvider: widget.homeProvider,
                          planId: '${appointmentDetails.id}',
                        ),
                      ),
                    );
                    break;
                  case sfc.CalendarElement.calendarCell:
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => PlanAddScreen(
                          loginProvider: widget.loginProvider,
                          homeProvider: widget.homeProvider,
                          date: details.date ?? DateTime.now(),
                        ),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _DataSource extends sfc.CalendarDataSource {
  _DataSource(List<sfc.Appointment> source) {
    appointments = source;
  }
}
