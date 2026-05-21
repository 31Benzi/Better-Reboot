import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/tile/setting_tile.dart';
import 'package:reboot_launcher/src/pager/abstract_page.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends AbstractPage {
  const InfoPage({Key? key}) : super(key: key);

  @override
  AbstractPageState<InfoPage> createState() => _InfoPageState();

  @override
  String get name => translations.infoName;

  @override
  String get iconAsset => "assets/images/info.png";

  @override
  bool hasButton(String? routeName) => false;

  @override
  PageType get type => PageType.info;
}

class _InfoPageState extends AbstractPageState<InfoPage> {
  
  @override
  List<SettingTile> get settings => [
    _credits,
    _reportBug
  ];

  SettingTile get _credits => SettingTile(
      icon: Icon(
          FluentIcons.people_24_regular
      ),
      title: const Text('Credits'),
      subtitle: const Text('See who helped build and support Reboot Launcher'),
      onPressed: _openCreditsPage,
      content: Button(
        onPressed: _openCreditsPage,
        child: const Text('View Credits'),
      )
  );

  Future<void> _openCreditsPage() async {
    await Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        settings: const RouteSettings(
            name: 'Credits'
        ),
        pageBuilder: (context, incoming, outgoing) => const CreditsPage()
    ));
  }

  SettingTile get _reportBug => SettingTile(
      icon: Icon(
          FluentIcons.bug_24_regular
      ),
      title: Text(translations.settingsUtilsBugReportName),
      subtitle: Text(translations.settingsUtilsBugReportSubtitle),
      content: Button(
        onPressed: _showBugReportDialog,
        child: Text(translations.settingsUtilsBugReportContent),
      )
  );

  void _showBugReportDialog() {
    String discordUsername = "";
    String bugDescription = "";
    List<File> selectedFiles = [];
    bool isSubmitting = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ContentDialog(
              title: const Text('Report a Bug'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(errorMessage!, style: TextStyle(color: Colors.red.normal)),
                      ),
                    const Text('Discord Username'),
                    const SizedBox(height: 4),
                    TextBox(
                      placeholder: 'e.g. benzi#1234',
                      onChanged: (val) => discordUsername = val,
                    ),
                    const SizedBox(height: 12),
                    const Text('What is the bug?'),
                    const SizedBox(height: 4),
                    TextBox(
                      maxLines: 4,
                      placeholder: 'Describe the issue...',
                      onChanged: (val) => bugDescription = val,
                    ),
                    const SizedBox(height: 12),
                    const Text('Files (Images/Videos - Optional)'),
                    const SizedBox(height: 4),
                    Button(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
                        if (result != null) {
                          setState(() {
                            selectedFiles.addAll(result.paths.map((path) => File(path!)));
                          });
                        }
                      },
                      child: const Text('Select Files'),
                    ),
                    const SizedBox(height: 8),
                    if (selectedFiles.isNotEmpty)
                      Text('${selectedFiles.length} file(s) selected', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              actions: [
                Button(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting 
                    ? null 
                    : () async {
                        if (bugDescription.trim().isEmpty) {
                          setState(() => errorMessage = "Please describe the bug.");
                          return;
                        }
                        setState(() {
                          isSubmitting = true;
                          errorMessage = null;
                        });

                        try {
                          var request = http.MultipartRequest('POST', Uri.parse('https://discord.com/api/webhooks/1505348549129273434/2GAaKZx7s0isWrpAC4tiDFzLZyi5wczC56kpF-_3D-4zJY9p5_RJNYHSDrmhDS2TKNcr'));
                          request.fields['content'] = '**New Bug Report**\n**Discord Username:** ${discordUsername.isEmpty ? "Not provided" : discordUsername}\n**Description:**\n$bugDescription';
                          
                          for (var file in selectedFiles) {
                            request.files.add(await http.MultipartFile.fromPath('file${selectedFiles.indexOf(file)}', file.path));
                          }
                          
                          var response = await request.send();
                          if (response.statusCode >= 200 && response.statusCode < 300) {
                            if (context.mounted) Navigator.pop(context);
                          } else {
                            setState(() => errorMessage = "Failed to send report. Status code: ${response.statusCode}");
                          }
                        } catch (e) {
                          setState(() => errorMessage = "Error: $e");
                        } finally {
                          if (context.mounted) setState(() => isSubmitting = false);
                        }
                      },
                  child: isSubmitting ? const ProgressRing() : const Text('Submit'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget? get button => null;
}

class ContributorCard extends StatelessWidget {
  static const String _teamImagePath = r'C:\Users\Benzi\Downloads\reboot_icon_team.png';
  final String name;
  final String handle;
  final String? organization;
  final String description;
  final List<String> projects;
  final String? githubUrl;

  const ContributorCard({
    Key? key,
    required this.name,
    required this.handle,
    this.organization,
    required this.description,
    required this.projects,
    this.githubUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final teamImageFile = File(_teamImagePath);
    final hasTeamImage = teamImageFile.existsSync();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.inactiveColor.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (organization != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      organization!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: hasTeamImage
                          ? Image.file(
                              teamImageFile,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                FluentIcons.person_24_regular,
                                color: theme.accentColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (handle.isNotEmpty)
                          Text(
                            '@$handle',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.inactiveColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (projects.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: projects.map((project) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: theme.micaBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentIcons.link_24_regular,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            project,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (githubUrl != null)
                    Button(
                      onPressed: () => launchUrl(Uri.parse(githubUrl!)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.open_24_regular),
                          const SizedBox(width: 4),
                          Text(handle.isNotEmpty ? 'View @$handle' : 'View Project'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContributorCard(
              name: 'Reboot Team',
              handle: '',
              description: 'This is a fork of the original Reboot Launcher. Full credit for the core structure and original work goes to the Reboot Team.',
              projects: const [],
            ),
          ],
        ),
      ),
    );
  }
}
