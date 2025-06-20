#!/bin/bash

echo "Patching $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c to use $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh"

function replace_zenoh_deps()
{
    FILE=$1
    # remove 'version' and 'branch' in each zenoh dep
    perl -i -pe 's|(zenoh.*?)\bversion = ".*?", |$1|' $FILE
    perl -i -pe 's|(zenoh.*?)[, ]*\bbranch = ".*?"|$1|' $FILE

    perl -i -pe 's|(zenoh .*?)\bgit = ".*?"|$1path = "'"$CONTAINER_WORKSPACE"'/eclipse-zenoh/zenoh/zenoh"|' $FILE
    perl -i -pe 's|(zenoh-ext .*?)\bgit = ".*?"|$1path = "'"$CONTAINER_WORKSPACE"'/eclipse-zenoh/zenoh/zenoh-ext"|' $FILE
    perl -i -pe 's|(zenoh-runtime .*?)\bgit = ".*?"|$1path = "'"$CONTAINER_WORKSPACE"'/eclipse-zenoh/zenoh/commons/zenoh-runtime"|' $FILE
    perl -i -pe 's|(zenoh-util .*?)\bgit = ".*?"|$1path = "'"$CONTAINER_WORKSPACE"'/eclipse-zenoh/zenoh/commons/zenoh-util"|' $FILE
    perl -i -pe 's|(zenoh-protocol .*?)\bgit = ".*?"|$1path = "'"$CONTAINER_WORKSPACE"'/eclipse-zenoh/zenoh/commons/zenoh-protocol"|' $FILE
}


CARGO_TOML="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/Cargo.toml"
CARGO_TOML_IN="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/Cargo.toml.in"
OPAQUE_TYPES_CARGO_TOML="$CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c/build-resources/opaque-types/Cargo.toml"

replace_zenoh_deps ${CARGO_TOML}
replace_zenoh_deps ${CARGO_TOML_IN}
replace_zenoh_deps ${OPAQUE_TYPES_CARGO_TOML}
