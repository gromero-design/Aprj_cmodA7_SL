package fpgahelp.com;

import android.bluetooth.BluetoothSocket;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

public class SecondFragment extends Fragment {
    private final String TAG = "StateChangeFrag2";

    public String[] pattern = { "Custom       ",
                                "Blinking",
                                "Walking",
                                "Dimmer"};

    public String[] pattern_mode = {"Walk Up ",
                                    "Walk Dn",
                                    "Walk U/D",
                                    "Blink"};

    public String[] themes  = { "Custom",
                                "Xmas","Xmas2",
                                "Colorful1","Colorful2","Colorful3",
                                "Halloween","Liverpool","NYCityFC","SaintPatrick",
                                "USA Flag", "IRE Flag","ARG Flag","ENG Flag","ITA Flag"};

    public String[] themes_mode  = {"Stretch ",
                                    "Repeat"};

    public String[] solidColor  = {"BLK ","RED","GRN","YEL","BLU","MAG","CYA","WHT"};
    public String[] intensity   = {"Min","1","2","3","4","5","6","Max"};
    public String[] fileId      = {"0","1","2","3","4","5","6","7","8","9"};

    // #defines for identifying shared types between calling functions
    private final static int REQUEST_ENABLE_BT = 1; // used to identify adding bluetooth names
    private final static int MESSAGE_READ = 2; // used in bluetooth handler to identify message update
    private final static int CONNECTING_STATUS = 3; // used in bluetooth handler to identify message status

    private final Handler mHandler = new Handler(); // Our main handler that will receive callback notifications

    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        Log.d(TAG,"onCreateView Frag2");
        GlobalVars.mFragNumber = 2;
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_second, container, false);
    }

    public void onViewCreated(@NonNull final View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        int temp;
        final BTService.ConnectedThread mConnectedThread = GlobalVars.gCThread;

        final CheckBox mChannel1_BOX = view.findViewById(R.id.c1checkBox);
        final CheckBox mChannel2_BOX = view.findViewById(R.id.c2checkBox);
        final CheckBox mChannel3_BOX = view.findViewById(R.id.c3checkBox);
        final CheckBox mChannel4_BOX = view.findViewById(R.id.c4checkBox);
        final CheckBox mChannel5_BOX = view.findViewById(R.id.c5checkBox);
        final CheckBox mChannel6_BOX = view.findViewById(R.id.c6checkBox);
        final CheckBox mChannel7_BOX = view.findViewById(R.id.c7checkBox);
        final CheckBox mChannel8_BOX = view.findViewById(R.id.c8checkBox);
        final CheckBox mChannel9_BOX = view.findViewById(R.id.c9checkBox);
        final CheckBox mChannel10_BOX = view.findViewById(R.id.c10checkBox);
        final CheckBox mChannel11_BOX = view.findViewById(R.id.c11checkBox);
        final CheckBox mChannel12_BOX = view.findViewById(R.id.c12checkBox);
        final CheckBox mChannel13_BOX = view.findViewById(R.id.c13checkBox);
        final CheckBox mChannel14_BOX = view.findViewById(R.id.c14checkBox);
        final CheckBox mChannel15_BOX = view.findViewById(R.id.c15checkBox);
        final CheckBox mChannel16_BOX = view.findViewById(R.id.c16checkBox);
        final CheckBox mRed_BOX = view.findViewById(R.id.red_checkBox);
        final CheckBox mGrn_BOX = view.findViewById(R.id.grn_checkBox);
        final CheckBox mBlu_BOX = view.findViewById(R.id.blu_checkBox);

        final Button mEXIT_BTN = (Button) view.findViewById(R.id.exit_btn);
        final Button mClearCh_BTN = (Button) view.findViewById(R.id.clearCh_btn);
        final Button mSetCh_BTN = (Button) view.findViewById(R.id.setCh_button);
        final Button mClearColors_BTN = (Button) view.findViewById(R.id.clearColors_button);
        final Button mSetColors_BTN = (Button) view.findViewById(R.id.setColors_button);
        final Button mSetPattern_BTN = (Button) view.findViewById(R.id.setPattern_button);
        final Button mSetTheme_BTN = (Button) view.findViewById(R.id.setTheme_button);
        final Button mSetSolid_BTN = (Button) view.findViewById(R.id.setsolidColor_button);
        final Button mSave_BTN = (Button) view.findViewById(R.id.save_button);
        final Button mRestore_BTN = (Button) view.findViewById(R.id.restore_button);
        final Button mSetup_BTN = (Button) view.findViewById(R.id.setup_button);

        final RadioButton mFg_Button = view.findViewById(R.id.fg_radioButton);
        final RadioButton mBg_Button = view.findViewById(R.id.bg_radioButton);

        final SeekBar mRed_BAR = view.findViewById(R.id.red_seekBar);
        final SeekBar mGrn_BAR = view.findViewById(R.id.grn_seekBar);
        final SeekBar mBlu_BAR = view.findViewById(R.id.blu_seekBar);
        final SeekBar mPixel_BAR = view.findViewById(R.id.pixel_seekBar);
        final SeekBar mTimer_BAR = view.findViewById(R.id.timer_seekBar);


        final TextView redHex = (TextView) view.findViewById(R.id.redhex_textView);
        final TextView grnHex = (TextView) view.findViewById(R.id.grnhex_textView);
        final TextView bluHex = (TextView) view.findViewById(R.id.bluhex_textView);
//        final EditText VcText = (EditText) view.findViewById(R.id.Vc_editText);

        Spinner mSolidColor_SPIN = (Spinner) view.findViewById(R.id.solidColor_spinner);
        ArrayAdapter<String> mSolidColor_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,solidColor);
        mSolidColor_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mSolidColor_SPIN.setAdapter(mSolidColor_Adapter);

        final Spinner mIntensity_SPIN = (Spinner) view.findViewById(R.id.intensity_spinner);
        ArrayAdapter<String> mIntensity_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,intensity);
        mIntensity_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mIntensity_SPIN.setAdapter(mIntensity_Adapter);

        Spinner mPattern_SPIN = (Spinner) view.findViewById(R.id.pattern_spinner);
        ArrayAdapter<String> mPattern_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,pattern);
        mPattern_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mPattern_SPIN.setAdapter(mPattern_Adapter);

        final Spinner mPattern_mode_SPIN = (Spinner) view.findViewById(R.id.pattern_mode_spinner);
        ArrayAdapter<String> mPattern_mode_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,pattern_mode);
        mPattern_mode_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mPattern_mode_SPIN.setAdapter(mPattern_mode_Adapter);

        Spinner mThemes_SPIN = (Spinner) view.findViewById(R.id.themes_spinner);
        ArrayAdapter<String> mThemes_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,themes);
        mThemes_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mThemes_SPIN.setAdapter(mThemes_Adapter);

        Spinner mThemes_mode_SPIN = (Spinner) view.findViewById(R.id.themes_mode_spinner);
        ArrayAdapter<String> mThemes_mode_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,themes_mode);
        mThemes_mode_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mThemes_mode_SPIN.setAdapter(mThemes_mode_Adapter);

        Spinner mFileId_SPIN = (Spinner) view.findViewById(R.id.id_spinner);
        ArrayAdapter<String> mFileId_Adapter = new ArrayAdapter<String>(getContext(),android.R.layout.simple_spinner_item,fileId);
        mFileId_Adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mFileId_SPIN.setAdapter(mFileId_Adapter);

        //-------------------------------------------------------------------------------------
        // Initialize:
        // This should be done with a proper SaveState function, I don't know how to do it
        // here global initializations

        temp = GlobalVars.mChannelHex & 0x0001;
        if (temp == 0x0001) {
            mChannel1_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0002;
        if (temp == 0x0002) {
            mChannel2_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0004;
        if (temp == 0x0004) {
            mChannel3_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0008;
        if (temp == 0x0008) {
            mChannel4_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0010;
        if (temp == 0x0010) {
            mChannel5_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0020;
        if (temp == 0x0020) {
            mChannel6_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0040;
        if (temp == 0x0040) {
            mChannel7_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0080;
        if (temp == 0x0080) {
            mChannel8_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0100;
        if (temp == 0x0100) {
            mChannel9_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0200;
        if (temp == 0x0200) {
            mChannel10_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0400;
        if (temp == 0x0400) {
            mChannel11_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x0800;
        if (temp == 0x0800) {
            mChannel12_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x1000;
        if (temp == 0x1000) {
            mChannel13_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x2000;
        if (temp == 0x2000) {
            mChannel14_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x4000;
        if (temp == 0x4000) {
            mChannel15_BOX.setChecked(true);
        }
        temp = GlobalVars.mChannelHex & 0x8000;
        if (temp == 0x8000) {
            mChannel16_BOX.setChecked(true);
        }
        mSolidColor_SPIN.setSelection(GlobalVars.mSolidColorPosition);
        mIntensity_SPIN.setSelection(GlobalVars.mIntensityPosition);
        mPattern_SPIN.setSelection(GlobalVars.mPatternPosition);
        mPattern_mode_SPIN.setSelection(GlobalVars.mPatternModePosition);
        mThemes_SPIN.setSelection(GlobalVars.mThemePosition);
        mThemes_mode_SPIN.setSelection(GlobalVars.mThemeModePosition);
        mPixel_BAR.setProgress(GlobalVars.mPixels);
        mTimer_BAR.setProgress(GlobalVars.mTimer);
        if (GlobalVars.mBackground == 0) {
            mFg_Button.setChecked(true);
        }
        else {
            mBg_Button.setChecked(true);
        }
        // End of global initialization
        //-----------------------------------------------------------------------------------
        Log.d(TAG,"onViewCreated Frag2 "+mHandler);

        // Set channel number active
        mChannel1_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0001,mChannel1_BOX);
            }
        });

        mChannel2_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0002,mChannel2_BOX);
            }
        });

        mChannel3_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0004,mChannel3_BOX);
            }
        });

        mChannel4_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0008,mChannel4_BOX);
            }
        });

        mChannel5_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0010,mChannel5_BOX);
            }
        });

        mChannel6_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0020,mChannel6_BOX);
            }
        });

        mChannel7_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0040,mChannel7_BOX);
            }
        });

        mChannel8_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0080,mChannel8_BOX);
            }
        });

        mChannel9_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0100,mChannel9_BOX);
            }
        });

        mChannel10_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0200,mChannel10_BOX);
            }
        });

        mChannel11_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0400,mChannel11_BOX);
            }
        });

        mChannel12_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x0800,mChannel12_BOX);
            }
        });

        mChannel13_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x1000,mChannel3_BOX);
            }
        });

        mChannel14_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x2000,mChannel14_BOX);
            }
        });

        mChannel15_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x4000,mChannel15_BOX);
            }
        });

        mChannel16_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                setChannel(0x8000,mChannel16_BOX);
            }
        });

        // SET CHAN button : Set all channels active
        mSetCh_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mSetCh_BTN.isPressed()){
                        GlobalVars.mChannelHex = GlobalVars.CHANNELS_MSK;
                            mChannel1_BOX.setChecked(true);
                            mChannel2_BOX.setChecked(true);
                            mChannel3_BOX.setChecked(true);
                            mChannel4_BOX.setChecked(true);
                            mChannel5_BOX.setChecked(true);
                            mChannel6_BOX.setChecked(true);
                            mChannel7_BOX.setChecked(true);
                            mChannel8_BOX.setChecked(true);
                            mChannel9_BOX.setChecked(true);
                            mChannel10_BOX.setChecked(true);
                            mChannel11_BOX.setChecked(true);
                            mChannel12_BOX.setChecked(true);
                            mChannel13_BOX.setChecked(true);
                            mChannel14_BOX.setChecked(true);
                            mChannel15_BOX.setChecked(true);
                            mChannel16_BOX.setChecked(true);
                        Log.d(TAG,"Channels "+GlobalVars.mChannelHex);
                    }
            }
        });

        // CLEAR CHAN button : Unset all channels but number 1, default
        mClearCh_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mClearCh_BTN.isPressed()){
                        GlobalVars.mChannelHex = 0x00;
                            mChannel1_BOX.setChecked(false);
                            mChannel2_BOX.setChecked(false);
                            mChannel3_BOX.setChecked(false);
                            mChannel4_BOX.setChecked(false);
                            mChannel5_BOX.setChecked(false);
                            mChannel6_BOX.setChecked(false);
                            mChannel7_BOX.setChecked(false);
                            mChannel8_BOX.setChecked(false);
                            mChannel9_BOX.setChecked(false);
                            mChannel10_BOX.setChecked(false);
                            mChannel11_BOX.setChecked(false);
                            mChannel12_BOX.setChecked(false);
                            mChannel13_BOX.setChecked(false);
                            mChannel14_BOX.setChecked(false);
                            mChannel15_BOX.setChecked(false);
                            mChannel16_BOX.setChecked(false);
                        mConnectedThread.write("c0\n"); /////// must be resolved in hardware
                        Log.d(TAG,"Channels "+GlobalVars.mChannelHex);
                    }
            }
        });

        // SET R-G-B button : save selected RGB in queue
        mSetColors_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mSetColors_BTN.isPressed()){
                        setColor(mRed_BOX, redHex,
                                 mGrn_BOX, grnHex,
                                 mBlu_BOX, bluHex);
                    }
                    mConnectedThread.write("8\n");
            }
        });

        // CLEAR R-G-B button : clear queue and turn off RGB
        mClearColors_BTN.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mClearColors_BTN.isPressed()){
                        redHex.setText("000");
                        mRed_BOX.setChecked(false);
                        mRed_BAR.setProgress(0);// reset seek bar after set box check to false
                        grnHex.setText("000");
                        mGrn_BOX.setChecked(false);
                        mGrn_BAR.setProgress(0);
                        bluHex.setText("000");
                        mBlu_BOX.setChecked(false);
                        mBlu_BAR.setProgress(0);
                        mConnectedThread.write("0\n");
                        mConnectedThread.write("9\n");
                        Log.d(TAG,"Channels "+GlobalVars.mChannelHex);
                    }
            }
        });

        // FOREGROUND button : selects fg
        mFg_Button.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mFg_Button.isChecked()){
                        GlobalVars.mBackground = 0;
                        mConnectedThread.write("f\n");
                    }
            }
        });

        // BACKGROUND button : selects bg
        mBg_Button.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                if(mConnectedThread != null) //First check to make sure thread created
                    if (mBg_Button.isChecked()){
                        GlobalVars.mBackground = 1;
                        mConnectedThread.write("b\n");
                    }
            }
        });

        mRed_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
            }
        });

        mGrn_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
            }
        });

        mBlu_BOX.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
            }
        });

        // RED bar : sends the color to HW
        mRed_BAR.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue = 0;
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progressChangedValue = progress;
                String redValue = String.format("%03d",progressChangedValue);
                redHex.setText(redValue);
                if(mRed_BOX.isChecked())
                    setColor(mRed_BOX,redHex,mGrn_BOX,grnHex,mBlu_BOX,bluHex); // 0x000000FF
            }
            public void onStartTrackingTouch(SeekBar seekBar) {
            }
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        // GREEN bar : sends the color to HW
        mGrn_BAR.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue = 0;
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progressChangedValue = progress;
                String grnValue = String.format("%03d",progressChangedValue);
                grnHex.setText(grnValue);
                if(mGrn_BOX.isChecked())
                    setColor(mRed_BOX,redHex,mGrn_BOX,grnHex,mBlu_BOX,bluHex); // 0x00FF0000
            }
            public void onStartTrackingTouch(SeekBar seekBar) {
            }
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        // BLUE bar : sends the color to HW
        mBlu_BAR.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue = 0;
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progressChangedValue = progress;
                String bluValue = String.format("%03d",progressChangedValue);
                bluHex.setText(bluValue);
                if(mBlu_BOX.isChecked())
                    setColor(mRed_BOX,redHex,mGrn_BOX,grnHex,mBlu_BOX,bluHex); // 0x0000FF00
            }
            public void onStartTrackingTouch(SeekBar seekBar) {
            }
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        // SET COLOR button : set color/intensity from spinners to all channels
        mSetSolid_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String value = String.format("%01d",GlobalVars.mSolidColorPosition);
                if(mConnectedThread != null){
                    if(mSetSolid_BTN.isPressed()){
                        mConnectedThread.write("i" + Integer.toHexString(GlobalVars.mIntensityPosition) + "\n");
                        mConnectedThread.write(value+"\n");
                        mConnectedThread.write("8\n");
                    }
                }
            }
        });

        // SET COLOR spin : select solid color
        mSolidColor_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
               String item = parent.getItemAtPosition(position).toString();
               GlobalVars.mSolidColorPosition = position;
               GlobalVars.mSolidColorItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // INTENSITY spin : selects intensity
        mIntensity_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mIntensityPosition = position;
                GlobalVars.mIntensityItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // PATTERN button : selects pattern/mode from spinners
        mSetPattern_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mConnectedThread != null){
                    if(mSetPattern_BTN.isPressed()){
                        mConnectedThread.write("r" + Integer.toHexString(GlobalVars.mPatternModePosition) + "\n");
                        mConnectedThread.write("9\n");
                        mConnectedThread.write("p" + Integer.toHexString(GlobalVars.mPatternPosition) + "\n");
                        Log.d(TAG,"Selected Pattern "+GlobalVars.mPatternItem+" position "+GlobalVars.mPatternPosition+" all channels "+GlobalVars.mChannelHex);
                    }
                }
            }
        });

        // PATTERN spin :
        mPattern_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mPatternPosition = position;
                GlobalVars.mPatternItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // PATTERN_MODE spin
        mPattern_mode_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mPatternModePosition = position;
                GlobalVars.mPatternModeItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // THEME button : selects theme/mode from spinners
        mSetTheme_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int msk     = 1;
                int bittemp = 0;
                int i       = 0;
                if(mConnectedThread != null){
                    if(mSetTheme_BTN.isPressed()){
                        mConnectedThread.write("m" + Integer.toHexString(GlobalVars.mThemeModePosition) + "\n");
                        /*
                        if (GlobalVars.mThemeItem == "Custom"){
                            GlobalVars.mIntensityPosition = 7;
                            mIntensity_SPIN.setSelection(GlobalVars.mIntensityPosition);
                        }
                        */
                        mConnectedThread.write("i" + Integer.toHexString(GlobalVars.mIntensityPosition) + "\n");
                        for (i = 0; i < GlobalVars.MAX_CHANNELS; i++) {
                            bittemp = msk & GlobalVars.mChannelHex;
                            String h = Integer.toHexString(i);
                            if (bittemp != 0) {
                                mConnectedThread.write("c" + h + "\n");
                                mConnectedThread.write("e" + Integer.toHexString(GlobalVars.mThemePosition) + "\n");
                                mConnectedThread.write("d\n");
                                Log.d(TAG,"Selected Theme "+GlobalVars.mThemeItem+" position "+GlobalVars.mThemePosition+" channel "+bittemp);
                            }
                            msk = msk << 1;
                        }
                    }
                }
            }
        });

        // THEMES spin
        mThemes_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mThemePosition = position;
                GlobalVars.mThemeItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // THEMES_MODE spin
        mThemes_mode_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mThemeModePosition = position;
                GlobalVars.mThemeModeItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // ID spin :
        mFileId_SPIN.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String item = parent.getItemAtPosition(position).toString();
                GlobalVars.mFileIdPosition = position;
                GlobalVars.mFileIdItem = item;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // SAVE button : save pattern buffer into HW based on ID spinner
        mSave_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int msk     = 1;
                int bittemp = 0;
                int i       = 0;
                int vc_value = GlobalVars.mFileIdPosition*16;
                GlobalVars.mSaveCh = vc_value;
                if(mConnectedThread != null){
                    if(mSave_BTN.isPressed()){
                        for (i = 0; i < GlobalVars.MAX_CHANNELS; i++) {
                            bittemp = msk & GlobalVars.mChannelHex;
                            String h = Integer.toHexString(i);
                            String vc = Integer.toHexString(vc_value+i);
                            if (bittemp != 0) {
                                mConnectedThread.write("c" + h + "\n"); // real channel
                                mConnectedThread.write("V" + vc + "\n"); // Virtual channel
                                mConnectedThread.write("S\n"); // Save channel into virtual channel
                            }
                            msk = msk << 1;
                        }
                    }
                }
            }
        });

        // RESTORE button : restore pattern from HW based on ID spinner
        mRestore_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int msk     = 1;
                int bittemp = 0;
                int i       = 0;
                int vc_value = GlobalVars.mFileIdPosition*16;
                GlobalVars.mRestoreCh = vc_value;
                if(mConnectedThread != null){
                    if(mRestore_BTN.isPressed()){
                        for (i = 0; i < GlobalVars.MAX_CHANNELS; i++) {
                            bittemp = msk & GlobalVars.mChannelHex;
                            String h = Integer.toHexString(i);
                            String vc = Integer.toHexString(vc_value+i);
                            if (bittemp != 0) {
                                mConnectedThread.write("c" + h + "\n"); // real channel
                                mConnectedThread.write("V" + vc + "\n");
                                mConnectedThread.write("R\n"); // restore virtual channel to channel
                            }
                            msk = msk << 1;
                            mConnectedThread.write("d\n");
                        }
                    }
                }
            }
        });

        // PIXEL bar : selects number of pixels in walking mode
        mPixel_BAR.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue = 0;
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progressChangedValue = progress;
                if (progressChangedValue <= 1)
                    progressChangedValue = 1;
                GlobalVars.mPixels = progressChangedValue;
                int decValue = progressChangedValue;
                mConnectedThread.write("a" + Integer.toHexString(decValue) + "\n");
            }
            public void onStartTrackingTouch(SeekBar seekBar) {
            }
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        // TIMER bar : selects time for blinking/walking/dimming modes
        mTimer_BAR.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue = 0;
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progressChangedValue = progress;
                if (progressChangedValue <= 1)
                    progressChangedValue = 1;
                GlobalVars.mTimer = progressChangedValue;
                int decValue = progressChangedValue;
                mConnectedThread.write("t" + Integer.toHexString(decValue) + "\n");
            }
            public void onStartTrackingTouch(SeekBar seekBar) {
            }
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        // EXIT button : go to previous menu
        mEXIT_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mConnectedThread != null) { //First check to make sure thread created
                    /*mConnectedThread.write("9\n"); // reset counters*/
                    mConnectedThread.write("x\n"); // exit to main menu
                    NavHostFragment.findNavController(SecondFragment.this)
                            .navigate(R.id.action_SecondFragment_to_FirstFragment);
                } else {
                    NavHostFragment.findNavController(SecondFragment.this)
                            .navigate(R.id.action_SecondFragment_to_FirstFragment);
                }
            }
        });

        // SETUP button : go to next menu
        mSetup_BTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mConnectedThread != null) { //First check to make sure thread created
                    if (mSetup_BTN.isPressed()) {
                        NavHostFragment.findNavController(SecondFragment.this)
                                .navigate(R.id.action_SecondFragment_to_ThirdFragment);
                    }
                }
            }
        });
        
    }


    /*********************************************************************************************
     * Common Functions:
     * SetColor
     * SetChannelColor
     * SetChannel
     *
    */
    private void setColor(CheckBox mRed_BOX, TextView redHex,
                          CheckBox mGrn_BOX, TextView grnHex,
                          CheckBox mBlu_BOX, TextView bluHex){
        int ch = GlobalVars.mChannelHex;
        int decValue;
        int decValueR;
        int decValueG;
        int decValueB;
        if(mRed_BOX.isChecked()) {
            String strValue = (String) redHex.getText();
            decValueR = Integer.parseInt(strValue);
        }
         else
             decValueR = 0;

        if(mGrn_BOX.isChecked()) {
            String strValue = (String) grnHex.getText();
            decValueG = Integer.parseInt(strValue)<<GlobalVars.GRN_SHIFT;
        }
        else
            decValueG = 0;

        if(mBlu_BOX.isChecked()) {
            String strValue = (String) bluHex.getText();
            decValueB = Integer.parseInt(strValue) << GlobalVars.BLU_SHIFT;
        }
        else
            decValueB = 0;

        decValue = decValueR | decValueG | decValueB;
        setChannelColor(ch,decValue);
    }

    private void setChannelColor(int ch, int color){
        final BTService.ConnectedThread mConnectedThread = GlobalVars.gCThread;
        int msk     = 1;
        int bitTemp = 0;
        int i       = 0;
        if (mConnectedThread != null) { //First check to make sure thread created
            for (i = 0; i < GlobalVars.MAX_CHANNELS; i++) {
                bitTemp = msk & ch;
                String h = Integer.toHexString(i);
                if (bitTemp != 0) {
                    mConnectedThread.write("c" + h + "\n");
                    GlobalVars.mColorsChannel[i] = color;
                    String mCmdBuffer = Integer.toHexString(GlobalVars.mColorsChannel[i]);
                    mConnectedThread.write("s" + mCmdBuffer + "\n");
                    Log.d(TAG,"setChannelColor "+mCmdBuffer+" channel "+i+" color "+color+" ch "+ch+" bitTemp "+bitTemp);
                }
                msk = msk << 1;
            }
        }
    }

    /*
     * This function set the checked channel
     */
    private void setChannel(int ch, CheckBox myBox){
        final BTService.ConnectedThread mConnectedThread = GlobalVars.gCThread;
        int tempVar = 0;
        if(mConnectedThread != null) //First check to make sure thread created
            if (myBox.isChecked()) {
                tempVar = GlobalVars.mChannelHex;
                GlobalVars.mChannelHex = tempVar | ch;
                Log.d(TAG, "Channel set " + ch + " All Channels " + GlobalVars.mChannelHex);
            } else {
                tempVar = GlobalVars.mChannelHex;
                GlobalVars.mChannelHex = tempVar & ~ch;
                Log.d(TAG, "Channel clear " + ch + " All Channels " + GlobalVars.mChannelHex);
            }

    }
/*
    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        // Save UI state changes to the savedInstanceState.
        // This bundle will be passed to onCreate if the process is
        // killed and restarted.
//        savedInstanceState.putBoolean("MyBoolean", true);
//        savedInstanceState.putDouble("myDouble", 1.9);
        savedInstanceState.putInt("mChannelHex", GlobalVars.mChannelHex);
//        savedInstanceState.putString("MyString", "Welcome back to Android");
    }
    @Override
    public void onViewStateRestored(@Nullable Bundle savedInstanceState) {
        super.onViewStateRestored(savedInstanceState);
        // Restore UI state from the savedInstanceState.
        // This bundle has also been passed to onCreate.
//        boolean myBoolean = savedInstanceState.getBoolean("MyBoolean");
//        double myDouble = savedInstanceState.getDouble("myDouble");
        int mChannelHex = savedInstanceState.getInt("mChannelHex");
//        String myString = savedInstanceState.getString("MyString");
        // recover
        GlobalVars.mChannelHex = mChannelHex;
    }

 */
}
