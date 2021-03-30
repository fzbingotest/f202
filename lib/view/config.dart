import 'package:Tour/utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:provider/provider.dart';
class ConfigsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  bool check = false;
  @override
  void initState() {
    super.initState();
    bluetoothService.instance.getBassActive();
  }
  @override
  void dispose() {
    print('dispose  ' + this.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build " + this.toString());
    return new Container(
      padding: EdgeInsets.all(Global.bodyPadding),
      child: Column(
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
              style: Global.contentTextStyle, // Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),

          Container(
            height: Global.titleHeight/2,
            child: Selector(builder:  (BuildContext context, bool data, Widget child) {
              return Text(
                MyLocalizations.of(Global.context).getText(data ?'high_gain':'low_gain'),
                style: data ? Global.contentTextRed:Global.contentTextGreen, // Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              );
            }, selector: (BuildContext context, bluetoothService btService) {
              //return data to builder
              return btService.bass;
            },),
            /*Text(
              MyLocalizations.of(Global.context).getText(data ?'low_gain'),
              style: Global.contentTextStyle, // Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),*/
          ),

          Container(
            height: Global.contentHeight,
            child: Selector(builder:  (BuildContext context, bool data, Widget child) {
              return Image.asset((data ?'assets/images/enhance_1.png' : 'assets/images/enhance_0.png'), height: Global.imageHeight, width: Global.imageWidth);
            }, selector: (BuildContext context, bluetoothService btService) {
              //return data to builder
              return btService.bass;
            },),

          ),

          Container(
            height: Global.buttonHeight,
            child: Selector(builder:  (BuildContext context, bool data, Widget child) {
              return new CupertinoSwitch(
                value: data,
                activeColor: Global.appRed, //Colors.red,     // 激活时原点颜色
                //focusColor: Colors.green,
                trackColor: Global.appGreen,
                onChanged: (bool val) {
                  bluetoothService.instance.setBassActive(val);
                },
              );
            }, selector: (BuildContext context, bluetoothService btService) {
              //return data to builder
              return btService.bass;
            },
            ),
          ),

        ],
      ),
    );
  }
}

class ConfigsPageGuide extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _ConfigsPageStateGuide();
}

class _ConfigsPageStateGuide extends State<ConfigsPageGuide> {
  bool check = false;

  @override
  void initState() {
    super.initState();

    print('initState  ' + this.toString());
  }
  @override
  void dispose() {
    print('dispose  ' + this.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build " + this.toString());
    return new Container(
      padding: EdgeInsets.all(Global.bodyPadding),
      child: Column(

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
                },
              )
          ),

        ],
      ),
    );
  }
}