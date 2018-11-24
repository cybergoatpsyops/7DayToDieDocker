FROM ubuntu:latest
MAINTAINER cyberGoatPsyOps

# Install dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -q -y wget lib32gcc1 telnet

# Create workspace for server
WORKDIR /home/steam

# Downloading Steam cmd
RUN wget http://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN mkdir ./bin && tar -xvzf steamcmd_linux.tar.gz -C ./bin

# Downloading 7Days Server
RUN mkdir -p /home/steam/server
RUN /home/steam/bin/steamcmd.sh \
	+login anonymous \
	+force_install_dir /home/steam/server \
	+app_update 294420 -validate -beta latest_experimental \
	+quit

# Copy serverconfig into dockercontainer
RUN mkdir -p /root/.local/share/7DaysToDie/Saves
COPY serverconfig.xml ./server
COPY serveradmin.xml /root/.local/share/7DaysToDie/Saves/

EXPOSE 8080/tcp 8081/tcp
EXPOSE 26900-26903/tcp 26900-26903/udp
EXPOSE 27000-27099/udp

# Starting server on docker start
CMD export LD_LIBRARY_PATH=/home/steam/server && \
    /home/steam/server/7DaysToDieServer.x86_64 \
	-configfile=/home/steam/server/serverconfig.xml \
	-logfile /home/steam/server/output.log \
	-quit -batchmode -nographics -dedicated $@

