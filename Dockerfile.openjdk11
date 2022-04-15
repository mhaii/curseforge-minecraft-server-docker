# use non-slim because it doesn't include wget, curl, or unzip
# only able to use upto some java 10-ish cause script has "-d64" flag that was removed and will cause error
FROM openjdk:11-jre AS STAGING

WORKDIR /stage

ARG url="[use --build-arg url=XXXXX to specify server file url]"
RUN filename=$(basename $url); output_dir=${filename%%.zip}; wget $url; unzip $filename; mv -f $output_dir/* .; rm -rf $filename $output_dir
# accept EULA after initiation so that script wouldn't start running server
RUN chmod a+x ./startserver.sh; ./startserver.sh; echo "eula=true" > eula.txt; rm -f modpack-download.zip


########################################################

FROM openjdk:11-jre-slim AS RUNTIME

WORKDIR /minecraft
COPY --from=STAGING /stage .

VOLUME ["/minecraft/world", "/minecraft/backups", "/minecraft/server.properties", "/minecraft/ops.json"]

EXPOSE 25565
ENTRYPOINT ["./startserver.sh"]
