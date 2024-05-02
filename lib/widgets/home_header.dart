import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/widgets/custom_icon_button.dart';

class HomeHeader extends StatefulWidget {
  final LoginProvider loginProvider;
  final HomeProvider homeProvider;

  const HomeHeader({
    required this.loginProvider,
    required this.homeProvider,
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  void _init() async {
    await widget.homeProvider.init(
      group: widget.loginProvider.groups.first,
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.loginProvider.company?.name ?? '',
                style: const TextStyle(
                  color: kWhiteColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ComboBox<CompanyGroupModel>(
                  value: widget.homeProvider.currentGroup,
                  items: widget.loginProvider.groups.map((e) {
                    return ComboBoxItem(
                      value: e,
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.homeProvider.currentGroupChange(value);
                  },
                ),
              ),
              const SizedBox(width: 2),
              CustomIconButton(
                icon: FluentIcons.add,
                iconColor: kBlackColor,
                backgroundColor: kWhiteColor,
                onPressed: () {},
              ),
            ],
          ),
          CustomIconButton(
            icon: FluentIcons.sign_out,
            iconColor: kBlackColor,
            backgroundColor: kWhiteColor,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
