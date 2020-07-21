import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Tour/utils/const.dart';
//import 'package:Tour/utils/myI18nWidget.dart';
import 'package:Tour/utils/myLocalizations.dart';
//import 'package:Tour/utils/myLocalizationsDelegate.dart';
import 'package:Tour/view/settings.dart';
import 'package:Tour/view/equalize.dart';
import 'package:Tour/view/update.dart';
import 'package:Tour/view/info.dart';

import '../utils/const.dart';
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
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  String _model = 'none';
  String _address = '';
  int _step = 1;

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
    else if (state == AppLifecycleState.resumed) {
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
    //Global.init();
    super.initState();
    print(this.toString());
    WidgetsBinding.instance.addObserver(this);
    _getDevice();
    /*setState(() {
    });*/
  }

  Future<Null> _getDevice() async {
    try {
      var result = await platform.invokeMethod('native_get_current_device');
      Map<String, String> res = new Map<String, String>.from(result);
      _model = res['Model'];
      _address = res['Address'];
      if(_model.contains('none') ) {
        print("no device connected");
//        print("~~" + MyLocalizations.of(Global.context).toString() + "~~"+Global.context.toString());
//        print("adb@@@@  "+ MyLocalizations.of(Global.context).testText);
        //platform.invokeMethod('native_go_to_setting');
        //TODO connect devices
        //_connectDevice();
      }
      setState((){});
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
      _getDevice();
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

    print('index build ~~' + _currentIndex.toString()+'app init=' + Global.appGuide.toString() + 'step=' + _step.toString());
    if((Global.appGuide&(1 <<_currentIndex)) != 0)
      return _getMainUI();
    else
      return Listener(
        onPointerUp: (e){
          _step++;
          print('`````````onPointerUp --' + _currentIndex.toString() + ' _step = ' +_step.toString());
          if((_step > 2 && _currentIndex  <= 1) || (_step >3 && _currentIndex  == 2) || (_step >1 && _currentIndex  == 3)) {
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
      );
  }

  Widget _getMainUI()
  {
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

    return new MaterialApp(
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
  }

  Widget _getGuideUI()
  {
    // 声明定义一个 底部导航的工具栏
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationIconView) => navigationIconView.item)
          .toList(),  // 添加 icon 按钮
      currentIndex: _currentIndex,  // 当前点击的索引值
      type: BottomNavigationBarType.fixed,    // 设置底部导航工具栏的类型：fixed 固定
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
            child: Image.asset('assets/images/logo.png', height: Global.bottomLogoHeight, width: Global.bottomLogoWidth),
            preferredSize: Size(Global.bottomViewWidth, Global.bottomViewHeight),
          ),
        ),
        body: new Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: Global.appBodyHeight,
                  child: _myWidget,   // 动态的展示我们当前的页面
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
        left: Global.columnPadding*2+ (Global.appWidth /4)*_currentIndex,
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
        left: Global.columnPadding*2 + (Global.appWidth /4)*_currentIndex,
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
        left: Global.columnPadding*2 + (Global.appWidth /4)*_currentIndex,
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