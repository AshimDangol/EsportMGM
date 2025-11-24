import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String theme;
  final String? photoUrl;
  final List<String> friendIds;
  final List<String> bookmarkedClanIds;

  const User({
    required this.id,
    required this.email,
    this.theme = 'system',
    this.photoUrl,
    this.friendIds = const [],
    this.bookmarkedClanIds = const [],
  });

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: map['email'] as String? ?? '',
      theme: map['theme'] as String? ?? 'system',
      photoUrl: map['photoUrl'] as String?,
      friendIds: List<String>.from(map['friendIds'] ?? []),
      bookmarkedClanIds: List<String>.from(map['bookmarkedClanIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'theme': theme,
      'photoUrl': photoUrl,
      'friendIds': friendIds,
      'bookmarkedClanIds': bookmarkedClanIds,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? theme,
    String? photoUrl,
    List<String>? friendIds,
    List<String>? bookmarkedClanIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      theme: theme ?? this.theme,
      photoUrl: photoUrl ?? this.photoUrl,
      friendIds: friendIds ?? this.friendIds,
      bookmarkedClanIds: bookmarkedClanIds ?? this.bookmarkedClanIds,
    );
  }
}
