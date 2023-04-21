import 'package:beamer/beamer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _notFoundController;

  static const _pageSize = 30;

  final _pagingController = PagingController<int, PullRequest>(firstPageKey: 1);

  final openPullRequestIcon = SvgPicture.asset(
    "assets/git-pull-request.svg",
    semanticsLabel: 'Pull Request Open Icon',
    colorFilter: const ColorFilter.mode(
        Color(0xFF42B954), BlendMode.srcIn), // Color(0xFF1D7F3A)
  );

  final closedPullRequestIcon = SvgPicture.asset(
    "assets/git-pull-request-closed.svg",
    semanticsLabel: 'Pull Request Closed Icon',
    colorFilter: const ColorFilter.mode(
        Color(0xFFCE2331), BlendMode.srcIn), //Color(0xFFF5504B)
  );

  final mergedPullRequestIcon = SvgPicture.asset("assets/git-merge.svg",
      semanticsLabel: 'Pull Request Merged Icon',
      colorFilter: const ColorFilter.mode(
          Color(0xFF8450DD), BlendMode.srcIn)); //Color(0xFFA571F5)

  final draftPullRequestIcon = SvgPicture.asset(
      "assets/git-pull-request-draft.svg",
      semanticsLabel: 'Pull Request Draft Icon',
      colorFilter: const ColorFilter.mode(
          Color(0xFF7E8590), BlendMode.srcIn)); //Color(0xFF656D76)

  @override
  void initState() {
    super.initState();
    _notFoundController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
    _loadingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }



  Future<void> _fetchPage(int pageKey) async {
    try {
      final gitHubService = ref.read(githubRepositoryProvider);
      final repo = ref.read(repoProvider);
      final options = ref.read(optionsProvider).copyWith(page: pageKey);
      // final newItems = ref.read(closedPullRequestsProvider);
      final newItems = await gitHubService.getClosedPullRequests(
          repo: repo, options: options);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _notFoundController.dispose();
    _loadingController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addDark = ref.watch(isDarkModeProvider) ? '-dark' : '';
    ref.listen(optionsProvider, (previous, next) {
      _pagingController.refresh();
    });
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedListView<int, PullRequest>.separated(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<PullRequest>(
          itemBuilder: (context, item, index) {
            final PullRequest pullRequest = item;
            final leadingIcon = pullRequest.draft
                ? draftPullRequestIcon
                : pullRequest.mergedAt != null
                    ? mergedPullRequestIcon
                    : pullRequest.state == "closed"
                        ? closedPullRequestIcon
                        : openPullRequestIcon;
            return ListTile(
              leading: leadingIcon,
              title: Text("${pullRequest.title} #${pullRequest.number}"),
              subtitle: Text(
                  "by ${pullRequest.userName} at ${timeago.format(pullRequest.updatedAt)}"),
              onTap: () => context.beamToNamed('/pr/${pullRequest.id}',
                  data: pullRequest),
            );
          },
          // firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
          //   error: _pagingController.error,
          //   onTryAgain: () => _pagingController.refresh(),
          // ),
          // newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
          //   error: _pagingController.error,
          //   onTryAgain: () => _pagingController.retryLastFailedRequest(),
          // ),
          firstPageProgressIndicatorBuilder: (_) => Center(
            child: Lottie.asset('assets/loadingV2$addDark.json',
                controller: _loadingController, fit: BoxFit.scaleDown),
          ),
          // newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: SizedBox(
              width: 200,
              child: Lottie.asset('assets/404$addDark.json',
                  controller: _notFoundController, fit: BoxFit.contain),
            ),
          ),
          // noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

// class DioErrorWidget extends StatelessWidget {
//   final Object error;
//   final AnimationController notFoundController;

//   const DioErrorWidget(
//       {super.key, required this.error, required this.notFoundController});

//   @override
//   Widget build(BuildContext context) {
//     if (error is DioError && (error as DioError).response?.statusCode == 404) {
//       return SizedBox(
//         width: 200,
//         child: Lottie.asset('assets/404${addDark()}.json',
//             controller: notFoundController, fit: BoxFit.contain),
//       );
//     }
//     return Text(error.toString());
//   }
// }

