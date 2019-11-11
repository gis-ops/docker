Base dockerfile for the gis-ops dockerhub prime_server image

Build nodejs together with the latest prime_server version from gisops docker hub:
```bash
docker build -t gisops/prime_server-nodejs:xxx-10.15.0 .
```

Build command for the latest version:
```bash
docker build -t gisops/prime_server-nodejs:latest-10.15.0 .
```