import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_pr_dashboard/providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>((states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.dark_mode_outlined);
    }
    return const Icon(Icons.light_mode_outlined);
  });

  bool? _useDarkTheme;
  bool get useLightMode {
    switch (ref.read(themModeProvider)) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamicColor = ref.watch(dynamicColorProvider);
    final confirmOnExit = ref.watch(confirmOnExitProvider);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Icon(
            color: Theme.of(context).colorScheme.tertiary,
            size: 56,
            Icons.account_tree,
          ),
        ),
        const Divider(),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.exit_to_app_outlined),
            title: const Text("Confirm On Exit"),
            trailing: Switch(
              value: confirmOnExit,
              onChanged: (value) => ref
                  .read(confirmOnExitProvider.notifier)
                  .update((state) => value),
            ),
          ),
        ),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text("Material You"),
            trailing: Switch(
              value: dynamicColor,
              onChanged: (value) => ref
                  .read(dynamicColorProvider.notifier)
                  .update((state) => value),
            ),
          ),
        ),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(CupertinoIcons.paintbrush),
            title: const Text("Theme"),
            trailing: Switch(
              thumbIcon: thumbIcon,
              value: _useDarkTheme ?? !useLightMode,
              onChanged: (value) {
                setState(() {
                  _useDarkTheme = value;
                });
                if (value) {
                  ref
                      .read(themModeProvider.notifier)
                      .update((state) => ThemeMode.dark);
                } else {
                  ref
                      .read(themModeProvider.notifier)
                      .update((state) => ThemeMode.light);
                }
              },
            ),
          ),
        ),
        const AboutListItem()
      ],
    );
  }
}

class AboutListItem extends StatefulWidget {
  const AboutListItem({super.key});

  @override
  State<StatefulWidget> createState() => _AboutListItemState();
}

class _AboutListItemState extends State<AboutListItem> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: AboutListTile(
          icon: const Icon(Icons.info_outlined),
          applicationIcon: const Icon(Icons.account_tree),
          applicationName: _packageInfo.appName,
          applicationVersion: _packageInfo.version,
          applicationLegalese: '\u{a9} 2023 Saikiran Reddy',
          aboutBoxChildren: [
            ListTile(
              title: const Text("Version"),
              subtitle: Text(
                  "Build Number : ${_packageInfo.buildNumber}\nBuild Signature: ${_packageInfo.buildSignature}"),
              isThreeLine: true,
            ),
            ListTile(
              title: const Text("Installer"),
              subtitle:
                  Text("Store : ${_packageInfo.installerStore ?? '¯\\(ツ)/¯'}"),
              isThreeLine: true,
            )
          ]),
    );
  }
}
