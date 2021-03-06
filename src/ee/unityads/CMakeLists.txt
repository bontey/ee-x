#/****************************************************************************
# Copyright (c) 2013-2014 cocos2d-x.org
# Copyright (c) 2015-2017 Chukong Technologies Inc.
#
# http://www.cocos2d-x.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ****************************************************************************/
cmake_minimum_required(VERSION 3.1)

# project(ee_x_unityads)

include_directories(
  third_party/nlohmann/include
  src/ee/unityads/internal
  src/ee/unityads
)

set(EE_X_UNITY_ADS_SRC
  src/ee/unityads/internal/UnityInterstitialAd.cpp
  src/ee/unityads/internal/UnityRewardedVideo.cpp
  src/ee/unityads/UnityAdsBridge.cpp
)

set(EE_X_UNITY_ADS_HEADERS
  src/ee/unityads/internal/UnityInterstitialAd.hpp
  src/ee/unityads/internal/UnityRewardedVideo.hpp
  src/ee/unityads/UnityAdsBridge.hpp
)

# add_library(${PROJECT_NAME} ${LIB_SRC} ${LIB_HEADERS})

# target_link_libraries(${PROJECT_NAME}
#   ee_x_ads
# )