import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        const SettingsListItem(
            title: "General", icon: Icons.tune_outlined, location: "/settings"),
        const SettingsListItem(
            title: "Appearance",
            icon: Icons.palette_outlined,
            location: "/settings"),
        const AboutListItem()
      ],
    );
  }
}

class SettingsListItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String location;

  const SettingsListItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          onTap: () {},
        ));
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
