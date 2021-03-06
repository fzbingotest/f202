import 'package:Tour/index/guide.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myI18nWidget.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:Tour/utils/myLocalizationsDelegate.dart';


import 'index/index.dart';
import 'utils/const.dart';
void main() {
  // 强制竖屏
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_){
    SystemChrome.setEnabledSystemUIOverlays ([]);
    Global.init().then((value) => runApp(MyApp()));

  });
}
GlobalKey<MyI18nWidgetState> myI18nWidgetStateKey=GlobalKey<MyI18nWidgetState>();
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      onGenerateTitle: (context){
        //默认的 build()的 context对象无法获得 MyLocalizations对象，
        //所以这里引用 onGenerateTitle的 context对象。
        //print("~~~~" + MyLocalizations.of(context).testText);
        print("~~" + MyLocalizations.of(context).toString() + "~~"+context.toString());
        Global.initContest(context);
        print("~~" + MyLocalizations.of(Global.context).toString() + "~~"+Global.context.toString());
        return MyLocalizations.of(context).testText;
      },
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('zh', 'HK'),
        const Locale('zh', 'TW'),
        const Locale('zh', 'CN'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        MyLocalizationsDelegate(),
        const FallbackCupertinoLocalisationsDelegate(),
      ],
      //title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color.fromARGB(255,52,52,52),
          canvasColor: Color.fromARGB(255,52,52,52),
          brightness: Brightness.dark,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        /*theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        //primarySwatch: Colors.blue,
       // primaryColor: Colors.black,
       // canvasColor: Colors.black,
        brightness: Brightness.dark,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),*/
      home: MyI18nWidget(
        key: myI18nWidgetStateKey,
        child:  new FirstPage(),// MyHomePage(title: 'FENDER'),
      )
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => new _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool _guide = true;
  @override
  Widget build(BuildContext context) {
    if(Global.appGuide < 5 && _guide)
    {
      Future.delayed(Duration(microseconds: 500), () {
        Navigator.push(
            context, new MaterialPageRoute(builder: (context) => new Guide()));
      });
      _guide = false;
    }
    return new Index();
  }
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
