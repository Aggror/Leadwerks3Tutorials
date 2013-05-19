package com.leadwerks.leandroidb;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.opengl.GLSurfaceView;
import android.util.Log;

class AndroidRenderer implements GLSurfaceView.Renderer {
    
	public native void init(int width, int height);
    public native void step();
    public native void up(float x, float y, int touchId);
    public native void move(float x, float y, int touchId);
    public native void touch(float x, float y, int touchId);
    public native void recreateSurface(int width, int height);
    public native void handleRotate();
	public native void pause();
	public native void resume();
	public native int getDeviceOrientation();
	public native void onSensorChanged(float x, float y, float z);
    boolean initRun = false;
	private AndroidActivity androidActivity = null;
    
    static {
    	System.loadLibrary("app");
    }

	public void setActivity(AndroidActivity androidActivity) {
		this.androidActivity = androidActivity;
	}

	public void onDrawFrame(GL10 gl) {
    	step();
    }
    
    public void onSurfaceChanged(GL10 gl, int width, int height) {
    	//Log.i(AndroidActivity.LOG_TAG, "surface changed.");    	
    	//Debug.waitForDebugger();
    	
    	if(!initRun) {
        	//Log.i(AndroidActivity.LOG_TAG, "surface init."); 
    		
    		init(width, height);
    		initRun = true;
    	}
    	else {
        	//Log.i(AndroidActivity.LOG_TAG, "surface recreate.");
        	recreateSurface(width, height);
    	}
    }
    
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    	//Log.i(AndroidActivity.LOG_TAG, "surface created");
    }
    
    public void setDeviceOrientation(int newOrientation) {
    	if(androidActivity == null)
    		return;

   		androidActivity.setDeviceOrientation(newOrientation);
    }
}
