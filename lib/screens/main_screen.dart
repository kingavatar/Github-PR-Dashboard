import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';
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

// Color color1 = Color(0xFF1D7F3A);
  final closedPullRequestIcon = SvgPicture.asset(
    "assets/git-pull-request-closed.svg",
    semanticsLabel: 'Pull Request Closed Icon',
    colorFilter: const ColorFilter.mode(
        Color(0xFFCE2331), BlendMode.srcIn), // Color(0xFFA571F5)
  );

  final mergedPullRequestIcon = SvgPicture.asset("assets/git-merge.svg",
      semanticsLabel: 'Pull Request Merged Icon',
      colorFilter: const ColorFilter.mode(Color(0xFF8450DD), BlendMode.srcIn));
  // Color(0xFFF5504B)

  @override
  void initState() {
    super.initState();
    _notFoundController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
    _loadingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat();
  }

  @override
  void dispose() {
    _notFoundController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closedPullRequests = ref.watch(closedPullRequestsProvider);
    return closedPullRequests.when(
      data: (data) => ListView.separated(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final PullRequest pullRequest = data[index];
          return ListTile(
            leading: pullRequest.mergedAt != null
                ? mergedPullRequestIcon
                : closedPullRequestIcon,
            title: Text("${pullRequest.title} #${pullRequest.number}"),
            subtitle: Text(
                "by ${pullRequest.userName} at ${timeago.format(pullRequest.updatedAt)}"),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
      loading: () => Center(
          child: Lottie.asset('assets/loadingV2.json',
              controller: _loadingController, fit: BoxFit.scaleDown)),
      error: (error, stackTrace) => Center(
          child: (error as DioError).response?.statusCode == 404
              ? SizedBox(
                  width: 200,
                  child: Lottie.asset('assets/404.json',
                      controller: _notFoundController, fit: BoxFit.contain),
                )
              : null),
    );
  }
}
