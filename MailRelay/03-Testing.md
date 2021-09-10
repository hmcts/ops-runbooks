This section contains multiple test scenarios which you can use to test that mail relay is working as expected. 

<b>Test unauthneticated relay, determine if unauthenticated relay is on or off.</b>

1) Stand up a temporary pod 
kubectl run -it --rm --restart=Never -n admin --image=docker.io/alpine:3.13 alpine2 --command -- /bin/sh

2) Add tools to the new linux vm 
apk add busybox-extras

3) Connect to telnet and try to send an email from pcol to an email 

telnet <ip:port>
helo possessionclaim.gov.uk
mail from: noreply-pcol@hmcts.net
rcpt to: <recipient email>
data
354 Enter message, ending with "." on a line by itself
data
Subject: test                                         
test test test
.
250 OK id=1loSVf-0000os-G2

<b>Test using SWAKS</b>

    kubectl run my-shell -it --rm --restart=Never -n admin --image=ubuntu --command -- bash
    apt update
    apt install swaks
    apt install telnet
    swaks -a -tls -q HELO -s <ip>-au v1test -ap '<password'

<b>Test SSL using OpenSSL</b>

    openssl s_client -connect <ip:port> -starttls smtp
    helo possessionclaim.gov.uk
    mail from: noreply-pcol@hmcts.net
    rcpt to: <your email> 
    data
    Subject: test 
    test test test
    .

    more scenarios to be added