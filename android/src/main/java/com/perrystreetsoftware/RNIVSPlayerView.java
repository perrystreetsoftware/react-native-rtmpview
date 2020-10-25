package com.perrystreetsoftware;

import android.content.Context;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.FrameLayout;

import com.amazonaws.ivs.player.Cue;
import com.amazonaws.ivs.player.Player;
import com.amazonaws.ivs.player.PlayerException;
import com.amazonaws.ivs.player.PlayerView;
import com.amazonaws.ivs.player.Quality;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.uimanager.ThemedReactContext;

public class RNIVSPlayerView extends FrameLayout implements LifecycleEventListener {
    private static final String APP_NAME = "ReactIVSPlayerView";

    private PlayerView mPlayerView;
    private Player mPlayer;

    public enum Commands {
        COMMAND_LOAD("load"),
        COMMAND_PAUSE("pause");

        private final String mName;

        Commands(final String name) {
            mName = name;
        }

        @Override
        public String toString() {
            return mName;
        }
    }

    public RNIVSPlayerView(Context context) {
        super(context);
        init(context);
    }

    public RNIVSPlayerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public RNIVSPlayerView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        //Inflate xml resource, pass "this" as the parent, we use <merge> tag in xml to avoid
        //redundant parent, otherwise a LinearLayout will be added to this LinearLayout ending up
        //with two view groups
        inflate(getContext(), R.layout.react_rtmp_view,this);

        mPlayerView = findViewById(R.id.player_view);
        ((ThemedReactContext)context).addLifecycleEventListener(this);

        Player player = mPlayerView.getPlayer();
        mPlayer = player;
        player.addListener(new Player.Listener() {
            @Override
            public void onCue(@NonNull Cue cue) {

            }

            @Override
            public void onDurationChanged(long l) {

            }

            @Override
            public void onStateChanged(@NonNull Player.State state) {
                switch (state) {
                    case BUFFERING:
                        // player is buffering
                        break;
                    case READY:
                        mPlayer.play();
                        break;
                    case IDLE:
                        break;
                    case PLAYING:
                        // playback started
                        break;
                }
            }

            @Override
            public void onError(@NonNull PlayerException e) {

            }

            @Override
            public void onRebuffering() {

            }

            @Override
            public void onSeekCompleted(long l) {

            }

            @Override
            public void onVideoSizeChanged(int i, int i1) {
                // https://stackoverflow.com/a/39838774/61072
                post(measureAndLayout);
            }

            @Override
            public void onQualityChanged(@NonNull Quality quality) {

            }
        });
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

    public void load(String urlString) {
        if (mPlayer != null) {
            Uri uri = Uri.parse(urlString);

            mPlayer.load(uri);
        } else {
            Log.i(APP_NAME, "Unable to play; not idle");
        }
    }

    public void pause() {
        if (this.mPlayer != null) {
            mPlayer.pause();
        }
    }

    @Override
    public void onHostResume() {
        Log.i(APP_NAME, "Lifecycle: onHostResume");

//        if (this.getPlayOnResume()) {
//            play();
//        }
    }

    @Override
    public void onHostPause() {
        Log.i(APP_NAME, "Lifecycle: onHostPause");

//        if (this.getPauseOnStop()) {
//            stop();
//        }
    }

    @Override
    public void onHostDestroy() {
        Log.i(APP_NAME, "Lifecycle: onHostDestroy");
        cleanupMediaPlayerResources();
        release();
    }

    public void cleanupMediaPlayerResources() {
    }

    public void release() {
        if (null != mPlayer) {
            mPlayer.release();
            mPlayer = null;
        }
    }
}