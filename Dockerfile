# use non-slim because it doesn't include wget, curl, or unzip
# only able to use upto some java 10-ish cause script has "-d64" flag that was removed and will cause error
FROM openjdk:8u282-jre AS STAGING

WORKDIR /stage

#ARG url="[use --build-arg url=XXXXX to specify server file url]"
ARG url="https://media.forgecdn.net/files/3174/528/SIMPLE-SERVER-FILES-1.4.1.zip"
RUN filename=$(basename $url); output_dir=${filename%%.zip}; wget $url; unzip $filename; mv -f $output_dir/* .; rm -rf $filename $output_dir
# accept EULA after initiation so that script wouldn't start running server
RUN chmod a+x ./startserver.sh; ./startserver.sh; echo "eula=true" >> eula.txt

########################################################

FROM openjdk:8u282-jre-slim AS RUNTIME

WORKDIR /minecraft
COPY --from=STAGING /stage .

VOLUME ["/minecraft/world", "/minecraft/server.properties"]

EXPOSE 25565
ENTRYPOINT ["./startserver.sh"]
