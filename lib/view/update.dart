import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/httpControl.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:wakelock/wakelock.dart';

class UpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with SingleTickerProviderStateMixin  {
  String _version;
  String _currentVersion = '';
  String _url = 'abc';
  String _updateInfo;
  double _step = 0.00;
  bool _isUpdating = false;
  Color _buttonColor = Colors.white;
  //Animation<double> _animation;
  AnimationController _animationController;
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.Tour/update_event_native');
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    print(this.toString());
    _animationController = AnimationController(duration: Duration(seconds: 150), vsync: this);
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
    try {
      if (_subscription != null) {
        _subscription.cancel();
      }
    } on PlatformException catch (e){
    print("failed to get devices "+e.toString());
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
        setState(() {
        });
        _isUpdating =false;
        Wakelock.disable();
        _connectDevice();
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

  Future<Null> _updateConfirm() async {
    bool delete = await _showUpdateConfirmDialog();
    if (delete == null) {
      print("NO");
    } else {
      print("Yes");
      _tryUpgrade();
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

  // pop up dialog
  Future<bool> _showConnectBtConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(context).getText('Done')),
          content: Text(MyLocalizations.of(context).getText('update_ok')),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('No')),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            CupertinoDialogAction(
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

  Future<bool> _showUpdateConfirmDialog() {
    //print("index build + " + context.toString());
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(context).getText('Warning')),
          content: Text(MyLocalizations.of(context).getText('Update_confirm')),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('Cancel')),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('Update')),
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
          ),

          SizedBox(
            //width: 50,
            height: Global.updateIconHeight,
            child: FlatButton(
              color: _buttonColor,
              highlightColor: Colors.green[700],
              //colorBrightness: Brightness.dark,
              //splashColor: Colors.grey,
              child: Text(_updateInfo, style: Global.floatHzTextStyle),
              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {
                if(!_isUpdating /*&& _currentVersion.compareTo(_version)!=0*/)
                  _updateConfirm();
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


class UpdatePageGuide extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _UpdatePageStateGuide();
}

class _UpdatePageStateGuide extends State<UpdatePageGuide> {
  String _version;
  String _updateInfo;
  Color _buttonColor = Colors.white;

  @override
  void initState() {
    super.initState();
    print(this.toString());
    _version = MyLocalizations.of(Global.context).getText('unknown');
    _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_Update');
  }
  @override
  void dispose() {
    super.dispose();
  }

  var _stack;
  Stack _buildStack() {
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset(
            'assets/images/update.png', height: Global.updateImgHeight,
            width: Global.updateImgWidth),
      ],
    );
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
                  child: Text(_updateInfo, style: Global.floatHzTextStyle),
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () {

                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}