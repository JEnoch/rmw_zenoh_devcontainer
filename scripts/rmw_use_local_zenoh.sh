#!/bin/bash

echo "Patching $ZENOH_VENDOR_CMAKEFILE to use $CONTAINER_WORKSPACE/eclipse-zenoh/..."

# comment VCS_URL and VCS_VERSION
sed -i '/\  VCS_URL/s|^|# |' $ZENOH_VENDOR_CMAKEFILE
sed -i '/\  VCS_VERSION/s|^|# |' $ZENOH_VENDOR_CMAKEFILE

# replace with "VCS_TYPE path" and "VCS_URL /path/to/repo"
sed -i "/#   VCS_URL https:\/\/github.com\/eclipse-zenoh\/zenoh-c.git/a\   VCS_URL $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c" $ZENOH_VENDOR_CMAKEFILE
sed -i "/#   VCS_URL https:\/\/github.com\/eclipse-zenoh\/zenoh-cpp/a\   VCS_URL $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-cpp" $ZENOH_VENDOR_CMAKEFILE
sed -i '/#   VCS_URL/a\   VCS_TYPE path' $ZENOH_VENDOR_CMAKEFILE


echo "Patching $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c to use $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh"

function replace_zenoh_deps()
{
    FILE=$1
    # remove 'version' and 'branch' in each zenoh dep
    perl -i -pe 's|(zenoh.*?)\bversion = ".*?", |$1|' $FILE
    perl -i -pe 's|(zenoh.*?)[, ]*\bbranch = ".*?"|$1|' $FILE

    perl -i -pe 's|(zenoh .*?)\bgit = ".*?"|$1path = "/ros_ws/src/zenoh/zenoh"|' $FILE
    perl -i -pe 's|(zenoh-ext .*?)\bgit = ".*?"|$1path = "/ros_ws/src/zenoh/zenoh-ext"|' $FILE
    perl -i -pe 's|(zenoh-runtime .*?)\bgit = ".*?"|$1path = "/ros_ws/src/zenoh/commons/zenoh-runtime"|' $FILE
    perl -i -pe 's|(zenoh-util .*?)\bgit = ".*?"|$1path = "/ros_ws/src/zenoh/commons/zenoh-util"|' $FILE
    perl -i -pe 's|(zenoh-protocol .*?)\bgit = ".*?"|$1path = "/ros_ws/src/zenoh/commons/zenoh-protocol"|' $FILE
}

CARGO_TOML="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/Cargo.toml"
CARGO_TOML_IN="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/Cargo.toml.in"
OPAQUE_TYPES_CARGO_TOML="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/build-resources/opaque-types/Cargo.toml"

replace_zenoh_deps ${CARGO_TOML}
replace_zenoh_deps ${CARGO_TOML_IN}
replace_zenoh_deps ${OPAQUE_TYPES_CARGO_TOML}
