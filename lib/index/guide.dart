import '../utils/myLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/bluetoothService.dart';
import '../utils/const.dart';

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

  void _prevPage(){
    print(this.toString()+' `````````onPointerUp --' +Global.appGuide.toString() );
    _step--;
    if(_step< 0)
      _step = 0;
    setState((){});
  }
  void _NextPage(){
    print(this.toString()+' `````````onPointerUp --' +Global.appGuide.toString() );
    _step++;
    setState((){});
    if(_step >= Global.guideSteps) {
      Global.saveFirstRun(_step);
      Navigator.pop(context);
    }
  }

  Widget _getMainUI(BuildContext context)
  {
    //
    print(this.toString() + '--' + Global.appGuide.toString());
    return new Scaffold(
          appBar: new AppBar(
            elevation: 0,
          ),
          body: Column(
            children: <Widget>[
              /*Container(
                height: Global.bottomViewHeight/2,
              ),*/
              PreferredSize(
                child: Image.asset('assets/images/logor.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
                preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
              ),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerUp: (e){
                  _NextPage();
                },

                /*child: SizedBox(
                  width: Global.appWidth, height: Global.appBodyHeight,*/
                child: Container(
                    padding: EdgeInsets.fromLTRB(Global.bodyPadding, Global.bodyPadding, Global.bodyPadding, 0),
                  height: Global.appBodyHeight,
                  child:  _getPage(),
                ),
              ),
              ButtonBar(
                buttonHeight: Global.bottomLogoHeight/3,
                  children: <Widget>[
                    (_step == 0 )? null:FlatButton(
                      child: Row(
                        children:<Widget>[
                          Icon(Icons.keyboard_arrow_left, /*size: 18.0*/),
                          Text(MyLocalizations.of(Global.context).getText('Prev')),
                        ]
                      ),
                      onPressed: () {_prevPage();},
                    ),
                    SizedBox( width: Global.columnPadding*3, ),
                    FlatButton(
                      child: Row(
                        children:<Widget>[
                          (_step<(Global.guideSteps-1))?Text(MyLocalizations.of(Global.context).getText('Next')): Text(MyLocalizations.of(Global.context).getText('Finish')),
                          Icon(Icons.keyboard_arrow_right, /*size: 18.0*/),
                        ]
                      ),
                      onPressed: () {print('Next3');_NextPage();},
                    ),
                  ]
              ),
          ]
        )
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
                child: Row(
                    children: <Widget>[
                      Image.asset('assets/images/pairing0.png', /*height: Global.bottomLogoHeight*1.8,*/ width: (Global.appWidth - Global.bodyPadding*2 - Global.columnPadding)/2),
                      SizedBox( width: Global.columnPadding, ),
                      Image.asset('assets/images/pairing1.png', /*height: Global.bottomLogoHeight*1.8,*/ width: (Global.appWidth - Global.bodyPadding*2 - Global.columnPadding)/2),
                    ]
                ),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('pairing_text0'), style: Global.contentTextStyle),
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
                    Image.asset('assets/images/pairing0.png', /*height: Global.bottomLogoHeight*1.8,*/ width: (Global.appWidth - Global.bodyPadding*2 - Global.columnPadding)/2),
                    SizedBox( width: Global.columnPadding, ),
                    Image.asset('assets/images/pairing1.png', /*height: Global.bottomLogoHeight*1.8,*/ width: (Global.appWidth - Global.bodyPadding*2 - Global.columnPadding)/2),
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
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('ButtonTitle'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              height: Global.bottomLogoHeight*2,
              child:Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox( height : Global.bottomLogoHeight*1.2,  width: Global.appWidth/4/*- Global.bodyPadding/2*/),
                      SizedBox( height : Global.bottomLogoHeight*0.5 ,  width: Global.appWidth/4/*- Global.bodyPadding/2*/,
                      child: Text(MyLocalizations.of(Global.context).getText('Button'), style: Global.guideButtonTextStyle,textAlign: TextAlign.right,),
                      ),
                      SizedBox( height : Global.bottomLogoHeight*0.3 ,  width: Global.appWidth/4/*- Global.bodyPadding/2*/,
                        child: Text(MyLocalizations.of(Global.context).getText('LED'), style: Global.guideButtonTextStyle,textAlign: TextAlign.right,),
                      ),

                    ],
                  ),
                  SizedBox(
                      height: Global.bottomLogoHeight*2,
                      child: Image.asset('assets/images/button_33.png', height: Global.bottomLogoHeight*2, width: Global.appWidth/2- Global.bodyPadding),
                  )
                ]
              )
            ),
            SizedBox( height : Global.tabImgHeight ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('hold_button'), style: Global.contentTextStyle),
            ),
            SizedBox( height : Global.tabImgHeight/4 ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('button_pairing'), style: Global.contentTextStyle),
            ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('button_reset'), style: Global.contentTextStyle),
            ),
            SizedBox(
              width: Global.appWidth- (Global.bodyPadding*2),
              child: Text(MyLocalizations.of(Global.context).getText('button_R_pairing'), style: Global.contentTextStyle),
            ),
          ],
        );
      case 6:
        return Column(
          children: <Widget>[
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('Factory_reset'), style: Global.titleTextStyle1),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: PreferredSize(
                child: Image.asset('assets/images/pairing1.png', height: Global.bottomLogoHeight*2, width: Global.appWidth),
                preferredSize: Size(Global.appWidth, Global.bottomLogoHeight),
              ),
            ),
            SizedBox( height : Global.tabImgHeight ),
            Container(
              child: Text(MyLocalizations.of(Global.context).getText('reset_content'), style: Global.contentTextStyle),
            ),
          ],
        );
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