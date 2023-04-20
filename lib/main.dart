import 'package:beamer/beamer.dart';
// import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/github_theme.dart';
import 'package:github_pr_dashboard/screens/main_screen.dart';
import 'package:github_pr_dashboard/screens/search_screen.dart';
import 'package:github_pr_dashboard/screens/settings_screen.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) {
          final initialIndex =
              state.queryParameters['tab'] == 'settings' ? 1 : 0;
          return HomeScreen(initialIndex: initialIndex);
        },
        '/search': (context, state, data) {
          return BeamPage(
            key: const ValueKey('search'),
            title: "SearchScreen",
            child: const SearchScreen(),
            onPopPage: (context, delegate, _, page) {
              delegate.update(
                configuration: const RouteInformation(
                  location: '/?tab=pr',
                ),
                rebuild: false,
              );
              return true;
            },
          );
        }
      },
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const githubTheme = GithubTheme();
    return MaterialApp.router(
      title: 'Github Cloded PR Dashboard',
      theme: githubTheme.toThemeData(),
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(
        delegate: routerDelegate,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, required this.initialIndex});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _settingController;
  late AnimationController _homeController;
  late AnimationController _searchController;
  late AnimationController _filterController;
  final TextEditingController _controllerRepository = TextEditingController();
  bool showSearchBar = false;
  bool isBottomSheetOpen = false;
  PersistentBottomSheetController<void>? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _settingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _homeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _searchController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _filterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _settingController.dispose();
    _homeController.dispose();
    _searchController.dispose();
    _filterController.dispose();
    _controllerRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? AppBarTitle(
                controller: _controllerRepository,
                showSearchBar: showSearchBar,
              )
            : null,
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.beamToNamed('/search')),
          Builder(
            builder: (context) => IconButton(
              splashRadius: 50,
              // iconSize: 100,
              icon: Lottie.asset('assets/menuV4.json',
                  controller: _filterController, fit: BoxFit.contain),
              onPressed: () {
                // Controlling BottomSheet
                if (isBottomSheetOpen) {
                  _bottomSheetController?.close();
                  setState(() {
                    isBottomSheetOpen = false;
                  });
                  return;
                } else {
                  setState(() {
                    isBottomSheetOpen = true;
                  });
                  _filterController.reset();
                  _filterController.forward();
                }

                _bottomSheetController =
                    Scaffold.of(context).showBottomSheet<void>(
                  constraints: const BoxConstraints(maxWidth: 640),
                  elevation: 8,
                  enableDrag: true,
                  clipBehavior: Clip
                      .antiAliasWithSaveLayer, // for ripple to overflow out of bottomsheet
                  (context) {
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(
                                icon: Icon(Icons.filter),
                                text: "Filter",
                              ),
                              Tab(
                                icon: Icon(Icons.sort),
                                text: "Sort",
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 200,
                            child: TabBarView(
                              children: [
                                Center(child: Text('Home')),
                                Center(child: Text('Star')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
                _bottomSheetController?.closed
                    .then((_) => _filterController.reverse());
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
          index: _currentIndex,
          children: [MainScreen(), const SettingsScreen()]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() => _currentIndex = index);
            Beamer.of(context).update(
              configuration: RouteInformation(
                location: index == 0 ? '/?tab=pr' : '/?tab=settings',
              ),
              rebuild: false,
            );
            if (index == 0) {
              _settingController.reverse();
              if (_homeController.status == AnimationStatus.dismissed) {
                _homeController.reset();
                _homeController.forward();
              } else {
                _homeController.reverse();
              }
            } else if (index == 1) {
              _homeController.forward();
              if (_settingController.status == AnimationStatus.dismissed) {
                _settingController.reset();
                _settingController.forward();
              } else {
                _settingController.reverse();
              }
            }
          },
          destinations: <Widget>[
            NavigationDestination(
              icon: Lottie.asset('assets/home.json',
                  width: 28, controller: _homeController, fit: BoxFit.contain),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Lottie.asset('assets/settingsV2.json',
                  controller: _settingController, fit: BoxFit.contain),
              label: 'Settings',
            ),
          ]),
      // Tried with Flashybar but ascthetics of Material 3 are better
      // FlashyTabBar(
      //   animationCurve: Curves.linear,
      //   selectedIndex: _currentIndex,
      //   iconSize: 30,
      //   onItemSelected: (index) {
      //     setState(() => _currentIndex = index);
      //     _routerDelegates[_currentIndex].update(rebuild: false);
      //   },
      //   items: [
      //     FlashyTabBarItem(
      //       icon: const Icon(Icons.event),
      //       title: const Text('Events'),
      //     ),
      //     FlashyTabBarItem(
      //       icon: const Icon(Icons.settings),
      //       title: const Text('Settings'),
      //     ),
      //   ],
      // ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  final bool showSearchBar;
  final TextEditingController controller;
  AppBarTitle(
      {super.key, required this.showSearchBar, required this.controller});

  final githubIcon = SvgPicture.asset(
    "assets/mark-github.svg",
    width: 24,
    semanticsLabel: 'Github Icon',
    fit: BoxFit.contain,
  );

  @override
  Widget build(BuildContext context) {
    return Row(children: [githubIcon, const Text(" PR Dashboard")]);
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}
