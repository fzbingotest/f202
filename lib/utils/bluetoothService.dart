
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class bluetoothService with ChangeNotifier {
  static const String TAG = 'bluetoothService';
  static const String CHANNEL_NAME="palovue.iSound/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('palovue.iSound/main_event_native');
  static const _LeftHold= 2;
  static const _RightHold = 5;
  static const _Left2tap = 1;
  static const _Right_2tap = 4;
  static const _Left_tap = 0;
  static const _Right_tap = 3;
  static bluetoothService _instance ;

  VoidCallback _noDeviceListener;
  VoidCallback _deviceValidListener;

  StreamSubscription _subscription;
  bool isInitial = false;
  String model ='none';
  String address ='none';
  String battery ='';
  String boxBattery = '';
  String status ='';
  String signal = '';
  String firmware = '';
  String appVersion = '1.2.1';
  bool bass = false;
  bool inGuide = true;
  List<int> buttonFunction = [0,0,0,0,0,0];

  static get instance => _instance;
  bluetoothService initial() {
    print(TAG + "initial ---->"+ isInitial.toString());
    if(! isInitial ) {
      _subscription = eventChannel.receiveBroadcastStream().listen(
          _onEvent, onError: _onError);
      isInitial = true;
      _instance = this;
      _noDeviceListener = null;
      _deviceValidListener = null;
    }
    return _instance;
  }
  void appGuideExit()
  {
    getDevice();
    inGuide = false;
  }
  void setDeviceCallback(VoidCallback a)
  {
    _noDeviceListener = a;
  }
  void setDeviceValidCallback(VoidCallback a)
  {
    _deviceValidListener = a;
  }

  bool isRConnected()
  {
    return model.contains('iSound R');
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
        if(model.contains('iSound R')){
          firmware = res['Box battery'];
          boxBattery= res['value'];
        }
        else {
          firmware = res['value'];
          boxBattery = res['Box battery'];
        }
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
      case 'battery':
        print(TAG +'get battery ' + res['value']);
        battery = res['value'];
        notifyListeners();
        break;
      case 'device':
        print(TAG +'get device' + res['address']);
        model = res['model'];
        address = res['address'];

        if(!address.startsWith('50:0B:32')&& !address.startsWith('00:50:32') && model.contains('PALOVUE') == false) {
          if(_noDeviceListener!= null)
          _noDeviceListener();
        }
        else if (_deviceValidListener != null)
          _deviceValidListener();
        notifyListeners();
        break;
      case 'button':
        print(TAG +'get button' + res['value']);
        _decodeButtonFunc(res['value']);
        notifyListeners();
        break;
      case 'service':
        print(TAG +'get service' + res['value']);
        if(res['value'].startsWith('connect')== true && _deviceValidListener != null)
          _deviceValidListener();
        break;

    }

  }
  void _decodeButtonFunc(String button){
    int val = int.parse(button);
    print(TAG +'_decodeButtonFunc ' + val.toString());
    buttonFunction[_LeftHold] = (val>>10)&0x3;
    buttonFunction[_RightHold] = (val>>8)&0x3;
    buttonFunction[_Left2tap] = (val>>6)&0x3;
    buttonFunction[_Right_2tap] = (val>>4)&0x3;
    buttonFunction[_Left_tap] = (val>>2)&0x3;
    buttonFunction[_Right_tap] = (val)&0x3;

  }
  void _onError(Object error) {
    print(TAG + "_onError _result ---->"+ error.toString());
  }

  void dispose(){
    //super.dispose();
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

  void getInfo()
  {
    try {
      platform.invokeMethod('native_get_information');
    } on PlatformException catch (e) {
      print("failed to get information "+e.toString());
    }

  }

  void getDevice() {
    try {
      platform.invokeMethod('native_get_current_device');
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

  void finishUpdate() {
    try {
      platform.invokeMethod('native_check_current_device');
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

  int _calcButtonFunc(){
    int ret = 0;
    ret = ((buttonFunction[_LeftHold]&0x3)<<10)|((buttonFunction[_RightHold]&0x3)<<8)
    |((buttonFunction[_Left2tap]&0x3)<<6) |((buttonFunction[_Right_2tap]&0x3)<<4)
    |((buttonFunction[_Left_tap]&0x3)<<2) |((buttonFunction[_Right_tap]&0x3));
    return ret;
  }
  int _resetButtonFunc(){
    int ret = 0;
    buttonFunction[_LeftHold] = buttonFunction[_RightHold] = buttonFunction[_Left2tap] = buttonFunction[_Right_2tap] = buttonFunction[_Left_tap] = buttonFunction[_Right_tap] = 0;
    return ret;
  }

  void setButtonFunction(int index, int value) {
    try {
      int button = 0;
      buttonFunction[index] = value;
      button = _calcButtonFunc();
      platform.invokeMethod('native_set_button', button);
      print("setButtonFunction " + button.toString());
      notifyListeners();
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

  void resetButtonFunction() {
    try {
      int button = _resetButtonFunc();
      platform.invokeMethod('native_set_button', button);
      print("setButtonFunction " + button.toString());
      notifyListeners();
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }
  void getButtonFunction() {
    try {
      platform.invokeMethod('native_get_button');
      //print("_setBassActive " + active.toString());
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
  }

}