library;

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../models/post.dart';
import 'base_service.dart';

class PostService extends BaseService {
  Future<PaginatedPosts> getPosts({
    int page = 1,
    int perPage = 15,
    String search = '',
    String? status,
  }) async {
    final response = await get(
      ApiConfig.posts,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return PaginatedPosts.fromJson(response);
  }

  Future<Post> getPost(int id) async {
    final response = await get(ApiConfig.postById(id));
    return Post.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Post> createPost(Map<String, dynamic> data) async {
    final response = await post(ApiConfig.posts, data: await _toFormData(data));
    return Post.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Post> updatePost(int id, Map<String, dynamic> data) async {
    final response = await post(
      ApiConfig.postById(id),
      data: await _toFormData({
        ...data,
        '_method': 'PUT',
      }),
    );
    return Post.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<void> deletePost(int id) async {
    await delete(ApiConfig.postById(id));
  }

  Future<Map<String, dynamic>> uploadEditorImage(XFile image) async {
    final formData = FormData.fromMap({
      'upload': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      ),
    });

    return post(ApiConfig.postUploadImage, data: formData);
  }

  Future<Map<String, dynamic>> uploadGalleryImage(int postId, XFile image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      ),
    });

    return post(ApiConfig.postGalleryUpload(postId), data: formData);
  }

  Future<void> deleteGalleryImage(int postId, int imageId) async {
    await delete(ApiConfig.postGalleryDelete(postId, imageId));
  }

  Future<void> reorderGallery(
    int postId,
    List<Map<String, dynamic>> images,
  ) async {
    await post(
      ApiConfig.postGalleryReorder(postId),
      data: {
        'images': images
            .map(
              (image) => {
                'id': image['id'],
                'sort_order': image['sort_order'],
              },
            )
            .toList(),
      },
    );
  }

  Future<FormData> _toFormData(Map<String, dynamic> data) async {
    final map = <String, dynamic>{};

    for (final entry in data.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      if (value is XFile) {
        map[entry.key] = await MultipartFile.fromFile(
          value.path,
          filename: value.name,
        );
        continue;
      }

      if (value is List<int>) {
        for (var i = 0; i < value.length; i++) {
          map['${entry.key}[$i]'] = value[i].toString();
        }
        continue;
      }

      map[entry.key] = value;
    }

    return FormData.fromMap(map);
  }
}

final postService = PostService();
