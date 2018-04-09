
# react-native-rtmpview

## Getting started

`$ npm install git+https://git@github.com/perrystreetsoftware/react-native-rtmpview.git --save`

### iOS installation

Find your iOS podfile, and add:

    pod 'Yoga', path: '../node_modules/react-native/ReactCommon/yoga/Yoga.podspec'
    pod 'React', path: '../node_modules/react-native'
    pod 'react-native-rtmpview', :path => '../node_modules/react-native-rtmpview'

Next, run 

    pod install

Because this library has pod dependencies, it must be added through Cocoapods; you cannot use `link`

## Usage
```javascript

import { RtmpView } from 'react-native-rtmpview';

<RtmpView
  style={styles.player}
  ref={e => { this.player = e; }}
  onPlaybackState={(data) => {
    this.handlePlaybackState(data);
  }}
  url="rtmp://live.hkstv.hk.lxdns.com/live/hks"/>

```
