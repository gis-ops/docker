# Valhalla Docker image by GIS • OPS

A hyper-flexible Docker image for the excellent [Valhalla](https://github.com/valhalla/valhalla) routing framework.

```bash
docker run -dt --name valhalla_gis-ops -v $PWD/custom_files:/custom_files gisops/valhalla:latest
```

This image aims at being user-friendly and most efficient with your time and resources. Once built, you can easily change Valhalla's configuration, the underlying OSM data graphs are built from, accompanying data (like Admin Areas, elevation tiles) or even pre-built graph tiles. Upon `docker restart <container>` those changes are taken into account via **hashed files**, and, if necessary, new graph tiles will be built automatically.

## Features

-   Easily switch graphs by mapping different volumes to containers.
-   Stores all relevant data (Admin areas, elevation, TimeZone data, tiles) in the mapped volume.
-   Load and built from **multiple URLs** pointing to valid pbf files.
-   Load local data through volume mapping.
-   **Supports auto rebuild** on volume file changes through hash mapping.

## Container recipes

For the following instructions to work, you'll need to have the image locally available already, either from [Docker Hub](https://hub.docker.com/repository/docker/gisops/valhalla) or from local:

```bash
docker build -t gisops/valhalla .
#or
docker pull gisops/valhalla:latest
```

Then start a background container from that image:

```bash
docker run -dt -v $PWD/custom_files:/custom_files --name valhalla_1 valhalla
```

The important part here is, that you map a volume from your host machine to **`/custom_files`**. The container will dump all relevant Valhalla files to that directory.

At this point Valhalla is running, but there is no graph tiles yet. Follow the steps below to customize your Valhalla instance in a heartbeat.

> Note, alternatively you could create `custom_files` on your host before starting the container with all necessary files you want to be respected, e.g. the OSM PBF files.

#### Build Valhalla with arbitrary OSM data

Just dump **single or multiple** OSM PBF files to your mapped `custom_files` directory, restart the container and Valhalla will start building the graphs:

```bash
cd custom_files
# Download Andorra & Faroe Islands
wget http://download.geofabrik.de/europe/faroe-islands-latest.osm.pbf http://download.geofabrik.de/europe/andorra-latest.osm.pbf
docker restart valhalla_1
```

If you change the PBF files by either adding new ones or deleting any, Valhalla will build new tiles on the next restart.

#### Customize Valhalla configuration

If you need to customize Valhalla's configuration to e.g. increase the allowed maximum distance for the `/route` POST endpoint, just edit `custom_files/valhalla.json` and restart the container. It won't rebuild the tiles in this case.

#### Run Valhalla with pre-built tiles

In the case where you have a pre-built `tiles.tar` package from another Valhalla instance, you can also dump that to `custom_files/` and they're loaded upon container restart.

## Environment variables

This image respects the following custom environment variables to be passed during container startup:

- `tile_urls`: Add as many (space-separated) URLs as you like, e.g. https://download.geofabrik.de/europe/andorra-latest.osm.pbf http://download.geofabrik.de/europe/faroe-islands-latest.osm.pbf
- `min_x`: Minimum longitude for elevation tiles, in decimal WGS84, e.g. 18.5
- `min_y`: Minimum latitude for elevation tiles, in decimal WGS84, e.g. 18.5
- `max_x`: Maximum longitude for elevation tiles, in decimal WGS84, e.g. 18.5
- `max_y`: Maximum latitude for elevation tiles, in decimal WGS84, e.g. 18.5
- `use_tiles_only`: ??
- `force_rebuild`: Force a complete rebuild of the PBF files. Only skipping elevation.
- `force_rebuild_elevation`: Force a rebuild of the elevation data as well.
- `build_elevation`: General switch to build with elevation support.
- `build_admins`: General switch to build with admin data support.
- `build_time_zones`: General switch to build with time zone support.

## Example `docker-compose.yml`

- Create a `docker-compose.yml` and paste the content below.
- Now create a `custom_files` folder in the same directory to be able to mount it as a volume.
- Add your desired PBF extracts in the folder or specify URLs in the `docker-compose.yml`.
- Local files are always preferred!
- If you change your local files and want to rebuild, just restart the docker container.
```docker
version: '3.0'
services:
  valhalla:
    image: gisops/valhalla:latest
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

See [Environment variables](#environment-variables) for an explanation of the environment variables.
