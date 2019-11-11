Base dockerfile for the gis-ops dockerhub valhalla image

Build command for a specific version:
```bash
docker build --build-arg version=xxx -t gisops/valhalla:xxx .
```

Build command for the latest version:
```bash
docker build -t gisops/valhalla:latest .
```