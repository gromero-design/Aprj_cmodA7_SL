package fpgahelp.com;

import android.bluetooth.BluetoothSocket;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class ThirdFragment extends Fragment {
    private final String TAG = "StateChangeFrag3";

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        Log.d(TAG,"onCreateView Frag3");
        GlobalVars.mFragNumber = 3;
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_third, container, false);
    }

    public void onViewCreated(@NonNull final View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        final Button mECHO_ON_BTN = (Button) view.findViewById(R.id.echon_btn);
        final Button mECHO_OFF_BTN = (Button) view.findViewById(R.id.echoff_btn);
        final Button mSEND_BTN = (Button) view.findViewById(R.id.send_btn);
        final Button mCLEAR_BTN = (Button) view.findViewById(R.id.clear_btn);
        final Button mPixel_BTN = (Button) view.findViewById(R.id.pixels_button);
        final Button mPREVIOUS_BTN = (Button) view.findViewById(R.id.previous_btn);
//        final Button mReset_BTN = (Button) view.findViewById(R.id.default_button);
        final Button mReadClock_BTN = (Button) view.findViewById(R.id.read_clock_btn);
        final Button mSyncClock_BTN = (Button) view.findViewById(R.id.sync_clock_btn);

        final EditText editText = (EditText) view.findViewById(R.id.cmd_editText);
        final TextView mReadBuffer = (TextView) view.findViewById(R.id.readBuffer);
        mReadBuffer.setMovementMethod(new ScrollingMovementMethod());
        final TextView mMsgBuffer = (TextView) view.findViewById(R.id.msg_textView);
        final EditText PixText = (EditText) view.findViewById(R.id.Pix_editText);

        final BTService.ConnectedThread mConnectedThread = GlobalVars.gCThread;
        final BluetoothSocket mBTSocket = GlobalVars.gBTSocket;
        final SimpleDateFormat sdf = new SimpleDateFormat("yyyy:MM:dd:kk:mm:ss"); //"E, dd/MMM/yyyy kk:mm:ss z"

        Log.d(TAG,"onViewCreated Frag3 "+mConnectedThread);
        Log.d(TAG,"onViewCreated Frag3 "+mBTSocket);

        // SEND button : send command to HW
        mSEND_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mSEND_BTN.isPressed()){
                        Log.d(TAG,"setOnClickListener_SEND mHandler = ");
                        mMsgBuffer.setText("");
                        mReadBuffer.setText("");
                        String mCmdBuffer = editText.getText().toString();
                        mConnectedThread.write(mCmdBuffer+"\n");
                        editText.getText().clear();
                        SystemClock.sleep(100);
                        mReadBuffer.setText(GlobalVars.mBufferMsg);
                        Log.d(TAG,"SEND "+mCmdBuffer);
                }
            }
        });

        // CLEAR button : clear command and message fields
        mCLEAR_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if (mCLEAR_BTN.isPressed()){
                    Log.d(TAG,"setOnClickListener_CLEAR ");
                    editText.getText().clear();
                    mMsgBuffer.setText("");
                    mReadBuffer.setText("");
                }
            }
        });


        // ECHO_ON button : enable echo from HW
        mECHO_ON_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mECHO_ON_BTN.isPressed()){
                        Log.d(TAG,"setOnClickListener_ECHO_ON "+mConnectedThread);
                        mMsgBuffer.setText("");
                        mMsgBuffer.setText("Echo ON");
                        mConnectedThread.write("x");    // return to main menu in HW
                        mConnectedThread.write("E"); // decimal 5, Echo ON CTRL-E
                        mConnectedThread.write("a\n");    // go to application menu in HW
                    }
            }
        });

        // ECHO_OFF button : disable echo from HW
        mECHO_OFF_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mECHO_OFF_BTN.isPressed()){
                        Log.d(TAG,"setOnClickListener_ECHO_OFF "+mConnectedThread);
                        mMsgBuffer.setText("");
                        mMsgBuffer.setText("Echo OFF");
                        mConnectedThread.write("x");    // return to main menu in HW
                        mConnectedThread.write("e"); // decimal 26, Echo OFF CTRL-Z
                        mConnectedThread.write("a\n");    // go to application menu in HW
                        mConnectedThread.write("v"); // version
                        mConnectedThread.write("k");   // real clock
                    }
            }
        });


        // PIXELS button : set pixel number
        mPixel_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int pix_value = 1;
                String pix_string = PixText.getText().toString();
                if (!"".equals(pix_string)) {
                    pix_value = Integer.parseInt(pix_string);
                }
                GlobalVars.mLEDS = pix_value;
                if(mConnectedThread != null){
                    if(mPixel_BTN.isPressed()){
                        String pix = Integer.toHexString(pix_value);
                        mConnectedThread.write("n" + pix + "\n"); // real channel
                    }
                }
            }
        });

        // CLOCK button : read real time clock from HW
        mReadClock_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mConnectedThread != null){
                    if(mReadClock_BTN.isPressed()){
                        mMsgBuffer.setText("");
                        mMsgBuffer.setText(GlobalVars.mDeviceName+ " : Version + Clock (Y M dD h m s)");
                        mConnectedThread.write("v"); // version
                        mConnectedThread.write("k");   // real clock
//                        SystemClock.sleep(100);
                        mReadBuffer.setText(GlobalVars.mBufferMsg);
//                        Log.d(TAG,"Read Buffer = "+GlobalVars.mBufferMsg);
                    }
                }
            }
        });

        // SYNC button : synchronize Android clock with HW
        mSyncClock_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // set date/time
                mMsgBuffer.setText("");
                mMsgBuffer.setText(GlobalVars.mDeviceName+ " : Sync Clock");
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
                mConnectedThread.write("k"); // real clock
//                SystemClock.sleep(100);
                mReadBuffer.setText(GlobalVars.mBufferMsg);
            }
        });

        // EXIT button : return to previous menu
        mPREVIOUS_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.d(TAG, "setOnClickListener_PREVIOUS = " + mConnectedThread);
                if (mConnectedThread != null) { //First check to make sure thread created
                    GlobalVars.mRefresh = 1;
                    Log.d(TAG, "setOnClickListener_PREVIOUS");
                    NavHostFragment.findNavController(ThirdFragment.this)
                            .navigate(R.id.action_ThirdFragment_to_SecondFragment);
                } else {
                    NavHostFragment.findNavController(ThirdFragment.this)
                            .navigate(R.id.action_ThirdFragment_to_SecondFragment);
                }
            }
        });

        // DEFAULT button : set default values in HW
 /*       mReset_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mReset_BTN.isPressed()){
//                        Log.d(TAG,"setOnClickListener_ECHO_OFF "+mConnectedThread);
                        mMsgBuffer.setText("Set To Default Values and read HW clock");
                        mConnectedThread.write("0\n"); // Clear Colors
                        mConnectedThread.write("9\n"); // Clear counters
                        mConnectedThread.write("m0\n"); // Theme mode stretch
                        mConnectedThread.write("r0\n"); // Pattern mode WalkUp
                        mConnectedThread.write("i3\n"); // Intensity MIN
                        mConnectedThread.write("a1\n"); // Active pixels
                    }
            }
        });
*/
    }
}
