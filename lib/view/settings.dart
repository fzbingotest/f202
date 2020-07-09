import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fm6832/utils/const.dart';
import 'package:fm6832/utils/myLocalizations.dart';
//import 'package:flutter_screenutil/screenutil.dart';
class ConfigsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  bool check = false;
  static const String CHANNEL_NAME="fender.fm8932/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.fm8932/bass_event_native');
  StreamSubscription _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);

    print(this.toString());
    _getBassActive();
  }
  @override
  void dispose() {

    if(_subscription != null){
      _subscription.cancel();
    }
    super.dispose();
  }
  void _onEvent(Object event) {
    print("bass _onEvent _result ---->"+ event.toString());
    Map<String, int> res = new Map<String, int>.from(event);
    if(res['key'] == 2)
      {
        check = res['value']==1?true:false;
        setState(() {});
      }

    //setState(() {});
  }

  void _onError(Object error) {
    print("bass _onError _result ---->"+ error.toString());
    check=false;
    setState(() {});
  }

  void _getBassActive() {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_get_bass');
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  void _setBassActive(bool active) {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_set_bass', active);
      print("_setBassActive " + active.toString());
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(Global.bodyPadding),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: Global.titleHeight,
              child: Text(
                MyLocalizations.of(Global.context).getText('Audio_Enhance'),
                style: TextStyle(color: Colors.white, fontSize: Global.fontSizeTitle), // Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: Global.contentHeight,
              child: Text(
                MyLocalizations.of(Global.context).getText('enhance_content'),
              style: TextStyle(color: Colors.grey, fontSize: Global.fontSizeInfo), // Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
              ),
            ),

            Container(
            height: Global.contentHeight,
            child: Image.asset((check ?'assets/images/enhance_1.png' : 'assets/images/enhance_0.png'), height: Global.imageHeight, width: Global.imageWidth),
            ),

            Container(
            height: Global.buttonHeight,
            child: new CupertinoSwitch(
              value: this.check,
              activeColor: Color.fromARGB(255, 236, 27, 35), //Colors.red,     // 激活时原点颜色
              //focusColor: Colors.green,
              trackColor: Color.fromARGB(255, 13, 252, 6),
              onChanged: (bool val) {
                this.setState(() {
                  this.check = !this.check;
                  _setBassActive(this.check);
                });
              },
              )
            ),

          ],
        ),
    );
  }
}

class SettingText extends Container{
  @override
  Widget build(BuildContext context) {
    Widget current = child;
    return current;
  }
}