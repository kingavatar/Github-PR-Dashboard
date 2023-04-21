// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PullRequest {
  final int id;
  final int number;
  final String title;
  final DateTime createdAt;
  final DateTime? closedAt;
  final DateTime updatedAt;
  final String userName;
  final String userImage;
  final String state;
  final DateTime? mergedAt;
  final bool draft;
  final Map<String, dynamic> repoData;

  PullRequest({
    required this.id,
    required this.number,
    required this.title,
    required this.createdAt,
    required this.closedAt,
    required this.updatedAt,
    required this.userName,
    required this.userImage,
    required this.state,
    required this.mergedAt,
      required this.draft,
      required this.repoData
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
        id: json['id'],
        number: json['number'],
        title: json['title'],
        createdAt: DateTime.parse(json['created_at']),
        closedAt: json['closed_at'] != null
            ? DateTime.parse(json['closed_at'])
            : null,
        updatedAt: DateTime.parse(json['updated_at']),
        userName: json['user']['login'],
        userImage: json['user']['avatar_url'],
        state: json['state'],
        mergedAt: json['merged_at'] != null
            ? DateTime.parse(json['merged_at'])
            : null,
        draft: json['draft'],
        repoData: json);
  }
}

@immutable
class Repo {
  final String owner;
  final String name;

  const Repo({
    required this.owner,
    required this.name,
  });

  Repo copyWith({
    String? owner,
    String? name,
  }) {
    return Repo(
      owner: owner ?? this.owner,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'owner': owner,
      'name': name,
    };
  }

  factory Repo.fromMap(Map<String, dynamic> map) {
    return Repo(
      owner: map['owner'] as String,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Repo.fromJson(String source) =>
      Repo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Repo(owner: $owner, name: $name)';

  @override
  bool operator ==(covariant Repo other) {
    if (identical(this, other)) return true;

    return other.owner == owner && other.name == name;
  }

  @override
  int get hashCode => owner.hashCode ^ name.hashCode;
}

class RepoNotifier extends StateNotifier<Repo> {
  RepoNotifier(super.state);

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateOwner(String owner) {
    state = state.copyWith(owner: owner);
  }

  void updateRepo({String name = '', String owner = ''}) {
    state = state.copyWith(owner: owner, name: name);
  }
}

enum PullRequestState { open, closed, all }

enum PullRequestSort { created, updated, popularity, longRunning }

enum PullRequestSortDirection { asc, desc }

class PullRequestOptions {
  final PullRequestState state;
  final PullRequestSort sort;
  final PullRequestSortDirection direction;

  PullRequestOptions({
    required this.state,
    required this.sort,
    required this.direction,
  });

  PullRequestOptions copyWith({
    PullRequestState? state,
    PullRequestSort? sort,
    PullRequestSortDirection? direction,
  }) {
    return PullRequestOptions(
      state: state ?? this.state,
      sort: sort ?? this.sort,
      direction: direction ?? this.direction,
    );
  }

  @override
  String toString() =>
      'PullRequestOptions(state: $state, sort: $sort, direction: $direction)';

  @override
  bool operator ==(covariant PullRequestOptions other) {
    if (identical(this, other)) return true;

    return other.state == state &&
        other.sort == sort &&
        other.direction == direction;
  }

  @override
  int get hashCode => state.hashCode ^ sort.hashCode ^ direction.hashCode;
}

class PullRequestOptionsNotifier extends StateNotifier<PullRequestOptions> {
  PullRequestOptionsNotifier(super.state);

  void updateState(PullRequestState pullState) {
    state = state.copyWith(state: pullState);
  }

  void updateSort(PullRequestSort sort) {
    state = state.copyWith(sort: sort);
  }

  void updateDirection(PullRequestSortDirection direction) {
    state = state.copyWith(direction: direction);
  }

  void updateOptions(PullRequestOptions options) {
    state = state.copyWith(
        state: options.state, sort: options.sort, direction: options.direction);
  }
}
