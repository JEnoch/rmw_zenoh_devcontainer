ARG ROS_DISTRO=rolling

FROM ghcr.io/sloretz/ros:${ROS_DISTRO}-desktop-full

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    python3-pip cargo clang \
    curl less vim jq iputils-ping iproute2 psmisc \
    ros-${ROS_DISTRO}-turtlebot3-gazebo
ENV SHELL=/bin/bash

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
CMD ["/bin/bash"]
