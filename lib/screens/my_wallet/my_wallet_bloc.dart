import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_wallet/network/repository/wallet_repository.dart';
import 'package:viet_wallet/network/response/get_list_wallet_response.dart';

import 'my_wallet_event.dart';
import 'my_wallet_state.dart';

class MyWalletPageBloc extends Bloc<MyWalletPageEvent, MyWalletPageState> {
  final _walletRepository = WalletRepository();

  MyWalletPageBloc(BuildContext context) : super(MyWalletPageState()) {
    on((event, emit) async {
      if (event is GetListWalletEvent) {
        emit(state.copyWith(isLoading: true));
        ConnectivityResult networkStatus =
            await Connectivity().checkConnectivity();
        if (networkStatus == ConnectivityResult.none) {
          emit(state.copyWith(
            isLoading: false,
            isNoInternet: true,
          ));
          return;
        }
        final response = await _walletRepository.getListWallet();
        if (response is GetListWalletResponse) {
          emit(state.copyWith(
            isLoading: false,
            isNoInternet: false,
            moneyTotal: response.moneyTotal,
            listWallet: response.walletList,
          ));
        }
      }
      if (event is RemoveWalletEvent) {
        emit(state.copyWith(isLoading: true));
        final networkStatus = await Connectivity().checkConnectivity();
        if (networkStatus == ConnectivityResult.none) {
          emit(state.copyWith(
            isLoading: false,
            isNoInternet: true,
          ));
          return;
        }
        if (event.walletId == null) {
          return;
        }
        await _walletRepository.removeWalletWithID(walletId: event.walletId!);
      }
    });
  }
}
