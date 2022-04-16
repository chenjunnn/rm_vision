#!/bin/zsh

# Clone config repo if it doesn't exist
if [ ! "$(ls -A /root/ros_ws/src/rm_pioneer_config)" ]; then
    git clone https://github.com/chenjunnn/rm_pioneer_config -b ${ROBOT} src/rm_pioneer_config
else
    export ROBOT=$(git -C src/rm_pioneer_config branch --show-current)
fi

case $ROBOT in
    hero)
        export ROS_DOMAIN_ID=1
        camera_type = mindvision
        ;;
    standard3)
        export ROS_DOMAIN_ID=3
        camera_type = mindvision
        ;;
    standard4)
        export ROS_DOMAIN_ID=4
        camera_type = hik
        ;;
    standard5)
        export ROS_DOMAIN_ID=5
        camera_type = mindvision
        ;;
    guard)
        export ROS_DOMAIN_ID=6
        camera_type = mindvision
        ;;
    *)
        echo "Unknown robot type: $ROBOT"
        ;;
esac

if [ ! "$(ls -A /root/ros_ws/src/ros2_${camera_type}_camera)" ]; then
    case $camera_type in
        mindvision)
            git clone https://github.com/chenjunnn/ros2_mindvision_camera.git src/ros2_hik_camera
            ;;
        hik)
            git clone https://github.com/nolem-77/ros2_hik_camera.git src/ros2_mindvision_camera
            export MVCAM_SDK_PATH=src/ros2_hik_camera/hikSDK
            export MVCAM_COMMON_RUNENV=src/ros2_hik_camera/hikSDK/lib
            export LD_LIBRARY_PATH=src/ros2_hik_camera/hikSDK/lib:$LD_LIBRARY_PATH
            ;;
        *)
            echo "Unknown camera type: $camera_type"
            ;;
fi

source /opt/ros/galactic/setup.zsh
colcon build --symlink-install --packages-select rm_pioneer_description rm_pioneer_bringup

exec "$@"
