import 'dart:io';

import 'package:Tour/index/guide.dart';
import 'package:Tour/utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:Tour/view/settings.dart';
import 'package:Tour/view/equalize.dart';
import 'package:Tour/view/update.dart';
import 'package:Tour/view/info.dart';
import 'package:Tour/view/config.dart';

import '../utils/const.dart';
import 'navigation_icon_view.dart';

import 'package:provider/provider.dart';

//
class Index extends StatefulWidget {
  //
  @override
  State<StatefulWidget> createState()  => new _IndexState();
}

class _IndexState extends State<Index> with TickerProviderStateMixin, WidgetsBindingObserver{

  int _currentIndex = 0;    //
  List<NavigationIconView> _navigationViews;  //
  List<StatefulWidget> _pageList;   //
  StatefulWidget _currentPage;  //
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  String _model = 'none';
  int _step = 1;
  bluetoothService _btService = new bluetoothService();
  bool _isNoDevice = false;

  @override
  void deactivate(){
    super.deactivate();
    print(this.toString() + 'deactivate');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print(this.toString() + 'didChangeAppLifecycleState -> ' + 'AppLifecycleState.paused');
      if(_isNoDevice == true)
      {
        _isNoDevice = false;
        Navigator.of(context).pop();
      }
    }
    else if (state == AppLifecycleState.resumed) {
      print(this.toString() + 'didChangeAppLifecycleState -> ' + 'AppLifecycleState.resumed');
      if(_currentIndex == 3)
        _btService.getInfo();
    }
  }

  @override
  void dispose() {
    super.dispose();
    //_btService.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    //Global.init();
    super.initState();
    print(this.toString());
    WidgetsBinding.instance.addObserver(this);
    _btService.initial();
    _btService.setDeviceCallback( _connectDevice);
    _btService.setDeviceValidCallback( _validDevice);
    _btService.getDevice();

  }

  Future<Null> _connectDevice() async {
    if(Global.appGuide < Global.guideSteps )
      if(_btService.inGuide == true)
        return ;

    bool delete = await _showConnectBtConfirmDialog();
    if (delete == null) {
      print("NO");
      exit(0);
    } else {
      print("Yes");
      platform.invokeMethod('native_go_to_setting');
      exit(0);
    }
  }

  void _validDevice()
  {
/*
    if(_isNoDevice == true)
      {
        _isNoDevice = false;
        Navigator.of(context).pop();
      }
*/
  }

  Future<bool> _showConnectBtConfirmDialog() {
    _isNoDevice = true;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(context).getText('Warning')),
          content: Text(MyLocalizations.of(context).getText('No_fender_connected')),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('No')),
              onPressed: () => Navigator.of(context).pop(), //
            ),
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

  void createPage()
  {
    //
    //print("createPage -- " + MyLocalizations.of(context).getText('DRIVE'));
    _navigationViews = <NavigationIconView>[

      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.grey),
          /*new Icon(Icons.assessment),*/
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('DRIVE')),
          vsync: this), // vsync
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.grey),
           activeIcon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('EQ')), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('UPDATE')), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/setting.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/setting.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('SETTING')), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('INFO')), vsync: this),
    ];

    //
    /*for (NavigationIconView view in _navigationViews) {
      //view.controller.addListener(_rebuild);
    }*/

    //
    _pageList = <StatefulWidget>[
      new ConfigsPage(),
      new EqualizePage(),
      new UpdatePage(),
      new SettingPage(),
      new InfoPage(),
    ];
    _currentPage = _pageList[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    Global.initScreen(context);
    createPage();
    print('index build ~~' + _currentIndex.toString()+'app init=' + Global.appGuide.toString() + 'step=' + _step.toString());
    return _getMainUI(context);

    /*if(Global.appGuide == 0)//((Global.appGuide&(1 <<_currentIndex)) != 0)
      return _getMainUI(context);
    else
      return Listener(
        onPointerUp: (e){
          _step++;
          print('`````````onPointerUp --' + _currentIndex.toString() + ' _step = ' +_step.toString());
          if((_step > 2 && _currentIndex  <= 1) || (_step >3 && _currentIndex  == 2) || (_step >1 && _currentIndex  == 3)|| (_step >1 && _currentIndex  == 4)) {
            Global.saveFirstRun(Global.appGuide|(1<< _currentIndex));
            _step = 1;
          }
          setState((){});
        },

    child: Center(
        child: Stack(
          alignment: Alignment.center,
          //overflow: Overflow.visible,
          children: <Widget>[
            _getGuideUI(),
            Positioned(
              bottom: 0,
              child: Container( child: Text('') , color: Color.fromARGB(168, 0, 0, 0), height: Global.appHeight, width: Global.appWidth,),
            ),
            _getDescribeWidget(),
            _getPointWidget(),

          ],
        )
      )
      );*/
  }

  Widget _getMainUI(BuildContext context)
  {
    //
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationIconView) => navigationIconView.item)
          .toList(),  //
      currentIndex: _currentIndex,  //
      type: BottomNavigationBarType.fixed,    //
      onTap: (int index){   //
        setState((){    //
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
          _currentPage = _pageList[_currentIndex];
        });
      },
    );

    print('_getMainUI --------- _btService = '+_btService.toString() );
    _btService.initial();
    _btService.getDevice();

    return new MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => _btService,
        child:
          new Scaffold(
    /*appBar: new AppBar(
              //title: Text(MyLocalizations.of(Global.context).testText),
              bottom: PreferredSize(
                child: Image.asset('assets/images/logo.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
                preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
              ),
            ),*/
            body: new Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: Global.bottomViewHeight/2,
                    ),
                    PreferredSize(
                      child: Image.asset('assets/images/logor.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
                      preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
                    ),
                    Container(
                      height: Global.appBodyHeight,
                      child: _currentPage,   //
                      //color: Colors.red[400],
                    ),
                    /*Selector(builder:  (BuildContext context, String data, Widget child) {
                      print('model rebuild model ');
                      return Text(data, style: Global.titleTextStyle1/*TextStyle(color: Colors.white, fontSize: 20)*/);
                    }, selector: (BuildContext context, bluetoothService btService) {
                      //return data to builder
                      return btService.model;
                    },),*/
                    //Text(_model, style: Global.titleTextStyle1/*TextStyle(color: Colors.white, fontSize: 20)*/)
                  ],
                )
            ),
            bottomNavigationBar: Container(
              height: Global.bottomViewHeight,
              child: bottomNavigationBar,   //
              //color: Colors.red[400],
            ),   //

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

  Widget _getGuideUI()
  {
    //
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationIconView) => navigationIconView.item)
          .toList(),  //
      currentIndex: _currentIndex,  //
      type: BottomNavigationBarType.fixed,    //
      onTap: (int index){
      },
    );
    Widget _myWidget;
    switch(_currentIndex){
      case 0:
        _myWidget = new ConfigsPageGuide();
        break;
      case 1:
        _myWidget = new EqualizePageGuide();
        break;
      case 2:
        _myWidget = new UpdatePageGuide();
        break;
      case 3:
      default:
        _myWidget = new InfoPageGuide();
        break;
    }

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          //title: Text(MyLocalizations.of(Global.context).testText),
          bottom: PreferredSize(
            child: Image.asset('assets/images/logor.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
            preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
          ),
        ),
        body: new Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: Global.appBodyHeight,
                  child: _myWidget,   //
                  //color: Colors.red[400],
                ),
                //Text(_model, style: Global.titleTextStyle1/*TextStyle(color: Colors.white, fontSize: 20)*/)
              ],
            )
        ),
        bottomNavigationBar: bottomNavigationBar,   //

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

  Widget _getDescribeWidget()
  {
    String _text = '';
    double _bottom = 0.0;
    switch(_currentIndex)
    {
      case 0:
        _text = _step==1? MyLocalizations.of(context).getText('Enhance_describe'): MyLocalizations.of(context).getText('model_describe');
        _bottom = Global.bottomViewHeight*_step +  Global.columnPadding*5;
        break;
      case 1:
        if( _step==1) {
          _text = MyLocalizations.of(context).getText('Eq_describe');
          _bottom = (Global.bottomViewHeight * _step + Global.columnPadding * 5);
        }
        else {
          return Positioned(
              top: Global.bottomLogoHeight + Global.bottomViewHeight,
              child: Container(
                padding: new EdgeInsets.fromLTRB( Global.columnPadding,  Global.columnPadding*5, Global.columnPadding, Global.columnPadding*5),
                width: (Global.appWidth - Global.columnPadding*5),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child:  Text(MyLocalizations.of(context).getText('EqReset_describe'), textAlign: TextAlign.center, style: Global.floatHzTextStyle,),)
          );
        }
        break;
      case 2:
        if(_step == 1) {
          _text = MyLocalizations.of(context).getText('Update_describe');
          _bottom = Global.bottomViewHeight * _step + Global.columnPadding * 5;
        }
        else{
          return Positioned(
              bottom: Global.bottomViewHeight*4.5,
              child: Container(
                padding: new EdgeInsets.fromLTRB( Global.columnPadding,  Global.columnPadding*5, Global.columnPadding, Global.columnPadding*5),
                width: (Global.appWidth - Global.columnPadding*5),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child:  Text(
                  MyLocalizations.of(context).getText(_step == 2? 'Update_describe1': 'Update_describe2') , textAlign: TextAlign.center, style: Global.floatHzTextStyle,),)
          );
        }
        break;
      case 3:
      default:
        _text =MyLocalizations.of(context).getText('Info_describe');
        _bottom = Global.bottomViewHeight*_step +  Global.columnPadding*5;
        break;
    }
        return Positioned(
            bottom: _bottom,
            child: Container(
              padding: new EdgeInsets.fromLTRB( Global.columnPadding,  Global.columnPadding*5, Global.columnPadding, Global.columnPadding*5),
              width: (Global.appWidth - Global.columnPadding*5),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child:  Text(_text, textAlign: TextAlign.center, style: Global.floatHzTextStyle,),)
        );
  }

  Widget _getPointWidget()
  {
    if(_currentIndex == 0)
      return _step == 1 ?
      Positioned(
        bottom: Global.bottomViewHeight*(_step-1),
        left: Global.columnPadding*2,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.circular(65.0)),
        ),
          height: Global.bottomViewHeight, width: Global.bottomViewWidth,),
      )
          :
      Positioned(
        bottom: Global.bottomViewHeight*(_step-1) + Global.columnPadding*2,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.circular(65.0)),
        ),
          height: Global.bottomViewHeight, width: Global.appWidth/2,),
      );
    else if(_currentIndex == 1)
    {
      return _step == 1 ?
      Positioned(
        bottom: Global.bottomViewHeight*(_step-1),
        left: Global.columnPadding*2+ (Global.appWidth /5)*_currentIndex,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.circular(65.0)),
        ),
          height: Global.bottomViewHeight, width: Global.bottomViewWidth,),
      )
          :
      Positioned(
        top: Global.bottomLogoHeight + Global.bottomViewHeight + Global.eqBodyPadding + Global.columnPadding*3 + Global.tabHeight,
        right: Global.eqBodyPadding + Global.columnPadding,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.circular(45.0)),
        ),
          height: Global.resetHeight, width: Global.resetHeight),
      );
    }
    else if(_currentIndex == 2)
    {
      return _step == 1 ?
      Positioned(
        bottom: Global.bottomViewHeight*(_step-1),
        left: Global.columnPadding*2 + (Global.appWidth /5)*_currentIndex,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.elliptical(Global.bottomViewWidth,  Global.bottomViewHeight)),
        ),
          height: Global.bottomViewHeight, width: Global.bottomViewWidth,
        ),
      )
          :
      Positioned(
        top: Global.bottomLogoHeight + Global.bottomViewHeight + Global.eqBodyPadding + Global.columnPadding*6+ Global.updateBodyHeight,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.elliptical( Global.appWidth*4/5,   Global.updateIconHeight*1.5)),
        ),
          height: Global.updateIconHeight*1.5, width: Global.appWidth*4/5,
        ),
      );
    }
    else {
      return Positioned(
        bottom: Global.bottomViewHeight*(_step-1),
        left: Global.columnPadding*2 + (Global.appWidth /5)*_currentIndex,
        child: Container( child: Text('') , decoration: new BoxDecoration(
          color: Color.fromARGB(55, 128, 128, 128),
          borderRadius: BorderRadius.all(Radius.elliptical(Global.bottomViewWidth,  Global.bottomViewHeight)),
        ),
         height: Global.bottomViewHeight, width: Global.bottomViewWidth,
        ),
      );
    }
  }

}