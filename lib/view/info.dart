import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';

class InfoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _InfoPageState();
}


class _InfoPageState extends State<InfoPage> {
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  final List<String> _listTitle = ['Model', 'Address','Battery','Box battery','Status','Signal','Firmware','App_Version'];
  Map<String, String> _listContent =  {'Model': 'tws', 'Address': '0:0:0:0:0:0','Battery': '50','Box battery':'50',
                                    'Status': 'Not charging','Signal': '-30 db','Firmware': '1.0.0','App_Version': '1.0.6'};
  static const EventChannel eventChannel =  const EventChannel('fender.Tour/event_native');
  StreamSubscription _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _getDevice();
    //platform.invokeMethod('call_native_method', 22);
  }
  @override
  void dispose() {
    super.dispose();
    //
    try {
      if (_subscription != null) {
        _subscription.cancel();
      }
    } on PlatformException catch (e){
      print("failed to get devices "+e.toString());
    }

  }

  void _onEvent(Object event) {
    print("_onEvent _result ---->"+ event.toString());
    Map<String, String> res = new Map<String, String>.from(event);

    setState(() {
      _listContent.addAll(res);
    });
  }

  void _onError(Object error) {
    print("_onError _result ---->"+ error.toString());
  }

  Future<Null> _getDevice() async {
    try {
      var result = await platform.invokeMethod('native_get_information');
      Map<String, String> res = new Map<String, String>.from(result);

      print("initState _result ---->"+ result.toString());
      _listContent.addAll(res);
    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Global.bodyPadding),
      alignment:Alignment.bottomLeft,
      child: Column(
        children: _listTitle.asMap().keys.map((f)=>
            Container(
                height: Global.tabHeight,
                child: Row(
                  children: <Widget>[
                    SizedBox(child: Text(MyLocalizations.of(Global.context).getText(_listTitle[f])+':', style: Global.contentTextStyle), width:Global.infoItemTitleWidth),
                    SizedBox( width: Global.columnPadding),
                    Expanded(
                      child: Text(_listContent[_listTitle[f]], style: Global.contentTextStyle),
                    )
                  ],
                )
            )).toList(),
      )
     );
  }
}

class InfoPageGuide extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _InfoPageStateGuide();
}


class _InfoPageStateGuide extends State<InfoPageGuide> {
  final List<String> _listTitle = ['Model', 'Address','Battery','Box battery','Status','Signal','Firmware','App_Version'];
  Map<String, String> _listContent =  {'Model': 'tws', 'Address': '0:0:0:0:0:0','Battery': '50','Box battery':'50',
    'Status': 'Not charging','Signal': '-30 db','Firmware': '1.0.0','App_Version': '1.0.6'};
  @override
  void initState() {
    super.initState();
    //platform.invokeMethod('call_native_method', 22);
  }
  @override
  void dispose() {
    super.dispose();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Global.bodyPadding),
        alignment:Alignment.bottomLeft,
        child: Column(
          children: _listTitle.asMap().keys.map((f)=>
              Container(
                  height: Global.tabHeight,
                  child: Row(
                    children: <Widget>[
                      SizedBox(child: Text(MyLocalizations.of(Global.context).getText(_listTitle[f])+':', style: Global.contentTextStyle), width:Global.infoItemTitleWidth),
                      SizedBox( width: Global.columnPadding),
                      Expanded(
                        child: Text(_listContent[_listTitle[f]], style: Global.contentTextStyle),
                      )
                    ],
                  )
              )).toList(),
        )
    );
  }
}