Base dockerfile for the gis-ops dockerhub prime_server image

Build command for a specific version:
```bash
docker build --build-arg version=xxx -t gisops/prime_server:xxx .
```

Build command for the latest version:
```bash
docker build -t gisops/prime_server:latest .
```