import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:viet_wallet/network/response/collection_response.dart';
import 'package:viet_wallet/screens/new_collection/new_collection_bloc.dart';
import 'package:viet_wallet/screens/new_collection/option_category/option_category_bloc.dart';
import 'package:viet_wallet/utilities/app_constants.dart';
import 'package:viet_wallet/widgets/app_image.dart';
import 'package:viet_wallet/widgets/primary_button.dart';

import '../../network/model/collection_model.dart';
import '../../network/model/wallet.dart';
import '../../network/provider/collection_provider.dart';
import '../../utilities/enum/api_error_result.dart';
import '../../utilities/screen_utilities.dart';
import '../../utilities/shared_preferences_storage.dart';
import '../../utilities/utils.dart';
import 'new_collection_event.dart';
import 'new_collection_state.dart';
import 'option_category/option_category.dart';

class NewCollectionPage extends StatefulWidget {
  final bool isEdit;
  final CollectionModel? collectionReport;

  const NewCollectionPage({
    Key? key,
    this.isEdit = false,
    this.collectionReport,
  }) : super(key: key);

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  final _collectionProvider = CollectionProvider();

  final String _currency = SharedPreferencesStorage().getCurrency() ?? 'VND';

  final _moneyController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showIconClear = false;

  ItemOption itemOption = ItemOption(
    itemId: 0,
    title: 'Chi tiền',
    icon: Icons.remove,
  );
  ItemCategory itemCategorySelected = ItemCategory(
    categoryId: null,
    title: "Chọn hạng mục",
    iconLeading: '',
  );

  String datePicker = formatToLocaleVietnam(DateTime.now());
  String timePicker = DateFormat.Hms().format(DateTime.now());
  DateTime? _datePicked;
  DateTime? _timePicked;

  bool _isMathReport = false;

  int? walletId;
  String? walletName;
  String? walletType;

  void initCollectionEdit() {
    if (widget.collectionReport == null) {
      return;
    }
    setState(() {
      itemOption = (widget.collectionReport?.transactionType == 'EXPENSE')
          ? ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove)
          : ItemOption(itemId: 1, title: 'Thu tiền', icon: Icons.add);
      datePicker = formatToLocaleVietnam(
          DateTime.tryParse(widget.collectionReport?.ariseDate ?? '') ??
              DateTime.now());
      timePicker = DateFormat.Hms().format(
          DateTime.tryParse(widget.collectionReport?.ariseDate ?? '') ??
              DateTime.now());
      _isMathReport = widget.collectionReport?.addToReport ?? false;
      _noteController.text = widget.collectionReport?.description ?? '';
      _moneyController.text = (widget.collectionReport?.amount).toString();
      walletId = widget.collectionReport?.walletId;
      walletName = widget.collectionReport?.walletName;
      walletType = widget.collectionReport?.walletType;
      itemCategorySelected = ItemCategory(
        categoryId: widget.collectionReport?.categoryId,
        title: widget.collectionReport?.categoryName,
        iconLeading: widget.collectionReport?.categoryLogo,
      );
    });
  }

  @override
  void initState() {
    BlocProvider.of<NewCollectionBloc>(context).add(CollectionInit());
    initCollectionEdit();
    _noteController.addListener(() {
      setState(() {
        _showIconClear = _noteController.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewCollectionBloc, NewCollectionState>(
      listenWhen: (preState, curState) {
        return curState.apiError != ApiError.noError;
      },
      listener: (context, curState) {
        if (curState.apiError == ApiError.internalServerError) {
          showMessage1OptionDialog(context, 'Error!',
              content: 'Internal_server_error');
        }
        if (curState.apiError == ApiError.noInternetConnection) {
          showMessage1OptionDialog(context, 'Error!',
              content: 'No_internet_connection');
        }
      },
      builder: (context, curState) {
        return _body(context, curState);
      },
    );
  }

  Widget _body(BuildContext context, NewCollectionState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: widget.isEdit,
          backgroundColor: Theme.of(context).primaryColor,
          leading: widget.isEdit
              ? InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                    color: Colors.white,
                  ),
                )
              : const SizedBox(
                  width: 24,
                ),
          centerTitle: true,
          title: GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => _buildOptionDialog(context),
              );
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    itemOption.title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.isEdit
                  ? const SizedBox(
                      width: 24,
                    )
                  : InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.history,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _money(),
                _select(state),
                _mathReport(),
                _buttonSave(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: widget.isEdit
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrimaryButton(
                  text: 'Xóa',
                  onTap: () {
                    showMessage2OptionDialog(
                      context,
                      'Bạn có muốn xóa giao dịch này?',
                      cancelLabel: 'Hủy',
                      okLabel: 'Xóa',
                      onOK: () async {
                        await _collectionProvider.deleteCollection(
                          collectionId: (widget.collectionReport?.id)!,
                        );
                        Navigator.pop(this.context, 'refresh');
                      },
                    );
                  },
                ),
                PrimaryButton(
                  text: 'Cập nhật',
                  onTap: () async {
                    final Map<String, dynamic> data = {
                      "addToReport": _isMathReport,
                      "amount": double.tryParse(
                          _moneyController.text.trim().toString()),
                      'ariseDate': isNotNullOrEmpty(_getDateTimePicked())
                          ? _getDateTimePicked()
                          : widget.collectionReport?.ariseDate,
                      "categoryId": itemCategorySelected.categoryId,
                      "description": _noteController.text.trim(),
                      "transactionType":
                          (itemOption.itemId == 0) ? 'EXPENSE' : 'INCOME',
                      "walletId": walletId,
                    };

                    final response = await _collectionProvider.updateCollection(
                      collectionId: (widget.collectionReport?.id)!,
                      data: data,
                    );

                    if (response is CollectionModel) {
                      showMessage1OptionDialog(
                        this.context,
                        'Cập nhật giao dịch thành công',
                        onClose: () {
                          Navigator.pop(this.context, 'refresh');
                        },
                      );
                    }
                  },
                ),
              ],
            )
          : PrimaryButton(
              text: 'Lưu',
              onTap: () async {
                if (_moneyController.text.trim().isEmpty) {
                  showMessage1OptionDialog(context, 'Vui lòng nhập số tiền');
                } else if (itemCategorySelected.categoryId == null) {
                  showMessage1OptionDialog(
                    context,
                    'Vui lòng chọn danh mục thu/chi',
                  );
                } else if (walletId == null) {
                  showMessage1OptionDialog(context, 'Vui lòng chọn ví');
                } else {
                  await _postCollection(context);
                }
              },
            ),
    );
  }

  Future<void> _postCollection(BuildContext context) async {
    final Map<String, dynamic> data = {
      "addToReport": _isMathReport,
      "amount": double.tryParse(_moneyController.text.trim().toString()),
      'ariseDate': isNotNullOrEmpty(_getDateTimePicked())
          ? _getDateTimePicked()
          : DateTime.now().toIso8601String(),
      "categoryId": itemCategorySelected.categoryId,
      "description": _noteController.text.trim(),
      "transactionType": (itemOption.itemId == 0) ? 'EXPENSE' : 'INCOME',
      "walletId": walletId
    };

    final response = await _collectionProvider.newCollection(data: data);

    if (response is CollectionResponse) {
      showMessage1OptionDialog(
        this.context,
        'Thêm giao dịch thành công',
        onClose: () {
          reloadPage();
        },
      );
    }
  }

  void reloadPage() {
    setState(() {
      _moneyController.clear();
      _noteController.clear();
      walletId = null;
      walletName = null;
      walletType = null;
      itemCategorySelected = ItemCategory(
          categoryId: null, title: "Chọn hạng mục", iconLeading: '');
      itemOption = ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove);
      datePicker = formatToLocaleVietnam(DateTime.now());
      timePicker = DateFormat.Hms().format(DateTime.now());
    });
  }

  String _getDateTimePicked() {
    if (_datePicked != null && _timePicked != null) {
      return DateTime(
        _datePicked!.year,
        _datePicked!.month,
        _datePicked!.day,
        _timePicked!.hour,
        _timePicked!.minute,
        _timePicked!.second,
      ).toIso8601String();
    } else {
      return '';
    }
  }

  Widget _mathReport() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isMathReport = !_isMathReport;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Không tính vào báo cáo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: FlutterSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      width: 40,
                      height: 20,
                      valueFontSize: 25.0,
                      toggleSize: 18,
                      value: _isMathReport,
                      borderRadius: 10,
                      padding: 2,
                      showOnOff: false,
                      onToggle: (val) {
                        setState(() {
                          _isMathReport = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              AppConstants.mathReport,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _select(NewCollectionState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).backgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectCategory(),
            Divider(
              height: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            _noteHandle(),
            Divider(
              height: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            _pickDateTime(),
            Divider(
              height: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            _selectWallet(state.listWallet),
          ],
        ),
      ),
    );
  }

  Widget _selectCategory() {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BlocProvider(
            create: (context) => OptionCategoryBloc(context),
            child: OptionCategoryPage(
              categoryIdSelected: itemCategorySelected.categoryId,
            ),
          ),
        ).whenComplete(() {
          setState(() {
            itemCategorySelected =
                SharedPreferencesStorage().getItemCategorySelected();
          });
        });
      },
      dense: false,
      horizontalTitleGap: 6,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AppImage(
          localPathOrUrl: itemCategorySelected.iconLeading,
          width: 30,
          height: 30,
          boxFit: BoxFit.cover,
          alignment: Alignment.center,
          errorWidget: const Icon(
            Icons.help_outline,
            color: Colors.grey,
            size: 30,
          ),
        ),
      ),
      title: Text(
        itemCategorySelected.title ?? '',
        style: TextStyle(
          fontSize: 20,
          color: (itemCategorySelected.categoryId != null)
              ? Colors.black
              : Colors.grey,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _noteHandle() {
    return TextField(
      maxLines: null,
      controller: _noteController,
      textAlign: TextAlign.start,
      onChanged: (_) {},
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
      textInputAction: TextInputAction.done,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        // contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        hintText: 'Ghi chú',
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            Icons.event_note,
            size: 30,
            color: Colors.grey,
          ),
        ),
        suffixIcon: _showIconClear
            ? Padding(
                padding: const EdgeInsets.only(left: 6, right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _noteController.clear();
                    });
                  },
                  child: const Icon(
                    Icons.cancel,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _pickDateTime() {
    return ListTile(
      dense: false,
      horizontalTitleGap: 6,
      leading: const Icon(
        Icons.calendar_month,
        size: 30,
        color: Colors.grey,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2000, 01, 01),
                maxTime: DateTime(2025, 12, 30),
                locale: LocaleType.vi,
                currentTime: DateTime.now(),
                onConfirm: (date) {
                  setState(() {
                    datePicker = formatToLocaleVietnam(date);
                    _datePicked = date;
                  });
                },
                onCancel: () {
                  setState(() {});
                },
              );
            },
            child: Text(datePicker),
          ),
          InkWell(
            onTap: () {
              DatePicker.showTimePicker(
                context,
                showTitleActions: true,
                currentTime: DateTime.now(),
                locale: LocaleType.vi,
                onConfirm: (time) {
                  setState(() {
                    timePicker = DateFormat.Hms().format(time);
                    _timePicked = time;
                  });
                },
                onCancel: () {
                  setState(() {});
                },
              );
            },
            child: Text(timePicker),
          ),
        ],
      ),
    );
  }

  Widget _selectWallet(List<Wallet>? listWallet) {
    return ListTile(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                centerTitle: true,
                title: const Text(
                  'Chọn tài khoản',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isNullOrEmpty(listWallet)
                    ? Text(
                        'Không có dữ liệu tài khoản, vui lòng thêm tài khoản mới.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : ListView.builder(
                        itemCount: listWallet!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  walletId = listWallet[index].id;
                                  walletName = listWallet[index].name;
                                  walletType = listWallet[index].accountType;
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).backgroundColor,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Icon(
                                        isNotNullOrEmpty(
                                                listWallet[index].accountType)
                                            ? getIconWallet(
                                                walletType: listWallet[index]
                                                    .accountType,
                                              )
                                            : Icons.help,
                                        size: 30,
                                        color: Colors.grey.withOpacity(0.6),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            listWallet[index].name ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            '${listWallet[index].accountBalance} ${listWallet[index].currency}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (walletId == listWallet[index].id)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Icon(
                                          Icons.check_circle_outline,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
              ),
            ),
          ),
        ).whenComplete(() {
          setState(() {});
        });
      },
      dense: false,
      horizontalTitleGap: 6,
      leading: Icon(
        isNotNullOrEmpty(walletType)
            ? getIconWallet(walletType: walletType!)
            : Icons.help_outline,
        size: 30,
        color: Colors.grey,
      ),
      title: Text(
        walletName ?? 'Chọn tài khoản/ ví',
        style: TextStyle(
          fontSize: 16,
          color: isNotNullOrEmpty(walletName) ? Colors.black : Colors.grey,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _money() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Số tiền:',
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextFormField(
                        controller: _moneyController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        // inputFormatters: [InputFormatter()],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '.00 $_currency',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(8),
      content: Container(
        height: 300,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView.builder(
          itemCount: itemsOption.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  itemOption = itemsOption[index];
                });
                Navigator.pop(context);
              },
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: ListTile(
                      dense: false,
                      visualDensity:
                          const VisualDensity(vertical: -4, horizontal: 0),
                      horizontalTitleGap: 0,
                      minVerticalPadding: -4,
                      selectedColor: Colors.grey.withOpacity(0.3),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              itemsOption[index].icon,
                              size: 24,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              itemsOption[index].title,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: (itemsOption[index].itemId == itemOption.itemId)
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ItemCategory {
  final int? categoryId;
  final String? title;
  final String? iconLeading;

  ItemCategory({
    this.categoryId,
    this.title,
    this.iconLeading,
  });
}

class ItemOption {
  final int itemId;
  final String title;
  final IconData icon;

  ItemOption({
    required this.itemId,
    required this.title,
    required this.icon,
  });
}

List<ItemOption> itemsOption = [
  ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove),
  ItemOption(itemId: 1, title: 'Thu tiền', icon: Icons.add),
  // ItemOption(title: 'Cho vay', icon: Icons.payment),
  // ItemOption(title: 'Đi vay', icon: Icons.currency_exchange),
  // ItemOption(title: 'Chuyển khoản', icon: Icons.swap_horiz_outlined),
  // ItemOption(title: 'Điều chỉnh số dư', icon: Icons.low_priority),
];
