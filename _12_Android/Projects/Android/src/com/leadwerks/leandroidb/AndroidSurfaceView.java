package com.leadwerks.leandroidb;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.res.Configuration;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;
import android.util.Log;

public class AndroidSurfaceView extends GLSurfaceView {
	
	public native void setAPKFilePath(String path);
	
	public AndroidSurfaceView(Context context) {
		super(context);
		
		// Get the path to the APK file for this application:
		ApplicationInfo info = context.getApplicationInfo();
		setAPKFilePath(info.sourceDir);
	}
	
	public AndroidSurfaceView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	@Override
	protected void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
    	//Log.i(AndroidActivity.LOG_TAG, "view configuration changed");    	
	}
}
