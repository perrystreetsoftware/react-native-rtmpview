package com.perrystreetsoftware;

import android.os.Handler;
import android.os.Message;
import androidx.annotation.NonNull;

import com.google.android.exoplayer2.ext.rtmp.RtmpDataSource;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DataSpec;
import com.google.android.exoplayer2.upstream.TransferListener;

import java.lang.ref.WeakReference;
import java.util.Date;

public class RNRtmpTransferListener implements TransferListener {
    static final int MSG_CHECK_BITRATE = 0;
    static final int RECALC_RATE_IN_MS = 5000;

    public interface RtmpBitrateListener {
        void onBitrateRecalculated(double bitrateInKbps);
    }

    private WeakReference<RtmpBitrateListener> mListener;
    private Date mLastCheckTime;
    private long mBytesTransferredSinceLastCheck;
    private boolean mDisposed;

    private final IncomingHandler mHandler = new IncomingHandler(this);

    static class IncomingHandler extends Handler {
        private WeakReference<RNRtmpTransferListener> mTarget;

        public IncomingHandler(RNRtmpTransferListener target) {
            this.mTarget = new WeakReference<>(target);
        }

        @Override
        public void handleMessage(Message msg) {
            RNRtmpTransferListener target = this.mTarget.get();

            if (target != null) {
                switch (msg.what) {
                    case MSG_CHECK_BITRATE:
                        target.calculateNewBitrate();
                        break;
                    default:
                        super.handleMessage(msg);
                }
            } else {
                super.handleMessage(msg);
            }
        }
    }

    public RNRtmpTransferListener(@NonNull RtmpBitrateListener listener) {
        this.mListener = new WeakReference<>(listener);

        this.start();
    }

    public void dispose() {
        this.mHandler.removeMessages(MSG_CHECK_BITRATE);
        this.mDisposed = true;
    }

    public void start() {
        if (!this.mDisposed) {
            this.mBytesTransferredSinceLastCheck = 0;
            this.mHandler.sendMessageDelayed(Message.obtain(this.mHandler, MSG_CHECK_BITRATE), RECALC_RATE_IN_MS);
        }
    }

    public void calculateNewBitrate() {
        if (!this.mDisposed) {
            Date now = new Date();
            if (mLastCheckTime != null) {
                long seconds = (now.getTime() - mLastCheckTime.getTime()) / 1000;
                double bitrateInKbps = (((double) this.mBytesTransferredSinceLastCheck * 8.f) / (double) seconds) / 1000f;

                RtmpBitrateListener listener = this.mListener.get();

                if (listener != null) {
                    listener.onBitrateRecalculated(bitrateInKbps);
                }
            }

            mLastCheckTime = now;
            this.mBytesTransferredSinceLastCheck = 0;

            this.mHandler.sendMessageDelayed(Message.obtain(this.mHandler, MSG_CHECK_BITRATE), RECALC_RATE_IN_MS);
        }
    }

    @Override
    public void onTransferInitializing(DataSource source, DataSpec dataSpec, boolean isNetwork) {

    }

    @Override
    public void onTransferStart(DataSource source, DataSpec dataSpec, boolean isNetwork) {

    }

    @Override
    public void onBytesTransferred(DataSource source, DataSpec dataSpec, boolean isNetwork, int bytesTransferred) {
        this.mBytesTransferredSinceLastCheck += bytesTransferred;
    }

    @Override
    public void onTransferEnd(DataSource source, DataSpec dataSpec, boolean isNetwork) {

    }
}
