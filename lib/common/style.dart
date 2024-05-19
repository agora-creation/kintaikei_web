import 'package:fluent_ui/fluent_ui.dart';

const kBackgroundColor = Color(0xFF3949AB);
const kMainColor = Color(0xFF3949AB);
const kBlackColor = Color(0xFF333333);
const kGreyColor = Color(0xFF9E9E9E);
const kGrey300Color = Color(0xFFE0E0E0);
const kGrey600Color = Color(0xFF757575);
const kBlueGreyColor = Color(0xFF607D8B);
const kWhiteColor = Color(0xFFFFFFFF);
const kBlueColor = Color(0xFF2196F3);
const kRedColor = Color(0xFFF44336);
const kYellowColor = Color(0xFFFFEB3B);
const kCyanColor = Color(0xFF00BCD4);
const kGreenColor = Color(0xFF4CAF50);

FluentThemeData customTheme() {
  return FluentThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: 'SourceHanSansJP-Regular',
    activeColor: kWhiteColor,
    cardColor: kWhiteColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: kMainColor,
      overlayBackgroundColor: kWhiteColor,
      highlightColor: kWhiteColor,
      selectedTextStyle: ButtonState.all<TextStyle>(const TextStyle(
        color: kWhiteColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'SourceHanSansJP-Bold',
      )),
      selectedIconColor: ButtonState.all(kWhiteColor),
      unselectedTextStyle: ButtonState.all<TextStyle>(const TextStyle(
        color: kWhiteColor,
      )),
      unselectedIconColor: ButtonState.all(kWhiteColor),
    ),
    checkboxTheme: CheckboxThemeData(
      checkedDecoration: ButtonState.all<Decoration>(
        BoxDecoration(
          color: kBlueColor,
          border: Border.all(color: kBlueColor),
        ),
      ),
      uncheckedDecoration: ButtonState.all<Decoration>(
        BoxDecoration(
          color: kWhiteColor,
          border: Border.all(color: kGrey600Color),
        ),
      ),
    ),
  );
}

List<String> kWeeks = ['月', '火', '水', '木', '金', '土', '日'];
List<String> kRepeatIntervals = ['毎日', '毎週', '毎月', '毎年'];
List<Color> kColors = const [
  Color(0xFF3F51B5),
  Color(0xFF673AB7),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
  Color(0xFFF44336),
  Color(0xFF03A9F4),
  Color(0xFF039BE5),
  Color(0xFF00ACC1),
  Color(0xFF00897B),
  Color(0xFF43A047),
  Color(0xFF7CB342),
  Color(0xFFC0CA33),
  Color(0xFFFDD835),
  Color(0xFFFFB300),
  Color(0xFFFB8C00),
  Color(0xFFF4511E),
  Color(0xFF6D4C41),
  Color(0xFF757575),
  Color(0xFF546E7A),
];
List<int> kAlertMinutes = [0, 10, 30, 60];

DateTime kFirstDate = DateTime.now().subtract(const Duration(days: 1095));
DateTime kLastDate = DateTime.now().add(const Duration(days: 1095));

const kHeaderDecoration = BoxDecoration(
  color: kWhiteColor,
  border: Border(bottom: BorderSide(color: kGrey300Color)),
);

const kIntroStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  fontFamily: 'SourceHanSansJP-Bold',
);
