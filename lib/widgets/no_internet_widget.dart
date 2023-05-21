import 'package:flutter/material.dart';

import '../utilities/app_constants.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 32.0),
            child: Text(
              AppConstants.noInternetTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.wifi_off,
            size: 150,
            color: Colors.grey,
          ),
          Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: Text(
              AppConstants.noInternetContent,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
