FROM ubuntu:20.04
RUN  apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lxde-core lxterminal
RUN apt-get -y install tightvncserver firefox nano wmctrl \
    gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl \
    wget sudo less net-tools iputils-ping && \
    apt-get remove modemmanager -y && rm -rf /var/lib/apt/lists/*

# files for VNC
RUN touch /root/.Xresources
RUN touch /root/.Xauthority
WORKDIR /root
RUN mkdir .vnc

RUN useradd test && \
    usermod -a -G dialout test && \
    mkdir /home/test && \
    chown test /home/test

RUN mkdir /apps && cd /apps &&\
    wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage && \
    chmod a+x QGroundControl.AppImage && \
    chown test /apps && \
    sudo -u test ./QGroundControl.AppImage --appimage-extract && \
    mkdir /root/Desktop

# COPY xstartup with start for lxde
COPY xstartup /root/.vnc/
COPY qgc.sh /usr/local/bin
COPY qgc.sh /root/Desktop

RUN echo "export USER=root" >> /root/.bashrc
ENV USER root
# COPY script. removes Lock files and start tightvncserver
COPY entrypoint.sh /entrypoint.sh
# set password
RUN printf "test\ntest\nn\n" | vncpasswd

EXPOSE 5901
ENTRYPOINT ["/entrypoint.sh" ]
