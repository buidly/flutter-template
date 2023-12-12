import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

String getAddressFromSession(SessionData? data) {
  final selectedNamespace = data?.namespaces[AppConstants.namespace];

  if (selectedNamespace != null && selectedNamespace.accounts.isNotEmpty) {
    List<String> parts = selectedNamespace.accounts[0].split(':');

    if (parts.length >= 3) {
      return parts[2];
    } else {
      return '';
    }
  }

  return '';
}
