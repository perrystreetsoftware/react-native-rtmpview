declare module 'react-native-rtmpview' {
    import * as React from 'react';
    import * as ReactNative from 'react-native';

    export type RtmpViewScalingModeValue = 'MovieScalingModeAspectFill' | 'MovieScalingModeResize';


    export interface RtmpViewProps {
        backgroundPlay?: boolean;
        shouldMute?: boolean;
        url?: string;
        scalingMode?: {
            MovieScalingModeAspectFill?: RtmpViewScalingModeValue;
            MovieScalingModeResize?: RtmpViewScalingModeValue;
        };
        onLoadState: () => ReactNative.NativeSyntheticEvent;
        onBitrateRecalculated: () => ReactNative.NativeSyntheticEvent,
        onPlaybackState: () => ReactNative.NativeSyntheticEvent;
        onFirstVideoFrameRendered: () => ReactNative.NativeSyntheticEvent;
    }

    export class RtmpView extends React.Component<RtmpViewProps> {
        initialize(): any;
        play(): any;
        stop(): any;
        pause(): any;
        mute(): any;
        unmute(): any;
    }

    export default RtmpView;
}
