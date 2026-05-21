import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:reboot_common/common.dart';
import 'package:reboot_launcher/src/config/discord_rpc_config.dart';
import 'package:reboot_launcher/src/controller/dll_controller.dart';
import 'package:reboot_launcher/src/controller/settings_controller.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/tile/file_setting_tile.dart';
import 'package:reboot_launcher/src/tile/setting_tile.dart';
import 'package:reboot_launcher/src/pager/abstract_page.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<TextFormBoxState> settingsConsoleDllInputKey = GlobalKey();
final GlobalKey<TextFormBoxState> settingsAuthDllInputKey = GlobalKey();
final GlobalKey<TextFormBoxState> settingsMemoryDllInputKey = GlobalKey();
final GlobalKey<TextFormBoxState> settingsGameServerDllInputKey = GlobalKey();

class SettingsPage extends AbstractPage {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  String get name => translations.settingsName;

  @override
  String get iconAsset => "assets/images/settings.png";

  @override
  PageType get type => PageType.settings;

  @override
  bool hasButton(String? pageName) => false;

  @override
  AbstractPageState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends AbstractPageState<SettingsPage> {
  final DllController _dllController = Get.find<DllController>();
  final SettingsController _settingsController = Get.find<SettingsController>();

  @override
  Widget? get button => null;

  @override
  List<Widget> get settings => [
    _internalFiles,
    _launcher,
    _installationDirectory,
  ];

  SettingTile get _internalFiles => SettingTile(
    icon: Icon(
        FluentIcons.archive_settings_24_regular
    ),
    title: Text(translations.settingsClientName),
    subtitle: Text(translations.settingsClientDescription),
    children: [
      createFileSetting(
          key: settingsConsoleDllInputKey,
          title: translations.settingsClientConsoleName,
          description: translations.settingsClientConsoleDescription,
          controller: _dllController.unrealEngineConsoleDll,
          onReset: () async {
            final path = _dllController.getDefaultDllPath(GameDll.console);
            _dllController.unrealEngineConsoleDll.text = path;
            await _dllController.download(GameDll.console, path, force: true);
            settingsConsoleDllInputKey.currentState?.validate();
          }
      ),
      createFileSetting(
          key: settingsAuthDllInputKey,
          title: translations.settingsClientAuthName,
          description: translations.settingsClientAuthDescription,
          controller: _dllController.backendDll,
          onReset: () async {
            final path = _dllController.getDefaultDllPath(GameDll.auth);
            _dllController.backendDll.text = path;
            await _dllController.download(GameDll.auth, path, force: true);
            settingsAuthDllInputKey.currentState?.validate();
          }
      ),
      createFileSetting(
          key: settingsMemoryDllInputKey,
          title: translations.settingsClientMemoryName,
          description: translations.settingsClientMemoryDescription,
          controller: _dllController.memoryLeakDll,
          onReset: () async {
            final path = _dllController.getDefaultDllPath(GameDll.memoryLeak);
            _dllController.memoryLeakDll.text = path;
            await _dllController.download(GameDll.memoryLeak, path, force: true);
            settingsAuthDllInputKey.currentState?.validate();
          }
      ),
      _gameServer
    ],
  );

  SettingTile get _gameServer => SettingTile(
    icon: Icon(
        FluentIcons.document_24_regular
    ),
    title: Text(translations.settingsServerName),
    subtitle: Text(translations.settingsServerSubtitle),
    children: [
      createFileSetting(
          key: settingsGameServerDllInputKey,
          title: translations.settingsOldServerFileName,
          description: translations.settingsServerFileDescription,
          controller: _dllController.customGameServerDll,
          onReset: () async {
            final path = _dllController.getDefaultDllPath(GameDll.gameServer);
            _dllController.customGameServerDll.text = path;
            await _dllController.download(GameDll.gameServer, path, force: true);
            settingsGameServerDllInputKey.currentState?.validate();
          }
      ),
    ],
  );

  SettingTile get _launcher => SettingTile(
    icon: const Icon(
        FluentIcons.chat_24_regular
    ),
    title: Text(translations.settingsUtilsDiscordRpcName),
    subtitle: Text(
        isDiscordRpcConfigured
            ? translations.settingsUtilsDiscordRpcDescription
            : translations.settingsUtilsDiscordRpcNotConfigured
    ),
    contentWidth: null,
    content: Row(
      children: [
        Obx(() => Text(
            _settingsController.discordRichPresence.value ? translations.on : translations.off
        )),
        const SizedBox(width: 16.0),
        Obx(() => ToggleSwitch(
            checked: _settingsController.discordRichPresence.value,
            onChanged: isDiscordRpcConfigured
                ? (value) => _settingsController.discordRichPresence.value = value
                : null
        )),
      ],
    ),
  );

  SettingTile get _installationDirectory => SettingTile(
      icon: Icon(
          FluentIcons.folder_24_regular
      ),
      title: Text(translations.settingsUtilsInstallationDirectoryName),
      subtitle: Text(translations.settingsUtilsInstallationDirectorySubtitle),
      content: Button(
        onPressed: () => launchUrl(installationDirectory.uri),
        child: Text(translations.settingsUtilsInstallationDirectoryContent),
      )
  );
}
