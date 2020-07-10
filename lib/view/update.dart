import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f202/utils/const.dart';
import 'package:f202/utils/httpControl.dart';
import 'package:f202/utils/myLocalizations.dart';
import 'package:wakelock/wakelock.dart';

class UpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with SingleTickerProviderStateMixin  {
  //static const String UPDATE = '   Firmware Update   ';
  //static const String UPDATING = '   Firmware updating   ';
  String _version;
  String _currentVersion = '';
  String _url = 'abc';
  String _updateInfo;
  double _step = 0.00;
  bool _isUpdating = false;
  Color _buttonColor = Colors.white;
  //Animation<double> _animation;
  AnimationController _animationController;
  static const String CHANNEL_NAME="fender.f202/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.f202/update_event_native');
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    print(this.toString());
    _animationController =
        AnimationController(duration: Duration(seconds: 150), vsync: this);
   // _animation = Tween(begin: 0.001, end: 1.0).animate(_animationController);
    _subscription = eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _animationController.addListener(() {
      _step= _step+0.00008;
      if(_step > 0.999)
        _step = 0.999;
      //print("_animationController" +_step.toString());
      setState(() {

      });
    });
    _version = MyLocalizations.of(Global.context).getText('unknown');
    _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_Update');
    getCurrentVersion();
    checkLatestVersion();

  }
  @override
  void dispose() {
    _animationController.dispose();
    if(_subscription != null){
      _subscription.cancel();
    }
    super.dispose();
  }
  void _onEvent(Object event) {
    print("_UpdatePageState _onEvent _result ---->"+ event.toString());
    Map<String, String> res = new Map<String, String>.from(event);
    if(res['status']!=null && res['status'].compareTo('0')==0)
      {
        //update success
        _animationController.stop();
        _step = 1.0;
        _connectDevice();
        _isUpdating =false;
        Wakelock.disable();
      }
    else if(res['Firmware']!=null )
      {
        _currentVersion = res['Firmware'];
        print('version check = ' + _version + ':' + _currentVersion + " = " + _version.compareTo(_currentVersion).toString());
      }
    else{
      _step = 0.0;
      _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_Update');
      _animationController.stop();
      _step = 0.0;
      setState(() {});
      _isUpdating =false;
      _showToast();
      Wakelock.disable();
    }

    //setState(() {});
  }

  void _onError(Object error) {
    print("_UpdatePageState _onError _result ---->"+ error.toString());
  }

  void checkLatestVersion() {
    Map<String, String> map;
    HttpController.get("https://foxdaota.s3.cn-north-1.amazonaws.com.cn/ota/fender/f202/release/f202_ota_release.json", (data) {
      if (data != null) {
        final body = json.decode(data.toString());
        map = new Map<String, String>.from(body);
        _version = map['version'];
        _url = map['url'];
        print('version check = ' + _version + ':' + _currentVersion + " = " + _version.compareTo(_currentVersion).toString());
        setState(() {
        });
      }
    });
  }
  void getCurrentVersion()
  {
    platform.invokeMethod('native_get_firmware_version');
  }

  Future<Null> _connectDevice() async {
    bool delete = await _showConnectBtConfirmDialog();
    if (delete == null) {
      print("NO");
      exit(0);
    } else {
      print("Yes");
      platform.invokeMethod('native_go_to_setting');
      exit(0);
    }
  }

  void _showToast(){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: MyLocalizations.of(Global.context).getText('update_failed'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void _noUpdate(){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: 'Firmware is up to date!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 24.0,
    );
  }

  // 弹出对话框
  Future<bool> _showConnectBtConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).getText('Done')),
          content: Text(MyLocalizations.of(context).getText('update_ok')),
          actions: <Widget>[
            FlatButton(
              child: Text(MyLocalizations.of(context).getText('No')),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text(MyLocalizations.of(context).getText('OK')),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  var _stack;
  Stack _buildStack() {
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: Global.updateProcessHeight,
          width: Global.updateProcessWidth,
          child: RotatedBox(
              quarterTurns: 3, //旋转90度(1/4圈)
              child: new LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                value: _step,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              )
          ),
        ),
        Image.asset(
            'assets/images/update.png', height: Global.updateImgHeight,
            width: Global.updateImgWidth),
      ],
    );
  }

  void _tryUpgrade(){
    if(_url.contains('http')){
      platform.invokeMethod('native_upgrade', _url);
      _step = 0.0;
      _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_updating');
      _isUpdating = true;
      _animationController.forward();
      Wakelock.enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("update" + context.toString());
    _stack = _buildStack();
    //_step = 0.0;
    return new Container(
      padding: EdgeInsets.all(Global.eqBodyPadding),
      child: Center(
        child:  Column(
        children: <Widget>[
          Row(
              children: <Widget>[
              Text(
                MyLocalizations.of(Global.context).getText('latest_firmware'),
                style: Global.contentTextStyle,
              ),
              Text(
                _version,
                style: Global.contentTextStyle,
              ),
            ],
          ),

          Container(
            height: Global.updateBodyHeight,
            child: _stack,//Image.asset('assets/images/update.png' , height: ScreenUtil().setHeight(900), width: ScreenUtil().setWidth(615)),
            /*decoration: BoxDecoration(
              color: Colors.red,
            ),*/
            //color: Colors.red[400],
          ),

          SizedBox(
            //width: 50,
            height: Global.updateIconHeight,
            child: FlatButton(
              color: _buttonColor,
              highlightColor: Colors.green[700],
              //colorBrightness: Brightness.dark,
              //splashColor: Colors.grey,
              child: Text(_updateInfo, style: Global.contentTextStyle),
              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {
                if(!_isUpdating && _currentVersion.compareTo(_currentVersion)!=0)
                  _tryUpgrade();
                else if (!_isUpdating)
                  _noUpdate();
                //_connectDevice();
            },
          )
        ),
        ],
      ),
      ),
    );
  }
}