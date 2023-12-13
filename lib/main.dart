import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/core/utils/open_deep_link.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:fluttertemplate/get_it.dart';
import 'package:fluttertemplate/layers/domain/usecase/get_transactions.dart';
import 'package:fluttertemplate/layers/domain/usecase/send_transactions.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_bloc.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_state.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/view/sign_transaction_button.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/wallet_connect/bloc/wallet_connect_bloc.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/wallet_connect/view/wallet_connect_button.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  final Alice alice = getIt<Alice>();
  final Dio dio = getIt<Dio>();

  dio.interceptors.add(alice.getDioInterceptor());
  dio.options = BaseOptions(contentType: Headers.jsonContentType);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Alice alice = getIt<Alice>();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool initialized = false;
  final GetTransactions getTransactions = getIt<GetTransactions>();
  final SendTransactions sendTransactions = getIt<SendTransactions>();
  final FlavorSettings flavorSettings = getIt<FlavorSettings>();
  final WalletConnectionService walletConnService =
      getIt<WalletConnectionService>();

  @override
  void initState() {
    super.initState();

    initializeWalletConnect();
  }

  Future<void> initializeWalletConnect() async {
    await walletConnService.initializeClient();

    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletConnectBloc>(
          create: (_) => WalletConnectBloc(walletConnService),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            walletConnectionService: walletConnService,
            sendTransactions: sendTransactions,
            getTransactions: getTransactions,
            flavorSettings: flavorSettings,
          ),
        ),
      ],
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.readyToSign) {
            openDeepLink(AppConstants.multiversxDeeplinkUrl);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              // TRY THIS: Try changing the color here to a specific color (to
              // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
              // change color while the other colors stay the same.
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(widget.title),
            ),
            body: const Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                //
                // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                // action in the IDE, or press "p" in the console), to see the
                // wireframe for each widget.
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WalletConnectButton(),
                  SignTransactionButton(),
                ],
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        },
      ),
    );
  }
}
