Base dockerfile for the gis-ops dockerhub valhalla image

Build command for a specific version:
```bash
docker build --build-arg version=xxx -t gisops/valhalla:xxx .
```

Build command for the latest version:
```bash
docker build -t gisops/valhalla:latest .
```


# Description   
-   An easy graph switch through remapping different volumes.
-   Stores all relevant data (Admin areas, elevation, TimeZone data, tiles) in the mapped volume.
-   Load and built from multiple urls pointing to valid pbf files.
-   Load local data through an easy volume mapping.
-   Supports auto rebuild on local file changes through hash mapping.

# Example docker-compose

- Create a `docker-compose.yml` and paste the content below.
- Now create a `custom_files` folder in the same directory to be able to mount it as a volume.
- Add your desired pbf extracts in the folder or specify URLs in the `docker-compose.yml`.
- Local files are always preferred!
- If you change your local files and want to rebuild, just restart the docker container.
```docker
version: '3.0'
services:
  valhalla:
    image: gisops/valhalla:latest
    entrypoint: "/valhalla/scripts/run.sh"
    ports:
      - "8002:8002"
    volumes:
      - ./custom_files/:/custom_files
    environment:
      - tile_urls=https://download.geofabrik.de/europe/andorra-latest.osm.pbf https://download.geofabrik.de/europe/albania-latest.osm.pbf
      - min_x=18 # -> Albania | -180 -> World
      - min_y=38 # -> Albania | -90  -> World
      - max_x=22 # -> Albania |  180 -> World
      - max_y=43 # -> Albania |  90  -> World
      - use_tiles_only=False
      - force_rebuild=False
      - force_rebuild_elevation=False
      - build_elevation=True
      - build_admins=True
      - build_time_zones=True
```
- tile_urls: Add as many URLs as you like.
- force_rebuild: Force a complete rebuild of the pbf files. Only skipping elevation.
- force_rebuild_elevation: Force a rebuild of the elevation data as well.
- build_elevation: General switch to build with elevation support.
- build_admins: General switch to build with admin data support.
- build_time_zones: General switch to build with time zone support.