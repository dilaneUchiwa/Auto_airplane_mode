import 'dart:async';
import 'dart:ffi';

import 'package:connectivity_plus/connectivity_plus.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ConnectivityResult _connectionStatus=ConnectivityResult.none;
  final Connectivity  _connectivity=Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var listener;
  final List<String> image=['assets/iconGreen.png','assets/iconRed.png']; 
  String time=DateTime.now().toString();

  bool start=false;
  bool isConnected=false;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    var customChecker=InternetConnectionChecker.createInstance(
      checkInterval: const Duration(seconds: 1),
      addresses: [AddressCheckOptions(hostname: "www.google.com",port: 80)]
    );

    listener=customChecker.onStatusChange.listen((status){
      switch(status){
        case InternetConnectionStatus.connected:
          setState(() {
            isConnected=true;
          });
        break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            isConnected=false;
          });
        break;
      }
    });
    
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    listener.dispose();
    super.dispose();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: 
             Padding(
              padding: const EdgeInsets.only(top: 20),
              child: 
              Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.more_vert)
                )
              ],
             ),
             )
          ),
          Flexible(
            flex:10,
            child:
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(start)Text(
                       time,
                      style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
                    ),
                    IconButton(
                      onPressed: (() {
                        setState(() {
                          start=!start;
                        });
                      }),
                      iconSize: 300,
                      icon: Image.asset(image[start?1:0]),
                    ),
                   if(start)Text('Connection Status: ${_connectionStatus.toString()}'),
                   if(start)isConnected?const Text('connected to internet',style: TextStyle(color: Colors.green),):const Text('Not connected to internet',style: TextStyle(color: Colors.red))
                  ],
                )
              )
          )
        ],
      ),
      )
    );
  }
}