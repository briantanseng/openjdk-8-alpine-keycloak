# openjdk-8-alpine-keycloak
JBoss Keycloak server 4.3.0.Final on Alpine Linux with Open JDK 8

Built for SQL Server support. Edit configuration/standalone.xml to configure the database connection string. 

TODO: Modify to support various relational database servers.

Image on docker hub: https://hub.docker.com/r/briantanseng/openjdk-8-alpine-keycloak/

## Sample usage

### Default configuration uses the H2 database and runs on standalone mode:

```
docker run --name keycloak \
-it --rm -p 8080:8080 \
briantanseng/openjdk-8-alpine-keycloak
```

### Create an admin user as you running the server
```
docker run --name keycloak \
-e KEYCLOAK_USER=admin \
-e KEYCLOAK_PASSWORD=S3cr3t-P@ssw0rd \
-it --rm -p 8080:8080 \
briantanseng/openjdk-8-alpine-keycloak
```

### Options for operating modes (set via the OPERATING_MODE environment variable):

- standalone (default, if none specified)
- standalone_clustered
- domain_master
- domain_slave

```
docker run --name keycloak \
-e KEYCLOAK_USER=admin \
-e KEYCLOAK_PASSWORD=S3cr3t-P@ssw0rd \
-e OPERATING_MODE=standalone \
-it --rm -p 8080:8080 \
briantanseng/openjdk-8-alpine-keycloak
```

### Setup for Production environment

1. Run the command to test if Keycloak is running

```
docker run --name keycloak \
-it --rm -p 8080:8080 \
briantanseng/openjdk-8-alpine-keycloak
```

2. Copy files from the running keycloak instance to your host machine

Create a directory where you will copy directories from a running Keycloak container: 

```
mkdir ~/keycloak
```

2.1 Copy the pertinent execution directory  

2.1.1 If running on standalone mode, copy the standalone directory 

```
docker cp keycloak:/keycloak/standalone/ ~/keycloak/
```

2.1.2 If running on domain clustered mode, copy the domain directory 

```
docker cp keycloak:/keycloak/domain/ ~/keycloak/
```

2.2 (Optional) Copy the themes directory to easily drop your themes

```
docker cp keycloak:/keycloak/themes/ ~/keycloak/
```

After copying files from your Keycloak container, enter ```CTRL+C``` to stop the server from step 1 above.

3. Edit the pertinent configuration file depending on the operating mode you will be running your server:
- standalone/configuration/standalone.xml
- standalone/configuration/standalone-xa.xml
- domain/configuration/domain.xml

Mount the directory/directories you copied from step 2.

Execute ```docker run```. Here are some options to run Keycloak in standalone mode:

```
docker run --name keycloak \
--cpus=".5" \
--ulimit rtprio=99 \
--security-opt=no-new-privileges \
--cpu-shares=1024 \
--memory="500m" \
--memory-swap="1g" \
--pids-limit=200 \
--read-only=true \
--restart on-failure:5 \
-e OPERATING_MODE=standalone \
-v ~/keycloak/standalone/:/keycloak/standalone/:rw \
-p [IP-ADDRESS-OF-KEYCLOAK-SERVER]:8080:8080 \
-d briantanseng/openjdk-8-alpine-keycloak:latest
```

4. Be sure to run Docker Bench for Security to check for security concerns.

See: https://github.com/docker/docker-bench-security 
