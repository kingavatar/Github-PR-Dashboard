// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'4619a38722412da54e429a9d6f2339f4fcd69361';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$githubRepositoryHash() => r'2ed4418d0a7b142024a534a05d1bd74b37a5cda8';

/// See also [githubRepository].
@ProviderFor(githubRepository)
final githubRepositoryProvider = AutoDisposeProvider<GithubRepository>.internal(
  githubRepository,
  name: r'githubRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$githubRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GithubRepositoryRef = AutoDisposeProviderRef<GithubRepository>;
String _$closedPullRequestsHash() =>
    r'84bbcb90cf3772d911b6c6f5afd9fff275eda3b8';

/// See also [closedPullRequests].
@ProviderFor(closedPullRequests)
final closedPullRequestsProvider =
    AutoDisposeFutureProvider<List<PullRequest>>.internal(
  closedPullRequests,
  name: r'closedPullRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$closedPullRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClosedPullRequestsRef = AutoDisposeFutureProviderRef<List<PullRequest>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
