#!/bin/bash

# Test that the prefab binary exists
if hash prefab 2>/dev/null; then
  echo "Prefab is installed"
else
  echo "Prefab binary not found. See https://github.com/google/prefab for install instructions"
  exit 1
fi

echo "Building libraries for FluidSynth"
./build_all_android.sh

# Get the version string from the source
major=$(grep "#define FLUIDSYNTH_VERSION_MAJOR" include/fluidsynth/version.h | cut -d' ' -f3)
minor=$(grep "#define FLUIDSYNTH_VERSION_MINOR" include/fluidsynth/version.h | cut -d' ' -f3)
patch=$(grep "#define FLUIDSYNTH_VERSION_MICRO" include/fluidsynth/version.h | cut -d' ' -f3)
version=$major"."$minor"."$patch

mkdir -p build/prefab
cp -R prefab/* build/prefab

ABIS=("x86" "x86_64" "arm64-v8a" "armeabi-v7a")

pushd build/prefab

  # Remove .DS_Store files as these will cause the prefab verification to fail
  find . -name ".DS_Store" -delete

  # Write the version number into the various metadata files
  mv fluidsynth-VERSION fluidsynth-$version
  mv fluidsynth-VERSION.pom fluidsynth-$version.pom
  sed -i '' -e "s/VERSION/${version}/g" fluidsynth-$version.pom fluidsynth-$version/prefab/prefab.json

  # Copy the headers
  pushd ../..
  find include -name '*.h' | cpio -pdm build/prefab/fluidsynth-$version/prefab/modules/fluidsynth/
  popd

  # Copy the libraries
  for abi in ${ABIS[@]}
  do
    echo "Copying the ${abi} library"
    cp -v "../../lib/${abi}/libfluidsynth.so" "fluidsynth-${version}/prefab/modules/fluidsynth/libs/android.${abi}/"
  done

  # Verify the prefab packages
  for abi in ${ABIS[@]}
  do

    prefab --build-system cmake --platform android --os-version 29 \
        --stl c++_shared --ndk-version 21 --abi ${abi} \
        --output prefab-output-tmp $(pwd)/fluidsynth-${version}/prefab

    result=$?; if [[ $result == 0 ]]; then
      echo "${abi} package verified"
    else
      echo "${abi} package verification failed"
      exit 1
    fi
  done

  # Zip into an AAR and move into parent dir
  pushd fluidsynth-${version}
    zip -r fluidsynth-${version}.aar . 2>/dev/null;
    zip -Tv fluidsynth-${version}.aar 2>/dev/null;

    # Verify that the aar contents are correct (see output below to verify)
    result=$?; if [[ $result == 0 ]]; then
      echo "AAR verified"
    else
      echo "AAR verification failed"
      exit 1
    fi

    mv fluidsynth-${version}.aar ..
  popd

  # Zip the .aar and .pom files into a maven package
  zip fluidsynth-${version}.zip fluidsynth-${version}.* 2>/dev/null;
  zip -Tv fluidsynth-${version}.zip 2>/dev/null;

  # Verify that the zip contents are correct (see output below to verify)
  result=$?; if [[ $result == 0 ]]; then
    echo "Zip verified"
  else
    echo "Zip verification failed"
    exit 1
  fi
popd

echo "Prefab zip ready for deployment: ./build/prefab/fluidsynth-${version}.zip"