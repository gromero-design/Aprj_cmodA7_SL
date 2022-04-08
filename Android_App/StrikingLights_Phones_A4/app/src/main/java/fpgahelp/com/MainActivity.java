package fpgahelp.com;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.provider.Settings;
import android.util.Log;
import android.view.Menu;

import android.view.View;
import android.widget.ArrayAdapter;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "StateChange";
    int ACTION_REQUEST_MULTIPLE_PERMISSION = 1;  // Any number

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        GlobalVars.mConnected  = 0;
        GlobalVars.mRunEnabled = 0;
        GlobalVars.gBTSocket   = null;
        GlobalVars.gCThread    = null;
        startService();

        Log.d(TAG,"onCreate");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        Log.d(TAG,"onCreateOptionsMenu");
        return true;
    }

    //  Debugging Section
    @Override
    protected void onStart(){
        super.onStart();
        Log.d(TAG,"onStart");
    }

    @Override
    protected void onResume(){
        super.onResume();
        Log.d(TAG,"onResume");
    }
    @Override
    protected void onPause(){
        super.onPause();
        Log.d(TAG,"onPause");
    }
    @Override
    protected void onStop(){
        super.onStop();
        if(GlobalVars.mFragNumber <= 1) {
            GlobalVars.mRunEnabled = 0;
            GlobalVars.mConnected = 0;
            BTService.ConnectedThread mConnectedThread = GlobalVars.gCThread;
            mConnectedThread.destroySocket();
        }
        Log.d(TAG, "onStop");
    }
    @Override
    protected void onRestart(){
        super.onRestart();
        Log.d(TAG,"onRestart");
    }
    @Override
    protected void onDestroy(){
        super.onDestroy();
        stopService();
        Log.d(TAG,"onDestroy");
    }
    @Override
    protected void onSaveInstanceState(Bundle outState){
        super.onSaveInstanceState(outState);
        Log.d(TAG,"onSaveInstanceState");
    }
    @Override
    protected void onRestoreInstanceState(Bundle SaveInstanceState){
        super.onRestoreInstanceState(SaveInstanceState);
        Log.d(TAG,"onRestoreInstanceState");
    }

    public void startService(){
        startService(new Intent(getBaseContext(),BTService.class));
        Log.d(TAG,"BTService started");
    }

    public void stopService(){
        stopService(new Intent(getBaseContext(),BTService.class));
        Log.d(TAG,"BTService stopped");
    }
}

