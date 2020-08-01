
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class bluetoothService with ChangeNotifier {
  static const String TAG = 'bluetoothService';
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.Tour/main_event_native');
  static bluetoothService _instance ;

  StreamSubscription _subscription;
  bool isInitial = false;
  String model ='none';
  String address ='none';
  String battery ='50';
  String boxBattery = '50';
  String status ='Not charging';
  String signal = '-30 db';
  String firmware = '1.0.0';
  String appVersion = '1.0.7';
  bool bass = false;
  static get instance => _instance;
  bluetoothService initial() {
    print(TAG + "initial ---->"+ isInitial.toString());
    if(! isInitial ) {
      _subscription = eventChannel.receiveBroadcastStream().listen(
          _onEvent, onError: _onError);
      isInitial = true;
      _instance = this;
    }
    return _instance;
  }

  void _onEvent(Object event) {
    print(TAG + " _onEvent _result ---->"+ event.toString());
    Map<String, String> res = new Map<String, String>.from(event);
    switch(res['key'])
    {
      case 'Firmware':
        print(TAG +'get Firmware' + res['value']);
        print(TAG +'get Box battery' + res['Box battery']);
        //int.parse(res['Box battery']);
        firmware = res['value'];
        boxBattery= res['Box battery'];
        notifyListeners();
        break;
      case 'eqBank':
        print(TAG +'get eqBank' + res['value']);
        break;
      case 'bassActivated':
        print(TAG +'get bassActivated' + res['value']);
        bass =  res['value'] == 'true';
        notifyListeners();
        break;
      case 'eqActivated':
        print(TAG +'get eqActivated' + res['value']);
        break;
      case 'Signal':
        print(TAG +'get Signal' + res['value']);
        signal = res['value']+' db';
        notifyListeners();
        break;
      case 'device':
        print(TAG +'get device' + res['address']);
        model = res['model'];
        address = res['address'];

        notifyListeners();
        break;

    }

  }

  void _onError(Object error) {
    print(TAG + "_onError _result ---->"+ error.toString());
  }

  void dispose(){
    super.dispose();
    print(TAG + "dispose ----");
    if(_subscription != null){
      _subscription.cancel();
      isInitial = false;
    }
  }

  void getBassActive() {
    try {
      platform.invokeMethod('native_get_bass');
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

  void setBassActive(bool active) {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      bass = active;
      platform.invokeMethod('native_set_bass', active);
      print("_setBassActive " + active.toString());
      notifyListeners();
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

}