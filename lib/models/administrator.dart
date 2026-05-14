/// Administrator Model
///
/// Represents an admin user in the system
library;

import 'package:json_annotation/json_annotation.dart';

part 'administrator.g.dart';

@JsonSerializable()
class Administrator {
  final int id;
  final String name;
  final String email;
  final List<Role>? roles;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Administrator({
    required this.id,
    required this.name,
    required this.email,
    this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory Administrator.fromJson(Map<String, dynamic> json) =>
      _$AdministratorFromJson(json);

  Map<String, dynamic> toJson() => _$AdministratorToJson(this);

  Administrator copyWith({
    int? id,
    String? name,
    String? email,
    List<Role>? roles,
    String? createdAt,
    String? updatedAt,
  }) {
    return Administrator(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get primary role name
  String? get primaryRole =>
      roles?.isNotEmpty == true ? roles!.first.name : null;
}

@JsonSerializable()
class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class PaginatedAdministrators {
  final List<Administrator> data;
  final PaginationMeta meta;

  PaginatedAdministrators({required this.data, required this.meta});

  factory PaginatedAdministrators.fromJson(Map<String, dynamic> json) =>
      _$PaginatedAdministratorsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedAdministratorsToJson(this);
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
