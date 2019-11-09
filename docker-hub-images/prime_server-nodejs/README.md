Base dockerfile for the gis-ops dockerhub prime_server image

Build command for a specific version:
```bash
docker build --build-arg version=xxx -t gisops/prime_server-nodejs10.15.0:xxx .
```

Build command for the latest version:
```bash
docker build -t gisops/prime_server-nodejs:latest-10.15.0 .
```