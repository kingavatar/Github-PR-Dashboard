import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PullRequest {
  final int id;
  final int number;
  final String title;
  final DateTime createdAt;
  final DateTime closedAt;
  final DateTime updatedAt;
  final String userName;
  final String userImage;
  final String state;
  final DateTime? mergedAt;

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
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
        id: json['id'],
        number: json['number'],
        title: json['title'],
        createdAt: DateTime.parse(json['created_at']),
        closedAt: DateTime.parse(json['closed_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        userName: json['user']['login'],
        userImage: json['user']['avatar_url'],
        state: json['state'],
        mergedAt: json['merged_at'] != null
            ? DateTime.parse(json['merged_at'])
            : null);
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
