import 'package:beamer/beamer.dart';
// import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/github_theme.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';
import 'package:github_pr_dashboard/screens/main_details.dart';
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
        '/pr/:prId': (context, state, data) {
          final prId = state.pathParameters['prId'];
          return BeamPage(
              key: ValueKey('pr-$prId'),
              title: "Pull Request Details",
              child: PullRequestDetailsScreen(
                pullRequest: (data is PullRequest) ? data : null,
                pullRequestId: prId,
              ),
              onPopPage: (context, delegate, _, page) {
                delegate.update(
                  configuration: const RouteInformation(
                    location: '/?tab=pr',
                  ),
                  rebuild: false,
                );
                return true;
              });
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

// To Display only on Home Page
  T? displayOnlyHome<T>(T widget) {
    if (_currentIndex == 0) {
      return widget;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: displayOnlyHome(AppBarTitle()),
        actions: displayOnlyHome([
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
                    return const BottomModalWidget();
                  },
                );
                _bottomSheetController?.closed
                    .then((_) => _filterController.reverse());
              },
            ),
          ),
        ]),
      ),
      body: IndexedStack(
          index: _currentIndex,
          children: const [MainScreen(), SettingsScreen()]),
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

class AppBarTitle extends ConsumerWidget {
  AppBarTitle({super.key});

  final githubIcon = SvgPicture.asset(
    "assets/mark-github.svg",
    width: 24,
    semanticsLabel: 'Github Icon',
    fit: BoxFit.contain,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repoProvider);
    return Row(children: [
      githubIcon,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "${repo.name}\n",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.grey[700])),
          TextSpan(
              text: "Pull Requests",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ])),
      )
    ]);
  }
}

class BottomModalWidget extends ConsumerWidget {
  const BottomModalWidget({super.key});

  static const stateRadioItems = {
    'Closed': PullRequestState.closed,
    'Open': PullRequestState.open,
    'All': PullRequestState.all
  };

  static const sortRadioItems = {
    'Updated': PullRequestSort.updated,
    'Created': PullRequestSort.created,
    'Popularity': PullRequestSort.popularity,
    'Long Running': PullRequestSort.longRunning
  };

  static const directionRadioItems = {
    'Descending': PullRequestSortDirection.desc,
    'Ascending': PullRequestSortDirection.asc
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(optionsProvider);
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
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                Column(
                    children: stateRadioItems.entries
                        .map((item) => RadioListTile<PullRequestState>(
                              title: Text(item.key),
                              value: item.value,
                              groupValue: options.state,
                              onChanged: (value) {
                                ref.read(optionsProvider.notifier).updateState(
                                    value ?? PullRequestState.closed);
                              },
                            ))
                        .toList()),
                Column(
                  children: <Widget>[
                    const Text("Sort"),
                    ...sortRadioItems.entries
                        .map((item) => RadioListTile<PullRequestSort>(
                              title: Text(item.key),
                              value: item.value,
                              groupValue: options.sort,
                              onChanged: (value) {
                                ref.read(optionsProvider.notifier).updateSort(
                                    value ?? PullRequestSort.updated);
                              },
                            ))
                        .toList(),
                    const Text("Direction"),
                    ...directionRadioItems.entries
                        .map((item) => RadioListTile<PullRequestSortDirection>(
                              title: Text(item.key),
                              value: item.value,
                              groupValue: options.direction,
                              onChanged: (value) {
                                ref
                                    .read(optionsProvider.notifier)
                                    .updateDirection(
                                        value ?? PullRequestSortDirection.desc);
                              },
                            ))
                        .toList(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
