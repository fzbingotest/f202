import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Tour/utils/const.dart';
import 'package:Tour/utils/myLocalizations.dart';
import 'package:Tour/utils/myTabs.dart';


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
  final List<double> _rockList     = [1,2,3,4,-1,-2,1];
  final List<double> _seztoList   = [0,0,0,0,0,0,0];
  final List<double> _electronicList = [-1,3,3,1,2,3,2];
  //final List<double> _classicList    = [-1,2,2,2,2,3,1];
  final List<double> _classicList    = [1,2,2,2,2,2,1];
  final List<double> _femaleList    = [0,0,1,1,2,1,3];
  //final List<double> _monitorList   = [-1,-3,2,1,1,0,0];
  //final List<double> _jazzList   = [-3,-1,0,1,0,-1,-3];
  final List<double> _jazzList   = [-3,-1,1,1,0,-1,-1];
  //final List<double> _maleList   = [2,3,3,-2,-3,-4,-3];
  final List<double> _maleList   = [2,3,2,0,-1,-1,-2];
  final List<double> _customizeList   = [0,0,0,0,0,0,0];
  static const String CHANNEL_NAME="fender.Tour/call_native";
  static const platform=const MethodChannel(CHANNEL_NAME);
  static const EventChannel eventChannel =  const EventChannel('fender.Tour/eq_event_native');
  StreamSubscription _subscription;
  void buildEqList()
  {
    _eqList =  <StatefulWidget>[
      new EqualizeView(type: 'Normal', listGain: _customizeList),
      new EqualizeView(type: 'Jazz', listGain: _jazzList),
      new EqualizeView(type: 'Electronic', listGain: _electronicList),
      new EqualizeView(type: 'Classical', listGain: _classicList),
      new EqualizeView(type: 'Female Vocals', listGain: _femaleList),
      new EqualizeView(type: 'Rock', listGain: _rockList),
      new EqualizeView(type: 'Male Vocals', listGain: _maleList),
      new EqualizeView(type: 'Sezto', listGain: _seztoList),
//      new EqualizeView(type: 'Customize', listGain: _customizeList),
    ];
  }

  void _getPreset() {
    try {
       platform.invokeMethod('native_get_current_preset');
    } on PlatformException catch (e) {
      print("failed to _getPreset "+e.toString());
    }
  }

  void _getPresetActive() {
    try {
      platform.invokeMethod('native_get_preset_active');
    } on PlatformException catch (e) {
      print("failed to _getPresetActive "+e.toString());
    }
  }

  void _setPreset(int bank) {
    try {
      platform.invokeMethod('native_set_preset', bank);
      print("_setPreset " +bank.toString());
    } on PlatformException catch (e) {
      print("failed to _setPreset "+e.toString());
    }
    //_listContent['Model'] = _result;
  }

  void _setPresetActive(bool active) {
    try {
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
    print('_tabController = '+ _tabController.toString() + ', index = ' +  _tabController.index.toString() + ', _preset = ' +  _preset.toString());
    if(_tabController.index == _preset) {
      if (_preset == 7) {
        _getCustomEq();
      }
      return;
    }
    if(_preset ==7)
      setState(() {
      });
    _preset = _tabController.index;
    //_tabController.index  = _preset;
    if(_preset == 0)
      _setPresetActive(false);
    else {
      if(!_presetActive)
        _setPresetActive(true);
      //_setPreset(_tabController.index-1);
      print('_tabController = '+ _tabController.toString() + ', _preset = ' +  _preset.toString());

      if(_preset == 7){
        _setPreset(0);
        _setPreset(1);
      }
      else if(_preset == 1)
      {
        _setPreset(0);
      }
      else {
        _setPreset(_preset);
      }
    }
  }

  void _getCustomEq(){
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      platform.invokeMethod('native_get_custom_eq');
      print("_getCustomEq ");
    } on PlatformException catch (e) {
      print("failed to _getCustomEq "+e.toString());
    }
  }

  static void setCustomEq(int band, int gain){
    try {
      //var result = platform.invokeMethod('native_get_information');
      //Map<String, String> res = new Map<String, String>.from(result);
      List args = new List();
      args.add(band);
      args.add(gain);
      platform.invokeMethod('native_set_custom_eq', args);
      print("setCustomEq ");
    } on PlatformException catch (e) {
      print("failed to setCustomEq "+e.toString());
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

  bool _keyValid(int key) => (key>=-12 && key<=12);
  int _bank2UI(int bank)
  {
    if(bank == 1)
      return 7;
    else if(bank == 0)
      return 1;
    else
      return bank;
  }

  void _onEvent(Object event) {
    print("EQ _onEvent _result ---->"+ event.toString());
    Map<String, int> res = new Map<String, int>.from(event);
    if(res['key'] == 0)
    {
      _preset = _bank2UI(res['bank']);
      if(_presetActive)
      _tabController.animateTo(_preset);
      setState(() {});
    }
    else if(res['key'] == 1)
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
    else if(res['key'] == 7)
    {
      String key = 'band';
      String key1 = '';
      for(int i= 0; i<7; i++)
      {
        key1 = key+i.toString();
        if(res[key1] != null && _keyValid(res[key1])) {
          _seztoList[i] = res[key1].toDouble();
          if(_seztoList[i] < Global.eqMin)
            _seztoList[i] = Global.eqMin;
          else if (_seztoList[i] > Global.eqMax)
            _seztoList[i] = Global.eqMax;
          setCustomEq(i, res[key1].toInt());
        }
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
        //width: Global.tabImgWidth,//ScreenUtil().setWidth(350),
        height: Global.tabImgHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //border: Border.all(color: Colors.redAccent, width: 1)
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(title, style:Global.eqHzTextStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    buildEqList();
    print('EQ rebuild ' + _tabController.index.toString());
    return new Container(
      padding: EdgeInsets.all(Global.eqBodyPadding),
      child: Center(
        child:  Column(
          children: <Widget>[
            Container(
              height: Global.tabHeight*1.2,
              child: myTabBar(
                unselectedLabelColor: Colors.grey,
                //indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                indicator: MyBoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey),
                isScrollable:true,
                tabs: <Widget>[
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Normal')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Jazz')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Electronic')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Classical')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Female_Vocals')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Rock')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Male_Vocals')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Sezto')),
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
            Container(
              width: Global.appWidth - Global.eqBodyPadding*2,
              child: (_tabController.index==7) ? Text(MyLocalizations.of(Global.context).getText('eqHint'), style: Global.eqHintTextStyle, textAlign: TextAlign.left,):null,
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
                    child: CupertinoSlider(value: widget.listGain[f],min: Global.eqMin,max: Global.eqMax,thumbColor: Colors.red,activeColor: Colors.grey, divisions: 24,
                        onChanged: (double value) {
                          if(widget.type.contains('Sezto')) {
                            int temp = value.round();
                            widget.listGain[f] = temp.toDouble();
                            setState(() {
                            });
                          }
                        },
                        onChangeEnd: (double newValue) {
                          if(widget.type.contains('Sezto')) {
                            _EqualizePageState.setCustomEq(f, newValue.round());
                            print('Ended change on $newValue');
                          }

                        },
                        ),
                  ),
                widget.type.contains('Sezto')? SizedBox(child: Text(widget.listGain[f].toString()+'db', style: Global.eqHzTextStyle,), width: Global.eqItemValueWidth): Text(''),
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
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Jazz')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Sezto')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Electronic')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Classical')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Female_Vocals')),
                  _buildTabItem(MyLocalizations.of(Global.context).getText('Rock')),
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
