import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/screenutil.dart';

class Global {
  static SharedPreferences _prefs;
  static int firstRun;
  static bool _isScreenInit = false;
  static BuildContext appContext;
  static int guideSteps = 7;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    int _firstRun = _prefs.getInt("first_run");
    if (_firstRun != null) {
      try {
        firstRun = _firstRun;
      } catch (e) {
        print(e);
      }
    }
    else
      firstRun = 0;

    print('_firstRun ' + _firstRun.toString() + ', firstRun ' + firstRun.toString());

    //初始化网络请求相关配置
    //Git.init();
  }

  static bool initScreen(BuildContext context){
    if(!_isScreenInit)
      {
        ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
        _isScreenInit = true;
      }
    return false;
  }

  static bool initContest(BuildContext context){
    appContext = context;
    return false;
  }

  static BuildContext get context => appContext;


  static double get navigationIconWidth => ScreenUtil().setWidth(90);
  static double get fontSizeInfo => ScreenUtil().setSp(72);
  static double get fontSizeTitle => ScreenUtil().setSp(128);
  static double get bottomLogoWidth => ScreenUtil().setWidth(798);
  static double get bottomLogoHeight => ScreenUtil().setHeight(300);
  static double get bottomViewWidth => ScreenUtil().setWidth(250);
  static double get bottomViewHeight => ScreenUtil().setHeight(300);
  static double get appBodyHeight => ScreenUtil().setHeight(3120 -300 - 240- 300);

  ///setting view
  static double get bodyPadding => ScreenUtil().setWidth(160);
  static double get titleHeight => ScreenUtil().setHeight(360);
  static double get contentHeight => ScreenUtil().setHeight(500);
  static double get imageHeight => ScreenUtil().setHeight(200);
  static double get imageWidth => ScreenUtil().setWidth(532);
  static double get buttonHeight => ScreenUtil().setHeight(300);

  static double get columnPadding => ScreenUtil().setWidth(10);
  //EQ view
  //static double get contentHeight => ScreenUtil().setHeight(500);
  static double get eqBodyPadding => ScreenUtil().setWidth(100);
  static double get tabImgHeight => ScreenUtil().setHeight(100);
  static double get tabImgWidth => ScreenUtil().setWidth(350);
  static double get tabHeight => ScreenUtil().setHeight(180);
  static double get resetHeight => ScreenUtil().setHeight(160);
  static double get eqListHeight => ScreenUtil().setHeight(1400);
  static double get eqItemHeight => ScreenUtil().setHeight(200);
  static double get eqItemTitleWidth => ScreenUtil().setWidth(260);
  static double get eqItemValueWidth => ScreenUtil().setWidth(240);
  //static double get buttonHeight => ScreenUtil().setHeight(300);
  static TextStyle get contentTextGreen => TextStyle(color: Color.fromARGB(255, 13, 252, 6), fontSize: ScreenUtil().setSp(72));
  static TextStyle get contentTextRed => TextStyle(color: Color.fromARGB(255, 236, 27, 35), fontSize: ScreenUtil().setSp(72));

  static TextStyle get contentTextStyle => TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(72));
  static TextStyle get subtitleTextStyle1 => TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(72));
  static TextStyle get titleTextStyle1 => TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(96));
  static TextStyle get eqHzTextStyle => TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(60));
  static TextStyle get eqHintTextStyle => TextStyle(color: Colors.lightGreenAccent, fontSize: ScreenUtil().setSp(50));
  static TextStyle get guideButtonTextStyle => TextStyle(color: Color.fromARGB(255, 32, 216, 255), fontSize: ScreenUtil().setSp(50));
  static TextStyle get floatHzTextStyle => TextStyle(color: Colors.black87, fontSize: ScreenUtil().setSp(72), fontWeight: FontWeight.normal, decoration: TextDecoration.none);
  static Color     get appRed => Color.fromARGB(255, 236, 27, 35);
  static Color     get appGreen => Color.fromARGB(255, 13, 252, 6);
  static TextStyle get warningTextStyle => TextStyle(color: Color.fromARGB(255, 236, 27, 35), fontSize: ScreenUtil().setSp(72));
  //update view
  static double get updateImgHeight => ScreenUtil().setHeight(916);
  static double get updateImgWidth => ScreenUtil().setWidth(876);
  static double get updateProcessHeight => ScreenUtil().setHeight(763);
  static double get updateProcessWidth => ScreenUtil().setWidth(700);
  static double get updateBodyHeight => ScreenUtil().setHeight(1350);
  static double get updateIconHeight => ScreenUtil().setHeight(200);
  static double get appHeight => ScreenUtil().setHeight(3120);
  static double get appWidth => ScreenUtil().setWidth(1440);
  static double get eqMin => -6.0;
  static double get eqMax => 6.0;


  static double get infoItemTitleWidth => ScreenUtil().setWidth(460);

  static int get appGuide => (firstRun!=null? firstRun: 0);
  // 持久化Profile信息
  static void saveFirstRun(int val) {
    _prefs.setInt("first_run", val);
    firstRun = val;
  }
}