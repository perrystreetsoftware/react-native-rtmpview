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
    this.player.initialize();
  }

  render() {
    return (
      <View style={styles.container}>
      <RtmpView
        style={styles.player}
        shouldMute={false}
        ref={e => { this.player = e; }}
        onPlaybackState={(data) => {
          this.handlePlaybackState(data);
        }}
        onLoadState={(data) => {
          this.handleLoadState(data);
        }}
        onFirstVideoFrameRendered={(data) => {
          this.handleFirstVideoFrameRendered(data);
        }}
        onBitrateRecalculated={(data) => {
          this.handleBitrateRecalculated(data);
        }}
        url="rtmp://stream1.livestreamingservices.com:1935/tvmlive/tvmlive"/>

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
