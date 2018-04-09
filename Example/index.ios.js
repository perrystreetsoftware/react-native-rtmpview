/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  NativeModules,
  NativeEventEmitter,
  Button,
  View
} from 'react-native';
import { RtmpView } from 'react-native-rtmpview';

export default class Example extends Component {
  constructor(props, context) {
    super(props, context);
    this.player = null;


    const RNRtmpEventManager =
      NativeModules.RNRtmpEventManager;

    if (!(typeof RNRtmpEventManager === "undefined")) {
      const RNRtmpEventManager = new NativeEventEmitter(
        NativeModules.RNRtmpEventManager
      );

      RNRtmpEventManager.addListener(
        "RNRtmpEvent",
        (data) => this.handleRNRtmpEvent(data)
      );

      console.log("React Native Received: Just finished adding listeners");
    }
  }

  handlePlaybackState(data) {
    console.log(
      "React Native Received PlaybackState " + JSON.stringify(data)
    );

    // debugger;
    // this.player.rawClass();
    // this.player.playbackState(function(args) {
    //   console.log("Playback state is " + JSON.stringify(args));
    // });
  }

  handleRNRtmpEvent(data) {
    console.log(
      "React Native Received RNRtmpEventManager " + JSON.stringify(data)
    );

    // this.player.rawClass();
    // this.player.playbackState(function(args) {
    //   console.log("Playback state is " + JSON.stringify(args));
    // });
  }

  render() {
    return (
      <View style={styles.container}>
      <RtmpView
        style={styles.player}
        ref={e => { this.player = e; }}
        onPlaybackState={(data) => {
          this.handlePlaybackState(data);
        }}
        url="rtmp://live.hkstv.hk.lxdns.com/live/hks"/>

      <Button
        onPress={() => {
          this.player.pause()
        }}
        title="Pause"
      />
      <Button
        onPress={() => {
          this.player.play()
        }}
        title="Play"
      />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  player: {
    width: 200,
    height: 200
  }
});

AppRegistry.registerComponent('Example', () => Example);
