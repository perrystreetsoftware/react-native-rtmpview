//
//  IVSPlayerView.js
//
//  Created by Eric Silverberg on 2020/11/01.
//  Copyright © 2020 Perry Street Software. All rights reserved.
//

import React, { Component } from 'react';
import { PropTypes } from 'prop-types';
import { requireNativeComponent, View, UIManager, findNodeHandle } from 'react-native';

var RCT_IVS_VIDEO_REF = 'IVSPlayerView';

class IVSPlayerView extends Component {
  constructor(props) {
    super(props);
  }

  _onDidChangeState = (event) => {
    if (!this.props.onDidChangeState) {
      return;
    }
    this.props.onDidChangeState(event.nativeEvent)
  }

  initialize() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_IVS_VIDEO_REF]),
      UIManager.getViewManagerConfig('RNIVSPlayerView').Commands.initialize,
      null
    );
  }

  pause() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_IVS_VIDEO_REF]),
      UIManager.getViewManagerConfig('RNIVSPlayerView').Commands.pause,
      null
    );
  }

  load(urlString) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.refs[RCT_IVS_VIDEO_REF]),
      UIManager.getViewManagerConfig('RNIVSPlayerView').Commands.load,
      [urlString]
    );
  }

  render() {
    return <RNIVSPlayerView
      ref={RCT_IVS_VIDEO_REF}
      onLoadState={this._onDidChangeState.bind(this)}
      {...this.props}
    />;
  };
}

IVSPlayerView.name = RCT_IVS_VIDEO_REF;
IVSPlayerView.propTypes = {
  url: PropTypes.string,
  ...View.propTypes
};

const RNIVSPlayerView = requireNativeComponent('RNIVSPlayerView', IVSPlayerView, {
});

module.exports = IVSPlayerView;
