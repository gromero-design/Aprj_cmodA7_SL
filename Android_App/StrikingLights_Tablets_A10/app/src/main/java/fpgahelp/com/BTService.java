package fpgahelp.com;

import android.annotation.SuppressLint;
import android.app.Service;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

public class BTService extends Service {
    private static final String TAG = "StateChangeBTService";
    private static final int RESULT_OK = 1; //? I added here, original is not defined where is coming from?
    private final String version_number = "SW Version V10 (04/15/2020 = 08:55)";

    // #defines for identifying shared types between calling functions
    private final static int REQUEST_ENABLE_BT = 1; // used to identify adding bluetooth names
    private final static int MESSAGE_READ = 2; // used in bluetooth handler to identify message update
    private final static int CONNECTING_STATUS = 3; // used in bluetooth handler to identify message status
//    public final static Handler mHandler = new Handler();

    @Override
    public void onCreate() {
        Log.d("BTService", "BTService Created");
        super.onCreate();
    }

    @SuppressLint("HandlerLeak")
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "BTService Started");
        // Our main handler that will receive callback notifications
/*
        Handler mHandler = new Handler() {
            public void handleMessage(android.os.Message msg) {
                 Log.d(TAG, "Handler Frag1: New Message");
                if (msg.what == MESSAGE_READ) {
                    Log.d(TAG, "Handler BTService: Message Received");
                    String readMessage = null;
                    try {
                        readMessage = new String((byte[]) msg.obj, "UTF-8");
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }
                    GlobalVars.mBuffer = readMessage;
                    GlobalVars.mRunEnabled=1;
                }
                if (msg.what == CONNECTING_STATUS) {
                    Log.d(TAG, "Handler BTService: Connecting Status");
                    if (msg.arg1 == 1) {
                        Log.d(TAG, "Handler: Connecting Status to Device: " + msg.obj);
                        GlobalVars.mBuffer = ("Connected to Device: " + (String) (msg.obj));
                    }
                    else
                        GlobalVars.mBuffer = ("Connection Failed");
                }
                Log.d(TAG, "handleMessage BTService");
            }
        };
*/
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public static class ConnectedThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;
        private final Handler mHandler;

        public ConnectedThread(BluetoothSocket socket, Handler mHandler) {
            this.mHandler = mHandler;
            mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
                Log.d(TAG,"BTService ConnectedThread "+mHandler);
            } catch (IOException e) {
                e.printStackTrace();
            }
            mmInStream = tmpIn;
            mmOutStream = tmpOut;
        }

        public void run() {
            byte[] buffer = new byte[2048];  // buffer store for the stream
            int bytes; // bytes returned from read()
            // Keep listening to the InputStream until an exception occurs
            while (true) {
                try {
                    // Read from the InputStream
                    bytes = mmInStream.available();
                    if(bytes != 0) {
                        SystemClock.sleep(100); //pause and wait for rest of data. Adjust this depending on your sending speed.
                        bytes = mmInStream.available(); // how many bytes are ready to be read?
                        bytes = mmInStream.read(buffer, 0, bytes); // record how many bytes we actually read
                        mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
                                .sendToTarget(); // Send the obtained bytes to the UI activity
                        Log.d(TAG,"BTService ConnectedThread read "+bytes);
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }

/* Call this from the main activity to send data to the remote device */

        public void write(String input) {
            byte[] bytes = input.getBytes();           //converts entered String into bytes
            try {
                mmOutStream.write(bytes);
                Log.d(TAG,"BTService ConnectedThread write");
            } catch (IOException e) { }
        }

/* Call this from the main activity to shutdown the connection */

        public void cancel() {
            try {
                mmSocket.close();
                Log.d(TAG,"BTService ConnectedThread SocketClose");
            } catch (IOException e) { }
       }

        public void destroySocket(){
            try {
                if(mmInStream != null)
                {
                    mmInStream.close();
//                    mmInStream = null;
                }
                if(mmOutStream != null)
                {
                    mmOutStream.close();
//                    mmOutStream  = null;
                }
                if(mmSocket != null)
                {
                    mmSocket.close();
//                    mmSocket = null;
                }
                if(mmInStream == null && mmOutStream == null && mmSocket == null)
                {
                    mmSocket.close();
                }
            } catch (IOException e1) {
//                mmInStream = null;
//                mmOutStream  = null;
//                ConfigData.m_SharedBluetoothSocket = null;
                e1.printStackTrace();
            }
        }
    }
};



