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

final optionsProvider = StateNotifierProvider.autoDispose<
    PullRequestOptionsNotifier, PullRequestOptions>((ref) {
  ref.keepAlive();
  return PullRequestOptionsNotifier(PullRequestOptions(
      state: PullRequestState.closed,
      sort: PullRequestSort.updated,
      direction: PullRequestSortDirection.desc,
      page: 1));
});

@riverpod
Future<bool> checkRepo(CheckRepoRef ref) async {
  final gitHubService = ref.watch(githubRepositoryProvider);
  final repo = ref.watch(repoProvider);
  return gitHubService.checkRepoExists(repo: repo);
}
