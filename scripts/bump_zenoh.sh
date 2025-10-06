#!/bin/bash

source $(dirname "$0")/functions.sh

ZENOH_TAG=${1:-main}

echo "Setting rmw_zenoh to use zenoh tag $ZENOH_TAG"

get_commit_id eclipse-zenoh/zenoh-cpp $ZENOH_TAG
get_commit_id eclipse-zenoh/zenoh-c $ZENOH_TAG
get_commit_id eclipse-zenoh/zenoh $ZENOH_TAG


NEW_ZENOH_CPP_COMMIT=$(get_commit_id eclipse-zenoh/zenoh-cpp $ZENOH_TAG)
NEW_ZENOH_C_COMMIT=$(get_commit_id eclipse-zenoh/zenoh-c $ZENOH_TAG)
NEW_ZENOH_COMMIT=$(get_commit_id eclipse-zenoh/zenoh $ZENOH_TAG)

OLD_ZENOH_CPP_COMMIT=$(get_zenoh_cpp_commit)
OLD_ZENOH_C_COMMIT=$(get_zenoh_c_commit)
OLD_ZENOH_COMMIT=$(get_zenoh_commit)

echo "Bumping Zenoh to $ZENOH_TAG:"
echo " - zenoh:     $OLD_ZENOH_COMMIT -> $NEW_ZENOH_COMMIT"
echo " - zenoh-c:   $OLD_ZENOH_C_COMMIT -> $NEW_ZENOH_C_COMMIT"
echo " - zenoh-cpp: $OLD_ZENOH_CPP_COMMIT -> $NEW_ZENOH_CPP_COMMIT"
echo "Proceed ? (y/n)"
read PROCEED
if [ "$PROCEED" != "y" ]; then
    echo "Aborting"
    exit 0
fi

# Update zenoh_cpp_vendor/CMakeLists.txt
echo "Replacing commits in $ZENOH_VENDOR_CMAKEFILE:"
sed -i "s|$OLD_ZENOH_CPP_COMMIT|$NEW_ZENOH_CPP_COMMIT|g" "$ZENOH_VENDOR_CMAKEFILE"
sed -i "s|$OLD_ZENOH_C_COMMIT|$NEW_ZENOH_C_COMMIT|g" "$ZENOH_VENDOR_CMAKEFILE"

# Sync zenoh-cpp, zenoh-c and zenoh to those commits
echo "Syncing zenoh-cpp, zenoh-c and zenoh to those commits"
sync_zenoh_commits

# Create PR message
echo "Creating PR message in PR_bump_zenoh_${ZENOH_TAG}.md"
cat > PR_bump_zenoh_${ZENOH_TAG}.md << EOF
## Description

Bump Zenoh to [${ZENOH_TAG}](https://github.com/eclipse-zenoh/zenoh/releases/tag/${ZENOH_TAG}), making the following changes of commit ids:

- zenoh-cpp: [${OLD_ZENOH_CPP_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh-cpp/commit/${OLD_ZENOH_CPP_COMMIT}) -> [${NEW_ZENOH_CPP_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh-cpp/commit/${NEW_ZENOH_CPP_COMMIT}) -  [diff](https://github.com/eclipse-zenoh/zenoh-cpp/compare/${OLD_ZENOH_CPP_COMMIT}...${NEW_ZENOH_CPP_COMMIT})
- zenoh-c: [${OLD_ZENOH_C_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh-c/commit/${OLD_ZENOH_C_COMMIT}) -> [${NEW_ZENOH_C_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh-c/commit/${NEW_ZENOH_C_COMMIT}) - [diff](https://github.com/eclipse-zenoh/zenoh-c/compare/${OLD_ZENOH_C_COMMIT}...${NEW_ZENOH_C_COMMIT})
- zenoh: [${OLD_ZENOH_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh/commit/${OLD_ZENOH_COMMIT}) -> [${NEW_ZENOH_COMMIT:0:7}](https://github.com/eclipse-zenoh/zenoh/commit/${NEW_ZENOH_COMMIT}) - [diff](https://github.com/eclipse-zenoh/zenoh/compare/${OLD_ZENOH_COMMIT}...${OLD_ZENOH_COMMIT})

It includes those notable changes:

EOF

# Print list of PRs for each project

function list_prs()
{
    PROJECT=$1
    OLD_COMMIT=$2
    NEW_COMMIT=$3

    echo "### ${PROJECT}"
    echo ""

    cd $CONTAINER_WORKSPACE/eclipse-zenoh/$PROJECT
    git log --oneline "$OLD_COMMIT..$NEW_COMMIT" \
        | tac \
        | sed -E "s|^([a-f0-9]+) (.*) \(#([0-9]+)\)|* \2 \n  - https://github.com/eclipse-zenoh/${PROJECT}/pull/\3|g"
    cd - > /dev/null
    echo ""
}

list_prs zenoh $OLD_ZENOH_COMMIT $NEW_ZENOH_COMMIT >> PR_bump_zenoh_${ZENOH_TAG}.md
list_prs zenoh-c $OLD_ZENOH_C_COMMIT $NEW_ZENOH_C_COMMIT >> PR_bump_zenoh_${ZENOH_TAG}.md
list_prs zenoh-cpp $OLD_ZENOH_CPP_COMMIT $NEW_ZENOH_CPP_COMMIT >> PR_bump_zenoh_${ZENOH_TAG}.md
