import 'package:viet_wallet/network/api/api_path.dart';
import 'package:viet_wallet/network/provider/provider_mixin.dart';
import 'package:viet_wallet/network/response/collection_response.dart';

import '../model/collection_model.dart';
import '../response/base_get_response.dart';

class CollectionProvider with ProviderMixin {
  Future<BaseGetResponse> newCollection({
    required Map<String, dynamic> data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.post(
        ApiPath.transaction,
        data: data,
        options: await defaultOptions(url: ApiPath.transaction),
      );
      return CollectionResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.transaction);
    }
  }

  Future<Object> updateCollection({
    required int collectionId,
    required Map<String, dynamic> data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    final updateById = '${ApiPath.transaction}/$collectionId';
    try {
      final response = await dio.put(
        updateById,
        data: data,
        options: await defaultOptions(url: updateById),
      );
      return CollectionModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, updateById);
    }
  }

  Future<Object> deleteCollection({required int collectionId}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    final deleteById = '${ApiPath.transaction}/$collectionId';
    try {
      return await dio.delete(
        deleteById,
        options: await defaultOptions(url: deleteById),
      );
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, deleteById);
    }
  }
}
