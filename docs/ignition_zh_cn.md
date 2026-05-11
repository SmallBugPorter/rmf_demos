请注意，此设置在 Ubuntu 20.04 上使用 ROS2 Galactic 和 Ignition Fortress。

1. 首先设置系统依赖项：

    ```
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt-get update
    
    sudo apt install git python3-pip
    
    pip3 install vcstool
    pip3 install -U colcon-common-extensions
    ```

# 二进制安装

设置 Ignition 的最简单方法是从二进制安装：

    ```
    sudo apt install ignition-fortress
    ```

或者，您也可以从源代码安装。

# 源代码安装

1. 从源代码安装 `ignition-fortress`。有关更多详细信息，请参阅 [官方文档](https://gazebosim.org/docs/fortress/install_ubuntu_src#getting-the-sources)

    ```
    mkdir ws_edifice/src -p
    cd ws_edifice
    ```

1. 使用提供的 `ign-fortress.yaml` 文件初始化源：

    ```
    wget https://raw.githubusercontent.com/ignition-tooling/gazebodistro/master/collection-fortress.yaml
    vcs import < collection-fortress.yaml
    ```

1. 从源代码构建并将其添加到 `.bashrc` 中（或在运行任何演示之前记得手动 source）：

    ```
    sudo apt-get install cmake freeglut3-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libdart6-collision-ode-dev libdart6-dev libdart6-utils-urdf-dev libfreeimage-dev libgflags-dev libglew-dev libgts-dev libogre-1.9-dev libogre-2.1-dev libprotobuf-dev libprotobuf-dev libprotoc-dev libqt5core5a libswscale-dev libtinyxml2-dev libtinyxml-dev pkg-config protobuf-compiler python qml-module-qt-labs-folderlistmodel qml-module-qt-labs-settings qml-module-qtquick2 qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtqml-models2 qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev ruby ruby-ronn uuid-dev libzip-dev libjsoncpp-dev libcurl4-openssl-dev libyaml-dev libzmq3-dev libsqlite3-dev libwebsockets-dev swig ruby-dev -y
    
    colcon build --merge-install --symlink-install --cmake-args -DBUILD_TESTING=false
    
    echo "source ~/ws_edifice/install/setup.bash" >> ~/.bashrc
    ```
    
# 启动

要在 ignition 中启动演示，请将 `use_ignition` 参数设置为 1，例如启动办公演示：

  ```bash
  ros2 launch demos office.launch.xml use_ignition:=1
  ```