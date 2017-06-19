#!/bin/bash
#  IBM_PROLOG_BEGIN_TAG
#  This is an automatically generated prolog.
#
#  $Source: src/build/install/resources/gtest_add.sh $
#
# IBM Data Engine for NoSQL - Power Systems Edition User Library Project
#
# Contributors Listed Below - COPYRIGHT 2014,2015
# [+] International Business Machines Corp.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# IBM_PROLOG_END_TAG

# updates src/test/framework/googletest with 1.7.0

if [[ -z ${SURELOCKROOT} ]]; then echo ". ./env.bash, then rerun"; exit -1; fi
cd ${SURELOCKROOT}
if [[ -e src/test/framework/googletest ]]; then rm -fR src/test/framework/googletest; fi
wget https://github.com/google/googletest/archive/release-1.7.0.tar.gz
tar -zxf release-1.7.0.tar.gz
mkdir src/test/framework/googletest
mv googletest-release-1.7.0 src/test/framework/googletest/googletest
rm release-1.7.0.tar.gz

