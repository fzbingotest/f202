import '../utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/const.dart';
import '../utils/myLocalizations.dart';
import 'package:provider/provider.dart';
class SettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool check = false;
  static List<String> _listTitle = ['Left tap', 'Left double-tap', 'Left hold', 'Right tap', 'Right double-tap', 'Right hold'];
  /*List<int> _value = [1,3,2,1,3,2];*/
  @override
  void initState() {
    super.initState();
    bluetoothService.instance.getButtonFunction();
  }
  @override
  void dispose() {
    print('dispose  ' + this.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build " + this.toString());
    return new Column(

      children: <Widget>[ Container(
        padding: EdgeInsets.fromLTRB(Global.bodyPadding/2,  Global.bodyPadding,Global.bodyPadding/2,Global.bodyPadding),
        alignment:Alignment.bottomLeft,
        child: Column(
          children: _listTitle.asMap().keys.map((f)=>  _item(_listTitle[f], f)).toList(),
          ),
        ),
        Container(
          height: Global.tabHeight,
          child:FlatButton(
            color: Colors.white,
            highlightColor: Global.appGreen,
            //colorBrightness: Brightness.dark,
            //splashColor: Colors.grey,
            child: Text( MyLocalizations.of(Global.context).getText('Reset'), style: Global.floatHzTextStyle),
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            onPressed: () {
              bluetoothService.instance.resetButtonFunction();
            },
          )
        ),
      ]
    );
  }
  /*Volume down	  PP/HC/AC	    PREV SONG/RC	Volume up	    PP/HC/AC	    Next Song/RC
    PREV SONG/RC	Volume down	  Volume down	  Next Song/RC	Volume up	    Volume up
    PP/HC/AC	    PREV SONG/RC	PP/HC/AC	    PP/HC/AC	    Next Song/RC	PP/HC/AC*/
                                     /*'Left tap',  'Left double-tap', 'Left hold', 'Right double-tap', 'Right Tap2', 'Right hold'];*/
  static List<String> _listContent = ['Volume down', 'Play/Pause', 'PREV SONG', 'Volume up', 'Play/Pause', 'Next Song',
                                      'PREV SONG', 'Volume down', 'Volume down', 'Next Song', 'Volume up', 'Volume up',
                                      'Play/Pause', 'PREV SONG', 'Play/Pause', 'Play/Pause', 'Next Song', 'Play/Pause',];
  String _getString(int index, int value)
  {
    return _listContent[value*6+index];
  }

  Widget _item(String title, int val)
  {
    return Container(
      height: Global.tabHeight*1.2,
      child: Row(
        children: <Widget>[
          SizedBox(child: Text( MyLocalizations.of(Global.context).getText(title)+' :', style: Global.contentTextStyle), width:Global.infoItemTitleWidth*1.5),
          SizedBox( width: Global.columnPadding),
          Expanded(
            child: Selector(builder:  (BuildContext context, int data, Widget child) {
              print('InfoPageState rebuild............'+val.toString());
               return DropdownButtonHideUnderline(
                 child: DropdownButton(
                     dropdownColor:Colors.grey,
                     focusColor:Colors.red,
                   items: <DropdownMenuItem<int>>[
                     DropdownMenuItem(child: Text(MyLocalizations.of(Global.context).getText(_getString(val,0))/*"~0~"*/,style: TextStyle(color: data==0?Global.appGreen:Colors.white),),value: 0,),
                     DropdownMenuItem(child: Text(MyLocalizations.of(Global.context).getText(_getString(val,1))/*"~1~"*/,style: TextStyle(color: data==1?Global.appGreen:Colors.white),),value: 1,),
                     DropdownMenuItem(child: Text(MyLocalizations.of(Global.context).getText(_getString(val,2))/*"~2~"*/,style: TextStyle(color: data==2?Global.appGreen:Colors.white),),value: 2,),
                     DropdownMenuItem(child: Text(MyLocalizations.of(Global.context).getText('None')/*"~3~"*/,style: TextStyle(color: data==3?Global.appGreen:Colors.white),),value: 3,),
                   ],
                   onChanged: (selectValue){
                     bluetoothService.instance.setButtonFunction(val, selectValue);
                     },
                   value: data,
                   //elevation: 10,
                   //  iconSize: 30,//
                  ),
                 );
               }, selector: (BuildContext context, bluetoothService btService) {
              //return data to builder
              return btService.buttonFunction[val];
            },),
          ),
        ],
      ),
    );
  }
}
