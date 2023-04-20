import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio()..options.baseUrl = 'https://api.github.com';
}

@riverpod
GithubRepository githubRepository(GithubRepositoryRef ref) {
  return GithubRepository(ref.watch(dioProvider), ref);
}

final repoProvider =
    StateNotifierProvider.autoDispose<RepoNotifier, Repo>((ref) {
  ref.keepAlive();
  return RepoNotifier(const Repo(owner: 'flutter', name: 'flutter'));
});

@riverpod
Future<List<PullRequest>> closedPullRequests(ClosedPullRequestsRef ref) async {
  final gitHubService = ref.watch(githubRepositoryProvider);
  final repo = ref.watch(repoProvider);
  return gitHubService.getClosedPullRequests(repo);
}

final searchStatusCodeProvider = StateProvider.autoDispose<int?>((ref) {
  ref.keepAlive();
  return null;
});
