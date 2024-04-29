import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kintaikei_web/common/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      content: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '勤怠計',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    '勤怠打刻サービス : 管理画面',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              SpinKitPouringHourGlassRefined(color: kBlackColor),
            ],
          ),
        ),
      ),
    );
  }
}
