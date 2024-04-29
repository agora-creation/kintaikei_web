import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
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
        title: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '会社名',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: homeProvider.currentIndex,
        onChanged: (index) {
          homeProvider.currentIndexChange(index);
        },
        displayMode: PaneDisplayMode.open,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.event),
            title: const Text('スケジュールカレンダー'),
            body: Container(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.project_management),
            title: const Text('シフト表'),
            body: Container(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.running),
            title: const Text('勤怠打刻'),
            body: Container(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.group),
            title: const Text('スタッフ'),
            body: Container(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.entitlement_redemption),
            title: const Text('申請'),
            body: Container(),
          ),
        ],
      ),
    );
  }
}
