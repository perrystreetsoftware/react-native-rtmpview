
# react-native-rtmpview

## Getting started

`$ npm install react-native-rtmpview --save`

### iOS installation

Find or create an iOS podfile in the `./ios` directory, and add:

    pod 'Yoga', path: '../node_modules/react-native/ReactCommon/yoga/Yoga.podspec'
    pod 'React', path: '../node_modules/react-native'
    pod 'react-native-rtmpview', :path => '../node_modules/react-native-rtmpview'

Next, run

    pod install

Because react-native-rtmpview has cocoapod dependencies on third-party video playback libraries, it must be added through Cocoapods. (You cannot simply use `react-native link` for example, as you can with other libraries).

### Android installation

This library does not yet work with Android devices.


## Example

react-native-rtmpview includes an example project to help get you started. To build and run the example, download or clone the project from github, and then run the following from the root of the project:

```
    cd Example/
    npm install --save
    react-native run-ios
```

## Usage
```javascript

import { RtmpView } from 'react-native-rtmpview';

<RtmpView
  style={styles.player}
  shouldMute={true}
  ref={e => { this.player = e; }}
  onPlaybackState={(data) => {
    this.handlePlaybackState(data);
  }}
  onFirstVideoFrameRendered={(data) => {
    this.handleFirstVideoFrameRendered(data);
  }}
  url="rtmp://localhost:1935/live/stream"/>

```

### Events

By default this class will pass all events through using an event emitter,
which can be subscribed to this way:

```javascript
  const RNRtmpEventManager = new NativeEventEmitter(
    NativeModules.RNRtmpEventManager
  );

  RNRtmpEventManager.addListener(
    "RNRtmpEvent",
    (data) => this.handleRNRtmpEvent(data)
  );
```

However, there are two events that are especially useful: knowing playback
state changes, and knowing when the first video frame has been rendered.
This is because you can do things like remove a loading screen.

Thus, we have specially pulled out those events and made them actual
function properties of the view.


## Implementation details and alternatives

react-native-rtmpview is based on [KSYLive](https://github.com/ksvc/KSYLive_iOS), which is a popular iOS library for video and RTMP streaming. The complete list of options for RTMP streaming on iOS can be found [here on StackOverflow](https://stackoverflow.com/questions/43872012/ios-rtmp-streaming-library-lflivekit-vs-videocore-lib-vs-alternative), and includes:

* [HaishinKit (formerly lf)](https://github.com/shogo4405/HaishinKit.swift) - This library does not support RTMP playback (technically it does, but only as an '[experimental feature](https://github.com/shogo4405/HaishinKit.swift/issues/358)')
* [LaiFeng iOS Live Kit](https://github.com/LaiFengiOS/LFLiveKit) - Popular library in terms of stars (3k+) but not updated since 2016, so effectively abandoned.
* [VideoCore](https://github.com/jgh-/VideoCore-Inactive) - Popular (1k+ stars), but library abandoned in 2015.
* [react-native-nodemediaclient](https://github.com/NodeMedia/react-native-nodemediaclient) - The underlying native library is very limited and is still emerging in popularity (100+ stars). It does not surface as many playback events or provide as much configurabilty as other RTMP streaming libraries.
* [KSYLive_iOS](https://github.com/ksvc/KSYLive_iOS) - Growing in popularity (500+ stars) and updated very recently (in 2018)

As a result, we elected to base our implementation for RTMP in React Native on the actively-maintained KSYLive_iOS library, because it was both the most full-featured and still actively maintained.

We are actively investigating implementation options for Android.
