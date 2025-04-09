
ZENOH_VENDOR_CMAKEFILE=$WS/src/rmw_zenoh/zenoh_cpp_vendor/CMakeLists.txt


function get_zenoh_cpp_commit()
{
    grep -A 3 "ament_vendor(zenoh_cpp_vendor" $ZENOH_VENDOR_CMAKEFILE | grep "VCS_VERSION" | awk '{print $2}'
}

function get_zenoh_c_commit()
{
    grep -A 3 "ament_vendor(zenoh_c_vendor" $ZENOH_VENDOR_CMAKEFILE | grep "VCS_VERSION" | awk '{print $2}'
}

function get_zenoh_commit()
{
    ZENOH_C_COMMIT=$(get_zenoh_c_commit)
    ZENOH_C_URL="https://raw.githubusercontent.com/eclipse-zenoh/zenoh-c/${ZENOH_C_COMMIT}/Cargo.lock"
    curl -s $ZENOH_C_URL -o /tmp/Cargo.lock
    ZENOH_COMMIT=$(grep -A 5 "name = \"zenoh\"" /tmp/Cargo.lock | grep "source" | awk -F '#' '{print $2}' | tr -d '"')
    rm /tmp/Cargo.lock
    echo $ZENOH_COMMIT
}

function print_commit_info()
{
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <project_name> <commit_id>"
        return -1
    fi

    PROJECT=$1
    COMMIT=$2
    URL="https://api.github.com/repos/${PROJECT}/commits/${COMMIT}"
    COMMIT_DATA=$(curl -s $URL)
    DATE_TIME=$(echo $COMMIT_DATA | jq -r '.commit.committer.date')
    MESSAGE=$(echo $COMMIT_DATA | jq -r '.commit.message' | head -n 1)
    PR_NUMBER=$(echo $MESSAGE | grep -oP '(#\d+)' | head -1 | tr -d '(#)')

    echo "  - https://github.com/${PROJECT}/tree/${COMMIT}"
    echo "  - ${DATE_TIME} : ${MESSAGE}"
    echo "  - PR: https://github.com/${PROJECT}/pull/${PR_NUMBER}"
}

function zenoh_commits()
{
    ZENOH_CPP=$(get_zenoh_cpp_commit)
    echo "zenoh-cpp: ${ZENOH_CPP}"
    print_commit_info eclipse-zenoh/zenoh-cpp ${ZENOH_CPP}
    ZENOH_C=$(get_zenoh_c_commit)
    echo "zenoh-c:   ${ZENOH_C}"
    print_commit_info eclipse-zenoh/zenoh-c ${ZENOH_C}
    ZENOH=$(get_zenoh_commit)
    echo "zenoh:     ${ZENOH}"
    print_commit_info eclipse-zenoh/zenoh ${ZENOH}
}

function sync_zenoh_commits()
{
    ZENOH_CPP=$(get_zenoh_cpp_commit)
    echo ""
    echo "zenoh-cpp: checkout $ZENOH_CPP"
    cd $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-cpp
    git checkout $ZENOH_CPP
    cd - > /dev/null

    ZENOH_C=$(get_zenoh_c_commit)
    echo ""
    echo "zenoh-c: checkout $ZENOH_C"
    cd $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh-c
    git checkout $ZENOH_C
    cd - > /dev/null

    ZENOH=$(get_zenoh_commit)
    echo ""
    echo "zenoh: checkout $ZENOH"
    cd $CONTAINER_WORKSPACE/eclipse-zenoh/zenoh
    git checkout $ZENOH
    cd - > /dev/null
}