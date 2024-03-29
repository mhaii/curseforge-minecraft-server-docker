FROM openjdk:17-alpine AS STAGING

RUN apk add bash wget unzip

WORKDIR /stage

ARG url="[use --build-arg url=XXXXX to specify server file url]"
RUN filename=$(basename $url); output_dir=${filename%%.zip}; wget $url; unzip $filename; mv -f $output_dir/* .; rm -rf $filename $output_dir

RUN mv forge-*-installer* installer.jar; java -jar installer.jar --installServer; chmod a+x ./run.sh; ./run.sh;
RUN echo "eula=true" > eula.txt; rm -f installer.jar installer.jar.log INSTRUCTION* run.bat

########################################################

FROM openjdk:17-alpine AS RUNTIME

RUN apk add --no-cache bash python3 py3-pip
RUN pip3 install --no-cache --upgrade mcstatus

WORKDIR /minecraft
COPY --from=STAGING /stage .

# also "/minecraft/server.properties", "/minecraft/ops.json
VOLUME ["/minecraft/world", "/minecraft/backups"]

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=3m \
    --retries=3 \
    CMD mcstatus localhost ping || exit 1

EXPOSE 25565
ENTRYPOINT ["./run.sh"]
