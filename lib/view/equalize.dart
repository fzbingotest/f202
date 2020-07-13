import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f202/utils/const.dart';
import 'package:f202/utils/myLocalizations.dart';


class EqualizePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EqualizePageState();
}

class _EqualizePageState extends State<EqualizePage>  with SingleTickerProviderStateMixin  {
  int _preset = 0;
  bool _presetActive = false;
  TabController _tabController;
  List<Widget> _eqList;
  Color _resetColor = Colors.white;
  final List<double> _fenderList     = [7,3,2,2,1,4,11];
  final List<double> _seztoList   = [4,0,4,8,8,4,7];
  final List<double> _electronicList = [9,3,5,-6,-4,5,3];
  final List<double> _classicList    = [-6,-1,-4,2,-3,0,9];
  final List<double> _femaleList    = [-2,-2,5,4,5,-2,-5];
  final List<double> _monitorList   = [-4,-3,4,1,3,6,8];
  final List<double> _maleList   = [4,2,4,1,0,-2,-5];
  final List<double> _customizeList   = [0,0,0,0,0,0,0];
  static const String CHANNEL_NAME="fender.f202/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.f202/eq_event_native');
  StreamSubscription _subscription;
  void buildEqList()
  {
    _eqList =  <StatefulWidget>[
      new EqualizeView(type: 'Normal', listGain: _customizeList),
      new EqualizeView(type: 'Fender', listGain: _fenderList),
      new EqualizeView(type: 'Sezto', listGain: _seztoList),
      new EqualizeView(type: 'Electronic', listGain: _electronicList),
      new EqualizeView(type: 'Classical', listGain: _classicList),
      new EqualizeView(type: 'Female Vocals', listGain: _femaleList),
      new EqualizeView(type: 'Monitor', listGain: _monitorList),
      new EqualizeView(type: 'Male Vocals', listGain: _maleList),
//      new EqualizeView(type: 'Customize', listGain: _customizeList),
    ];
  }
  void _getPreset() {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_get_current_preset');
    } on PlatformException catch (e) {
      print("failed to _getPreset "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  void _getPresetActive() {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_get_preset_active');
    } on PlatformException catch (e) {
      print("failed to _getPresetActive "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  void _setPreset(int bank) {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_set_preset', bank);
      print("_setPreset " +bank.toString());
    } on PlatformException catch (e) {
      print("failed to _setPreset "+e.toString());
    }
    //_listContent['Model'] = _result;
  }

  void _setPresetActive(bool active) {
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_set_preset_active', active);
      print("_setPresetActive " +active.toString());
      _presetActive = active;
      _resetColor = _presetActive?Colors.red:Colors.white;
      if(!_presetActive) {
        _preset = 0;
        _tabController.animateTo(_preset);
      }
      setState(() {});
    } on PlatformException catch (e) {
      print("failed to _setPresetActive "+e.toString());
    }
    //_listContent['Model'] = _result;
  }
  @override
  void initState() {
    super.initState();
    _subscription = eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _tabController = TabController(vsync: this,length: 8);
    _tabController.addListener(onTabChange);
    _getPresetActive();
    _getPreset();
    //_setPresetActive(true);
  }

  void onTabChange(){
    print('_tabController = '+ _tabController.toString() + ', index = ' +  _tabController.index.toString());
    if(_tabController.index == _preset)
      return;
    _preset = _tabController.index;
    //_tabController.index  = _preset;
    //TODO set preset
    if(_preset == 0)
      _setPresetActive(false);
    else {
      if(!_presetActive)
        _setPresetActive(true);
      _setPreset(_tabController.index-1);
    }

  }

  @override
  void dispose() {
    _tabController.removeListener(onTabChange);
    _tabController.dispose();
    try {
      if (_subscription != null) {
        _subscription.cancel();
      }
    } on PlatformException catch (e){
      print("failed to get devices "+e.toString());
    }
    super.dispose();
  }
  void _onEvent(Object event) {
    print("EQ _onEvent _result ---->"+ event.toString());
    Map<String, int> res = new Map<String, int>.from(event);
    if(res['key'] == 0)
    {
      _preset = res['bank'];
      if(_presetActive)
      _tabController.animateTo(_preset+1);
      setState(() {});
    }
    if(res['key'] == 1)
    {
      _presetActive = res['value']==1?true:false;
      if(_presetActive)
        _resetColor = Colors.red;
      else {
        _tabController.animateTo(0);
        _resetColor = Colors.white;
      }
      setState(() {});
    }
  }

  void _onError(Object error) {
    print("EQ _onError _result ---->"+ error.toString());
  }

  Widget _buildTabItem(String title)
  {
    return Tab(
        child: Container(
        width: Global.tabImgWidth,//ScreenUtil().setWidth(350),
        height: Global.tabImgHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //border: Border.all(color: Colors.redAccent, width: 1)
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(title, style:Global.contentTextStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    buildEqList();
    return new Container(
      padding: EdgeInsets.all(Global.eqBodyPadding),
      child: Center(
        child:  Column(
          children: <Widget>[
            Container(
              height: Global.tabHeight,
              child: TabBar(
                unselectedLabelColor: Colors.grey,
                //indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey),
                isScrollable:true,
                tabs: <Widget>[
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Normal')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Fender')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Sezto')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Electronic')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Classical')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Female_Vocals')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Monitor')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Male_Vocals')),
                  //_buildTabItem("Customize"),
                ],
                controller: _tabController,  // 记得要带上tabController
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              height: Global.resetHeight,
              child: new IconButton(icon: new ImageIcon(AssetImage('assets/images/reset.png'),color: _resetColor), onPressed: (){
                if(_presetActive)
                _setPresetActive(!_presetActive);
                },),
            ),
            Container(
              height: Global.eqListHeight,
              child: TabBarView(
                physics: new NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _eqList,
              ),
            ),
          ],
        ),
      ),
    );
    }
}

class EqualizeView extends StatefulWidget {
  EqualizeView({Key key, @required this.type, @required this.listGain}) : super(key: key);
  final List<double> listGain;
  final String type;

  _EqualizeViewState createState() => new _EqualizeViewState();

}

class _EqualizeViewState extends State<EqualizeView> {
  final _listTitle = ['250Hz', '500Hz','1000Hz','2000Hz','4000Hz','8000Hz','16000Hz'];
  @override
  Widget build(BuildContext context) {
    _buildEqView();
    return Column(
      children: _listTitle.asMap().keys.map((f)=>
        Container(
          height: Global.eqItemHeight,
          child: Row(
              children: <Widget>[
                SizedBox(child: Text(_listTitle[f], style: Global.eqHzTextStyle,), width: Global.eqItemTitleWidth),
                  SizedBox( width: Global.columnPadding ),
                  Expanded(
                    child: CupertinoSlider(value: widget.listGain[f],min: -12,max: 12,thumbColor: Colors.red,activeColor: Colors.grey, divisions: 1,
                        onChanged: (double value) { }
                        ),
                  )
                ],
            )
            )).toList(),
      );
  }

  //List<Widget> _listEqItem;
  void _buildEqView() { }
}

class EqualizePageGuide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EqualizePageStateGuide();
}

class _EqualizePageStateGuide extends State<EqualizePageGuide>  with SingleTickerProviderStateMixin  {
  TabController _tabController;
  List<Widget> _eqList;
  Color _resetColor = Colors.white;
  final List<double> _fenderList     = [7,3,2,2,1,4,11];
  final List<double> _seztoList   = [4,0,4,8,8,4,7];
  final List<double> _electronicList = [9,3,5,-6,-4,5,3];
  final List<double> _classicList    = [-6,-1,-4,2,-3,0,9];
  final List<double> _femaleList    = [-2,-2,5,4,5,-2,-5];
  final List<double> _monitorList   = [-4,-3,4,1,3,6,8];
  final List<double> _maleList   = [4,2,4,1,0,-2,-5];
  final List<double> _customizeList   = [0,0,0,0,0,0,0];
  void buildEqList()
  {
    _eqList =  <StatefulWidget>[
      new EqualizeView(type: 'Normal', listGain: _customizeList),
      new EqualizeView(type: 'Fender', listGain: _fenderList),
      new EqualizeView(type: 'Sezto', listGain: _seztoList),
      new EqualizeView(type: 'Electronic', listGain: _electronicList),
      new EqualizeView(type: 'Classical', listGain: _classicList),
      new EqualizeView(type: 'Female Vocals', listGain: _femaleList),
      new EqualizeView(type: 'Monitor', listGain: _monitorList),
      new EqualizeView(type: 'Male Vocals', listGain: _maleList),
//      new EqualizeView(type: 'Customize', listGain: _customizeList),
    ];
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this,length: 8);
    _tabController.addListener(onTabChange);
  }

  void onTabChange(){
    print('_tabController = '+ _tabController.toString() + ', index = ' +  _tabController.index.toString());

  }

  @override
  void dispose() {
    _tabController.removeListener(onTabChange);
    _tabController.dispose();
     super.dispose();
  }

  Widget _buildTabItem(String title)
  {
    return Tab(
      child: Container(
        width: Global.tabImgWidth,//ScreenUtil().setWidth(350),
        height: Global.tabImgHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //border: Border.all(color: Colors.redAccent, width: 1)
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(title, style:Global.contentTextStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    buildEqList();
    return new Container(
      padding: EdgeInsets.all(Global.eqBodyPadding),
      child: Center(
        child:  Column(
          children: <Widget>[
            Container(
              height: Global.tabHeight,
              child: TabBar(
                unselectedLabelColor: Colors.grey,
                //indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blueGrey),
                isScrollable:true,
                tabs: <Widget>[
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Normal')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Fender')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Sezto')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Electronic')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Classical')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Female_Vocals')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Monitor')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Male_Vocals')),
                  //_buildTabItem("Customize"),
                ],
                controller: _tabController,  // 记得要带上tabController
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              height: Global.resetHeight,
              child: new IconButton(icon: new ImageIcon(AssetImage('assets/images/reset.png'),color: _resetColor), onPressed: (){}
                ),
            ),
            Container(
              height: Global.eqListHeight,
              child: TabBarView(
                physics: new NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _eqList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
