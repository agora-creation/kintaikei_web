import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/plan.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/plan_shift_add.dart';
import 'package:kintaikei_web/screens/plan_shift_mod.dart';
import 'package:kintaikei_web/services/plan.dart';
import 'package:kintaikei_web/services/plan_shift.dart';
import 'package:kintaikei_web/services/user.dart';
import 'package:kintaikei_web/widgets/custom_button_sm.dart';
import 'package:kintaikei_web/widgets/custom_shift.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanShiftScreen extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const PlanShiftScreen({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<PlanShiftScreen> createState() => _PlanShiftScreenState();
}

class _PlanShiftScreenState extends State<PlanShiftScreen> {
  PlanService planService = PlanService();
  PlanShiftService planShiftService = PlanShiftService();
  UserService userService = UserService();
  List<UserModel> users = [];
  List<sfc.CalendarResource> resourceColl = [];

  void _init() async {
    users = await userService.selectListToUserIds(
      userIds: widget.homeProvider.currentGroup?.userIds ?? [],
    );
    if (users.isNotEmpty) {
      for (UserModel user in users) {
        resourceColl.add(sfc.CalendarResource(
          displayName: user.name,
          id: user.id,
          color: kGrey300Color,
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var streamPlan = planService.streamList(
      companyId: widget.loginProvider.company?.id,
      groupId: widget.homeProvider.currentGroup?.id,
    );
    var streamPlanShift = planShiftService.streamList(
      companyId: widget.loginProvider.company?.id,
      groupId: widget.homeProvider.currentGroup?.id,
    );
    return Container(
      color: kWhiteColor,
      padding: const EdgeInsets.all(8),
      child: StreamBuilder2<QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>>(
        streams: StreamTuple2(streamPlan!, streamPlanShift!),
        builder: (context, snapshot) {
          List<sfc.Appointment> source = planService.convertListAppointment(
            snapshot.snapshot1,
            shift: true,
            users: users,
          );
          if (snapshot.snapshot2.hasData) {
            source.addAll(planShiftService.convertListAppointment(
              snapshot.snapshot2,
            ));
          }
          return CustomShift(
            dataSource: _ShiftDataSource(source, resourceColl),
            onTap: (sfc.CalendarTapDetails details) {
              sfc.CalendarElement element = details.targetElement;
              switch (element) {
                case sfc.CalendarElement.appointment:
                case sfc.CalendarElement.agenda:
                  sfc.Appointment appointmentDetails = details.appointments![0];
                  String type = appointmentDetails.notes ?? '';
                  if (type == 'plan') {
                    showDialog(
                      context: context,
                      builder: (context) => PlanDialog(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        planId: '${appointmentDetails.id}',
                      ),
                    );
                  } else if (type == 'planShift') {
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => PlanShiftModScreen(
                          loginProvider: widget.loginProvider,
                          homeProvider: widget.homeProvider,
                          planShiftId: '${appointmentDetails.id}',
                          selectedDate: details.date ?? DateTime.now(),
                        ),
                      ),
                    );
                  }
                  break;
                case sfc.CalendarElement.calendarCell:
                  final userId = details.resource?.id;
                  if (userId == null) return;
                  Navigator.push(
                    context,
                    FluentPageRoute(
                      builder: (context) => PlanShiftAddScreen(
                        loginProvider: widget.loginProvider,
                        homeProvider: widget.homeProvider,
                        users: users,
                        userId: '$userId',
                        selectedDate: details.date ?? DateTime.now(),
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
    );
  }
}

class _ShiftDataSource extends sfc.CalendarDataSource {
  _ShiftDataSource(
    List<sfc.Appointment> source,
    List<sfc.CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }
}

class PlanDialog extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;
  final String planId;

  const PlanDialog({
    required this.loginProvider,
    required this.homeProvider,
    required this.planId,
    super.key,
  });

  @override
  State<PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<PlanDialog> {
  PlanService planService = PlanService();
  PlanModel? plan;

  void _init() async {
    PlanModel? tmpPlan = await planService.selectDataToId(id: widget.planId);
    if (tmpPlan == null) {
      if (!mounted) return;
      showMessage(context, '予定データの取得に失敗しました', false);
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    plan = tmpPlan;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: plan?.color,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                plan?.subject ?? '',
                style: const TextStyle(color: kWhiteColor),
              ),
            ),
            const SizedBox(height: 8),
            InfoLabel(
              label: '予定期間',
              child: Container(
                color: kGrey300Color,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${convertDateText('yyyy/MM/dd HH:mm', plan?.startedAt)}〜${convertDateText('yyyy/MM/dd HH:mm', plan?.endedAt)}',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButtonSm(
          labelText: '閉じる',
          labelColor: kWhiteColor,
          backgroundColor: kGreyColor,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
