import 'package:Tour/utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<String> _listTitle = ['Model', /*'Address',*/'Battery',/*'Box battery','Status','Signal',*/'Firmware','Box battery','App_Version'];
  @override
  void initState() {
    super.initState();
    bluetoothService.instance.getInfo();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Global.bodyPadding),
      alignment:Alignment.bottomLeft,
      child: Column(
        children: _listTitle.asMap().keys.map((f)=>
            Container(
                height: Global.tabHeight*1.3,
                child: Row(
                  children: <Widget>[
                    SizedBox(child: Text(MyLocalizations.of(Global.context).getText(_listTitle[f])+':', style: Global.contentTextStyle), width:Global.infoItemTitleWidth*1.2,),
                    SizedBox( width: Global.columnPadding, ),
                    Expanded(
                      child: Selector(builder:  (BuildContext context, String data, Widget child) {
                        print('InfoPageState rebuild............'+f.toString());
                        return Text(data, style: Global.contentTextStyle/*TextStyle(color: Colors.white, fontSize: 20)*/);
                      }, selector: (BuildContext context, bluetoothService btService) {
                        //return data to builder
                        switch(f){
                          case 0:
                            return btService.model;
                          case 1:
                            return btService.battery+'%';
                          //case 2:
                            //return btService.status;
                            //return btService.boxBattery;
                          case 2:
                            return btService.firmware;
                          case 3:
                            return btService.boxBattery;
                          default:
                            return btService.appVersion;
                        }
                        //return btService.listContent[_listTitle[f]];
                      },),
                      //Text(_listContent[_listTitle[f]], style: Global.contentTextStyle),
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