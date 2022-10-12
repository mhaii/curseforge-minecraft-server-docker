FROM openjdk:17-alpine AS STAGING

ENV ATM7_INSTALL_ONLY true

RUN apk add bash wget unzip

WORKDIR /stage

ARG url="https://mediafilez.forgecdn.net/files/3995/913/ATM7-0.4.32-server.zip"
RUN filename=$(basename $url); output_dir=${filename%%.zip}; wget $url; unzip $filename; mv -f $output_dir/* .; rm -rf $filename $output_dir startserver.bat

RUN chmod a+x ./startserver.sh; ./startserver.sh; rm forge-*-installer* run.bat
RUN ls -la
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
ENTRYPOINT ["./startserver.sh"]
