import 'package:beamer/beamer.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/animations.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';
import 'package:github_pr_dashboard/screens/main_details.dart';
import 'package:github_pr_dashboard/screens/main_screen.dart';
import 'package:github_pr_dashboard/screens/search_screen.dart';
import 'package:github_pr_dashboard/screens/settings_screen.dart';
import 'package:github_pr_dashboard/widgets/navigation_bar.dart';
import 'package:github_pr_dashboard/widgets/navigation_rail.dart';
import 'package:lottie/lottie.dart';

void main() {
  Beamer.setPathUrlStrategy();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    setBrowserTabTitle: false,
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
                rebuild: true,
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
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      final dynamicColor = ref.watch(dynamicColorProvider);
      return MaterialApp.router(
        title: 'Github Closed PR Dashboard',
        theme: ThemeData(
            colorSchemeSeed: dynamicColor ? null : const Color(0XFF0D1117),
            colorScheme: dynamicColor ? lightColorScheme : null,
            brightness: Brightness.light,
            useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: dynamicColor ? null : const Color(0XFF0D1117),
            colorScheme: dynamicColor ? darkColorScheme : null,
            brightness: Brightness.dark,
            useMaterial3: true),
        themeMode: ref.watch(themModeProvider),
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(
          delegate: routerDelegate,
        ),
      );
    });
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, required this.initialIndex});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _settingController;
  late AnimationController _homeController;
  late AnimationController _searchController;
  late AnimationController _filterController;
  final TextEditingController _controllerRepository = TextEditingController();
  bool showSearchBar = false;
  bool isBottomSheetOpen = false;
  PersistentBottomSheetController<void>? _bottomSheetController;
  late final _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 1250),
      value: 0,
      vsync: this);
  late final _railAnimation = RailAnimation(parent: _controller);
  late final _barAnimation = BarAnimation(parent: _controller);
  bool controllerInitialized = false;

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
    _controller.dispose();
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final AnimationStatus status = _controller.status;
    if (MediaQuery.of(context).size.width > 600) {
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        _controller.forward();
      }
    } else {
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        _controller.reverse();
      }
    }
    if (!controllerInitialized) {
      controllerInitialized = true;
      _controller.value = MediaQuery.of(context).size.width > 600 ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addDark = ref.watch(isDarkModeProvider) ? '-dark' : '';
    final List<Destination> destinations = <Destination>[
      Destination(
          icon: Lottie.asset('assets/home$addDark.json',
              width: 28, controller: _homeController, fit: BoxFit.contain),
          label: "Home"),
      Destination(
          icon: Lottie.asset('assets/settingsV2$addDark.json',
              controller: _settingController, fit: BoxFit.contain),
          label: "Settings")
    ];
    return WillPopScope(
      onWillPop: () async {
        final confirmOnExit = ref.watch(confirmOnExitProvider);
        if (!confirmOnExit) {
          return true;
        }
        if (isBottomSheetOpen) {
          _bottomSheetController?.close();
          setState(() {
            isBottomSheetOpen = false;
          });
          return false;
        }
        final value = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('Are you sure you want to exit?'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('No'),
                  onPressed: () {
                    Beamer.of(context).navigator.pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Yes, exit'),
                  onPressed: () {
                    // call this to exit app
                    FlutterExitApp.exitApp();
                  },
                ),
              ],
            );
          },
        );

        return value == true;
      },
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                MyNavigationRail(
                  railAnimation: _railAnimation,
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
                      if (_settingController.status ==
                          AnimationStatus.dismissed) {
                        _settingController.reset();
                        _settingController.forward();
                      } else {
                        _settingController.reverse();
                      }
                    }
                  },
                  destinations: destinations,
                ),
                Expanded(
                  child: Scaffold(
                    appBar: displayOnlyHome(
                      AppBar(
                        title: AppBarTitle(),
                        actions: [
                          IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () => context.beamToNamed('/search')),
                          Builder(
                            builder: (context) => Consumer(
                              builder: (context, ref, child) {
                                final addDark = ref.watch(isDarkModeProvider)
                                    ? '-dark'
                                    : '';
                                return IconButton(
                                  splashRadius: 50,
                                  // iconSize: 100,
                                  icon: Lottie.asset(
                                      'assets/menuV4$addDark.json',
                                      controller: _filterController,
                                      fit: BoxFit.contain),
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
                                        Scaffold.of(context)
                                            .showBottomSheet<void>(
                                      constraints:
                                          const BoxConstraints(maxWidth: 640),
                                      elevation: 8,
                                      enableDrag: true,
                                      clipBehavior: Clip
                                          .antiAliasWithSaveLayer, // for ripple to overflow out of bottomsheet
                                      (context) {
                                        return const BottomModalWidget();
                                      },
                                    );
                                    _bottomSheetController?.closed.then(
                                        (_) => _filterController.reverse());
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: IndexedStack(
                      index: _currentIndex,
                      children: const [
                        MainScreen(),
                        SettingsScreen(),
                      ],
                    ),
                    bottomNavigationBar: MyBottomNavigationBar(
                      barAnimation: _barAnimation,
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (int index) {
                        setState(() => _currentIndex = index);
                        Beamer.of(context).update(
                          configuration: RouteInformation(
                            location:
                                index == 0 ? '/?tab=pr' : '/?tab=settings',
                          ),
                          rebuild: false,
                        );
                        if (index == 0) {
                          _settingController.reverse();
                          if (_homeController.status ==
                              AnimationStatus.dismissed) {
                            _homeController.reset();
                            _homeController.forward();
                          } else {
                            _homeController.reverse();
                          }
                        } else if (index == 1) {
                          _homeController.forward();
                          if (_settingController.status ==
                              AnimationStatus.dismissed) {
                            _settingController.reset();
                            _settingController.forward();
                          } else {
                            _settingController.reverse();
                          }
                        }
                      },
                      destinations: destinations,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class AppBarTitle extends ConsumerWidget {
  AppBarTitle({super.key});

  SvgPicture githubIcon(Color color) {
    return SvgPicture.asset(
      "assets/mark-github.svg",
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      width: 24,
      semanticsLabel: 'Github Icon',
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repoProvider);
    final isDark = ref.watch(isDarkModeProvider);
    return Row(children: [
      githubIcon(isDark ? const Color(0XFFFFFFFF) : const Color(0XFF000000)),
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
