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
              child: Image.asset('assets/images/logo.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
              preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
            ),
          ),
          body: Listener(
            onPointerUp: (e){
            print(this.toString()+' `````````onPointerUp --' +Global.appGuide.toString() );
            _step++;
             Global.saveFirstRun(_step);
            setState((){});
            if(_step == 3)
              Navigator.pop(context);
            },

            child: Container(

                padding: EdgeInsets.all(Global.bodyPadding),
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
              child: Text('Fender TOUR OverView', style: Global.titleTextStyle1),
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
              child: Text('PAIRING', style: Global.titleTextStyle1),
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
              child: Text('Open the charging case, press and hold the case button until the LED on the charging case blinks blue and green，the TWS LED blinks green.', style: Global.contentTextStyle),
            ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/pairing1.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
          ],
        );
      case 2:
      default:
        return Column(
          children: <Widget>[
            Container(
              child: Text('CHARGING', style: Global.titleTextStyle1),
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
              child: Text('Close the lid and attach the USB-C charging cable to the charging case', style: Global.contentTextStyle),
            ),

            Container(
              child: Text('The case LED will indicate the charging status: ', style: Global.contentTextStyle),
            ),

            Container(
              child: Text('LED is solid red = Charging             ', style: Global.contentTextStyle),
            ),

            Container(
              child: Text('LED is solid green = Fully charged', style: Global.contentTextStyle),
            ),
          ],
        );
    }
  }

}