// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administrator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Administrator _$AdministratorFromJson(Map<String, dynamic> json) =>
    Administrator(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AdministratorToJson(Administrator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'roles': instance.roles,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

Role _$RoleFromJson(Map<String, dynamic> json) =>
    Role(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

PaginatedAdministrators _$PaginatedAdministratorsFromJson(
  Map<String, dynamic> json,
) => PaginatedAdministrators(
  data: (json['data'] as List<dynamic>)
      .map((e) => Administrator.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedAdministratorsToJson(
  PaginatedAdministrators instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      currentPage: (json['current_page'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      from: (json['from'] as num).toInt(),
      to: (json['to'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'from': instance.from,
      'to': instance.to,
    };
