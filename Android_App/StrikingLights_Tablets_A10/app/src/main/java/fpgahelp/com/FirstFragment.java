package fpgahelp.com;

import android.app.Notification;
import android.content.IntentFilter;
import android.graphics.LightingColorFilter;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;

import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

public class FirstFragment extends Fragment {
    private static final String TAG = "StateChangeFrag1";
    private final String version_number = "SW Version V10 (04/15/2020 = 08:55)";
    private static final int RESULT_OK = 1; //? I added here, original is not defined where is coming from?

    // GUI Components
    private TextView mBluetoothStatus;
    private BluetoothAdapter mBTAdapter;
    private ArrayAdapter<String> mBTArrayAdapter;

    private final Handler mHandler = new Handler(); // Our main handler that will receive callback notifications
    private BTService.ConnectedThread mConnectedThread; // bluetooth background worker thread to send and receive data
    private BluetoothSocket mBTSocket; // bi-directional client-to-client data path

    private static final UUID BTMODULEUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"); // "random" unique identifier


    // #defines for identifying shared types between calling functions
    private final static int REQUEST_ENABLE_BT = 1; // used to identify adding bluetooth names
    private final static int MESSAGE_READ = 2; // used in bluetooth handler to identify message update
    private final static int CONNECTING_STATUS = 3; // used in bluetooth handler to identify message status

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        Log.d(TAG, "Handler Frag1: onCreateView "+mHandler);
        GlobalVars.mFragNumber = 1;
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_first, container, false);
    }

     @SuppressLint({"WrongViewCast", "HandlerLeak"})
    @Override
    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mBluetoothStatus = view.findViewById(R.id.bluetoothStatus);
        Button mScanBtn = (Button) view.findViewById(R.id.scan);
        Button mOffBtn = (Button) view.findViewById(R.id.off);
        Button mDiscoverBtn = (Button) view.findViewById(R.id.discover);
        Button mListPairedDevicesBtn = (Button) view.findViewById(R.id.PairedBtn);
        final Button mRUN_BTN = (Button) view.findViewById(R.id.run_btn);
        mRUN_BTN.setVisibility(View.INVISIBLE);
        final EditText editText = (EditText) view.findViewById(R.id.cmd_editText);

        mBTAdapter = BluetoothAdapter.getDefaultAdapter(); // get a handle on the bluetooth radio
        ListView mDevicesListView = (ListView) view.findViewById(R.id.devicesListView);
        mBTArrayAdapter = new ArrayAdapter<String>(view.getContext(),android.R.layout.simple_list_item_1);
        mDevicesListView.setAdapter(mBTArrayAdapter); // assign model to view
        mDevicesListView.setOnItemClickListener(mDeviceClickListener);

         final SimpleDateFormat sdf = new SimpleDateFormat("yyyy:MM:dd:kk:mm:ss"); //"E, dd/MMM/yyyy kk:mm:ss z"

        Log.d(TAG, "Handler Frag1: onViewCreate "+mHandler);

        if(mConnectedThread == null) // and GlobalVars.mConnected == 1
            mConnectedThread = GlobalVars.gCThread;
        if(mBTSocket == null)
            mBTSocket = GlobalVars.gBTSocket;
//         if (GlobalVars.mBufferMsg != null)
//             mBluetoothStatus.setText(GlobalVars.mBufferMsg);
         if(GlobalVars.mRunEnabled==1 && GlobalVars.mConnected==1)
             mRUN_BTN.setVisibility(View.VISIBLE);
         else
             mRUN_BTN.setVisibility(View.INVISIBLE);



         if (mBTArrayAdapter == null) {
            // Device does not support Bluetooth
            Log.d(TAG,"mBTArrayAdapter=null ");
            mBluetoothStatus.setText("Status: Bluetooth not found");
            Toast.makeText(getContext(),"Bluetooth device not found!",Toast.LENGTH_SHORT).show();
        }
        else {
            Log.d(TAG,"mBTArrayAdapter= not null ");
            // RUN button : go to next menu, synchronize Android clock with HW
            mRUN_BTN.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                if (GlobalVars.mConnected == 1) { //First check to make sure thread created
                    Log.d(TAG, "setOnClickListener_RUN ");
                    if (mRUN_BTN.isPressed()) {
                        // set date/time
                        Calendar calendar = Calendar.getInstance();
                        int day = calendar.get(Calendar.DAY_OF_WEEK);
                        int daynum = 0;
                        switch (day) {
                            case Calendar.MONDAY:
                               daynum = 0;
                                break;
                            case Calendar.TUESDAY:
                                daynum = 1;
                                break;
                            case Calendar.WEDNESDAY:
                                daynum = 2;
                                break;
                            case Calendar.THURSDAY:
                                daynum = 3;
                                break;
                            case Calendar.FRIDAY:
                                daynum = 4;
                                break;
                            case Calendar.SATURDAY:
                                daynum = 5;
                                break;
                            case Calendar.SUNDAY:
                                daynum = 6;
                                break;
                        }
                        Date date = new Date();
                        String dateString = sdf.format(date); //Formatting the date to the specified format
                        String[]  dateArray = dateString.split(":");
                        mConnectedThread.write("x");    // return to main menu in HW
                        mConnectedThread.write("s");    // go to system menu in HW
                        mConnectedThread.write("Y");    // return to main menu in HW
                        int year = Integer.parseInt(dateArray[0]);
                        mConnectedThread.write(Integer.toHexString(year)+"\n");    // return to main menu in HW
                        mConnectedThread.write("M");    // return to main menu in HW
                        int month = Integer.parseInt(dateArray[1]);
                        mConnectedThread.write(Integer.toHexString(month)+"\n");    // return to main menu in HW
                        mConnectedThread.write("D");    // return to main menu in HW
                        int daydate = Integer.parseInt(dateArray[2]);
                        daydate = daynum<<8 | daydate;
                        mConnectedThread.write(Integer.toHexString(daydate)+"\n");    // return to main menu in HW
                        mConnectedThread.write("H");    // return to main menu in HW
                        int hour = Integer.parseInt(dateArray[3]);
                        mConnectedThread.write(Integer.toHexString(hour)+"\n");    // return to main menu in HW
                        mConnectedThread.write("U");    // return to main menu in HW
                        int min = Integer.parseInt(dateArray[4]);
                        mConnectedThread.write(Integer.toHexString(min)+"\n");    // return to main menu in HW
                        mConnectedThread.write("S");    // return to main menu in HW
                        int sec = Integer.parseInt(dateArray[5]);
                        mConnectedThread.write(Integer.toHexString(sec)+"\n");    // return to main menu in HW
                        // end set date/time
                        mConnectedThread.write("x");    // return to main menu in HW
                        mConnectedThread.write("a");    // go to application menu in HW
                        NavHostFragment.findNavController(FirstFragment.this)
                                .navigate(R.id.action_FirstFragment_to_SecondFragment);
                    }
                }
                }
            });

            // Bluetooth Functions
            mScanBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG,"setOnClickListener_BTON ");
                    bluetoothOn(v);
                }
            });

            mOffBtn.setOnClickListener(new View.OnClickListener(){
                @Override
                public void onClick(View v){
                    Log.d(TAG,"setOnClickListener_BTOFF ");
                    bluetoothOff(v);
                }
            });

            mListPairedDevicesBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v){
                    Log.d(TAG,"setOnClickListener_PAIRED ");
                    listPairedDevices(v);
                }
            });

            mDiscoverBtn.setOnClickListener(new View.OnClickListener(){
                @RequiresApi(api = Build.VERSION_CODES.KITKAT)
                @Override
                public void onClick(View v){
                    Log.d(TAG,"setOnClickListener_DISCOVER ");
                    discover(v);
                }
            });
        }
    }

    private void bluetoothOn(View view){
        if (!mBTAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            mBluetoothStatus.setText("Bluetooth enabled");
            Toast.makeText(getContext(),"Bluetooth turned on",Toast.LENGTH_SHORT).show();
        }
        else{
            Toast.makeText(getContext(),"Bluetooth is already on", Toast.LENGTH_SHORT).show();
        }
    }

    // Enter here after user selects "yes" or "no" to enabling radio
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent Data) {
        // Check which request we're responding to
        super.onActivityResult(requestCode, resultCode, Data);
        if (requestCode == REQUEST_ENABLE_BT) {
            // Make sure the request was successful
            if (resultCode == RESULT_OK) {
                // The user picked a contact.
                // The Intent's data Uri identifies which contact was selected.
                mBluetoothStatus.setText("Enabled");
            } else
                mBluetoothStatus.setText("Disabled");
        }
    }

    private void bluetoothOff(View view){
        mBTAdapter.disable(); // turn off
        mBluetoothStatus.setText("Bluetooth disabled");
        Button mRUN_BTN = (Button) getView().findViewById(R.id.run_btn);
        mRUN_BTN.setVisibility(View.INVISIBLE);
        GlobalVars.mRunEnabled = 0;
        GlobalVars.mConnected  = 0;
        Toast.makeText(getContext(),"Bluetooth turned Off", Toast.LENGTH_SHORT).show();
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void discover(View view){
        // Check if the device is already discovering
        if(mBTAdapter.isDiscovering()){
            mBTAdapter.cancelDiscovery();
            Toast.makeText(getContext(),"Discovery stopped",Toast.LENGTH_SHORT).show();
        }
        else{
            if(mBTAdapter.isEnabled()) {
                mBTArrayAdapter.clear(); // clear items
                mBTAdapter.startDiscovery();
                Toast.makeText(getContext(), "Discovery started", Toast.LENGTH_SHORT).show();
                IntentFilter filter = new IntentFilter();
                filter.addAction(BluetoothDevice.ACTION_FOUND);
                getActivity().registerReceiver(blReceiver, filter);
                Log.d(TAG,"Discovery in action ");
            }
            else{
                Toast.makeText(getContext(), "Bluetooth not on", Toast.LENGTH_SHORT).show();
            }
        }
    }

    final BroadcastReceiver blReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.d(TAG,"blReceiver in action ");
            if(BluetoothDevice.ACTION_FOUND.equals(action)){
                Log.d(TAG,"Discovery: action found ");
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                // add the name to the list
                mBTArrayAdapter.add(device.getName() + "\n" + device.getAddress());
                mBTArrayAdapter.notifyDataSetChanged();
            }
        }
    };

    private void listPairedDevices(View view){
        Set<BluetoothDevice> mPairedDevices = mBTAdapter.getBondedDevices();
        if(mBTAdapter.isEnabled()) {
            // put it's one to the adapter
            for (BluetoothDevice device : mPairedDevices)
                mBTArrayAdapter.add(device.getName() + "\n" + device.getAddress());
//            Toast.makeText(getContext(), "Show Paired Devices", Toast.LENGTH_SHORT).show();
        }
        else {
            Toast.makeText(getContext(), "Bluetooth not on", Toast.LENGTH_SHORT).show();
        }
    }

    private AdapterView.OnItemClickListener mDeviceClickListener = new AdapterView.OnItemClickListener() {
        public void onItemClick(AdapterView<?> av, View v, int arg2, long arg3) {
            Log.d(TAG, "Handler Frag1: AdapterView "+mHandler);
            @SuppressLint("HandlerLeak")
            final Handler mHandler = new Handler() {
                public void handleMessage(android.os.Message msg) {
                    if (msg.what == MESSAGE_READ) {
                        Log.d(TAG, "Handler Frag1: Message Received");
                        String readMessage = null;
                        try {
                            readMessage = new String((byte[]) msg.obj, "UTF-8");
                        } catch (UnsupportedEncodingException e) {
                            e.printStackTrace();
                        }
                        GlobalVars.mBufferLength = msg.arg1;
                        GlobalVars.mBufferMsg = readMessage.substring(0,GlobalVars.mBufferLength);
                        Log.d(TAG, "msg.obj (String): "+GlobalVars.mBufferLength+" "+GlobalVars.mBufferMsg);
                    }
                    if (msg.what == CONNECTING_STATUS) {
                        Log.d(TAG, "Handler Frag1: Connecting Status");
                        if (msg.arg1 == 1) {
                            Log.d(TAG, "Handler Frag1: Connecting Status to Device: " + msg.obj);
                            mBluetoothStatus.setText("Connected to : " + (String) (msg.obj));
                            Button mRun_BTN = (Button) getView().findViewById(R.id.run_btn);
                            mRun_BTN.setVisibility(View.VISIBLE);
                            GlobalVars.mBufferMsg = (String) msg.obj;
                        }
                        else {
                            GlobalVars.mBufferMsg = (String) msg.obj;
                            mBluetoothStatus.setText("Connection Failed");
                        }
                    }
                }
            };

            if(!mBTAdapter.isEnabled()) {
                Toast.makeText(getContext(), "Bluetooth not on", Toast.LENGTH_SHORT).show();
                return;
            }

            Log.d(TAG,"BTonItemClick connecting...");
            // Get the device MAC address, which is the last 17 chars in the View
            String info = ((TextView) v).getText().toString();
            final String address = info.substring(info.length() - 17);
            final String name = info.substring(0,info.length() - 17);
            if(GlobalVars.mConnected == 1 && GlobalVars.mRunEnabled == 1){
                Toast.makeText(getContext(), " Already connected to "+name, Toast.LENGTH_SHORT).show();
                GlobalVars.mRunEnabled = 0;
                GlobalVars.mConnected  = 0;
                Button mRUN_BTN = (Button) getView().findViewById(R.id.run_btn);
                mRUN_BTN.setVisibility(View.INVISIBLE);
                mBluetoothStatus.setText("Disconnected from : " + name);
                mConnectedThread.destroySocket();
            }
            else{
                // Spawn a new thread to avoid blocking the GUI one
                new Thread()
                {
                    public void run() {
                        boolean fail = false;
                        BluetoothDevice device = mBTAdapter.getRemoteDevice(address);
                        try {
                            mBTSocket = createBluetoothSocket(device);
                        } catch (IOException e) {
                            fail = true;
                            Toast.makeText(getContext(), "Socket creation failed", Toast.LENGTH_SHORT).show();
                        }
                        // Establish the Bluetooth socket connection.
                        try {
                            mBTSocket.connect();
                        } catch (IOException e) {
                            try {
                                fail = true;
                                mBTSocket.close();
                                mHandler.obtainMessage(CONNECTING_STATUS, -1, -1)
                                        .sendToTarget();
                            } catch (IOException e2) {
                                //insert code to deal with this
                                Toast.makeText(getContext(), "Socket creation failed", Toast.LENGTH_SHORT).show();
                            }
                        }
                        if(!fail) {
                            mConnectedThread = new BTService.ConnectedThread(mBTSocket, mHandler);
                            mConnectedThread.start();
                            GlobalVars.gBTSocket = mBTSocket; // Save state in GlobalVars
                            GlobalVars.gCThread = mConnectedThread; // Save state in GlobalVars
                            GlobalVars.mConnected  = 1;
                            GlobalVars.mRunEnabled = 1;
                            Log.d(TAG,"BTonItemClick connecting... "+mBTSocket);
                            Log.d(TAG,"BTonItemClick connecting... "+mHandler);
                            Log.d(TAG,"BTonItemClick connecting... "+mConnectedThread);
                            mHandler.obtainMessage(CONNECTING_STATUS, 1, -1, name).sendToTarget();
                        }
                    }
                }.start();
            }
        }

    };

     private BluetoothSocket createBluetoothSocket(BluetoothDevice device) throws IOException {
        Log.d(TAG,"createBluetoothSocket");
        return  device.createRfcommSocketToServiceRecord(BTMODULEUUID);
    }



}
