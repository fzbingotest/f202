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
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:Tour/utils/bluetoothService.dart';

class UpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with SingleTickerProviderStateMixin  {
  String _updateInfo;
  double _step = 0.00;
  bool _isUpdating = false;
  Color _buttonColor = Colors.white;
  //Animation<double> _animation;
  AnimationController _animationController;
  static const String CHANNEL_NAME="palovue.fm6840/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('palovue.fm6840/update_event_native');
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    print(this.toString());
    _animationController = AnimationController(duration: Duration(seconds: 150), vsync: this);
    _subscription = eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _animationController.addListener(() {
      _step= _animationController.value;
      if(_step > 0.99)
        _step = 0.99;
      //print("_animationController" +_step.toString());
      setState(() {
      });
    });
    _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_Update');
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
    else if(res['progress']!=null )
    {
      _animationController.value = (0.05+ (double.parse(res['progress'])*0.65)/100);
      print('progress _step = ' + _step.toString() + ' -- ' + res['progress']);
      if(_animationController.value > 0.695)
        _animationController.forward();
    }
    else if(res['Firmware']!=null ){}
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

  Future<Null> _connectDevice() async {
    bool delete = await _showConnectBtConfirmDialog();
    if (delete == null) {
      print("NO");
      //exit(0);
    } else {
      print("Yes");
      //platform.invokeMethod('native_go_to_setting');
      //exit(0);
    }
    bluetoothService.instance.finishUpdate();
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
    //_step = 0.0;
    //_animationController.forward();
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: MyLocalizations.of(Global.context).getText('firmware_updated'),
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
            /*CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('No')),
              onPressed: () => Navigator.of(context).pop(),
                         ),*/
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
          title: Text(MyLocalizations.of(Global.context).getText('UPGRADE'), style: Global.titleTextStyle1),/*Text(MyLocalizations.of(context).getText('Warning')),*/
          content: Text(MyLocalizations.of(context).getText('Update_confirm')),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('Update')),
              onPressed: () {
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
    //print('step ' + _step.toString() + 'lowerBound ' + _animationController.value.toString());
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: Global.updateProcessHeight,
          width: Global.updateProcessWidth,
          child: RotatedBox(
              quarterTurns: 3,
              child: new CircularProgressIndicator(
                backgroundColor: Color.fromARGB(255, 48, 48, 48),
                strokeWidth: 8.0,
                value: _step,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              )
          ),
        ),
        Container(
            height: Global.updateImgHeight/2,
            width: Global.updateImgWidth/2,
            child:  Image.asset(
            'assets/images/update.png', height: Global.updateImgHeight,
            width: Global.updateImgWidth),
        )
      ],
    );
  }

  void _tryUpgrade(){
    if(bluetoothService.instance.updateUrl.contains('http')){
      platform.invokeMethod('native_upgrade', bluetoothService.instance.updateUrl);
      _step = 0.0;
      _updateInfo = MyLocalizations.of(Global.context).getText('Firmware_updating');
      _isUpdating = true;
      _animationController.forward();
      Wakelock.enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("update" + context.toString());
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
              Selector(builder:  (BuildContext context, String data, Widget child) {
                print('InfoPageState rebuild............'+data);
                return Text(data, style: Global.contentTextStyle/*TextStyle(color: Colors.white, fontSize: 20)*/);
                }, selector: (BuildContext context, bluetoothService btService) {
                  if(btService.version.contains('unknown'))
                    return MyLocalizations.of(Global.context).getText('unknown');
                  return btService.version;
                }
              )
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: Global.updateIconHeight/2,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: Global.updateIconHeight,
            child: _isUpdating? Text(
              (_step*100).toStringAsFixed(2)+'%',
              style: Global.contentTextStyle,
            ) : Text(' '),
          ),

          Container(
            height: Global.updateBodyHeight*0.7,
            child: _stack,//Image.asset('assets/images/update.png' , height: ScreenUtil().setHeight(900), width: ScreenUtil().setWidth(615)),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: Global.updateIconHeight,
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
                if(!_isUpdating && bluetoothService.instance.needUpdate())
                  _updateConfirm();
                else if (!_isUpdating)
                  _noUpdate();
                //_connectDevice();
              },
            )
          ),
          /*SizedBox( height: Global.updateIconHeight, width: Global.appWidth*3/4,
            child:Text(_isUpdating? MyLocalizations.of(Global.context).getText('Updating_warn'):MyLocalizations.of(Global.context).getText('Updating_warn'), style: Global.warningTextStyle),
          ),*/
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