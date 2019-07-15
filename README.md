
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

This library now works with Android clients. In your project's `settings.gradle` file, add:

    include ':react-native-rtmpview'
    project(':react-native-rtmpview').projectDir = new File(rootProject.projectDir, '<path_to>/node_modules/react-native-rtmpview/android')

Then, in your `ReactApplication` class, make sure that the `getPackages()` method includes:

    new RNRtmpViewPackage()

For example:

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          // other packages...
            new RNRtmpViewPackage()
      );
    }


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

export default class Example extends Component {
  componentDidMount() {
    this.player.initialize();
  }
  
  render() {
    return (
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
          url="rtmp://localhost:1935/live/stream"
        />
    )
  }
}

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

react-native-rtmpview is designed to use the best-of-breed RTMP playback libraries on both iOS and Android.


### iOS
On iOS, react-native-rtmpview is based on [KSYLive](https://github.com/ksvc/KSYLive_iOS), which is a popular iOS library for video and RTMP streaming. The complete list of options for RTMP streaming on iOS can be found [here on StackOverflow](https://stackoverflow.com/questions/43872012/ios-rtmp-streaming-library-lflivekit-vs-videocore-lib-vs-alternative), and includes:

* [HaishinKit (formerly lf)](https://github.com/shogo4405/HaishinKit.swift) - This library does not support RTMP playback (technically it does, but only as an '[experimental feature](https://github.com/shogo4405/HaishinKit.swift/issues/358)')
* [LaiFeng iOS Live Kit](https://github.com/LaiFengiOS/LFLiveKit) - Popular library in terms of stars (3k+) but not updated since 2016, so effectively abandoned.
* [VideoCore](https://github.com/jgh-/VideoCore-Inactive) - Popular (1k+ stars), but library abandoned in 2015.
* [react-native-nodemediaclient](https://github.com/NodeMedia/react-native-nodemediaclient) - The underlying native library is very limited and is still emerging in popularity (100+ stars). It does not surface as many playback events or provide as much configurabilty as other RTMP streaming libraries.
* [VLCKit](https://code.videolan.org/videolan/VLCKit) - Publishes MobileVLCKit, which does work in iOS, but does not give enough configuration options and does not allow customization of the video buffer. This makes the library unreliable when playing back an RTMP stream that is flaky and leads to an extreme lag between the playback time and the live video time.
* [KSYLive_iOS](https://github.com/ksvc/KSYLive_iOS) - Growing in popularity (500+ stars) and updated very recently (in 2018)

As a result, we elected to base our implementation for RTMP in React Native on the actively-maintained KSYLive_iOS library, because it was both the most full-featured and still actively maintained.

You will note that KSYLive itself publishes their own react native wrapper, which you will find at:
[https://github.com/ksvc/react-native-video-player](https://github.com/ksvc/react-native-video-player)

This is also of course a viable option for integrating an RTMP playback view within iOS and Android, however, this requires you to use the Kingsoft implementation on Android as well. Our library does NOT use Kingsoft for its Android implementation.

### Android

On Android, react-native-rtmpview is based on [ExoPlayer](https://github.com/google/ExoPlayer), which is supported and actively maintained by Google. ExoPlayer is a general-purpose media playback library, and in [version 2.5 added](https://medium.com/google-exoplayer/exoplayer-2-5-whats-new-b508c0ab606f) the [LibRtmp client for Android](https://github.com/ant-media/LibRtmp-Client-for-Android).

Because of this, we felt that the ExoPlayer / LibRTMP solution was the obvious choice when implementing Android support. Clients of react-native-rtmpview will get best-of-breed player solutions on both platforms. 

## About the example configuration

You will note in the Example/package.json file that we have an explicit dependency on react-native-rtmpview:

```
  "react-native-rtmpview": "*"
```

We do not have a relative dependency (i.e.,

```
  "react-native-rtmpview": "file:.."
```

Relative dependencies are created by running `npm -i ../` and they create a symoblic link (`ln -s`) inside of `node_modules/<your_library>/`, and are preferable because changes you make at the root of your project in the actual source code of your library are immediately reflected within your Example project, thus making development of your library easier.

We cannot do this; instead we must have a complete and unconnected copy of the project within `Example/node_modules/`. This means if you use the Example project to test/debug react-native-rtmpview, you will have to make those changes to code buried within `Example/node_modules/react-native-rtmpview`, and manually apply or copy those changes up one level at the root of the project.

We are required to use this architecture because if you create a relative link, every time you launch the app by running `react-native run-ios`, you will see a redbox stating:

```
"Unable to resolve module `react` from `<path>`: Module does not exist in the module map."
```

I have confirmed that this also plagues other apps with Example directories architected similiarly, including [react-native-twilio-video-webrtc](https://github.com/blackuy/react-native-twilio-video-webrtc)

There is [some chatter online](https://github.com/wix/wml/issues/14) about how to use wml to address this problem, but I was unable to get it working.

Thus, until React improves its module resolution process, we will be forced to manually copy over changes made while developing using the Example project.
