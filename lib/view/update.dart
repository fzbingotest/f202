import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/const.dart';
import '../utils/httpControl.dart';
import '../utils/myLocalizations.dart';
import 'package:wakelock/wakelock.dart';
import '../utils/bluetoothService.dart';

class UpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with SingleTickerProviderStateMixin  {
  String _version;
  String _currentVersion = '0.0.0';
  String _peerVersion = '';
  String _url = 'abc';
  String _updateInfo;
  double _step = 0.00;
  bool _isUpdating = false;
  Color _buttonColor = Colors.white;
  //Animation<double> _animation;
  AnimationController _animationController;
  static const String CHANNEL_NAME="palovue.iSound/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('palovue.iSound/update_event_native');
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
        if(res['Box battery']!=null)
          {
            _peerVersion = res['Box battery'];
            print('peer version check = ' + _version + ':' + _peerVersion + " = " + _version.compareTo(_peerVersion).toString());
          }
        setState(() {
        });
      }
    else if(res['progress']!=null )
    {
      _animationController.value = (0.05+ (double.parse(res['progress'])*0.65)/100);
      print('progress _step = ' + _step.toString() + ' -- ' + res['progress']);
      if(_animationController.value > 0.695)
        _animationController.forward();
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
    HttpController.get("https://foxdaota.s3.cn-north-1.amazonaws.com.cn/ota/palovue/release/palovue_tws_ota_release.json", (data) {
      if (data != null) {
        final body = json.decode(data.toString());
        map = new Map<String, String>.from(body);
        _version = map['version'];
        _url = map['url'];
        print('url = ' + _url);
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

                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget getUpdateGuide()
  {
    return Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children: <Widget>[
       /* Container(
          child: Text(MyLocalizations.of(Global.context).getText('UPGRADE'), style: Global.titleTextStyle1),
        ),*/
        SizedBox( height : Global.tabImgHeight ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test0'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test1'), style: Global.subtitleTextStyle1, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test2'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test2.2'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test2.3'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test2.4'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight ),
        SizedBox(
          width: Global.appWidth- (Global.bodyPadding*2),
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test3'), style: Global.subtitleTextStyle1, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test4'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test4.2'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test4.3'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test5'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test6'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
        SizedBox( height : Global.tabImgHeight/4 ),
        Container(
          child: Text(MyLocalizations.of(Global.context).getText('upgrade_test6.6'), style: Global.eqHzTextStyle, textAlign: TextAlign.left,),
        ),
      ],
    );
  }

  Future<bool> _showUpdateConfirmDialog() {
    //print("index build + " + context.toString());
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(Global.context).getText('UPGRADE'), style: Global.titleTextStyle1),/*Text(MyLocalizations.of(context).getText('Warning')),*/
          content: getUpdateGuide()/*Text(MyLocalizations.of(context).getText('Update_confirm'))*/,
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
              quarterTurns: 3, //旋转90�?1/4�?
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
              Text(
                _version,
                style: Global.contentTextStyle,
              ),
            ],
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
                if(!_isUpdating && /*_currentVersion.compareTo(_version)!=0 && */_currentVersion.compareTo('0.0.0') !=0)
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