import React, { Component } from 'react';
import {
  View,
  Text,
  requireNativeComponent,
  NativeModules,
  Dimensions,
  Platform,
} from 'react-native';
import PropTypes from 'prop-types';

let FastCamera, FastCameraMethods;
if (Platform.OS === 'ios') {
  FastCamera = requireNativeComponent('FastCamera');
  FastCameraMethods = NativeModules.FastCamera;
}

const { width, height } = Dimensions.get('window');

const androidCamera = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <Text style={{ fontSize: 18, color: 'red' }}>android not supported yet!</Text>
  </View>
);

const iOSCamera = (props) => {
  console.log('props::: ', props);
  return (
    <View style={{ }}>
      <FastCamera
        style={{ height, width }}
        onSaveSuccess={data => {
          // console.log('onSaveSuccess: ', data.nativeEvent);
          props.onSaveSuccess ? props.onSaveSuccess(data.nativeEvent.image) : null;
        }}
        onGalleryImage={data => {
          // console.log('onGalleryImage: ', data.nativeEvent);
          props.onGalleryImage ? props.onGalleryImage(data.nativeEvent.image) : null;
        }}
        onFlashToggle={data => {
          // console.log('flash info: ', data.nativeEvent);
          props.onFlashToggle ? props.onFlashToggle(data.nativeEvent.isflashOn) : null;
        }}
      />
      {props.children}
    </View>
  );
}

class MyFastCamera extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showSelectedPictureOptions: false, // set when the user select or take a picture.
      imageInfo: null,
      modalVisible: false,
    };
  }

  render() {
    return Platform.OS === 'ios' ? iOSCamera(this.props) : androidCamera(this.props);
  }
}

MyFastCamera.propTypes = {
  onSaveSuccess: PropTypes.func,
  onGalleryImage: PropTypes.func,
  onFlashToggle: PropTypes.func,
};

export default MyFastCamera;

export const Methods = FastCameraMethods;
