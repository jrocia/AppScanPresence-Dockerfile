FROM registry.access.redhat.com/ubi9/ubi:9.4
LABEL description="AppScan Presence in Dockerfile for Linux Image"
ARG APIKEYID
ARG APIKEYSECRET
ARG PRESENCEID
RUN : "${APIKEYID:?build-arg APIKEYID is mandatory}" \
 && : "${APIKEYSECRET:?build-arg APIKEYSECRET is mandatory}" \
 && : "${PRESENCEID:?build-arg PRESENCEID is mandatory}"
RUN yum install -y unzip shadow-utils && yum clean all
RUN useradd -m -s /sbin/nologin appscanpresence
WORKDIR /opt/AppScanPresence
RUN curl -s -X POST \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    -d '{"KeyId":"'"${APIKEYID}"'","KeySecret":"'"${APIKEYSECRET}"'"}' \
    'https://cloud.appscan.com/api/v4/Account/ApiKeyLogin' > /tmp/output.txt \
 && curl -s -X GET \
    --header 'Accept: application/zip' \
    --header 'Content-Length: 0' \
    --header "Authorization: Bearer $(grep -oP '(?<=\"Token\": \")[^\"]*' /tmp/output.txt)" \
    "https://cloud.appscan.com/api/v4/Presences/${PRESENCEID}/Download/Linux_x64" \
    > /tmp/AppScanPresence-Linux_x64.zip \
 && unzip /tmp/AppScanPresence-Linux_x64.zip -d /opt/AppScanPresence \
 && rm -f /tmp/output.txt /tmp/AppScanPresence-Linux_x64.zip
RUN chown -R appscanpresence:appscanpresence /opt/AppScanPresence
USER appscanpresence
ENTRYPOINT ["sh", "startPresence.sh"]
