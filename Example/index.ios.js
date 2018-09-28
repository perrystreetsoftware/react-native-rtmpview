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
  }

  handleFirstVideoFrameRendered(data) {
    console.log(
      "React Native Received FirstVideoFrameRendered"
    );

    this.player.unmute();
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
        shouldMute={true}
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
        url="rtmp://edge-lb-b97e24af79104e09.elb.us-east-1.amazonaws.com:1935/edge/tune_in"/>

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
