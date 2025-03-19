git clone https://github.com/dcdebug/demo.git
cd demo/docker-vpn
docker build --no-cache --rm --force-rm -f Dockerfile -t ex .

# restart docker.
service docker restart
# or
/etc/init.d/docker restart

# restart ex docker
docker stop ex
docker start ex

#docker run

#docker expressvpn list all
docker exec -it ex expressvpn list all

#disconnect
docker exec -it ex expressvpn disconnect

#connect
docker exec -it ex expressvpn connect smart

# status
docker exec -it ex expressvpn status

# run into the docker .
docker exec -it ex /bin/bash
