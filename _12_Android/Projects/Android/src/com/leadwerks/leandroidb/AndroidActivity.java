package com.leadwerks.leandroidb;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;

public class AndroidActivity extends Activity implements SensorEventListener {
	AndroidSurfaceView mView;

	public static final String LOG_TAG = "Leadwerks";
	private static final int PORTRAIT = 1;
	private static final int LANDSCAPE = 2;
	
	private SensorManager mSensorManager;
	private Sensor mAccelerometer;

	AndroidRenderer androidRenderer = new AndroidRenderer();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		//Log.i(LOG_TAG, "****************");
		//Log.i(LOG_TAG, "activity created");

		mSensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
		mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

		super.onCreate(savedInstanceState);

		setDeviceOrientation(androidRenderer.getDeviceOrientation());

		mView = new AndroidSurfaceView(this);
		mView.setEGLContextClientVersion(2);
		// androidRenderer = new AndroidRenderer();
		androidRenderer.setActivity(this);
		mView.setRenderer(androidRenderer);
		setContentView(mView);
	}

	protected void setDeviceOrientation(int newOrientation) {
		switch (newOrientation) {
		case PORTRAIT:
			this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
			break;
		case LANDSCAPE:
			this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
			break;
		}
	}
	
	@Override
	protected void onPause() {
		//Log.i(LOG_TAG, "activity paused");
		super.onPause();
		mSensorManager.unregisterListener(this);
		mView.onPause();
		androidRenderer.pause();
	}

	@Override
	protected void onResume() {
		//Log.i(LOG_TAG, "activity resumed");
		super.onResume();
		mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL);
		mView.onResume();
		androidRenderer.resume();
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		Integer activePointer = (event.getAction() >> MotionEvent.ACTION_POINTER_ID_SHIFT);
		Float x = event.getX(activePointer);
		Float y = event.getY(activePointer);

		switch (event.getAction() & MotionEvent.ACTION_MASK) {
		case MotionEvent.ACTION_DOWN:
		case MotionEvent.ACTION_POINTER_DOWN:
			// Log.i("touchtest", "action_down " + activePointer.toString() +
			// "(" + x + "," + y + ")");
			androidRenderer.touch(x, y, activePointer);
			break;
		case MotionEvent.ACTION_MOVE:
			// Log.i("touchtest", "action_move " + activePointer.toString() +
			// "(" + x + "," + y + ")");
			androidRenderer.move(x, y, activePointer);
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_POINTER_UP:
			// Log.i("touchtest", "action_up " + activePointer.toString() + "("
			// + x + "," + y + ")");
			androidRenderer.up(x, y, activePointer);
			break;
		}
		return true;
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		//Log.i(LOG_TAG, "configuration changed");
		super.onConfigurationChanged(newConfig);
		// setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		//Log.i(LOG_TAG, "configuration change finished");
		androidRenderer.handleRotate();
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {

		if (keyCode == KeyEvent.KEYCODE_MENU) {
			//Log.i(LOG_TAG, "menu pressed");
			return true;
		}

		return super.onKeyUp(keyCode, event);
	}

	public void onAccuracyChanged(Sensor sensor, int value) {
	}
		
	public void onSensorChanged(SensorEvent event) {
		//Log.i("accel", "x: " + event.values[0] + " y: " + event.values[1]
		//		+ " z: " + event.values[2]);
		androidRenderer.onSensorChanged(event.values[0], event.values[1], event.values[2]);
	}
}
