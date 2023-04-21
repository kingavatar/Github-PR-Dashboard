// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'8de6432714fc82b11866738e13143a387bf21f39';

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
String _$checkRepoHash() => r'dda3fec243fe9a182122a6e8f962ec3e0cdd1426';

/// See also [checkRepo].
@ProviderFor(checkRepo)
final checkRepoProvider = AutoDisposeFutureProvider<bool>.internal(
  checkRepo,
  name: r'checkRepoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$checkRepoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CheckRepoRef = AutoDisposeFutureProviderRef<bool>;
String _$isDarkModeHash() => r'93af930defbae2942863608e2b8421fa6e51f0f4';

/// See also [isDarkMode].
@ProviderFor(isDarkMode)
final isDarkModeProvider = AutoDisposeProvider<bool>.internal(
  isDarkMode,
  name: r'isDarkModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isDarkModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsDarkModeRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
