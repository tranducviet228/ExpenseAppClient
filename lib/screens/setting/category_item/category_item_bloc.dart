import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_wallet/network/provider/category_provider.dart';
import 'package:viet_wallet/utilities/enum/api_error_result.dart';

import '../../../network/response/get_list_category_response.dart';
import 'category_item_event.dart';
import 'category_item_state.dart';

class CategoryItemBloc extends Bloc<CategoryItemEvent, CategoryItemState> {
  final BuildContext context;
  final _categoryProvider = CategoryProvider();

  CategoryItemBloc(this.context) : super(CategoryItemState()) {
    on<CategoryItemEvent>((event, emit) async {
      if (event is CategoryInit) {
        emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(
            state.copyWith(
              isLoading: false,
              apiError: ApiError.noInternetConnection,
            ),
          );
        } else {
          final responseExpense =
              await _categoryProvider.getAllListCategory(param: "EXPENSE");
          if (responseExpense is GetCategoryResponse) {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.noError,
              listExCategory: responseExpense.listCategory,
            ));
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listExCategory: [],
            ));
          }

          final responseIncome =
              await _categoryProvider.getAllListCategory(param: "INCOME");
          if (responseIncome is GetCategoryResponse) {
            emit(
              state.copyWith(
                isLoading: false,
                apiError: ApiError.noError,
                listCoCategory: responseIncome.listCategory,
              ),
            );
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listCoCategory: [],
            ));
          }
        }
      }
    });
  }
}
