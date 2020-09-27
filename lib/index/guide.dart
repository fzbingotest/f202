import 'package:Tour/utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';
import '../utils/const.dart';
import 'navigation_icon_view.dart';

import 'package:provider/provider.dart';

//
class Guide extends StatefulWidget {
  //
  @override
  State<StatefulWidget> createState()  => new _GuideState();
}

class _GuideState extends State<Guide> with TickerProviderStateMixin, WidgetsBindingObserver{

  int _step = 0;

  @override
  void deactivate(){
    super.deactivate();
    print(this.toString() + ' -- deactivate');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(this.toString() + ' -- didChangeAppLifecycleState ' +state.toString());
  }

  @override
  void dispose() {
    super.dispose();
    print(this.toString() + ' -- dispose');
    bluetoothService.instance.appGuideExit();
    //_btService.dispose();
  }

  @override
  void initState() {
    //Global.init();
    super.initState();
    print(this.toString());

  }

  @override
  Widget build(BuildContext context) {
     return _getMainUI(context);
  }

  Widget _getMainUI(BuildContext context)
  {
    //
    print(this.toString() + '--' + Global.appGuide.toString());
    return new Scaffold(
          appBar: new AppBar(
            //title: Text(MyLocalizations.of(Global.context).testText),
            elevation: 0,
            bottom: PreferredSize(
              child: Image.asset('assets/images/logor.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
              preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
            ),
          ),
          body: Listener(
            onPointerUp: (e){
            print(this.toString()+' `````````onPointerUp --' +Global.appGuide.toString() );
            _step++;
            Global.saveFirstRun(_step);
            setState((){});
            if(_step == 5)
              Navigator.pop(context);
            },

            child: Container(
                padding: EdgeInsets.fromLTRB(Global.bodyPadding, Global.bodyPadding, Global.bodyPadding, 0),
              child:  _getPage(),
            ),
          ),
        );
  }
  Widget _getPage(){
    print("_getPage " + _step.toString());
    switch (_step){

      case 0:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('guide_overview'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
             child: PreferredSize(
               child: Image.asset('assets/images/earbud.png', height: Global.bottomLogoHeight, width: Global.appWidth),
               preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
             ),
            ),
            SizedBox( height : Global.tabImgHeight*3 ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/changingcase.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            ],
          );
      case 1:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('PAIRING'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/pairing0.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('pairing_text0'), style: Global.contentTextStyle),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/pairing1.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('PAIRING'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/images/pairing0.png', height: Global.bottomLogoHeight*1.8, /*width: Global.appWidth*/),
                    SizedBox( width: Global.columnPadding*10, ),
                    Image.asset('assets/images/pairing1.png', height: Global.bottomLogoHeight*1.8, /*width: Global.appWidth*/),
                  ]
                ),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('pairing_text1'), style: Global.contentTextStyle),
            ),
            /*SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/pairing1.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),*/
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('PAIRING'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/phone.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('pairing_text2'), style: Global.contentTextStyle),
            ),

          ],
        );
      case 4:

        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('CHARGING'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/charging0.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('charging_text1'), style: Global.contentTextStyle),
            ),

            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('charging_text2'), style: Global.contentTextStyle),
            ),

            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('charging_text3'), style: Global.contentTextStyle),
            ),

            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('charging_text4'), style: Global.contentTextStyle),
            ),
          ],
        );
      case 5:
      default:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('UPGRADE'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test1'), style: Global.subtitleTextStyle1, textAlign: TextAlign.left,),
            ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test2'), style: Global.eqHzTextStyle),
            ),
            SizedBox( height : Global.tabImgHeight ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test3'), style: Global.subtitleTextStyle1, textAlign: TextAlign.left,),
            ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test4'), style: Global.eqHzTextStyle),
            ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test5'), style: Global.eqHzTextStyle),
            ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('upgrade_test6'), style: Global.eqHzTextStyle),
            ),
          ],
        );
    }
  }

}