import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/screens/apply.dart';
import 'package:kintaikei_web/screens/group.dart';
import 'package:kintaikei_web/screens/plan.dart';
import 'package:kintaikei_web/screens/plan_shift.dart';
import 'package:kintaikei_web/screens/user.dart';
import 'package:kintaikei_web/screens/work.dart';
import 'package:kintaikei_web/widgets/home_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: HomeHeader(
          loginProvider: loginProvider,
          homeProvider: homeProvider,
        ),
      ),
      pane: NavigationPane(
        size: const NavigationPaneSize(openMaxWidth: 200),
        selected: homeProvider.currentIndex,
        onChanged: (index) {
          homeProvider.currentIndexChange(index);
        },
        displayMode: PaneDisplayMode.open,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.event),
            title: Text(
              '予定表',
              style: homeProvider.currentIndex == 0
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: PlanScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 0
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.project_management),
            title: Text(
              'シフト表',
              style: homeProvider.currentIndex == 1
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: PlanShiftScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 1
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.running),
            title: Text(
              '勤怠打刻',
              style: homeProvider.currentIndex == 2
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: WorkScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 2
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.group),
            title: Text(
              'スタッフ',
              style: homeProvider.currentIndex == 3
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: UserScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 3
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.entitlement_redemption),
            title: Text(
              '申請',
              style: homeProvider.currentIndex == 4
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: ApplyScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 4
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: Text(
              'グループ設定',
              style: homeProvider.currentIndex == 5
                  ? const TextStyle(color: kMainColor)
                  : null,
            ),
            body: GroupScreen(
              loginProvider: loginProvider,
              homeProvider: homeProvider,
            ),
            tileColor: homeProvider.currentIndex == 5
                ? ButtonState.all(kWhiteColor)
                : null,
          ),
        ],
      ),
    );
  }
}
