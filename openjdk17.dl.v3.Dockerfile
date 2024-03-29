FROM openjdk:17-alpine AS STAGING

RUN apk add bash wget unzip

WORKDIR /stage

ARG url="[use --build-arg url=XXXXX to specify server file url]"
RUN filename=$(basename $url); output_dir=${filename%%.zip}; wget $url; unzip $filename; mv -f $output_dir/* .; rm -rf $filename $output_dir
# accept EULA after initiation so that script wouldn't start running server
RUN sed -e 's/baseInstallPath: setup/baseInstallPath: server/g' -e 's/autoRestart: true/autoRestart: false/g' -i server-setup-config.yaml; chmod a+x ./startserver.sh; ./startserver.sh; sed -e 's/autoRestart: false/autoRestart: true/g' -i server-setup-config.yaml;
RUN cd server; echo "eula=true" > eula.txt; rm -f modpack-download.zip

########################################################

FROM openjdk:17-alpine AS RUNTIME

RUN apk add --no-cache bash python3 py3-pip
RUN pip3 install --no-cache --upgrade mcstatus

WORKDIR /minecraft
COPY --from=STAGING /stage .

# also "/minecraft/server/server.properties", "/minecraft/server/ops.json
VOLUME ["/minecraft/server/world", "/minecraft/backups"]

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=3m \
    --retries=3 \
    CMD mcstatus localhost ping || exit 1

EXPOSE 25565
ENTRYPOINT ["./startserver.sh"]
