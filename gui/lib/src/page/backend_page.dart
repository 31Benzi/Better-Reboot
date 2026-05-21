import 'package:fluent_ui/fluent_ui.dart' as fluentUi show FluentIcons;
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reboot_common/common.dart';
import 'package:reboot_launcher/src/controller/backend_controller.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/tile/setting_tile.dart';
import 'package:reboot_launcher/src/message/data.dart';
import 'package:reboot_launcher/src/messenger/overlay.dart';
import 'package:reboot_launcher/src/pager/abstract_page.dart';
import 'package:reboot_launcher/src/button/backend_start_button.dart';
import 'package:reboot_launcher/src/button/server_type_selector.dart';

final GlobalKey<OverlayTargetState> backendTypeOverlayTargetKey = GlobalKey();

class BackendPage extends AbstractPage {
  const BackendPage({Key? key}) : super(key: key);

  @override
  String get name => translations.backendName;

  @override
  String get iconAsset => "assets/images/backend.png";

  @override
  PageType get type => PageType.backend;

  @override
  bool hasButton(String? pageName) => pageName == null;

  @override
  AbstractPageState<BackendPage> createState() => _BackendPageState();
}

class _BackendPageState extends AbstractPageState<BackendPage> {
  final BackendController _backendController = Get.find<BackendController>();

  @override
  List<Widget> get settings => [
    _type,
    _hostName,
    _port,
    _resetDefaults
  ];

  Widget get _hostName => Obx(() {
    if(_backendController.type.value != AuthBackendType.remote) {
      return const SizedBox.shrink();
    }

    return SettingTile(
        icon: Icon(
            FluentIcons.globe_24_regular
        ),
        title: Text(translations.backendConfigurationHostName),
        subtitle: Text(translations.backendConfigurationHostDescription),
        content: TextFormBox(
            placeholder: translations.backendConfigurationHostName,
            controller: _backendController.host
        )
    );
  });

  SettingTile get _port => SettingTile(
      icon: Icon(
          fluentUi.FluentIcons.number_field
      ),
      title: Text(translations.backendConfigurationPortName),
      subtitle: Text(translations.backendConfigurationPortDescription),
      content: TextFormBox(
          placeholder: translations.backendConfigurationPortName,
          controller: _backendController.port,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ]
      )
  );

  SettingTile get _resetDefaults => SettingTile(
      icon: Icon(
          FluentIcons.arrow_reset_24_regular
      ),
      title: Text(translations.backendResetDefaultsName),
      subtitle: Text(translations.backendResetDefaultsDescription),
      content: Button(
        onPressed: () => showResetDialog(_backendController.reset),
        child: Text(translations.backendResetDefaultsContent),
      )
  );

  Widget get _type => SettingTile(
      icon: Icon(
          FluentIcons.password_24_regular
      ),
      title: Text(translations.backendTypeName),
      subtitle: Text(translations.backendTypeDescription),
      content: ServerTypeSelector(
        overlayKey: backendTypeOverlayTargetKey
      )
  );

  @override
  Widget get button => const BackendButton();
}
