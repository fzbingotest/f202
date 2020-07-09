import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'myLocalizations.dart';


class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations>{
  const MyLocalizationsDelegate();
  static MyLocalizationsDelegate delegate = const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }

  @override
  Future<MyLocalizations> load(Locale locale) {
    ///这里初始化 Localizations类
    return SynchronousFuture<MyLocalizations>(new MyLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<MyLocalizations> old) {
    return false;
  }
}