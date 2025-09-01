FROM registry.access.redhat.com/ubi9/ubi:latest
LABEL description="AppScan Presence in Dockerfile for Linux Image"
ENV APIKEYID xxxxxxxxxxxxxxxxxxx
ENV APIKEYSECRET xxxxxxxxxxxxxxxxxxx
ENV PRESENCEID xxxxxxxxxxxxxxxxxxx
RUN yum install -y unzip && yum clean all
RUN curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"KeyId":"'"${APIKEYID}"'","KeySecret":"'"${APIKEYSECRET}"'"}' 'https://cloud.appscan.com/api/v4/Account/ApiKeyLogin' > output.txt
RUN ls output.txt
RUN curl -X GET --header 'Accept: application/zip' --header 'Content-Length: 0' --header "Authorization: Bearer $(grep -oP '(?<="Token": ")[^"]*' output.txt)" https://cloud.appscan.com/api/v4/Presences/$PRESENCEID/Download/Linux_x64 > AppScanPresence-Linux_x64.zip
RUN mkdir AppScanPresence && unzip AppScanPresence-Linux_x64.zip -d AppScanPresence
ENTRYPOINT  ["sh","AppScanPresence/startPresence.sh"]
