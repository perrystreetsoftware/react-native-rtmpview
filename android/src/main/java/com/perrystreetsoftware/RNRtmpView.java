package com.perrystreetsoftware;

import android.content.Context;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.FrameLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.DefaultLoadControl;
import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.RenderersFactory;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.ext.rtmp.RtmpDataSourceFactory;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.video.VideoListener;

import java.util.Locale;

public class RNRtmpView extends FrameLayout implements LifecycleEventListener, RNRtmpTransferListener.RtmpBitrateListener {
    private static final String APP_NAME = "ReactRTMPView";

    private SimpleExoPlayer mPlayer;
    private PlayerView mExoPlayerView;
    private String mUrlString;
    private float mLastAudioVolume;
    private boolean mShouldMute;
    private double mLastBitrateCalculation;

    public enum Commands {
        COMMAND_INITIALIZE("initialize"),
        COMMAND_PLAY("play"),
        COMMAND_PAUSE("pause"),
        COMMAND_STOP("stop"),
        COMMAND_MUTE("mute"),
        COMMAND_UNMUTE("unmute");

        private final String mName;

        Commands(final String name) {
            mName = name;
        }

        @Override
        public String toString() {
            return mName;
        }
    }

    public enum Events {
        EVENT_BITRATE_RECALCULATED("onBitrateRecalculated"),
        EVENT_FIRST_VIDEO_FRAME_RENDERED("onFirstVideoFrameRendered"),
        EVENT_PLAYBACK_STATE("onPlaybackState"),
        EVENT_LOAD_STATE("onLoadState");

        private final String mName;

        Events(final String name) {
            mName = name;
        }

        @Override
        public String toString() {
            return mName;
        }
    }

    public RNRtmpView(Context context) {
        super(context);
        init(context);
    }

    public RNRtmpView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public RNRtmpView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        //Inflate xml resource, pass "this" as the parent, we use <merge> tag in xml to avoid
        //redundant parent, otherwise a LinearLayout will be added to this LinearLayout ending up
        //with two view groups
        inflate(getContext(), R.layout.react_rtmp_view,this);

        mExoPlayerView = findViewById(R.id.player_view);
    }

    public void initialize() {
        DefaultLoadControl loadControl =
                new DefaultLoadControl.Builder()
                        .setBufferDurationsMs(1000, 3000, 1000, 1000)
                        .setPrioritizeTimeOverSizeThresholds(true)
                        .createDefaultLoadControl();
        TrackSelection.Factory videoTrackSelectionFactory =
                new AdaptiveTrackSelection.Factory(new DefaultBandwidthMeter());
        TrackSelector trackSelector =
                new DefaultTrackSelector(videoTrackSelectionFactory);
        RenderersFactory renderersFactory = new DefaultRenderersFactory(this.getContext());
        mPlayer = ExoPlayerFactory.newSimpleInstance(renderersFactory, trackSelector, loadControl);
        mPlayer.addListener(new Player.EventListener() {
            @Override
            public void onTimelineChanged(Timeline timeline, @Nullable Object manifest, int reason) {
                Log.i(APP_NAME, "onTimelineChanged");
            }

            @Override
            public void onTracksChanged(TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {
                Log.i(APP_NAME, "onTracksChanged");
            }

            @Override
            public void onLoadingChanged(boolean isLoading) {
                Log.i(APP_NAME, String.format("onLoadingChanged to be %b %d %d", isLoading, mPlayer.getBufferedPercentage(), (int) mPlayer.getBufferedPosition()));

                // Aggressively seek to start of stream if starting a new load

                if (isLoading) {
                    mPlayer.seekTo(0);
                    RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Loading);
                }
            }

            @Override
            public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
                Log.i(APP_NAME, String.format("onPlayerStateChanged: %b %d", playWhenReady, playbackState));

                if (playbackState == Player.STATE_ENDED) {
                    RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Stopped);

                    mPlayer.seekTo(0);
                    mPlayer.setPlayWhenReady(true);

                } else if (playbackState == Player.STATE_READY) {
                    mPlayer.seekTo(0);

                    RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Playing);
                } else if (playbackState == Player.STATE_BUFFERING) {
                    RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Buffering);
                }
            }

            @Override
            public void onRepeatModeChanged(int repeatMode) {
                Log.i(APP_NAME, "onRepeatModeChanged");
            }

            @Override
            public void onShuffleModeEnabledChanged(boolean shuffleModeEnabled) {
                Log.i(APP_NAME, "onShuffleModeEnabledChanged");
            }

            @Override
            public void onPlayerError(ExoPlaybackException error) {
                Log.i(APP_NAME, "onPlayerError");
                RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Error, error);
            }

            @Override
            public void onPositionDiscontinuity(int reason) {
                Log.i(APP_NAME, "onPositionDiscontinuity");
                RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.Discontinuity);
            }

            @Override
            public void onPlaybackParametersChanged(PlaybackParameters playbackParameters) {
                Log.i(APP_NAME, "onPlaybackParametersChanged");
            }

            @Override
            public void onSeekProcessed() {
                Log.i(APP_NAME, "onSeekProcessed");
                RNRtmpView.this.onPlaybackStateChanged(RNRtmpPlaybackState.SeekingForward);
            }
        });

        mExoPlayerView.setPlayer(mPlayer);

        mExoPlayerView.setResizeMode(AspectRatioFrameLayout.RESIZE_MODE_ZOOM);
        mPlayer.setVideoScalingMode(C.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING);

        // https://stackoverflow.com/questions/39836356/react-native-resize-custom-ui-component
        mPlayer.addVideoListener(new VideoListener() {
            @Override
            public void onVideoSizeChanged(int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
                // https://stackoverflow.com/a/39838774/61072
                post(measureAndLayout);
            }

            @Override
            public void onRenderedFirstFrame() {
                RNRtmpView.this.onFirstVideoFrameRendered();
            }
        });
        if (this.mShouldMute) {
            mute();
        }

        play();
    }

    private final Runnable measureAndLayout = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    public void play() {
        String rtmpUrl = this.mUrlString;
        RtmpDataSourceFactory rtmpDataSourceFactory = new RtmpDataSourceFactory(new RNRtmpTransferListener(this));
        MediaSource videoSource = new ExtractorMediaSource.Factory(rtmpDataSourceFactory)
                .createMediaSource(Uri.parse(rtmpUrl + " live=1 buffer=1000 timeout=3"));
        mPlayer.prepare(videoSource);
        mPlayer.setPlayWhenReady(true);
    }

    public void pause() {
        mPlayer.stop();
    }

    public void stop() {
        mPlayer.stop();
    }

    public void setShouldMute(boolean value) {
        this.mShouldMute = value;
    }

    public void mute() {
        mLastAudioVolume = mPlayer.getVolume();

        mPlayer.setVolume(0);
    }

    public void unmute() {
        if (mLastAudioVolume == 0) {
            mLastAudioVolume = 1.0f;
        }

        mPlayer.setVolume(mLastAudioVolume);
    }

    @Override
    public void onHostResume() {

    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }

    public void cleanupMediaPlayerResources() {
        stop();
    }

    public void release() {
        if (null != mPlayer) {
            mPlayer.release();
            mPlayer = null;
        }
    }

    public void setUrl(String urlString) {
        this.mUrlString = urlString;
    }

    @Override
    public void onBitrateRecalculated(double bitrateInKbps) {
        this.mLastBitrateCalculation = bitrateInKbps;

        Log.i(APP_NAME, String.format("onBitrateCalculated: %f", bitrateInKbps));

        WritableMap event = Arguments.createMap();
        event.putString("bitrate", String.format(Locale.US, "%f", bitrateInKbps));

        ReactContext reactContext = (ReactContext)getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                Events.EVENT_BITRATE_RECALCULATED.toString(),
                event);
    }

    public void onFirstVideoFrameRendered() {
        WritableMap event = Arguments.createMap();

        ReactContext reactContext = (ReactContext)getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                Events.EVENT_FIRST_VIDEO_FRAME_RENDERED.toString(),
                event);
    }

    public enum RNRtmpLoadState {
        Unknown("Unknown"),
        Playable("Playable"),
        PlayThroughOK("PlayThroughOK"),
        Stalled("Stalled");

        private final String mFieldDescription;

        RNRtmpLoadState(String value) {
            mFieldDescription = value;
        }

        public String getFieldDescription() {
            return this.mFieldDescription;
        }
    }


    public void onLoadStateChanged(RNRtmpLoadState loadState) {
        WritableMap event = Arguments.createMap();
        event.putString("state", loadState.getFieldDescription());

        ReactContext reactContext = (ReactContext)getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                Events.EVENT_LOAD_STATE.toString(),
                event);
    }

    public enum RNRtmpPlaybackState {
        Stopped("Stopped"),
        Playing("Playing"),
        Buffering("Buffering"),
        Loading("Loading"),
        Paused("Paused"),
        Error("Error"),
        Discontinuity("Discontinuity"),
        SeekingForward("SeekingForward"),
        SeekingBackgward("SeekingBackward");

        private final String mFieldDescription;

        RNRtmpPlaybackState(String value) {
            mFieldDescription = value;
        }

        public String getFieldDescription() {
            return this.mFieldDescription;
        }
    }

    public void onPlaybackStateChanged(RNRtmpPlaybackState playbackState) {
        onPlaybackStateChanged(playbackState, null);
    }

    public void onPlaybackStateChanged(RNRtmpPlaybackState playbackState, Throwable error) {
        WritableMap event = Arguments.createMap();
        event.putString("state", playbackState.getFieldDescription());

        if (error != null) {
            event.putString("error", error.toString());
        }

        event.putMap("qos", getQos());

        ReactContext reactContext = (ReactContext)getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                Events.EVENT_PLAYBACK_STATE.toString(),
                event);
    }

    public WritableMap getQos() {
        WritableMap qos = Arguments.createMap();
        qos.putString("bitrate", String.format(Locale.US, "%f", mLastBitrateCalculation));
        qos.putString("playback_state", String.format(Locale.US, "%d", mPlayer.getPlaybackState()));
        qos.putString("buffered_percentage", String.format(Locale.US, "%d", mPlayer.getBufferedPercentage()));
        qos.putString("buffered_position", String.format(Locale.US, "%d", mPlayer.getBufferedPosition()));
        qos.putString("current_position", String.format(Locale.US, "%d", mPlayer.getCurrentPosition()));
        qos.putString("volume", String.format(Locale.US, "%f", mPlayer.getVolume()));

        return qos;
    }
}
