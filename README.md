# Flutter Template Readme

## Project Overview

This Flutter project serves as a template for connecting to xPortal and signing transactions. It supports three flavors: `dev` (devnet), `qa` (testnet), and `prod` (mainnet).

## Getting Started

To begin, use the following command:

````bash
flutter run --flavor <flavor>
```

Replace <flavor> with dev, qa, or prod based on your environment.

## Connection and Authentication

Use the WalletConnectButton widget for connection and disconnection. If separate buttons are needed, interact directly with the WalletConnectBloc:

To connect:
```bash
walletConnectBloc.add(const ConnectWalletEvent());
```

To disconnect:
```bash
walletConnectBloc.add(const DisconnectWalletEvent());
```

If you want to further authenticate your requests, you can use native auth token:
```bash
SharedPreferences.getString(AppConstants.nativeAuthTokenKey);
```

## Transaction Signing
Sign transactions with the SignTransactionButton widget. The TransactionBloc listens to the SignTransactionsEvent event, requiring a list of unsigned transactions.

Note: A dummy EGLD transfer transaction is hardcoded. To test, fill in the sender, receiver, and set the correct nonce for the sender:

```bash
Transaction(
  nonce: 0,
  value: '1000000000000000',
  sender: '', // Fill in sender address
  receiver: '', // Fill in receiver address
  gasPrice: 1000000000,
  gasLimit: 70000,
  data: '',
  version: 1,
  options: 0,
  chainID: 'D',
)
```

Feel free to adapt the template to meet your specific needs.
````
