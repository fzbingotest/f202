import 'package:flutter/material.dart';

class  MyLocalizations {
  final Locale locale;

  MyLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValuesMap = {
    'en_US': {
      'DRIVE': 'GAIN'/*'DRIVE'*/,
      'EQ': 'EQ',
      'UPDATE': 'UPDATE',
      'INFO': 'INFO',
      'Warning': 'Warning',
      'No_fender_connected': 'Fender Tour not connected. Try to connect?'/*'No Fender Tour Connected.\nTry to connect?'*/,
      'No': 'No thanks'/*'No Thanks'*/,
      'OK': 'OK',
      'latest_firmware': 'Latest Firmware: ',
      'Firmware_Update': '   Firmware update   '/*'   Firmware Update   '*/,
      'Firmware_updating': '   Firmware updating   '/*'   Firmware Updating   '*/,
      'unknown':'Checking',
      'update_failed': 'Update failed\nPlease try again later!',
      'Done': 'Done',
      'update_ok': '\nUpdate successful\n'/*'\nUpdate Successful.\n'*/,
      'Audio_Enhance': 'GAIN'/*'Audio Enhance'*/,
      'enhance_content': 'Crank it up to eleven by toggling the Gain function'/*'Audio Enhance function allows fine tuning and power boosting of music playback'*/,
      'high_gain':'HIGH'/*'High gain'*/,
      'low_gain':'LOW'/*'Low gain'*/,
      'Normal': 'Original',
      'Fender': 'Fender',
      'Jazz': 'Jazz',
      'Rock': 'Rock',
      'Sezto': 'customize',
      'Electronic': 'Electronic',
      'Classical': 'Classical',
      'Female_Vocals': 'Female Vocals',
      'Monitor': 'Monitor',
      'Male_Vocals': 'Male Vocals',
      'Model':'Model',
      'Address':'Serial Number',
      'Battery':'Battery',
      'Box battery':'RIGHT side firmware'/*'Right Side Firmware'*/,
      'Status':'Status',
      'Signal':'Signal',
      'Firmware':'LEFT side firmware'/*'Left Side Firmware'*/,
      'App_Version':'App version',
      'Enhance_describe':'  Adjust the power and intensity of your music playback. Select between Balanced and Ludicrous modes.',
      'model_describe':'  The model you connected is shown here.',
      'Eq_describe':'  Press the EQ icon to engage the equalizer. Adjust the frequencies to suit your liking.',
      'EqReset_describe':'  Press the "Reset" button to reset the EQ.',
      'Update_describe':'  Update your Fender Tour to the latest version of firmware by tapping here.',
      'Update_describe1':'  Press the “FIRMWARE UPDATE" button.',
      'Update_describe2':'  After the completion of firmware update, a dialog containing "Update success!" will pop up. Press "OK" to complete the process.',
      'Info_describe':'  Pressing the "INFO" icon displays the information of Fender Tour.',
      'Update_confirm':'Proceed with firmware update?'/*'Are you sure to update your firmware ?'*/,
      'Update':'Proceed'/*'Update'*/,
      'Cancel':'Cancel',
      'SETTING':'SETTINGS',
      'Reset':'Reset',
      'Updating_warn':'Please keep this app open in the foreground until the update is completed'/*'Please keep this screen on the front until the update is completed'*/,
      'guide_overview':'Fender TOUR overview',
      'Volume down':'Volume down',
      'Volume up':'Volume up',
      'Play/Pause':'Play/Pause',
      'PREV SONG':'PREV SONG',
      'Next Song':'Next Song',
      'None':'None',
      'Left tap':'Left tap',
      'Left double-tap':'Left double-tap',
      'Left hold':'Left hold',
      'Right tap':'Right tap',
      'Right double-tap':'Right double-tap',
      'Right hold':'Right hold',
      'firmware_updated':'The firmware is up to date',
      'PAIRING':'PAIRING',
      'pairing_text0': 'When pairing TOUR for the first time\n1. Open the charging case.\n2. With the IEMs inside the case, wait for the LED on the LEFT side IEM to blink green.\n3. Once it does, the TOUR is ready to pair to your device.'/*'When you use TOUR for the first time, open the charging case. Pair it to your phone after the green LED of Left side blinks.'*/,
      'pairing_text1': 'When pairing TOUR to another device\n1. Open the charging case.\n2. With the IEMs inside the case, press and hold the case button for 2 - 5 seconds.\n3. When the LED on the case blinks BLUE AND GREEN, release the charging case button and wait for the LEFT side IEM to blink green.\n4. Once it does, the TOUR is ready to pair to your device. '/*'When you pair TOUR with another device, open the charging case. Press and hold the case button for 2 - 7 seconds, or until the LED on the charging case blinks blue and green. TOUR will then blinks green LED on Left side.'*/,
      'pairing_text2': 'To complete pairing\n1. On your device, go to the Bluetooth settings.\n2. Select "Fender TOUR".\n3. If connected successfully, the LEFT side IEM will stop blinking green.'/*'On your device, go to the Bluetooth settings and select “Fender TOUR ”. The TOUR green LED will turn off once connected successfully.'*/,

      'CHARGING':'CHARGING',
      'charging_text1':'Close the lid of charging case and attach the USB-C charging cable to it.\n',
      'charging_text2':'The LED of charging case will indicate the charging status.: ',
      'charging_text3':'LED is solid red = Charging',
      'charging_text4':'LED is solid green = Fully charged',
      'UPGRADE':'UPDATING FIRMWARE'/*'UPGRADING FIRMWARE'*/,
      'upgrade_test0':'The firmware for the TOUR is updated separately for both sides. Please follow the steps accordingly to make sure both sides of the TOUR are updated to the latest firmware version.',
      'upgrade_test1':'Left side',
      'upgrade_test2':'1. Open the charging case and connect to your device.',
      'upgrade_test2.2':'2. With the IEMs inside the case, select the "Firmware update" button and choose "Update" when the prompt appears.',
      'upgrade_test2.3':'3. Please keep this app open in the foreground until the update is completed.',
      'upgrade_test2.4':'4. After completing LEFT side firmware update, close the charging case and proceed to update RIGHT side.'/*'Press the “Firmware Update” button and keep this screen on the front until the upgrade is completed.'*/,
      'upgrade_test3':'Right side',
      'upgrade_test4':'1. Open the charging case.',
      'upgrade_test4.2':'2. With the IEMs inside the case, press and hold the case button for 12-15 seconds.',
      'upgrade_test4.3':'3.  When the LED on the case blinks BLUE, release the case button and wait for LED on the RIGHT side IEM to blink green. '/*'Open the charging case and press the case button for 15 seconds, or until the LED on the charging case blinks blue. TOUR will then blinks green LED on Right side.\n'*/,
      'upgrade_test5':'4. Open the bluetooth settings on your device and pair with "Fender TOUR R"'/*'On your device, go to Bluetooth settings and select “Fender TOUR R”. The LED of right side will turn off once connected successfully.\n'*/,
      'upgrade_test6':'5. After successful connection to "Fender TOUR R", open the Fender TOUR app and repeat the steps for the Firmware update.',
      'upgrade_test6.6':'6. Once the update for the RIGHT side is completed, close the charging case. Your TOUR is now fully updated to the new firmware version.'/*'Go back to the App. Press the “Firmware Update” button, and keep this screen on the front until the upgrade is completed.'*/,
      'Prev':'Prev',
      'Next':'Next',
      'Finish':'Done',
      'Show_instructions':'Quick start guide',
      'Factory_reset': 'FACTORY RESET',
      'reset_content': 'Place both TWS in the charging case and close the lid.\nOpen the charging case, press & hold the case button until the case LED starts blinking green (about 12 seconds)\nRelease the button and close the case.\nThe Tour has been reset and is ready to pair.',
      'eqHint':'*please wait 5 seconds for customized EQ changes to take effect',
      'hold_button':'After pressing and holding the "F" button',
      'button_pairing':'LED on the case blinks BLUE AND GREEN: Normal Pairing mode',
      'button_reset':'LED on the case blinks GREEN only: Factory Reset mode',
      'button_R_pairing':'LED on the case blinks BLUE only: Right Side Pairing mode',
      'Button':'Button',
      'ButtonTitle':'BUTTON',
      'LED':'LED',
    },
    'zh_CN': {
      'DRIVE': '配置',
      'EQ': 'EQ',
      'UPDATE': '升级',
      'INFO': '资讯',
      'Warning': '警告',
      'No_fender_connected': '没有检测到Fender Tour.\n去连接?',
      'No': '不,谢谢',
      'OK': '是',
      'latest_firmware': '最新版本: ',
      'Firmware_Update': '   固件升级   ',
      'Firmware_updating': '   固件升级中   ',
      'unknown':'检查中',
      'update_failed': '升级失败\n请重试一下!',
      'Done': '完成',
      'update_ok': '\n升级成功.\n',
      'Audio_Enhance': '音讯增强',
      'enhance_content': '开启增益功能以加强动态音压。',
      'high_gain':'高增益',
      'low_gain':'低增益',
      'Normal': '原声',
      'Fender': 'Fender',
      'Jazz': '爵士',
      'Rock': '摇滚',
      'Sezto': '自定义',
      'Electronic': '电子音',
      'Classical': '古典',
      'Female_Vocals': '女声',
      'Monitor': '监听',
      'Male_Vocals': '男声',
      'Model':'型号',
      'Address':'序列号',
      'Battery':'电池',
      'Box battery':'右边版本',
      'Status':'充电状态',
      'Signal':'信号强度',
      'Firmware':'左边版本',
      'App_Version':'APP版本',
      'Enhance_describe':'  调整音乐播放的功率和强度。在平衡模式和特殊模式之间进行选择。',
      'model_describe':'  此处显示当前连接的耳机。',
      'Eq_describe':'  按下EQ按钮使用均衡器。根据你的喜好调整频率。',
      'EqReset_describe':'  按下"复位"按钮复位EQ设置',
      'Update_describe':'  点击这里，把你的Fender Tour升级到最新版本的固件。',
      'Update_describe1':'  按下这个"固件升级"按钮。',
      'Update_describe2':'  固件升级完成后，会弹出一个显示"升级成功!"的对话框。点击"OK"来完成升级。',
      'Info_describe':'  按下"详情"按钮，会显示Fender Tour的详细信息。',
      'Update_confirm':'您确定要升级固件吗？',
      'Update':'升级',
      'Cancel':'取消',
      'SETTING':'设置',
      'Reset':'重置',
      'Updating_warn':'请保持此界面,等待升级完成',
      'guide_overview': '概览'/*'Fender TOUR 概览'*/,
      'Volume down':'降低音量',
      'Volume up':'增大音量',
      'Play/Pause':'播放/暂停',
      'PREV SONG':'上一曲',
      'Next Song':'下一曲',
      'None':'无操作',
      'Left tap':'左边单击',
      'Left double-tap':'左边双击',
      'Left hold':'左边长按',
      'Right tap':'右边单击',
      'Right double-tap':'右边双击',
      'Right hold':'右边长按',
      'firmware_updated':'当前固件已是最新版本!',
      'PAIRING':'配对指引',
      'pairing_text0':'第一次使用 TOUR 时\n1. 打开充电盒\n2. 耳机维持在盒中，等待左边耳机闪绿灯\n3. 绿灯闪烁时，就可以进行配对。',
      'pairing_text1':'第二次配对时\n1. 打开充电盒\n2. 耳机维持在盒中，长按充电盒中间的按键2--5秒\n3. 按至充电盒指示灯蓝绿交替闪烁时，松开按钮，此时左边耳机会闪烁绿灯。\n4. TOUR 现在可供连接',
      'pairing_text2':'在你的蓝牙音频设备的蓝牙设置界面, 点击选择“Fender TOUR”. 如果成功连接，左边指示灯将会熄灭.',

      'CHARGING':'充电指引',
      'charging_text1':'合上盖子, 将type-C充电线接入充电口\n',
      'charging_text2':'充电盒指示灯显示充电状态: ',
      'charging_text3':'指示灯亮红灯 = 充电中',
      'charging_text4':'指示灯亮绿灯 = 充满电',
      'UPGRADE':'耳机升级指引',
      'upgrade_test1':'左边:',
      'upgrade_test2':'1. 打开充电盒，然后连接耳机',
      'upgrade_test3':'右边:',
      'upgrade_test4':'1. 打开充电盒',
      'upgrade_test5':'4. 在你的蓝牙音频设备的蓝牙设置界面, 点击选择“Fender TOUR R”. 如果成功连接, TWS指示灯将会熄灭.\n',
      'upgrade_test6':'5. 成功连接 ”Fender TOUR R“ 后，返回 TOUR App , 然后重复固件升级步骤',
      'upgrade_test0':'TOUR 的软件是左右分开升级，请根据以下步骤升级，以确保两边固件亦升级至最新版本。',
      'upgrade_test2.2':'2. 耳机维持在盒中，按下 “固件升级” 按钮',
      'upgrade_test2.3':'3. 保持升级界面在最前, 直到升级结束',
      'upgrade_test2.4':'4. 完结左边，关上充电盒后准备升级右边'/*'Press the “Firmware Update” button and keep this screen on the front until the upgrade is completed.'*/,
      'upgrade_test4.2':'2. 耳机维持在盒中，长按充电盒中间的按键 12-15 秒',
      'upgrade_test4.3':'3. 按至充电盒指示灯剩下蓝灯闪烁时，松开按钮，此时右边耳机会闪烁绿灯'/*'Open the charging case and press the case button for 15 seconds, or until the LED on the charging case blinks blue. TOUR will then blinks green LED on Right side.\n'*/,
      'upgrade_test6.6':'6. 右边软件升级结束后，关上充电盒，你的 TOUR 现已升级至最新固件'/*'Go back to the App. Press the “Firmware Update” button, and keep this screen on the front until the upgrade is completed.'*/,
      'Prev':'上一页',
      'Next':'下一页',
      'Finish':'完成',
      'Show_instructions':'设备指引',
      'Factory_reset': '恢复出厂设置',
      'reset_content': '将两个TWS耳机放入充电盒中并合上盖子\n打开充电盒，按住充电盒上的按键直到充电盒的指示灯闪绿灯(大约8-12秒)\n松开按键，合上盖子并等待约5秒\n该Tour设备已被复位重置并进入配对模式',
      'eqHint':'*调整EQ后请等待5秒的响应时间',
      'hold_button':'长按“F”按键后',
      'button_pairing':'蓝 绿 灯交替闪烁：正常配对',
      'button_reset':'绿灯闪烁：恢复出厂设置',
      'button_R_pairing':'蓝灯闪烁： 右耳机配对',
      'Button':'按键',
      'ButtonTitle':'按键',
      'LED':'指示灯',
    },
    'zh_HK': {
      'DRIVE': '配置',
      'EQ': 'EQ',
      'UPDATE': '升級',
      'INFO': '資訊',
      'Warning': '警告',
      'No_fender_connected': '沒有檢測到Fender Tour.\n去連接?',
      'No': '不,謝謝',
      'OK': '是',
      'latest_firmware': '最新版本: ',
      'Firmware_Update': '   軟件升級   ',
      'Firmware_updating': '   軟件升級中   ',
      'unknown':'檢查中',
      'update_failed': '升級失敗\n請重試!',
      'Done': '完成',
      'update_ok': '\n成功升級.\n',
      'Audio_Enhance': '音訊增強',
      'enhance_content': '開啟增益功能以加強動態音壓。',
      'high_gain':'高增益',
      'low_gain':'低增益',
      'Normal': 'Original',
      'Fender': 'Fender',
      'Jazz': '爵士',
      'Rock': '搖滾',
      'Sezto': 'Customize',
      'Electronic': '電子',
      'Classical': '古典',
      'Female_Vocals': '女聲',
      'Monitor': '監聽',
      'Male_Vocals': '男聲',
      'Model':'型號',
      'Address':'序列號',
      'Battery':'電量',
      'Box battery':'右邊版本',
      'Status':'充電狀態',
      'Signal':'信號强度',
      'Firmware':'左邊版本',
      'App_Version':'APP版本',
      'Enhance_describe':'  調整音樂播放的功率和强度。在平衡模式和特殊模式之間進行選擇。',
      'model_describe':'  此處顯示当前連接耳機。',
      'Eq_describe':'  按下EQ按鈕使用等化器。根據你的喜好調整頻率。',
      'EqReset_describe':'  按下"復位"按鈕復位EQ設定',
      'Update_describe':'  點擊這裡，把你的AE1i陞級到最新版本的固件。',
      'Update_describe1':'  按下這個"固件升級"按鈕。',
      'Update_describe2':'  固件升級完成後，會彈出一個顯示"陞級成功！"的對話方塊。點擊"OK"來完成陞級。',
      'Info_describe':'  按下"詳情"按鈕，會顯示Fender Tour的詳細資訊。',
      'Update_confirm':'您確定要升級軟件嗎？',
      'Update':'升級',
      'Cancel':'取消',
      'SETTING':'設置',
      'Reset':'重置',
      'Updating_warn':'請保持此界面,等待升級完成!',
      'guide_overview': '概覽'/*'Fender TOUR 概覽'*/,
      'Volume down':'降低音量',
      'Volume up':'增大音量',
      'Play/Pause':'播放/暫停',
      'PREV SONG':'上一曲',
      'Next Song':'下一曲',
      'None':'無操作',
      'Left tap':'左邊單擊',
      'Left double-tap':'左邊雙擊',
      'Left hold':'左邊長按',
      'Right tap':'右邊單擊',
      'Right double-tap':'右邊雙擊',
      'Right hold':'右邊長按',
      'firmware_updated':'當前軟件已是最新版本!',
      'PAIRING':'配對指引',
      'pairing_text0':'第一次使用 TOUR 時\n1. 打開充電盒\n2. 耳機維持在盒中，等待左邊耳機閃綠燈\n3. 綠燈閃爍時，就可以進行配對。',
      'pairing_text1':'第二次配對時\n1. 打開充電盒\n2. 耳機維持在盒中，長按充電盒中間的按鍵2--5秒\n3. 按至充電盒指示燈藍綠交替閃爍時，鬆開按鈕，此時左邊耳機會閃爍綠燈。\n4. TOUR 現在可供連接',
      'pairing_text2':'在你的設備藍牙設置界面, 點擊選擇“Fender TOUR”. 如果成功連接, 左邊指示燈將會熄滅.',

      'CHARGING':'充電指引',
      'charging_text1':'合上充電盒, 將type-C充電線接入充電口\n',
      'charging_text2':'充電盒指示燈顯示充電狀態: ',
      'charging_text3':'指示燈亮紅燈 = 充電中',
      'charging_text4':'指示燈亮綠燈 = 充滿電',
      'UPGRADE':'耳機升級指引',
      'upgrade_test1':'左邊:',
      'upgrade_test2':'1. 打開充電盒，然後連接耳機',
      'upgrade_test3':'右邊:',
      'upgrade_test4':'1. 打開充電盒',
      'upgrade_test5':'4. 在你的設備藍牙設置界面, 點擊選擇“Fender TOUR R”. 如果成功連接, TOUR 指示燈將會熄滅.\n',
      'upgrade_test6':'5. 成功連接 ”Fender TOUR R“ 後，返回 TOUR App ,  然後重複軟件升級步驟',
      'upgrade_test0':'TOUR 的軟件是左右分開升級，請根據以下步驟升級，以確保兩邊軟件亦升級至最新版本。',
      'upgrade_test2.2':'2. 耳機維持在盒中，按下 “軟件升級” 按鈕',
      'upgrade_test2.3':'3. 保持升級界面在最前, 直到升級結束',
      'upgrade_test2.4':'4. 完結左邊，關上充電盒後準備升級右邊'/*'Press the “Firmware Update” button and keep this screen on the front until the upgrade is completed.'*/,
      'upgrade_test4.2':'2. 耳機維持在盒中，長按充電盒中間的按鍵  12-15 秒',
      'upgrade_test4.3':'3. 按至充電盒指示燈剩下藍燈閃爍時，鬆開按鈕，此時右邊耳機會閃爍綠燈'/*'Open the charging case and press the case button for 15 seconds, or until the LED on the charging case blinks blue. TOUR will then blinks green LED on Right side.\n'*/,
      'upgrade_test6.6':'6. 右邊軟件升級結束後，關上充電盒，你的 TOUR 現已升級至最新版本'/*'Go back to the App. Press the “Firmware Update” button, and keep this screen on the front until the upgrade is completed.'*/,
      'Prev':'上一頁',
      'Next':'下一頁',
      'Finish':'完成',
      'Show_instructions':'設備指引',
      'Factory_reset': '恢復出廠設定',
      'reset_content': '將兩個 TWS 耳機放入充電盒中，並合上蓋子\n打開充電盒，按住充電盒上的按鍵，直至充電盒的指示燈轉為閃爍綠燈（大約 8 -12 秒）\n鬆開按鍵，合上蓋子並等待約 5 秒\n該 Tour 設備已經重設，並進入配對模式',
      'eqHint':'*調整 EQ 後請等待 5 秒來發揮效果',
      'hold_button':'長按“F”按鍵後',
      'button_pairing':'指示燈藍綠交替閃爍：正常配對',
      'button_reset':'綠燈閃爍：恢復出廠設置',
      'button_R_pairing':'藍燈閃爍： 右邊耳機配對',
      'Button':'按鍵',
      'ButtonTitle':'按鍵',
      'LED':'指示燈',
    },
    'zh_TW': {
      'DRIVE': '配置',
      'EQ': 'EQ',
      'UPDATE': '升級',
      'INFO': '資訊',
      'Warning': '警告',
      'No_fender_connected': '沒有檢測到Fender Tour.\n去連接?',
      'No': '不,謝謝',
      'OK': '是',
      'latest_firmware': '最新版本: ',
      'Firmware_Update': '   軟件升級   ',
      'Firmware_updating': '   軟件升級中   ',
      'unknown':'檢查中',
      'update_failed': '升級失敗\n請重試!',
      'Done': '完成',
      'update_ok': '\n成功升級.\n',
      'Audio_Enhance': '音訊增強',
      'enhance_content': '開啟增益功能以加強動態音壓。',
      'high_gain':'高增益',
      'low_gain':'低增益',
      'Normal': 'Original',
      'Fender': 'Fender',
      'Jazz': '爵士',
      'Rock': '搖滾',
      'Sezto': 'Customize',
      'Electronic': '電子',
      'Classical': '古典',
      'Female_Vocals': '女聲',
      'Monitor': '監聽',
      'Male_Vocals': '男聲',
      'Model':'型號',
      'Address':'序列號',
      'Battery':'電量',
      'Box battery':'右邊版本',
      'Status':'充電狀態',
      'Signal':'信號强度',
      'Firmware':'左邊版本',
      'App_Version':'APP版本',
      'Enhance_describe':'  調整音樂播放的功率和强度。在平衡模式和特殊模式之間進行選擇。',
      'model_describe':'  此處顯示当前連接耳機。',
      'Eq_describe':'  按下EQ按鈕使用等化器。根據你的喜好調整頻率。',
      'EqReset_describe':'  按下"復位"按鈕復位EQ設定',
      'Update_describe':'  點擊這裡，把你的AE1i陞級到最新版本的固件。',
      'Update_describe1':'  按下這個"固件升級"按鈕。',
      'Update_describe2':'  固件升級完成後，會彈出一個顯示"陞級成功！"的對話方塊。點擊"OK"來完成陞級。',
      'Info_describe':'  按下"詳情"按鈕，會顯示Fender Tour的詳細資訊。',
      'Update_confirm':'您確定要升級軟件嗎？',
      'Update':'升級',
      'Cancel':'取消',
      'SETTING':'設置',
      'Reset':'重置',
      'Updating_warn':'請保持此界面,等待升級完成!',
      'guide_overview': '概覽'/*'Fender TOUR 概覽'*/,
      'Volume down':'降低音量',
      'Volume up':'增大音量',
      'Play/Pause':'播放/暫停',
      'PREV SONG':'上一曲',
      'Next Song':'下一曲',
      'None':'無操作',
      'Left tap':'左邊單擊',
      'Left double-tap':'左邊雙擊',
      'Left hold':'左邊長按',
      'Right tap':'右邊單擊',
      'Right double-tap':'右邊雙擊',
      'Right hold':'右邊長按',
      'firmware_updated':'當前軟件已是最新版本!',
      'PAIRING':'配對指引',
      'pairing_text0':'第一次使用 TOUR 時\n1. 打開充電盒\n2. 耳機維持在盒中，等待左邊耳機閃綠燈\n3. 綠燈閃爍時，就可以進行配對。',
      'pairing_text1':'第二次配對時\n1. 打開充電盒\n2. 耳機維持在盒中，長按充電盒中間的按鍵2--5秒\n3. 按至充電盒指示燈藍綠交替閃爍時，鬆開按鈕，此時左邊耳機會閃爍綠燈。\n4. TOUR 現在可供連接',
      'pairing_text2':'在你的設備藍牙設置界面, 點擊選擇“Fender TOUR”. 如果成功連接, 左邊指示燈將會熄滅.',

      'CHARGING':'充電指引',
      'charging_text1':'合上充電盒, 將type-C充電線接入充電口\n',
      'charging_text2':'充電盒指示燈顯示充電狀態: ',
      'charging_text3':'指示燈亮紅燈 = 充電中',
      'charging_text4':'指示燈亮綠燈 = 充滿電',
      'UPGRADE':'耳機升級指引',
      'upgrade_test1':'左邊:',
      'upgrade_test2':'1. 打開充電盒，然後連接耳機',
      'upgrade_test3':'右邊:',
      'upgrade_test4':'1. 打開充電盒',
      'upgrade_test5':'4. 在你的設備藍牙設置界面, 點擊選擇“Fender TOUR R”. 如果成功連接, TOUR 指示燈將會熄滅.\n',
      'upgrade_test6':'5. 成功連接 ”Fender TOUR R“ 後，返回 TOUR App ,  然後重複軟件升級步驟',
      'upgrade_test0':'TOUR 的軟件是左右分開升級，請根據以下步驟升級，以確保兩邊軟件亦升級至最新版本。',
      'upgrade_test2.2':'2. 耳機維持在盒中，按下 “軟件升級” 按鈕',
      'upgrade_test2.3':'3. 保持升級界面在最前, 直到升級結束',
      'upgrade_test2.4':'4. 完結左邊，關上充電盒後準備升級右邊'/*'Press the “Firmware Update” button and keep this screen on the front until the upgrade is completed.'*/,
      'upgrade_test4.2':'2. 耳機維持在盒中，長按充電盒中間的按鍵  12-15 秒',
      'upgrade_test4.3':'3. 按至充電盒指示燈剩下藍燈閃爍時，鬆開按鈕，此時右邊耳機會閃爍綠燈'/*'Open the charging case and press the case button for 15 seconds, or until the LED on the charging case blinks blue. TOUR will then blinks green LED on Right side.\n'*/,
      'upgrade_test6.6':'6. 右邊軟件升級結束後，關上充電盒，你的 TOUR 現已升級至最新版本'/*'Go back to the App. Press the “Firmware Update” button, and keep this screen on the front until the upgrade is completed.'*/,
      'Prev':'上一頁',
      'Next':'下一頁',
      'Finish':'完成',
      'Show_instructions':'設備指引',
      'Factory_reset': '恢復出廠設定',
      'reset_content': '將兩個 TWS 耳機放入充電盒中，並合上蓋子\n打開充電盒，按住充電盒上的按鍵，直至充電盒的指示燈轉為閃爍綠燈（大約 8 -12 秒）\n鬆開按鍵，合上蓋子並等待約 5 秒\n該 Tour 設備已經重設，並進入配對模式',
      'eqHint':'*調整 EQ 後請等待 5 秒來發揮效果',
      'hold_button':'長按“F”按鍵後',
      'button_pairing':'指示燈藍綠交替閃爍：正常配對',
      'button_reset':'綠燈閃爍：恢復出廠設置',
      'button_R_pairing':'藍燈閃爍： 右邊耳機配對',
      'Button':'按鍵',
      'ButtonTitle':'按鍵',
      'LED':'指示燈',
    }
  };

  String getText(String key){
    ///注意用 locale.toString()而非locale
    return _localizedValuesMap[locale.toString()][key];
  }

  get testText =>'abc';

  ///MyLocalizations的实例是在 Localizations中通过 MyLocalizationsDelegate实例化,
  ///应用中要使用 MyLocalizations的实例需要通过 Localizations这个 Widget来获取。
  static MyLocalizations of(BuildContext context){
    return Localizations.of(context, MyLocalizations);
  }
}