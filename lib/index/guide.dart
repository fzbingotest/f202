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

  int _currentIndex = 0;    //
  List<NavigationIconView> _navigationViews;  //
  List<StatefulWidget> _pageList;   //
  StatefulWidget _currentPage;  //

  bluetoothService _btService = new bluetoothService();

  @override
  void deactivate(){
    super.deactivate();
    print(this.toString() + 'deactivate');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    super.dispose();
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
    Global.initScreen(context);
    return _getMainUI(context);
  }

  Widget _getMainUI(BuildContext context)
  {
    //
    print(this.toString() + '--' + Global.appGuide.toString());
    return new MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => _btService,
        child:
        new Scaffold(
          appBar: new AppBar(
            //title: Text(MyLocalizations.of(Global.context).testText),
            bottom: PreferredSize(
              child: Image.asset('assets/images/logo.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
              preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
            ),
          ),
          body: Listener(
            onPointerUp: (e){
            print(this.toString()+' `````````onPointerUp --' );
             Global.saveFirstRun(1);
            setState((){});
            },

            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    height: Global.appBodyHeight,
                    padding: EdgeInsets.all(Global.bodyPadding),
                    child: Text('Please put the earbud to charge case', style: Global.titleTextStyle1),   //
                    //color: Colors.red[400],
                  ),
                  //Text(_model, style: Global.titleTextStyle1/*TextStyle(color: Colors.white, fontSize: 20)*/)
                ],
              )
          ),
        ),
        ),
      ),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255,52,52,52),
        canvasColor: Color.fromARGB(255,52,52,52),
        brightness: Brightness.dark,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

    );
  }


}