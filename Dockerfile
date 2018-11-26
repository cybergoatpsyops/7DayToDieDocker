FROM ubuntu:latest
MAINTAINER cyberGoatPsyOps

# Install dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -q -y wget lib32gcc1 telnet

# Create workspace for server
WORKDIR /home/

# Downloading Steamcmd and extract to steamcmd folder
RUN wget http://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN mkdir ./steamcmd && tar -xvzf steamcmd_linux.tar.gz -C ./steamcmd

# Downloading 7Days lastest experimental Server build
RUN mkdir -p /home/steam/
RUN /home/steamcmd/steamcmd.sh \
	+login anonymous \
	+force_install_dir /home/steamcmd/7dtd_server \
	+app_update 294420 -validate -beta latest_experimental \
	+quit

# Copy serverconfig into dockercontainer
RUN mkdir -p /root/.local/share/7DaysToDie/Saves
COPY serverconfig.xml ./steamcmd/7dtd_server
COPY serveradmin.xml /root/.local/share/7DaysToDie/Saves/

VOLUME ["/steamcmd/7dtd_server/data"]

EXPOSE 8080-8082/tcp
EXPOSE 26900/tcp
EXPOSE 26900-26903/udp


# Starting server on docker start
CMD export LD_LIBRARY_PATH=/home/steamcmd/7dtd_server && \
    /home/steamcmd/7dtd_server/7DaysToDieServer.x86_64 \
	-configfile=/home/steamcmd/7dtd_server/serverconfig.xml \
	-logfile /home/steamcmd/7dtd_server/output.log \
	-quit -batchmode -nographics -dedicated $@