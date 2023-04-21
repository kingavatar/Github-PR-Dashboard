import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';

class GithubRepository {
  final Dio _dio;
  final Ref _ref;

  const GithubRepository(this._dio, this._ref);

  Future<List<PullRequest>> getClosedPullRequests(
      {required Repo repo, required PullRequestOptions options}) async {
    try {
      final response = await _dio
          .get('/repos/${repo.owner}/${repo.name}/pulls', queryParameters: {
        'state': options.state.name,
        'sort': options.sort.name,
        'direction': options.direction.name,
        'page': options.page
      });

      if (response.statusCode == 200) {
        return List<PullRequest>.from(response.data
            .map((pullRequest) => PullRequest.fromJson(pullRequest)));
      } else {
        if (response.statusCode == 404) {
          return List<PullRequest>.empty();
        }
        throw Exception('Failed to fetch closed pull requests');
      }
    } catch (error) {
      if (error is DioError) {
        if (error.response?.statusCode == 404) {
          return List<PullRequest>.empty();
        }
      }
      throw Exception('Failed to check if Repo Exists');
    }
  }

  Future<bool> checkRepoExists({required repo}) async {
    try {
      final response = await _dio.get('/repos/${repo.owner}/${repo.name}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to check if Repo Exists');
      }
    } catch (error) {
      return false;
    }
  }
}
