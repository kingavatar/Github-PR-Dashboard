import 'package:flutter/material.dart';
import 'package:github_pr_dashboard/animations.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/transitions/bottom_bar.dart';
import 'package:lottie/lottie.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final List<Destination> destinations;
  final BarAnimation barAnimation;
  const MyBottomNavigationBar(
      {super.key,
      required this.selectedIndex,
      required this.onDestinationSelected,
      required this.destinations,
      required this.barAnimation});

  @override
  Widget build(BuildContext context) {
    return BottomBarTransition(
      animation: barAnimation,
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => onDestinationSelected(index),
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: d.icon,
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
