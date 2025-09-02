# AppScanPresence-Dockerfile
  Bringing Appscan Presence to run inside container.

If you need to run AppScan Presence inside a container, here the Dockerfile recipe. Fill the 3 ENV (APIKEYID, APIKEYSECRET and PRESENCEID) and build it.

PS: do not add quotes and single quotes in ENV entries.

You must have:<br>
1 - An account in https://cloud.appscan.com<br>
2 - An pair API access. Documentation: https://help.hcltechsw.com/appscan/ASoC/appseccloud_generate_api_key_cm.html<br>
3 - An AppScan Presence agent where you will get PresenceID. Documentation: https://help.hcltechsw.com/appscan/ASoC/asp_scanning.html<br>

```Dockerfile  
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
```
<br>
PS: It is set to download AppScan Presence V2. If you want V1 change in final of this URL to v1:  https://cloud.appscan.com/api/v2/Presences/$PRESENCEID/Download/Linux_x86_64/v2 <br>

<br>
Basic Commands:

docker build -t lab/appscanpresence .<br>
docker run --name appscanpresence -d lab/appscanpresence<br>
docker exec -it appscanpresence /bin/bash<br>
docker start appscanpresence<br>
docker stop appscanpresence<br>

After run AppScan Presence Container remember: <br>
1 - the container needs internet access otherwise it will not connect the tunnel with cloud.appscan.com. Documentation: https://help.hcltechsw.com/appscan/ASoC/appseccloud_sys_req.html#appseccloud_sys_req__IPs <br>
2 - the container needs to access the url target, so access the container and run a simple command like curl URLtarget and check if it reachable. 
https://help.hcltechsw.com/appscan/ASoC/asp_automation_server.html <br>
3 - the agent does not connect tunnel if in the middle has SSL Inspection, so add exceptions in your network device. <br>
