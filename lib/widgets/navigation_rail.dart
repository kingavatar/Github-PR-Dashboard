import 'package:flutter/material.dart';
import 'package:github_pr_dashboard/animations.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/transitions/nav_rail.dart';

class MyNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final List<Destination> destinations;
  final RailAnimation railAnimation; // Add this variable

  const MyNavigationRail(
      {super.key,
      required this.selectedIndex,
      required this.onDestinationSelected,
      required this.destinations,
      required this.railAnimation});

  @override
  Widget build(BuildContext context) {
    return NavRailTransition(
      animation: railAnimation,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        // backgroundColor: backgroundColor,
        onDestinationSelected: onDestinationSelected,
        // leading: Column(
        //   children: [
        //     IconButton(
        //       onPressed: () {},
        //       icon: const Icon(Icons.menu),
        //     ),
        //     const SizedBox(height: 8),
        //     FloatingActionButton(
        //       shape: const RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(
        //           Radius.circular(15),
        //         ),
        //       ),
        //       backgroundColor: colorScheme.tertiaryContainer,
        //       foregroundColor: colorScheme.onTertiaryContainer,
        //       onPressed: () {},
        //       child: const Icon(Icons.add),
        //     ),
        //   ],
        // ),
        groupAlignment: -0.2,
        destinations: destinations.map((d) {
          return NavigationRailDestination(
            icon: d.icon,
            label: Text(d.label),
          );
        }).toList(),
        labelType: NavigationRailLabelType.selected,
      ),
    );
  }
}
