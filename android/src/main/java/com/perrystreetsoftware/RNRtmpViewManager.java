package com.perrystreetsoftware;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class RNRtmpViewManager extends SimpleViewManager<RNRtmpView> {
    public static final String REACT_CLASS = "RNRtmpView";

    public static final String PROP_URL = "url";
    public static final String PROP_SCALING_MODE = "scalingMode";
    public static final String PROP_SHOULD_MUTE = "shouldMute";
    public static final String PROP_PLAY_ON_RESUME = "playOnResume";
    public static final String PROP_PAUSE_ON_STOP = "pauseOnStop";


    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected RNRtmpView createViewInstance(ThemedReactContext reactContext) {
        return new RNRtmpView(reactContext);
    }

    @Override
    public void onDropViewInstance(RNRtmpView view) {
        super.onDropViewInstance(view);
        view.cleanupMediaPlayerResources();
        view.release();
    }

    @Override
    @Nullable
    public Map getExportedCustomDirectEventTypeConstants() {
        MapBuilder.Builder builder = MapBuilder.builder();
        for (RNRtmpView.Events event : RNRtmpView.Events.values()) {
            builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
        }
        return builder.build();
    }

    @Override
    public Map<String,Integer> getCommandsMap() {
        MapBuilder.Builder builder = MapBuilder.builder();
        for (RNRtmpView.Commands command : RNRtmpView.Commands.values()) {
            builder.put(command.toString(), command.ordinal());
        }
        return builder.build();
    }

    @Override
    public void receiveCommand(RNRtmpView videoView, int commandId, @Nullable ReadableArray args) {
        RNRtmpView.Commands command = RNRtmpView.Commands.values()[commandId];

        switch (command){
            case COMMAND_INITIALIZE:
                videoView.initialize();
                break;
            case COMMAND_PLAY:
                videoView.play();
                break;
            case COMMAND_PAUSE:
                videoView.pause();
                break;
            case COMMAND_STOP:
                videoView.stop();
                break;
            case COMMAND_MUTE:
                videoView.mute();
                break;
            case COMMAND_UNMUTE:
                videoView.unmute();
                break;
            default:
                break;
        }
    }

    @ReactProp(name = PROP_URL)
    public void setUrl(RNRtmpView videoView, final String url) {
        videoView.setUrl(url);
    }

    @ReactProp(name = PROP_SCALING_MODE)
    public void setScalingMode(RNRtmpView videoView, final String scalingMode) {
    }

    @ReactProp(name = PROP_SHOULD_MUTE)
    public void setShouldMute(RNRtmpView videoView, final boolean shouldMute) {
        videoView.setShouldMute(shouldMute);
    }

    @ReactProp(name = PROP_PLAY_ON_RESUME)
    public void setPlayOnResume(RNRtmpView videoView, final boolean value) {
        videoView.setPlayOnResume(value);
    }

    @ReactProp(name = PROP_PAUSE_ON_STOP)
    public void setPauseOnStop(RNRtmpView videoView, final boolean value) {
        videoView.setPauseOnStop(value);
    }
}
