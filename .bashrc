export WS=$CONTAINER_WORKSPACE/ros_ws
export PATH=$PATH:$CONTAINER_WORKSPACE/scripts

echo "source /opt/ros/$ROS_DISTRO/setup.bash"
source /opt/ros/$ROS_DISTRO/setup.bash

echo "source $WS/install/setup.bash"
source $WS/install/setup.bash

export RMW_IMPLEMENTATION=rmw_zenoh_cpp


###########
# ALIASES and FUNCTIONS#
###########
alias ll='ls -al'
source $CONTAINER_WORKSPACE/scripts/functions.sh

echo ROS_DISTRO=$ROS_DISTRO
echo RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION
echo CONTAINER_WORKSPACE=$CONTAINER_WORKSPACE
echo CONTAINER_WORKSPACE=$CONTAINER_WORKSPACE

cd $WS