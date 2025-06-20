#!/bin/bash

ZENOH_VENDOR_CMAKEFILE=$WS/src/rmw_zenoh/zenoh_cpp_vendor/CMakeLists.txt

echo "Patching $ZENOH_VENDOR_CMAKEFILE to use $CONTAINER_WORKSPACE/eclipse-zenoh/..."

# comment VCS_URL and VCS_VERSION
sed -i '/\  VCS_URL/s|^|# |' $ZENOH_VENDOR_CMAKEFILE
sed -i '/\  VCS_VERSION/s|^|# |' $ZENOH_VENDOR_CMAKEFILE

# replace with "VCS_TYPE path" and "VCS_URL /path/to/repo"
sed -i "/#   VCS_URL https:\/\/github.com\/eclipse-zenoh\/zenoh-c.git/a\   VCS_URL $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c" $ZENOH_VENDOR_CMAKEFILE
sed -i "/#   VCS_URL https:\/\/github.com\/eclipse-zenoh\/zenoh-cpp/a\   VCS_URL $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-cpp" $ZENOH_VENDOR_CMAKEFILE
sed -i '/#   VCS_URL/a\   VCS_TYPE path' $ZENOH_VENDOR_CMAKEFILE

# comment PATCHES which is not compatible with usage of VCS_TYPE path
sed -i '/\  PATCHES/s|^|# |' $ZENOH_VENDOR_CMAKEFILE

zenoh-c_use_local_zenoh.sh
