import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_pr_dashboard/models.dart';
import 'package:github_pr_dashboard/providers.dart';

class GithubRepository {
  final Dio _dio;
  final Ref _ref;

  const GithubRepository(this._dio, this._ref);

  Future<List<PullRequest>> getClosedPullRequests(Repo repo) async {
    final response = await _dio.get('/repos/${repo.owner}/${repo.name}/pulls',
        queryParameters: {
          'state': 'closed',
          'sort': 'updated',
          'direction': 'desc'
        });

    if (response.statusCode == 200) {
      return List<PullRequest>.from(response.data
          .map((pullRequest) => PullRequest.fromJson(pullRequest)));
    } else {
      throw Exception('Failed to fetch closed pull requests');
    }
  }
}
