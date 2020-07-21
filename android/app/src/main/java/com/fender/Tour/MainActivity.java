package com.fender.Tour;
import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
//import android.os.Environment;
import android.os.SystemClock;
import android.provider.Settings;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.android.FlutterActivity;

import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.lang.reflect.Method;

import com.fender.Tour.gaia.InformationGaiaManager;
import com.fender.Tour.receivers.BluetoothStateReceiver;
import com.fender.Tour.services.BluetoothService;
import com.fender.Tour.services.GAIABREDRService;
import com.fender.Tour.services.GAIAGATTBLEService;
import com.qualcomm.qti.libraries.gaia.GAIA;
import com.qualcomm.qti.libraries.vmupgrade.UpgradeError;
import com.qualcomm.qti.libraries.vmupgrade.UpgradeManager;
import com.qualcomm.qti.libraries.vmupgrade.codes.ResumePoints;


import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;


public class MainActivity extends FlutterActivity
        implements BluetoothStateReceiver.BroadcastReceiverListener, InformationGaiaManager.GaiaManagerListener{
    private static final String TAG = "MainActivity";
    private boolean DEBUG = Consts.DEBUG;
    private static final String CHANNEL= "fender.Tour/call_native";
    private MethodChannel methodChannel;

    private static final String EVENT_CHANNEL= "fender.Tour/event_native";
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private static final String EQ_EVENT_CHANNEL= "fender.Tour/eq_event_native";
    private EventChannel eqEventChannel;
    private EventChannel.EventSink eqEventSink;
    private static final String BASS_EVENT_CHANNEL= "fender.Tour/bass_event_native";
    private EventChannel bassEventChannel;
    private EventChannel.EventSink bassEventSink;
    private static final String UPDATE_EVENT_CHANNEL= "fender.Tour/update_event_native";
    private EventChannel updateEventChannel;
    private EventChannel.EventSink updateEventSink;
    private static final String MAIN_EVENT_CHANNEL= "fender.Tour/main_event_native";
    private EventChannel mainEventChannel;
    private EventChannel.EventSink mainEventSink;
    private Map<String, String> mMap;
    private long mStartTime = 0;
    private File mFile = null;
    private int mBatteryLevel = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.init();
    }

    @Override // Activity from ServiceActivity
    protected void onResume() {
        super.onResume();
        this.getContext().registerReceiver(mReceiver, makeFilter());
        mIsPaused = false;
        Log.d(TAG, "onResume.");
        if (mService != null) {
            initService();
        }
        else {
            Log.d(TAG, "BluetoothLEService not bound yet.");
            tryConnectedBtDevice();
        }
    }

    @Override // Activity from ServiceActivity
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause.");
        this.getContext().unregisterReceiver(mReceiver);
        mIsPaused = true;

        if (mService != null) {
            rmInformationFromDevice();
            mService.removeHandler(mHandler);
            mService = null;
            unbindService(mServiceConnection);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mService != null) {
            mService.removeHandler(mHandler);
            mService = null;
            unbindService(mServiceConnection);
        }

    }

    private boolean isDeviceReady(){
        return (mService!= null && mService.isGaiaReady() && mGaiaManager!= null);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        //
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL);
        methodChannel.setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                    String res = "Success";
                    switch (call.method) {
                        case "call_native_method":
                            int param = call.arguments();
                            res = "I am bingo from android" + param;
                            Log.i(TAG, "mGaiaManager");
                            //mGaiaManager.getInformation(InformationGaiaManager.Information.APP_VERSION);

                            result.success(res);
                            break;
                        case "native_get_bt_device":
                            getConnectedBtDevice(result);
                            break;
                        case "native_get_information":
                            getInformationFromDevice();
                            result.success(mMap);
                            break;
                        case "native_get_current_device":
                            getConnectedBtDevice(result);
                            break;
                        case "native_get_current_preset":
                            if (isDeviceReady())
                                mGaiaManager.getPreset();
                            result.success(res);
                            break;
                        case "native_set_preset":
                            int preset = call.arguments();
                            if (isDeviceReady())
                                mGaiaManager.setPreset(preset);

                            break;
                        case "native_set_preset_active": {
                            boolean active = call.arguments();
                            if (isDeviceReady())
                                mGaiaManager.setActivationState(InformationGaiaManager.Controls.PRESETS, active);

                            break;
                        }
                        case "native_get_custom_eq":
                            if (isDeviceReady())
                                mGaiaManager.getCustomEqParams();
                            break;
                        case "native_set_custom_eq":
                            ArrayList<Integer> args = call.arguments();
                            Log.i(TAG, "native_set_custom_eq " + args.toString());
                            if (isDeviceReady())
                                mGaiaManager.setCustomEqGain(args.get(0), args.get(1));

                            break;
                        case "native_get_preset_active":
                            if (isDeviceReady())
                                mGaiaManager.getActivationState(InformationGaiaManager.Controls.PRESETS);
                            break;
                        case "native_go_to_setting":
                            startActivity(new Intent(Settings.ACTION_BLUETOOTH_SETTINGS));

                            break;
                        case "native_get_bass":
                            if (isDeviceReady())
                                mGaiaManager.getActivationState(InformationGaiaManager.Controls.BASS_BOOST);
                            break;
                        case "native_set_bass": {
                            boolean active = call.arguments();
                            if (isDeviceReady())
                                mGaiaManager.setActivationState(InformationGaiaManager.Controls.BASS_BOOST, active);
                            break;
                        }
                        case "native_upgrade":
                            String url = call.arguments();
                            downloadFile(url, "1.bin");
                            return;
                        case "native_get_firmware_version":
                            if (isDeviceReady())
                                mGaiaManager.getInformation(InformationGaiaManager.Information.APP_VERSION);
                            break;
                        default:
                            result.success("I don't know what you say");
                            break;
                    }
                    /*if(mService == null)
                        getConnectedBtDevice(result);*/

                }
            }
        );

        eqEventChannel = new EventChannel(flutterEngine.getDartExecutor(), EQ_EVENT_CHANNEL);
        eqEventChannel.setStreamHandler(
            new EventChannel.StreamHandler() {
                // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                @Override
                public void onListen(Object arguments, EventChannel.EventSink events) {
                    eqEventSink = events;
                }

                @Override
                public void onCancel(Object arguments) {
                    //rmInformationFromDevice();
                    eqEventSink = null;
                }
            }
        );

        updateEventChannel = new EventChannel(flutterEngine.getDartExecutor(), UPDATE_EVENT_CHANNEL);
        updateEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        updateEventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        //rmInformationFromDevice();
                        updateEventSink = null;
                    }
                }
        );

        bassEventChannel = new EventChannel(flutterEngine.getDartExecutor(), BASS_EVENT_CHANNEL);
        bassEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        bassEventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        //rmInformationFromDevice();
                        bassEventSink = null;
                    }
                }
        );

        eventChannel = new EventChannel(flutterEngine.getDartExecutor(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        rmInformationFromDevice();
                        eventSink = null;
                    }
                }
        );
        mainEventChannel = new EventChannel(flutterEngine.getDartExecutor(), MAIN_EVENT_CHANNEL);
        mainEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        mainEventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        rmInformationFromDevice();
                        mainEventSink = null;
                    }
                }
        );
    }

    //获取已连接的蓝牙设备
    private void getConnectedBtDevice(MethodChannel.Result result){
        mMap = new HashMap<>();
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        Class<BluetoothAdapter> bluetoothAdapterClass = BluetoothAdapter.class;//得到BluetoothAdapter的Class对象
        try {

            //得到连接状态的方法
            Method method = bluetoothAdapterClass.getDeclaredMethod("getConnectionState", (Class[]) null);
            //打开权限
            method.setAccessible(true);
            int state = (int) method.invoke(adapter, (Object[]) null);
            if(state == BluetoothAdapter.STATE_CONNECTED){
                Log.i("BLUETOOTH","BluetoothAdapter.STATE_CONNECTED");
                Set<BluetoothDevice> devices = adapter.getBondedDevices(); //集合里面包括已绑定的设备和已连接的设备
                Log.i("BLUETOOTH","devices:"+devices.size());
                for(BluetoothDevice device : devices){
                    Method isConnectedMethod = BluetoothDevice.class.getDeclaredMethod("isConnected", (Class[]) null);
                    boolean isConnected = (boolean) isConnectedMethod.invoke(device, (Object[]) null);
                    if(isConnected){ //根据状态来区分是已连接的还是已绑定的，isConnected为true表示是已连接状态。
                        Log.i("BLUETOOTH-dh","connected:"+device.getName());
                        Method batteryMethod = BluetoothDevice.class.getDeclaredMethod("getBatteryLevel", (Class[]) null);
                        batteryMethod.setAccessible(true);
                        int battery = (int) batteryMethod.invoke(device, (Object[]) null);
                        Log.i(TAG,"Battery:"+battery);
                        //start bdr
                        mBatteryLevel = battery;
                        start_bdr_devices(device);
                        mMap.put("Model", device.getName());
                        mMap.put("Address",device.getAddress());
                        //getInformationFromDevice();
                        result.success(mMap);
                        return;
                    }
                }
            }
            mMap.put("Model", "none");
            mMap.put("Address","none");
            //getInformationFromDevice();
            result.success(mMap);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //获取已连接的蓝牙设备
    private void tryConnectedBtDevice(){
        mMap = new HashMap<String,String>();
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        Class<BluetoothAdapter> bluetoothAdapterClass = BluetoothAdapter.class;//得到BluetoothAdapter的Class对象
        try {

            //得到连接状态的方法
            Method method = bluetoothAdapterClass.getDeclaredMethod("getConnectionState", (Class[]) null);
            //打开权限
            method.setAccessible(true);
            int state = (int) method.invoke(adapter, (Object[]) null);
            if(state == BluetoothAdapter.STATE_CONNECTED){
                Log.i("BLUETOOTH","BluetoothAdapter.STATE_CONNECTED");
                Set<BluetoothDevice> devices = adapter.getBondedDevices(); //集合里面包括已绑定的设备和已连接的设备
                Log.i("BLUETOOTH","devices:"+devices.size());
                for(BluetoothDevice device : devices){
                    Method isConnectedMethod = BluetoothDevice.class.getDeclaredMethod("isConnected", (Class[]) null);
                    boolean isConnected = (boolean) isConnectedMethod.invoke(device, (Object[]) null);
                    if(isConnected){ //根据状态来区分是已连接的还是已绑定的，isConnected为true表示是已连接状态。
                        Log.i("BLUETOOTH-dh","connected:"+device.getName());
                        Method batteryMethod = BluetoothDevice.class.getDeclaredMethod("getBatteryLevel", (Class[]) null);
                        batteryMethod.setAccessible(true);
                        int battery = (int) batteryMethod.invoke(device, (Object[]) null);
                        Log.i(TAG,"Battery:"+battery);
                        mBatteryLevel = battery;
                        //start bdr
                        mMap.put("Model", device.getName());
                        mMap.put("Address",device.getAddress());
                        //getInformationFromDevice();
                        if(mainEventSink!=null)
                            mainEventSink.success(mMap);
                        start_bdr_devices(device);
                        return;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private IntentFilter makeFilter() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        return filter;
    }

    private BroadcastReceiver mReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            Log.e(TAG,"onReceive---------" + intent.getAction());
            switch (intent.getAction()) {
                case BluetoothAdapter.ACTION_STATE_CHANGED:
                    int blueState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0);
                    switch (blueState) {
                        case BluetoothAdapter.STATE_TURNING_ON:
                            Log.e(TAG,"onReceive---------STATE_TURNING_ON");
                            break;
                        case BluetoothAdapter.STATE_ON:
                            Log.e(TAG,"onReceive---------STATE_ON");
                            if(mService != null){
                                mService.reconnectToDevice();
                            }
                            else {
                                tryConnectedBtDevice();
                            }
                            break;
                        case BluetoothAdapter.STATE_TURNING_OFF:
                            Log.e(TAG,"onReceive---------STATE_TURNING_OFF");
                            if(mService != null){
                                mService.disconnectDevice();
                            }
                            //BleUtil.toReset(mContext);
                            break;
                        case BluetoothAdapter.STATE_OFF:
                            Log.e(TAG,"onReceive---------STATE_OFF");

                            //BleUtil.toReset(mContext);
                            break;
                    }
                    break;
            }
        }
    };

    private void start_bdr_devices(BluetoothDevice device)
    {
        // keep information
        SharedPreferences sharedPref = getSharedPreferences(Consts.PREFERENCES_FILE, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putInt(Consts.TRANSPORT_KEY, BluetoothService.Transport.BR_EDR);
        editor.putString(Consts.BLUETOOTH_ADDRESS_KEY, device.getAddress());
        editor.apply();
        if(mService == null)
            startService();
    }

    private void startUpgrade(File file) {
        if (file != null) {
            mStartTime = 0;
            mService.startUpgrade(file);
        }

    }

    /**
     * <p>This method is called when the service informs the activity about updates of the upgrade process.
     * Depending on the type of update information, this method acts as follows:
     * <ul>
     *     <li>{@link BluetoothService.UpgradeMessage#UPGRADE_STEP_HAS_CHANGED
     *     UPGRADE_STEP_HAS_CHANGED}: updates the step information of the VM Upgrade Dialog through the
     *     method .</li>
     *     <li>{@link BluetoothService.UpgradeMessage#UPGRADE_UPLOAD_PROGRESS
     *     UPGRADE_UPLOAD_PROGRESS}: updates the progress bar information through the method
     *     </li>
     *     <li>{@link BluetoothService.UpgradeMessage#UPGRADE_REQUEST_CONFIRMATION
     *     UPGRADE_REQUEST_CONFIRMATION}: displays a dialog to the user to ask their confirmation to continue the
     *     process.</li>
     *     <li>{@link BluetoothService.UpgradeMessage#UPGRADE_FINISHED
     *     UPGRADE_FINISHED}: informs the user that the upgrade had successfully finished.</li>
     *     <li>{@link BluetoothService.UpgradeMessage#UPGRADE_ERROR UPGRADE_ERROR}:
     *     this method will handle the error through the method {@link #manageError(UpgradeError) manageError}
     *     which will let the user knows.</li>
     * </ul></p>
     *
     * @param message
     *          The type of Upgrade message the Service wants the activity to have an update about.
     * @param content
     *          The complementary information corresponding to the message.
     */
    private void onReceiveUpgradeMessage(@BluetoothService.UpgradeMessage int message, Object content) {
        StringBuilder handleMessage = new StringBuilder("Handle a message from BLE service: UPGRADE_MESSAGE, ");
        Map<String, String> map = new HashMap<>();

        switch (message) {
            case BluetoothService.UpgradeMessage.UPGRADE_FINISHED:
                String status = "0";
                map.put("status", status );
                Log.i(TAG, " onReceiveUpgradeMessage " +  map.toString() +updateEventSink.toString());
                mStartTime = 0;
                if(updateEventSink != null)
                    updateEventSink.success(map);
                handleMessage.append("UPGRADE_FINISHED");
                break;

            case BluetoothService.UpgradeMessage.UPGRADE_REQUEST_CONFIRMATION:
                @UpgradeManager.ConfirmationType int confirmation = (int) content;
                //askForConfirmation(confirmation);
                if(mService!=null)
                    mService.sendConfirmation(confirmation, true);
                handleMessage.append("UPGRADE_REQUEST_CONFIRMATION");
                break;

            case BluetoothService.UpgradeMessage.UPGRADE_STEP_HAS_CHANGED:
                @ResumePoints.Enum int step = (int) content;
                if (step == ResumePoints.Enum.DATA_TRANSFER
                        && mStartTime == 0 /* step does not change due to a reconnection */) {
                    mStartTime = SystemClock.elapsedRealtime();
                }

                handleMessage.append("UPGRADE_STEP_HAS_CHANGED");
                break;

            case BluetoothService.UpgradeMessage.UPGRADE_ERROR:
                UpgradeError error = (UpgradeError) content;
                mStartTime = 0;
                manageError(error);
                map.put("status", error.getString() );
                Log.i(TAG, " onReceiveUpgradeMessage error " +  map.toString());
                mStartTime = 0;
                if(updateEventSink != null)
                    updateEventSink.success(map);
                handleMessage.append("UPGRADE_ERROR");
                break;

            case BluetoothService.UpgradeMessage.UPGRADE_UPLOAD_PROGRESS:
                double percentage = (double) content;

                handleMessage.append("UPGRADE_UPLOAD_PROGRESS");
                break;
        }

        if (DEBUG && message != BluetoothService.UpgradeMessage.UPGRADE_UPLOAD_PROGRESS) {
            // The upgrade upload messages are not displayed to avoid too many logs.
            Log.d(TAG, handleMessage.toString());
        }
    }

    /**
     * <p>This method is called when this activity receives a
     * {@link GAIAGATTBLEService.GattMessage GattMessage} from the Service.</p>
     * <p>This method will act depending on the type of GATT message which had been broadcast to this activity.</p>
     *
     * @param gattMessage
     *          The GATT Message type.
     * @param data
     *          Any complementary information provided with the GATT Message.
     */
    @SuppressLint("SwitchIntDef")
    private void onReceiveGattMessage(@GAIAGATTBLEService.GattMessage int gattMessage, Object data) {
        switch (gattMessage) {

            case GAIAGATTBLEService.GattMessage.RWCP_SUPPORTED:
                boolean rwcpSupported = (boolean) data;
                /*mOptionsFragment.onRWCPSupported(rwcpSupported);
                if (!rwcpSupported) {
                    Toast.makeText(this, R.string.toast_rwcp_not_supported, Toast.LENGTH_SHORT).show();
                }*/
                break;

            case GAIAGATTBLEService.GattMessage.RWCP_ENABLED:
                /*mIsRWCPEnabled = (boolean) data;
                mOptionsFragment.onRWCPEnabled(mIsRWCPEnabled, mFile != null);
                int textRWCPEnabled = mIsRWCPEnabled ? R.string.toast_rwcp_enabled : R.string.toast_rwcp_disabled;
                Toast.makeText(this, textRWCPEnabled, Toast.LENGTH_SHORT).show();*/
                break;

            case GAIAGATTBLEService.GattMessage.TRANSFER_FAILED:
                // The transport layer has failed to transmit bytes to the device using RWCP
                //mUpgradeDialog.displayError(getString(R.string.dialog_upgrade_transfer_failed));
                break;

            case GAIAGATTBLEService.GattMessage.MTU_SUPPORTED:
                boolean mtuSupported = (boolean) data;
                /*mOptionsFragment.onMtuSupported(mtuSupported, mFile != null);
                if (!mtuSupported) {
                    Toast.makeText(this, R.string.toast_mtu_not_supported, Toast.LENGTH_SHORT).show();
                }*/
                break;

            case GAIAGATTBLEService.GattMessage.MTU_UPDATED:
                int mtu = (int) data;
                /*mOptionsFragment.onMtuUpdated(mtu, mFile != null);
                Toast.makeText(this, getString(R.string.toast_mtu_updated) + " " + mtu, Toast.LENGTH_SHORT).show();*/
                break;
        }
    }

    /**
     * <p>When an error occurs during the upgrade, this method allows display of error information to the user
     * depending on the error type contained on the {@link UpgradeError UpgradeError} parameter.</p>
     *
     * @param error
     *              The information related to the error which occurred during the upgrade process.
     */
    private void manageError(UpgradeError error) {
        switch (error.getError()) {
            case UpgradeError.ErrorTypes.AN_UPGRADE_IS_ALREADY_PROCESSING:
                // nothing should happen as there is already an upgrade processing.
                // in case it's not already displayed, we display the Upgrade dialog
                //showUpgradeDialog(true);
                break;

            case UpgradeError.ErrorTypes.ERROR_BOARD_NOT_READY:
                // display error message + "please try again later"
                //mUpgradeDialog.displayError(getString(R.string.dialog_upgrade_error_board_not_ready));
                break;

            case UpgradeError.ErrorTypes.EXCEPTION:
                // display that an error has occurred?
                //mUpgradeDialog.displayError(getString(R.string.dialog_upgrade_error_exception));
                break;

            case UpgradeError.ErrorTypes.NO_FILE:
                //displayFileError();
                break;

            case UpgradeError.ErrorTypes.RECEIVED_ERROR_FROM_BOARD:
                /*mUpgradeDialog.displayError(ReturnCodes.getReturnCodesMessage(error.getReturnCode()),
                        Utils.getIntToHexadecimal(error.getReturnCode()));*/
                break;

            case UpgradeError.ErrorTypes.WRONG_DATA_PARAMETER:
                //mUpgradeDialog.displayError(getString(R.string.dialog_upgrade_error_protocol_exception));
                break;
        }
    }

    //##################################################################################################//
    /**
     * To manage the GAIA packets which has been received from the device and which will be send to the device.
     */
    private InformationGaiaManager mGaiaManager;

    /**
     * The BLE service to communicate with any device.
     */
    BluetoothService mService;

    /**
     * To know if this activity is in the pause state.
     */
    private boolean mIsPaused;
    /**
     * The handler used by the service to be linked to this activity.
     */
    private ActivityHandler mHandler;
    /**
     * The service connection object to manage the service bind and unbind.
     */
    private final ServiceConnection mServiceConnection = new ActivityServiceConnection(this);
    private @BluetoothService.Transport int mTransport = BluetoothService.Transport.UNKNOWN;

    // ====== SERVICE METHODS =======================================================================

    protected void handleMessageFromService(Message msg) {
        //noinspection UnusedAssignment
        String handleMessage = "Handle a message from BLE service: ";
        if (DEBUG) Log.d(TAG, handleMessage + " : " + msg.what);
        switch (msg.what) {
            case BluetoothService.Messages.CONNECTION_STATE_HAS_CHANGED:
                //getInformationFromDevice();
                @BluetoothService.State int connectionState = (int) msg.obj;
                String stateLabel = connectionState == BluetoothService.State.CONNECTED ? "CONNECTED"
                        : connectionState == BluetoothService.State.CONNECTING ? "CONNECTING"
                        : connectionState == BluetoothService.State.DISCONNECTING ? "DISCONNECTING"
                        : connectionState == BluetoothService.State.DISCONNECTED ? "DISCONNECTED"
                        : "UNKNOWN";
            {
                if(connectionState == BluetoothService.State.DISCONNECTED)
                {
                    //this.mService = null;
                    mMap.put("Model", "none");
                    mMap.put("Address","none");
                    //getInformationFromDevice();
                    if(mainEventSink!=null)
                        mainEventSink.success(mMap);
                }
            }
                if (DEBUG) Log.d(TAG, handleMessage + "CONNECTION_STATE_HAS_CHANGED: " + stateLabel);
                break;

            case BluetoothService.Messages.DEVICE_BOND_STATE_HAS_CHANGED:
                //getInformationFromDevice();
                int bondState = (int) msg.obj;
                String bondStateLabel = bondState == BluetoothDevice.BOND_BONDED ? "BONDED"
                        : bondState == BluetoothDevice.BOND_BONDING ? "BONDING"
                        : "BOND NONE";

                if (DEBUG) Log.d(TAG, handleMessage + "DEVICE_BOND_STATE_HAS_CHANGED: " + bondStateLabel);
                break;

            case BluetoothService.Messages.GATT_SUPPORT:
                if (DEBUG) Log.d(TAG, handleMessage + "GATT_SUPPORT");
                break;

            case BluetoothService.Messages.GAIA_PACKET:
                byte[] data = (byte[]) msg.obj;
                mGaiaManager.onReceiveGAIAPacket(data);
                break;

            case BluetoothService.Messages.GAIA_READY:
                //getInformationFromDevice();
                getStatusFromDevice();
                if (DEBUG) Log.d(TAG, handleMessage + "GAIA_READY");
                break;

            case BluetoothService.Messages.GATT_READY:
                if (DEBUG) Log.d(TAG, handleMessage + "GATT_READY");
                break;
            case BluetoothService.Messages.UPGRADE_MESSAGE:
                @BluetoothService.UpgradeMessage int upgradeMessage = msg.arg1;
                Object content = msg.obj;
                onReceiveUpgradeMessage(upgradeMessage, content);
                break;
            case BluetoothService.Messages.GATT_MESSAGE:
                @GAIAGATTBLEService.GattMessage int gattMessage = msg.arg1;
                Object gattData = msg.obj;
                onReceiveGattMessage(gattMessage, gattData);
                if (DEBUG) Log.d(TAG, handleMessage + "GATT_MESSAGE");
                break;
            default:
                if (DEBUG)
                    Log.d(TAG, handleMessage + "UNKNOWN MESSAGE: " + msg.what);
                break;
        }
    }


    protected void onServiceConnected() {
        @GAIA.Transport int transport = mTransport == BluetoothService.Transport.BR_EDR ?
                GAIA.Transport.BR_EDR : GAIA.Transport.BLE;
        mGaiaManager = new InformationGaiaManager(this, transport);
        Log.d(TAG, "onServiceConnected " + transport);
        //getInformationFromDevice();
    }

    protected void onServiceDisconnected() {
        rmInformationFromDevice();
        mGaiaManager = null;
        Log.d(TAG, "onServiceDisconnected " );
    }

    private boolean startService() {
        // get the bluetooth information
        SharedPreferences sharedPref = getSharedPreferences(Consts.PREFERENCES_FILE, Context.MODE_PRIVATE);

        // get the device Bluetooth address
        String address = sharedPref.getString(Consts.BLUETOOTH_ADDRESS_KEY, "");
        Log.i(TAG,"devices: address "+address);
        if (address.length() == 0 || !BluetoothAdapter.checkBluetoothAddress(address)) {
            // no address, not possible to establish a connection
            return false;
        }

        // get the transport type
        int transport = sharedPref.getInt(Consts.TRANSPORT_KEY, BluetoothService.Transport.UNKNOWN);
        mTransport = transport == BluetoothService.Transport.BLE ? BluetoothService.Transport.BLE :
                transport == BluetoothService.Transport.BR_EDR ? BluetoothService.Transport.BR_EDR :
                        BluetoothService.Transport.UNKNOWN;
        Log.i(TAG,"mTransports: "+mTransport);
        if (mTransport == BluetoothService.Transport.UNKNOWN) {
            // transport unknown, not possible to establish a connection
            return false;
        }

        // get the service class to bind
        Class<?> serviceClass = mTransport == BluetoothService.Transport.BLE ? GAIAGATTBLEService.class :
                GAIABREDRService.class; // mTransport can only be BLE or BR EDR

        // bind the service
        Intent gattServiceIntent = new Intent(this, serviceClass);
        gattServiceIntent.putExtra(Consts.BLUETOOTH_ADDRESS_KEY, address); // give address to the service
        Log.i(TAG,"bindService: "+ GAIABREDRService.class + " -- " + mServiceConnection);
        //startService(gattServiceIntent);
        return bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
    }
    // ====== PRIVATE METHODS ======================================================================

    /**
     * <p>This method allows to init the bound service by defining this activity as a handler listening its messages.</p>
     */
    private void initService() {
        Log.i(TAG,"initService: "+mService);
        if(mService == null)
            return;
        if (mHandler == null)
            mHandler = new ActivityHandler(this);
        mService.addHandler(mHandler);
        Log.i(TAG,"initService getDevice: "+mService.getDevice());
        if (mService.getDevice() == null) {
            // get the bluetooth information
            SharedPreferences sharedPref = getSharedPreferences(Consts.PREFERENCES_FILE, Context.MODE_PRIVATE);

            // get the device Bluetooth address
            String address = sharedPref.getString(Consts.BLUETOOTH_ADDRESS_KEY, "");
            boolean done = mService.connectToDevice(address);
            if (!done) Log.w(TAG, "connection failed");
            Log.w(TAG, "connection OK");
        }
    }

    /**
     * To initialise objects used in this activity.
     */
    private void init() {
        // the Handler to receive messages from the GAIAGATTBLEService once attached
        mHandler = new ActivityHandler(this);
    }

    // ====== INNER CLASS ==========================================================================

    /**
     * <p>This class is used to be informed of the connection state of the BLE service.</p>
     */
    private static class ActivityServiceConnection implements ServiceConnection {

        /**
         * The reference to this activity.
         */
        final WeakReference<MainActivity> mActivity;

        /**
         * The constructor for this activity service connection.
         *
         * @param activity
         *            this activity.
         */
        ActivityServiceConnection(MainActivity activity) {
            super();
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            MainActivity parentActivity = mActivity.get();

            if (componentName.getClassName().equals(GAIAGATTBLEService.class.getName())) {
                parentActivity.mService = ((GAIAGATTBLEService.LocalBinder) service).getService();
            }
            else if (componentName.getClassName().equals(GAIABREDRService.class.getName())) {
                parentActivity.mService = ((GAIABREDRService.LocalBinder) service).getService();
            }

            if (parentActivity.mService != null) {
                parentActivity.initService();
                parentActivity.onServiceConnected(); // to inform subclass
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            if (componentName.getClassName().equals(GAIAGATTBLEService.class.getName())) {
                MainActivity parentActivity = mActivity.get();
                parentActivity.mService = null;
                parentActivity.onServiceDisconnected(); // to inform subclass
            }
        }
    }

    /**
     * <p>This class is for receiving and managing messages from a {@link GAIAGATTBLEService}.</p>
     */
    private static class ActivityHandler extends Handler {

        /**
         * The reference to this activity.
         */
        final WeakReference<MainActivity> mReference;

        /**
         * The constructor for this activity handler.
         *
         * @param activity
         *            this activity.
         */
        ActivityHandler(MainActivity activity) {
            super();
            mReference = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            MainActivity activity = mReference.get();
            if (!activity.mIsPaused) {
                activity.handleMessageFromService(msg);
            }
        }
    }


    @Override
    public boolean sendGAIAPacket(byte[] packet) {
        Log.i(TAG, "sendGAIAPacket");

        return mService!= null && mService.sendGAIAPacket(packet);
    }

    @Override
    public void onGetPreset(int preset) {
        Map<String, Integer> map = new HashMap<>();
        map.put("key", 0 );
        map.put("bank", preset);
        Log.i(TAG, " onGetPreset " +  map.toString());
        if(eqEventSink != null)
            eqEventSink.success(map);
    }

    @Override
    public void onGetControlActivationState(int control, boolean activated) {
        Map<String, Integer> map = new HashMap<>();
        switch(control){
            case InformationGaiaManager.Controls.PRESETS:
                map.put("key", 1 );
                map.put("value", activated?1:0);
                if(eqEventSink != null)
                    eqEventSink.success(map);
                break;
            case InformationGaiaManager.Controls.ENHANCEMENT_3D:
                break;
            case InformationGaiaManager.Controls.BASS_BOOST:
                map.put("key", 2 );
                map.put("value", activated?1:0);
                if(bassEventSink != null)
                    bassEventSink.success(map);
                break;
        }
        //map.put(control, activated );
        Log.i(TAG, " onGetControlActivationState " +  map.toString());

    }

    @Override
    public void onControlNotSupported(int control) {
        Log.i(TAG, " onControlNotSupported " +  control);
    }

    @Override
    public void onGetCustomEqParams(List<Integer> gains, int gainCount) {
        Log.i(TAG, " onGetCustomEqParams " +  gains.toString() + "; count " + gainCount);
        Map<String, Integer> map = new HashMap<>();
        map.put("key", 7 );
        Log.i(TAG, " onGetPreset " +  map.toString());
        String key;
        for (int i = 0; i < gains.size(); i++){
            key = "band" + i;
            map.put(key,gains.get(i));
        }
        if(eqEventSink != null)
            eqEventSink.success(map);
    }

    @Override
    public void onInformationNotSupported(int information) {
        Log.i(TAG, " onInformationNotSupported ");
    }

    @Override
    public void onChargerConnected(boolean isConnected) {
        Map<String, String> map = new HashMap<>();
         if (isConnected) {
            map.put("Status", "Charging" );
        }
        else {
            map.put("Status", "Not charging" );
        }
        Log.i(TAG, " onChargerConnected " + map.toString());
        if(eventSink != null)
            eventSink.success(map);

    }

    @Override
    public void onGetBatteryLevel(int level) {
        Map<String, String> map = new HashMap<>();
        String text = ""+mBatteryLevel;
        map.put("Battery", text );
        Log.i(TAG, " onGetBatteryLevel " +  map.toString());
        if(eventSink != null)
            eventSink.success(map);
    }

    @Override
    public void onGetRSSILevel(int level) {
        Map<String, String> map = new HashMap<>();
        String text = ""+level+" db";
        map.put("Signal", text );
        Log.i(TAG, " onGetRSSILevel " + map.toString());
        if(eventSink != null)
            eventSink.success(map);

    }

    @Override
    public void onGetAPIVersion(int versionPart1, int versionPart2, int versionPart3) {
        String APIText = versionPart1 + "." + versionPart2 + "." + versionPart3;
        Log.i(TAG, " onGetAPIVersion " + APIText);
       // if(eventSink != null)
            //eventSink.success("Firmware : "+APIText);

    }

    @Override
    public void onGetAPPVersion(int versionPart1, int versionPart2, int versionPart3, int versionPart4) {
        String APPText = versionPart1 + "." + versionPart2 ;
        String BoxText = ""+versionPart3 ;
        Map<String, String> map = new HashMap<>();
        map.put("Firmware", APPText );
        if(updateEventSink!= null)
            updateEventSink.success(map);
        map.put("Box battery", BoxText );
        Log.i(TAG, " onGetAPPVersion = " + map.toString());
        if(eventSink != null)
            eventSink.success(map);
    }

    @Override
    public void onBluetoothDisabled() {
        Log.i(TAG, " onBluetoothDisabled ");
    }

    @Override
    public void onBluetoothEnabled() {
        Log.i(TAG, " onBluetoothEnabled ");
    }

    // ====== PRIVATE METHODS ======================================================================

    /**
     * <p>This method requests all device information which is displayed in this activity such as the RSSI or battery
     * levels, the API version, etc.</p>
     */
    private void getInformationFromDevice() {
        //Log.i(TAG, " getInformationFromDevice " + mService + mService.getConnectionState() + mService.isGaiaReady());
        if (mService!= null && mService.getConnectionState() == BluetoothService.State.CONNECTED
                && mService.isGaiaReady()) {
            mGaiaManager.getInformation(InformationGaiaManager.Information.API_VERSION);
            mGaiaManager.getNotifications(InformationGaiaManager.Information.BATTERY, true);
            mGaiaManager.getNotifications(InformationGaiaManager.Information.RSSI, true);
            mGaiaManager.getInformation(InformationGaiaManager.Information.APP_VERSION);
        }
    }

    private void getStatusFromDevice() {
        //Log.i(TAG, " getInformationFromDevice " + mService + mService.getConnectionState() + mService.isGaiaReady());
        if (mService!= null && mService.getConnectionState() == BluetoothService.State.CONNECTED
                && mService.isGaiaReady()) {
            mGaiaManager.getActivationState(InformationGaiaManager.Controls.BASS_BOOST);
            mGaiaManager.getActivationState(InformationGaiaManager.Controls.PRESETS);
            mGaiaManager.getInformation(InformationGaiaManager.Information.API_VERSION);
            mGaiaManager.getNotifications(InformationGaiaManager.Information.BATTERY, false);
            mGaiaManager.getNotifications(InformationGaiaManager.Information.RSSI, false);
            mGaiaManager.getInformation(InformationGaiaManager.Information.APP_VERSION);
            mGaiaManager.getPreset();

        }
    }

    private void rmInformationFromDevice() {
        if (mService!= null && mService.getConnectionState() == BluetoothService.State.CONNECTED
                && mService.isGaiaReady()) {
            mGaiaManager.getNotifications(InformationGaiaManager.Information.BATTERY, false);
            mGaiaManager.getNotifications(InformationGaiaManager.Information.RSSI, false);
         }
    }

    private DownloadManager mDownloadManager;
    private long mTaskId;

    //使用系统下载器下载
    private void downloadFile(String versionUrl, String fileName) {
        //创建下载任务
        DownloadManager.Request request = new DownloadManager.Request(Uri.parse(versionUrl));
        request.setAllowedOverRoaming(false);//漫游网络是否可以下载
        Log.i(TAG, " downloadFile " + versionUrl);


        //设置文件类型，可以在下载结束后自动打开该文件
        MimeTypeMap mimeTypeMap = MimeTypeMap.getSingleton();
        String mimeString = mimeTypeMap.getMimeTypeFromExtension(MimeTypeMap.getFileExtensionFromUrl(versionUrl));
        request.setMimeType(mimeString);

        //在通知栏中显示，默认就是显示的
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE);
        request.setVisibleInDownloadsUi(true);

        //sdcard的目录下的download文件夹，必须设置
        //request.setDestinationInExternalFilesDir(this.getContext(),"",versionUrl.substring(versionUrl.lastIndexOf("/") + 1) );
        String cachePath = Objects.requireNonNull(this.getContext().getExternalFilesDir("Download")).getPath();
        //Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        mFile = new File(cachePath, versionUrl.substring(versionUrl.lastIndexOf("/") + 1));
        if(mFile.exists())
            Log.i(TAG, "delfile" + mFile.delete());
        Log.i(TAG, " mFile " + mFile.toString()+ "uri = "+ Uri.fromFile(mFile));
        //request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, versionUrl.substring(versionUrl.lastIndexOf("/") + 1));
        //request.setDestinationInExternalFilesDir(),也可以自己制定下载路径
        request.setDestinationUri(Uri.fromFile(mFile));
        //将下载请求加入下载队列
        mDownloadManager = (DownloadManager) this.getContext().getSystemService(Context.DOWNLOAD_SERVICE);
        //加入下载队列后会给该任务返回一个long型的id，
        //通过该id可以取消任务，重启任务等等，看上面源码中框起来的方法
        assert mDownloadManager != null;
        mTaskId = mDownloadManager.enqueue(request);

        //注册广播接收者，监听下载状态
        this.getContext().registerReceiver(receiver,
                new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
    }
    //广播接受者，接收下载状态
    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            checkDownloadStatus();//检查下载状态
        }
    };
    //检查下载状态
    private void checkDownloadStatus() {
        DownloadManager.Query query = new DownloadManager.Query();
        query.setFilterById(mTaskId);//筛选下载任务，传入任务ID，可变参数
        Cursor c = mDownloadManager.query(query);
        Log.i(TAG, ">>>" + c.toString());
        if (c.moveToFirst()) {
            int status = c.getInt(c.getColumnIndex(DownloadManager.COLUMN_STATUS));
            switch (status) {
                case DownloadManager.STATUS_PAUSED:
                    Log.i(TAG, ">>>下载暂停");
                case DownloadManager.STATUS_PENDING:
                    Log.i(TAG, ">>>下载延迟");
                case DownloadManager.STATUS_RUNNING:
                    Log.i(TAG, ">>>正在下载");
                    break;
                case DownloadManager.STATUS_SUCCESSFUL:
                    Log.i(TAG, ">>>下载完成");
                    //下载完成安装APK
                    //downloadPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + File.separator + versionName;
                    //installAPK(new File(downloadPath));
                    mService.enableUpgrade(true);
                    startUpgrade(mFile);
                    break;
                case DownloadManager.STATUS_FAILED:
                    int reason = c.getInt(c.getColumnIndex(DownloadManager.COLUMN_REASON));
                    Log.i(TAG, ">>>下载失败 = " + reason);
                    break;
            }
        }
    }

}

