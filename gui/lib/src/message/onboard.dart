import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:reboot_launcher/src/controller/game_controller.dart';
import 'package:reboot_launcher/src/controller/settings_controller.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/message/profile.dart';
import 'package:reboot_launcher/src/messenger/overlay.dart';
import 'package:reboot_launcher/src/page/backend_page.dart';
import 'package:reboot_launcher/src/pager/pager.dart';
import 'package:reboot_launcher/src/page/host_page.dart';
import 'package:reboot_launcher/src/page/pages.dart';
import 'package:reboot_launcher/src/page/play_page.dart';
import 'package:reboot_launcher/src/button/version_selector.dart';

void startOnboarding() {
  final gameController = Get.find<GameController>();
  final settingsController = Get.find<SettingsController>();
  settingsController.firstRun.value = false;
  profileOverlayKey.currentState!.showOverlay(
      text: translations.startOnboardingText,
      offset: Offset(27.5, 17.5),
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.startOnboardingActionLabel,
          onTap: () async {
            onClose();
            await showProfileForm(context, gameController.username, gameController.password);
            _promptPlayPage();
          }
      )
  );
}

void _promptPlayPage() {
  pageIndex.value = PageType.play.index;
  pageOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptPlayPageText,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptPlayPageActionLabel,
          onTap: () async {
            onClose();
            _promptPlayVersion();
          }
      )
  );
}

void _promptPlayVersion() {
  final gameController = Get.find<GameController>();
  final hasBuilds = gameController.versions.value.isNotEmpty;
  gameVersionOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptPlayVersionText,
      attachMode: AttachMode.middle,
      offset: Offset(-25, 0),
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: hasBuilds ? translations.promptPlayVersionActionLabelHasBuilds : translations.promptPlayVersionActionLabelNoBuilds,
          onTap: () async {
            onClose();
            if(!hasBuilds) {
              await VersionSelector.openDownloadDialog();
            }
            _promptHostAccount();
          }
      )
  );
}



void _promptHostAccount() {
  pageIndex.value = PageType.host.index;
  profileOverlayKey.currentState!.showOverlay(
      text: translations.hostAccountText,
      offset: Offset(27.5, 17.5),
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.hostAccountAction,
          onTap: () async {
            onClose();
            _promptHostPage();
          }
      )
  );
}

void _promptHostPage() {
  pageOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptHostPageText,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptHostPageActionLabel,
          onTap: () {
            onClose();
            _promptHostVersion();
          }
      )
  );
}

void _promptHostVersion() {
  hostVersionOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptHostVersionText,
      attachMode: AttachMode.end,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptHostVersionActionLabel,
          onTap: () {
            onClose();
            _promptBackendPage();
          }
      )
  );
}

void _promptBackendPage() {
  pageIndex.value = PageType.backend.index;
  pageOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptBackendPageText,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptBackendPageActionLabel,
          onTap: () {
            onClose();
            _promptBackendTypePage();
          }
      )
  );
}

void _promptBackendTypePage() {
  backendTypeOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptBackendTypePageText,
      attachMode: AttachMode.end,
      offset: Offset(-25, 0),
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptBackendTypePageActionLabel,
          onTap: () {
            onClose();
            _promptInfoTab();
          }
      )
  );
}

void _promptInfoTab() {
  pageIndex.value = PageType.info.index;
  pageOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptInfoTabText,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptInfoTabActionLabel,
          onTap: () {
            onClose();
            _promptSettingsTab();
          }
      )
  );
}

void _promptSettingsTab() {
  pageIndex.value = PageType.settings.index;
  pageOverlayTargetKey.currentState!.showOverlay(
      text: translations.promptSettingsTabText,
      actionBuilder: (context, onClose) => _buildActionButton(
          context: context,
          label: translations.promptSettingsTabActionLabel,
          onTap: onClose
      )
  );
}

Widget _buildActionButton({
  required BuildContext context,
  required String label,
  bool themed = true,
  required void Function() onTap,
}) => Button(
    style: themed ? ButtonStyle(
        backgroundColor: WidgetStateProperty.all(FluentTheme.of(context).accentColor)
    ) : null,
    child: Text(label),
    onPressed: onTap
);
