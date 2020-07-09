
import 'dart:async';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class bluetoothService{
  static const String CHANNEL_NAME="fender.fm8932/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.fm8932/event_native');
  //StreamSubscription _subscription;

  /*void initial() async {
    var result = await platform.invokeMethod('native_get_bt_device');
    print("initState _result ---->" + result.toString());

    _subscription = eventChannel.receiveBroadcastStream().listen(
        _onEvent, onError: _onError);
  }
  void _onEvent(Object event) {
    print("_onEvent _result ---->"+ event.toString());
    //Map<String, String> res = new Map<String, String>.from(event);

  }

  void _onError(Object error) {
    print("_onError _result ---->"+ error.toString());
  }
  void dispose(){
    if(_subscription != null){
      _subscription.cancel();
    }
  }*/



}