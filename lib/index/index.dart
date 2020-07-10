import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:f202/utils/const.dart';
import 'package:f202/utils/myI18nWidget.dart';
import 'package:f202/utils/myLocalizations.dart';
import 'package:f202/utils/myLocalizationsDelegate.dart';
import 'package:f202/view/settings.dart';
import 'package:f202/view/equalize.dart';
import 'package:f202/view/update.dart';
import 'package:f202/view/info.dart';

import 'navigation_icon_view.dart'; // 如果是在同一个包的路径下，可以直接使用对应的文件名

// 创建一个 带有状态的 Widget Index
class Index extends StatefulWidget {
  //  固定的写法
  @override
  State<StatefulWidget> createState()  => new _IndexState();
}
//GlobalKey<MyI18nWidgetState> myI18nWidgetStateKey=GlobalKey<MyI18nWidgetState>();
// 要让主页面 Index 支持动效，要在它的定义中附加mixin类型的对象TickerProviderStateMixin
class _IndexState extends State<Index> with TickerProviderStateMixin, WidgetsBindingObserver{

  int _currentIndex = 0;    // 当前界面的索引值
  List<NavigationIconView> _navigationViews;  // 底部图标按钮区域
  List<StatefulWidget> _pageList;   // 用来存放我们的图标对应的页面
  StatefulWidget _currentPage;  // 当前的显示页面
  static const String CHANNEL_NAME="fender.f202/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  String _model = '';
  String _address = '';

  @override
  void deactivate(){
    super.deactivate();
    print(this.toString() + 'deactivate');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
      print(this.toString() + 'didChangeAppLifecycleState -> ' + 'AppLifecycleState.paused');
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      _getDevice();
      setState((){});
      print(this.toString() + 'didChangeAppLifecycleState -> ' + 'AppLifecycleState.resumed');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    print(this.toString());
    WidgetsBinding.instance.addObserver(this);
    _getDevice();
    setState(() {
    });
  }

  Future<Null> _getDevice() async {
    try {
      var result = await platform.invokeMethod('native_get_current_device');
      Map<String, String> res = new Map<String, String>.from(result);
      _model = res['Model'];
      _address = res['Address'];
      if(!_model.contains('F202') ) {
        print("no device connected");
//        print("~~" + MyLocalizations.of(Global.context).toString() + "~~"+Global.context.toString());
//        print("adb@@@@  "+ MyLocalizations.of(Global.context).testText);
        //platform.invokeMethod('native_go_to_setting');
        //TODO connect devices
        _connectDevice();
      }

    } on PlatformException catch (e) {
      print("failed to get devices "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  Future<Null> _connectDevice() async {
    bool delete = await _showConnectBtConfirmDialog();
    if (delete == null) {
      print("NO");
      exit(0);
    } else {
      print("Yes");

      platform.invokeMethod('native_go_to_setting');
    }
  }

  // 弹出对话框
  Future<bool> _showConnectBtConfirmDialog() {
    //print("index build + " + context.toString());
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(MyLocalizations.of(context).getText('Warning')),
          content: Text(MyLocalizations.of(context).getText('No_fender_connected')),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(MyLocalizations.of(context).getText('No')),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
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
    // 初始化导航图标
    //print("createPage -- " + MyLocalizations.of(context).getText('DRIVE'));
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.grey),
          /*new Icon(Icons.assessment),*/
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_enhance.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('DRIVE')),
          vsync: this), // vsync 默认属性和参数
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.grey),
           activeIcon: new ImageIcon(AssetImage('assets/images/tab_eq.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('EQ')), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_update.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('UPDATE')), vsync: this),
      new NavigationIconView(icon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.grey),
          activeIcon: new ImageIcon(AssetImage('assets/images/tab_info.png'), size: Global.navigationIconWidth, color: Colors.greenAccent),
          title: new Text(MyLocalizations.of(context).getText('INFO')), vsync: this),
    ];

    // 给每一个按钮区域加上监听
    /*for (NavigationIconView view in _navigationViews) {
      //view.controller.addListener(_rebuild);
    }*/

    // 将我们 bottomBar 上面的按钮图标对应的页面存放起来，方便我们在点击的时候
    _pageList = <StatefulWidget>[
      new ConfigsPage(),
      new EqualizePage(),
      new UpdatePage(),
      new InfoPage()
    ];
    _currentPage = _pageList[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    Global.initScreen(context);
    createPage();
    print("index build + " + context.toString());
    // 声明定义一个 底部导航的工具栏
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationIconView) => navigationIconView.item)
          .toList(),  // 添加 icon 按钮
      currentIndex: _currentIndex,  // 当前点击的索引值
      type: BottomNavigationBarType.fixed,    // 设置底部导航工具栏的类型：fixed 固定
      onTap: (int index){   // 添加点击事件
        setState((){    // 点击之后，需要触发的逻辑事件
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
          _currentPage = _pageList[_currentIndex];
        });
      },
    );

    Widget param =  new MaterialApp(

      home: new Scaffold(
        appBar: new AppBar(
          //title: Text(MyLocalizations.of(Global.context).testText),
          bottom: PreferredSize(
            child: Image.asset('assets/images/logo.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
              preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
          ),
        ),
        body: new Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: Global.appBodyHeight,
                  child: _currentPage,   // 动态的展示我们当前的页面
                  //color: Colors.red[400],
                ),

                Text(_model, style: Global.titleTextStyle1/*TextStyle(color: Colors.white, fontSize: 20)*/)
              ],
            )
        ),
        bottomNavigationBar: bottomNavigationBar,   // 底部工具栏

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

    print('index build ~~~~~~~~~~~~~~~~~~~~~~~~' + _currentIndex.toString());

    return param;

      /*Center(
        child: Stack(
          alignment: Alignment.center,
          //overflow: Overflow.visible,
          children: <Widget>[
            param,
            Positioned(
              bottom: 0,
              child: Container( child: Text('bingo') , color: Color.fromARGB(168, 0, 0, 0), height: Global.appHeight, width: Global.appWidth,),
            ),

            /*Positioned(
              bottom: Global.bottomLogoHeight,
              //left: 100,
              child: Text('I am bingo for test',style: Global.titleTextStyle1),
            ),*/
          ],
        )
    );*/
  }
}