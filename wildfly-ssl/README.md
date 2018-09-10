# Wildfly SSL PoC

This project runs a Wildfly 10 Server on a Docker image with mutual (two-way) SSL configuration.

## How to run

1. Run `main.sh` script

1. Load `browser-cert/int-client-keystore.jks` into your browser. The password is `ABCD1234`.

1. Access `https://localhost:8443`. If it is configured correctly, you should be asked to trust the server certificate.

## References

* [Wildfly quickstarts][1]

[1]: https://github.com/wildfly/quickstart/tree/10.x/helloworld-war-ssl
