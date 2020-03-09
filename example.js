/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
} from 'react-native';

import FastCamera, { Methods } from 'react-native-fast-camera';

const Item = (props) => (
  <TouchableOpacity
    style={{ justifyContent: 'center', alignItems: 'center' }}
    onPress={props.onPress}
  >
    <Text style={{ color: 'white' }}>{props.text}</Text>
  </TouchableOpacity>
);

const App: () => React$Node = () => {

  console.log('camera component: ', FastCamera);

  return (
    <FastCamera
      onSaveSuccess={imageUrl => {
        console.log('onSaveSuccess: ', imageUrl);
      }}
      onGalleryImage={imageUrl => {
        console.log('onGalleryImage: ', imageUrl);
      }}
      onFlashToggle={isflashOn => {
        console.log('flash info: ', isflashOn);
      }}
    >
      <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0 }}>
        <View style={{ padding: 10, flexDirection: 'row', justifyContent: 'space-between', backgroundColor: 'rgba(0,0,0,0.3)' }}>
          <Item
            onPress={() => { Methods.timer(); }}
            text="Timer"
          />
          <Item
            onPress={() => { Methods.toggleFlash(); }}
            text="Flash"
          />

          <TouchableOpacity
            style={{ justifyContent: 'center', alignItems: 'center' }}
            onPress={() => {
              Methods.takePicture();
            }}
          >
            <View style={{ width: 70, height: 70, borderRadius: 35, backgroundColor: '#FFF', justifyContent: 'center', alignItems: 'center' }}>
              <View style={{ width: 55, height: 55, borderRadius: 27.5, backgroundColor: '#D5D6EA' }} />
            </View>
          </TouchableOpacity>
          <Item
            onPress={() => { Methods.pickImage(); }}
            text="Gallery"
          />
          <Item
            onPress={() => { Methods.flipCamera(); }}
            text="Flip"
          />
        </View>
      </View>
    </FastCamera>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
});

export default App;
