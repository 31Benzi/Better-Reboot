import 'package:fluent_ui/fluent_ui.dart' as fluentUi show FluentIcons;
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reboot_launcher/src/controller/dll_controller.dart';
import 'package:reboot_launcher/src/controller/hosting_controller.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/tile/setting_tile.dart';
import 'package:reboot_launcher/src/message/data.dart';
import 'package:reboot_launcher/src/messenger/overlay.dart';
import 'package:reboot_launcher/src/pager/abstract_page.dart';
import 'package:reboot_launcher/src/button/game_start_button.dart';
import 'package:reboot_launcher/src/button/version_selector.dart';

final GlobalKey<OverlayTargetState> hostVersionOverlayTargetKey = GlobalKey();

class HostPage extends AbstractPage {
  const HostPage({Key? key}) : super(key: key);

  @override
  String get name => translations.hostName;

  @override
  String get iconAsset => "assets/images/host.png";

  @override
  PageType get type => PageType.host;

  @override
  bool hasButton(String? pageName) => pageName == null;

  @override
  AbstractPageState<HostPage> createState() => _HostingPageState();
}

class _HostingPageState extends AbstractPageState<HostPage> {
  final HostingController _hostingController = Get.find<HostingController>();
  final DllController _dllController = Get.find<DllController>();

  @override
  void initState() {
    if(_hostingController.name.text.isEmpty) {
      _hostingController.name.text = translations.defaultServerName;
    }

    if(_hostingController.description.text.isEmpty) {
      _hostingController.description.text = translations.defaultServerDescription;
    }

    super.initState();
  }

  @override
  Widget get button => LaunchButton(
      host: true,
      startLabel: translations.startHosting,
      stopLabel: translations.stopHosting
  );

  @override
  List<Widget> get settings => [
    VersionSelector.buildTile(
        key: hostVersionOverlayTargetKey
    ),
    _options,
    _resetDefaults
  ];

  SettingTile get _options => SettingTile(
    icon: Icon(
        FluentIcons.options_24_regular
    ),
    title: Text(translations.settingsServerOptionsName),
    subtitle: Text(translations.settingsServerOptionsSubtitle),
    children: [
      SettingTile(
          icon: Icon(
              FluentIcons.options_24_regular
          ),
          title: Text(translations.settingsClientArgsName),
          subtitle: Text(translations.settingsClientArgsDescription),
          content: TextFormBox(
            placeholder: translations.settingsClientArgsPlaceholder,
            controller: _hostingController.customLaunchArgs,
          )
      ),
      SettingTile(
        icon: Icon(
            FluentIcons.window_console_20_regular
        ),
        title: Text(translations.gameServerTypeName),
        subtitle: Text(translations.gameServerTypeDescription),
        contentWidth: null,
        content: Row(
          children: [
            Obx(() => Text(
                _hostingController.headless.value ? translations.on : translations.off
            )),
            const SizedBox(
                width: 16.0
            ),
            Obx(() => ToggleSwitch(
                checked: _hostingController.headless.value,
                onChanged: (value) => _hostingController.headless.value = value
            )),
          ],
        ),
      ),
      SettingTile(
        icon: Icon(
            FluentIcons.arrow_reset_24_regular
        ),
        title: Text(translations.hostAutomaticRestartName),
        subtitle: Text(translations.hostAutomaticRestartDescription),
        contentWidth: null,
        content: Row(
          children: [
            Obx(() => Text(
                _hostingController.autoRestart.value ? translations.on : translations.off
            )),
            const SizedBox(
                width: 16.0
            ),
            Obx(() => ToggleSwitch(
                checked: _hostingController.autoRestart.value,
                onChanged: (value) => _hostingController.autoRestart.value = value
            )),
          ],
        ),
      ),
      SettingTile(
          icon: Icon(
              fluentUi.FluentIcons.number_field
          ),
          title: Text(translations.settingsServerPortName),
          subtitle: Text(translations.settingsServerPortDescription),
          contentWidth: 64,
          content: TextFormBox(
              placeholder:  translations.settingsServerPortName,
              controller: _dllController.gameServerPort,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ]
          )
      )
    ],
  );

  SettingTile get _resetDefaults => SettingTile(
      icon: Icon(
          FluentIcons.arrow_reset_24_regular
      ),
      title: Text(translations.hostResetName),
      subtitle: Text(translations.hostResetDescription),
      content: Button(
        onPressed: () => showResetDialog(() {
          _hostingController.reset();
          _dllController.resetServer();
        }),
        child: Text(translations.hostResetContent),
      )
  );
}