import 'package:flutter/material.dart';

///用于操作子widget运行时更改语言
class MyI18nWidget extends StatefulWidget {
  final child;
  MyI18nWidget({this.child, Key key}):super(key:key);

  @override
  State<StatefulWidget> createState() => MyI18nWidgetState();
}

class MyI18nWidgetState extends State<MyI18nWidget> {
  var _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //获取当前设备语言
    _locale = Localizations.localeOf(context);
  }

  ///动态切换子widget的语言
  void changeLanguage(Locale locale){
    setState(() {
      _locale=locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: widget.child,
    );
  }
}