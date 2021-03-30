import 'dart:io';

import '../utils/bluetoothService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/const.dart';
import '../utils/myLocalizations.dart';
import '../view/settings.dart';
import '../view/equalize.dart';
import '../view/update.dart';
import '../view/info.dart';
import '../view/config.dart';

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
  static const String CHANNEL_NAME="palovue.iSound/call_native";
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
    if(_isNoDevice == true)
      return;

    bool delete = await _showConnectBtConfirmDialog();
    print("delete = " + delete.toString());
    if (delete == null) {
      print("NO");
      exit(0);
    } else if (delete == true){
      print("Yes");
      platform.invokeMethod('native_go_to_setting');
      exit(0);
    }
    else
      {
        print("Ha Ha ~~~");
        //exit(0);
      }
  }

  void _validDevice()
  {
    if(_isNoDevice == true)
      {
        _isNoDevice = false;
        Navigator.of(context).pop(false);
      }

  }

  Future<bool> _showConnectBtConfirmDialog() {
    _isNoDevice = true;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(context).getText('Warning')),
          content: Text(MyLocalizations.of(context).getText('No_palovue_connected')),
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

      /*new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.grey),
          *//*new Icon(Icons.assessment),*//*
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('DRIVE')),
          vsync: this), // vsync*/
     /* new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.grey),
           activeIcon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          label: MyLocalizations.of(context).getText('EQ'), vsync: this),*/
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          label: MyLocalizations.of(context).getText('UPDATE'), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_setting.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_setting.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          label: MyLocalizations.of(context).getText('SETTING'), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          label: MyLocalizations.of(context).getText('INFO'), vsync: this),
    ];

    //
    /*for (NavigationIconView view in _navigationViews) {
      //view.controller.addListener(_rebuild);
    }*/

    //
    _pageList = <StatefulWidget>[
      /*new ConfigsPage(),*/
      /*new EqualizePage(),*/
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
        if(_btService.isRConnected() && (index == 1 || index == 3))
          return;
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
            body: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new AssetImage('assets/images/black-brushed.png'),
                ),
              ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: Global.bottomViewHeight/2,
                    ),
                    PreferredSize(
                      child: Image.asset('assets/images/logop.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
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
          //primaryColor: Color.fromARGB(255,52,52,52),
          //canvasColor: Color.fromARGB(255,52,52,52),
          primaryColor:Colors.black,
          canvasColor:Colors.black,
          brightness: Brightness.dark,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

    );
  }

}