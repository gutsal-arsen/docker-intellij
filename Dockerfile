FROM picoded/ubuntu-openjdk-8-jdk:16.04 

MAINTAINER Florin Patan "florinpatan@gmail.com"

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV INTELLIJ_VERSION .IntelliJIdea2017.2

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing \
        sudo \
        software-properties-common \
        git \
        libxext-dev \
        libxrender-dev \
        libxslt1.1 \
        libxtst-dev \
        libgtk2.0-0 \
        libcanberra-gtk-module \
        unzip \
        wget \
        && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN echo 'Creating user: developer' && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    sudo echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    sudo chmod 0440 /etc/sudoers.d/developer && \
    sudo chown developer:developer -R /home/developer && \
    sudo chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo

RUN mkdir -p /home/developer/${INTELLIJ_VERSION}/config/options && \
    mkdir -p /home/developer/${INTELLIJ_VERSION}/config/plugins

ADD ./jdk.table.xml /home/developer/${INTELLIJ_VERSION}/config/options/jdk.table.xml
ADD ./jdk.table.xml /home/developer/.jdk.table.xml

ADD ./run /usr/local/bin/intellij

RUN chmod +x /usr/local/bin/intellij && \
    chown developer:developer -R /home/developer/${INTELLIJ_VERSION}

RUN echo 'Downloading IntelliJ IDEA' && \
    wget https://download-cf.jetbrains.com/idea/ideaIU-2017.2.5.tar.gz -O /tmp/intellij.tar.gz -q && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz

RUN sudo chown developer:developer -R /home/developer

USER developer
ENV HOME /home/developer
WORKDIR /home/developer/prog
CMD /usr/local/bin/intellij
