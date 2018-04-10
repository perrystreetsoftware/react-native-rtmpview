
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
