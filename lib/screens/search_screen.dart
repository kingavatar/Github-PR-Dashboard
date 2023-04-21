import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_pr_dashboard/providers.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  late AnimationController _searchController;
  late AnimationController _notFoundController;
  late AnimationController _loadingController;

  bool completedSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _notFoundController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
    _loadingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notFoundController.dispose();
    _loadingController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkRepo = ref.watch(checkRepoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              final repo = value.split("/");
              if (repo.length != 2) {
              } else {
                ref
                    .read(repoProvider.notifier)
                    .updateRepo(owner: repo[0], name: repo[1]);
                setState(() => completedSearching = true);
              }
              
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (_searchController.status == AnimationStatus.dismissed) {
                  _searchController.reset();
                  _searchController.forward();
                }
              } else {
                _searchController.reverse();
                setState(() => completedSearching = false);
              }
            },
            decoration: InputDecoration(
              suffixIcon: _ClearButton(
                  controller: controller, searchController: _searchController),
              hintText: 'Enter (e.g. flutter/flutter)',
            ),
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final addDark = ref.watch(isDarkModeProvider) ? '-dark' : '';
          return checkRepo.when(
        data: (data) {
          if (completedSearching && data) {
            Navigator.of(context).maybePop();
          } else if (completedSearching && !data) {
            return Center(
              child: SizedBox(
                width: 200,
                    child: Lottie.asset('assets/404$addDark.json',
                    controller: _notFoundController, fit: BoxFit.contain),
              ),
            );
          }
              return Container();
        },
        loading: () => Center(
                child: Lottie.asset('assets/loadingV2$addDark.json',
                controller: _loadingController, fit: BoxFit.scaleDown)),
        error: (error, stackTrace) => Center(
            child: (error as DioError).response?.statusCode == 404
                ? SizedBox(
                    width: 200,
                        child: Lottie.asset('assets/404$addDark.json',
                        controller: _notFoundController, fit: BoxFit.contain),
                  )
                : null),
          );
        },
      ),
    );
  }
}

class _ClearButton extends ConsumerWidget {
  const _ClearButton(
      {required this.controller, required this.searchController});

  final TextEditingController controller;
  final AnimationController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addDark = ref.watch(isDarkModeProvider) ? '-dark' : '';
    return IconButton(
      icon: Lottie.asset('assets/searchToX$addDark.json',
            controller: searchController, fit: BoxFit.scaleDown),
        onPressed: () {
          controller.clear();
          searchController.reverse();
        },
    );
  }
}
