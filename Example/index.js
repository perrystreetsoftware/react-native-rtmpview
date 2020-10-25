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
import { IVSPlayerView } from 'react-native-rtmpview';

export default class Example extends Component {
  constructor(props, context) {
    super(props, context);
    this.player = null;


    // const RNRtmpEventManager =
    //   NativeModules.RNRtmpEventManager;

    // if (!(typeof RNRtmpEventManager === "undefined")) {
    //   const RNRtmpEventManager = new NativeEventEmitter(
    //     NativeModules.RNRtmpEventManager
    //   );

    //   RNRtmpEventManager.addListener(
    //     "RNRtmpEvent",
    //     (data) => this.handleRNRtmpEvent(data)
    //   );

    //   console.log("React Native Received: Just finished adding listeners");
    // }
  }

  handlePlaybackState(data) {
    console.log(
      "React Native Received PlaybackState " + data.nativeEvent["state"]
    );
  }

  handleLoadState(data) {
    console.log(
      "React Native Received LoadState " + data.nativeEvent["state"]
    );
    console.log(
      "React Native Received LoadState Qos " + JSON.stringify(data.nativeEvent["qos"])
    );
  }

  handleFirstVideoFrameRendered(data) {
    console.log(
      "React Native Received FirstVideoFrameRendered"
    );

    this.player.unmute();
  }

  handleBitrateRecalculated(data) {
    console.log(
      "React Native BitrateRecalculated " + JSON.stringify(data.nativeEvent["bitrate"])
    );
  }

  handleRNRtmpEvent(data) {
    console.log(
      "React Native Received RNRtmpEventManager " + JSON.stringify(data)
    );
  }

  componentDidMount() {
    // this.player.initialize();
  }

  render() {
    return (
      <View style={styles.container}>
        <IVSPlayerView
          style={styles.player}
          ref={e => { this.player = e; }} />
        <Button
          onPress={() => {
            this.player.pause()
          }}
          title="Pause"
        />
        <Button
          onPress={() => {
            this.player.load("https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
          }}
          title="Play"
        />
        <Button
          onPress={() => {
            this.player.mute()
          }}
          title="Mute"
        />
        <Button
          onPress={() => {
            this.player.unmute()
          }}
          title="Unmute"
        />
        <Button
          onPress={() => {
            this.player.stop()
          }}
          title="Stop"
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
    width: '100%',
    height: '50%'
  }
});

AppRegistry.registerComponent('Example', () => Example);
