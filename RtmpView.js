//
//  RtmpView.js
//
//  Created by Eric Silverberg on 2018/04/07.
//  Copyright © 2018 Perry Street Software. All rights reserved.
//

import React, { Component } from 'react';
import { PropTypes } from 'prop-types';
import { requireNativeComponent, View, UIManager, findNodeHandle } from 'react-native';

var RCT_VIDEO_REF = 'RtmpView';

class RtmpView extends Component {
  constructor(props) {
    super(props);
  }

  _onPlaybackState = (event) => {
    if (!this.props.onPlaybackState) {
      return;
    }
    this.props.onPlaybackState(event.nativeEvent)
  }

  pause() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_VIDEO_REF]),
      UIManager.RNRtmpView.Commands.pause,
      null
    );
  }

  play() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_VIDEO_REF]),
      UIManager.RNRtmpView.Commands.play,
      null
    );
  }

  stop() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_VIDEO_REF]),
      UIManager.RNRtmpView.Commands.stop,
      null
    );
  }

  getPlaybackState() {

  }

  componentWillUnmount() {
      console.log('componentWillUnmount', this.route.name);
      this.stop()
  }

  render() {
    return <RNRtmpView
      ref={RCT_VIDEO_REF}
      {...this.props}
      onPlaybackState={this._onPlaybackState.bind(this)}
    />;
  };
}

RtmpView.name = RCT_VIDEO_REF;
RtmpView.propTypes = {
  url: PropTypes.string,
  onPlaybackState: PropTypes.func,
  ...View.propTypes
};

const RNRtmpView = requireNativeComponent('RNRtmpView', RtmpView, {
});

module.exports = RtmpView;
