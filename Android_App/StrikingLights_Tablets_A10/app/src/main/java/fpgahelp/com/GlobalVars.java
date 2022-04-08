package fpgahelp.com;

import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Message;
import android.util.Log;

import java.lang.reflect.Array;

// Global variables
public class GlobalVars {
    public static int mRefresh = 0; // refresh variables between frames

    // Constants
    public static final int MAX_CHANNELS = 16;
    public static final int CHANNELS_MSK = 0xFFFF; // 2^MAX_CHANNELS-1;
    public static final int RED_MSK = 0x000000FF;
    public static final int GRN_MSK = 0x00FF0000;
    public static final int BLU_MSK = 0x0000FF00;
    public static final int RED_SHIFT = 0;
    public static final int GRN_SHIFT = 16;
    public static final int BLU_SHIFT = 8;

    // Variables
    public static String mDeviceName  = "";
    public static int mChannel    = 0;    // decimal Channel
    public static int mChannelHex = 0; // binary  Channel
    public static int mPixels     = 1; // active pixels in walking pattern
    public static int mTimer      = 1; // timer for patterns
    public static int mSaveCh     = 0; // virtual channel default
    public static int mRestoreCh  = 0; // virtual channel default

    public static int mColorsChannel[] = new int[MAX_CHANNELS];
    public static int mPatternPosition = 0;
    public static int mPatternModePosition = 0;
    public static String mPatternItem  = "";
    public static String mPatternModeItem  = "";
    public static int mThemePosition   = 0;
    public static int mThemeModePosition   = 0;
    public static String mThemeItem    = "";
    public static String mThemeModeItem    = "";
    public static int mSolidColorPosition = 1;
    public static String mSolidColorItem  = "";
    public static int mIntensityPosition = 3;
    public static String mIntensityItem  = "";
    public static int mFileIdPosition = 0;
    public static String mFileIdItem  = "";
    public static int mBackground  = 0;// fg=0, bg=1
    public static int mLEDS  = 0;// total number of pixels

    public static int mConnected  = 0;
    public static int mRunEnabled = 0;
    public static int mFragNumber = 0;

    public static String mBufferMsg;
    public static int mBufferLength;
    public static BluetoothSocket gBTSocket;
    public static BTService.ConnectedThread gCThread;

}


