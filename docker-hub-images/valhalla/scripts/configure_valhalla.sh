#!/usr/bin/env bash

hash_counter()
{
# The first parameter is the location path of the tile file without the hash filename.
# That is handled internally. The second is the file with path that should be matched against the existing tiles hashes.
current_directory=${PWD}
cd ${1}
if  ! [[ -f "file_hashes.txt" ]]; then
    cd ${current_directory}
    return 0
fi

old_hashes=""
counter=0
# Read the old hashes
while IFS="" read -r line || [[ -n "$line" ]]
do
	old_hashes="${old_hashes} ${line}"
done < "file_hashes.txt"
for hash in ${old_hashes} ; do
    counter=$((counter+1))
done
return ${counter}
}

hash_exists()
{
# The first parameter is the location path of the tile file without the hash filename.
# That is handled internally. The second is the file with path that should be matched against the existing tiles hashes.
current_directory=${PWD}
cd ${1}

if  ! [[ -f "file_hashes.txt" ]]; then
    cd ${current_directory}
    return 1
fi

old_hashes=""
# Read the old hashes
while IFS="" read -r line || [[ -n "$line" ]]
do
	old_hashes="${old_hashes} ${line}"
done < "file_hashes.txt"
hash="$(printf '%s' "${2}" | sha256sum | cut -f1 -d' ')"
cd ${current_directory}
if [[ ${old_hashes} == *"${hash}"* ]]; then
  echo "Found valid hash for ${2}!"
  return 0
else
  return 1
fi
}

add_hashes()
{
# Add files to the hash list to check for updates on rerun.
# First parameter is the path where the hash file should be stored.
# The second is the string of file names with path.
current_directory=${PWD}
cd ${1}
hashes=""
for value in ${2}; do
    hash="$(printf '%s' "${value}" | sha256sum | cut -f1 -d' ')"
    echo "Add hash: ${hash} for file ${value}."
    hashes="${hashes} $hash"
done
echo ${hashes} >> file_hashes.txt
cat file_hashes.txt
cd ${current_directory}
}

# Go into custom tiles folder
cd $4

# Collect possible custom .pbf files
files=""
counter=0
skip_build=0

# Find and add .pbf files to the list of files
for file in *.pbf; do
    [[ -f "$file" ]] || break
    if ! hash_exists ${1} "${PWD}/${file}"; then
        echo "Hash not found for: ${file}!"
        skip_build=1
    fi
    files="${files} ${PWD}/${file}"
    counter=$((counter+1))
done

# Go to scripts folder
cd $1
hash_counter ${1}
hashes=${?}
echo "Existing Hashes: $hashes"
echo "File Counter: $counter"
# Exit if existing build is fine
if test -f "valhalla_tiles.tar" && [[ ${skip_build} == 0 ]] && [[ ${hashes} == ${counter} ]]; then
    echo "All files have already been build and valhalla_tiles.tar exist. Starting without new build!"
    exit 0
else
    echo "Either valhalla_tiles.tar couldn't be found or new files or file constellations were detected. Rebuilding!   "
fi

if [[ ${counter} -ge 1 ]]; then
    echo "=========================================="
    echo "Found ${files}. Using it as the OSM extract(s)"
    echo "=========================================="
     # Assign the file name of the osm extract for later used
    tile_files=${files}
elif curl --output /dev/null --silent --head --fail "${3}"; then
    echo ""
    echo "==============================================================="
    echo " Local OSM extracts not found in  ${4}. Using the given URL instead"
    echo " URL exists: ${3}"
    echo " Downloading OSM extract"
    echo "==============================================================="
    curl -O ${3}
    # Assign the file name of the osm extract for later use
    tile_files=${PWD}/$(ls -t | head -n1)
else
    echo "Please ensure that the tile_files or tile_url is valid"
    exit 1
fi
# Check for bounding box
mjolnir_timezone="";
mjolnir_admin="";
additional_data_elevation="";

# Adding the desired modules
if [[ $9 == "True" ]] && [[ "$5" != 0 ]] && [[ "$6" != 0 ]] && [[ "$7" != 0 ]] && [[ "$8" != 0 ]]; then
    echo ""
    echo "============================================================================"
    echo "= Valid bounding box and data elevation parameter added. Adding elevation! =";
    echo "============================================================================"
    # Build the elevation data
    valhalla_build_elevation $5 $6 $7 $8 ${PWD}/elevation_tiles;
    additional_data_elevation="--additional-data-elevation ${PWD}/elevation_tiles";
else
    echo ""
    echo "========================================================================="
    echo "= No valid bounding box or elevation parameter set. Skipping elevation! =";
    echo "========================================================================="
fi

if [[ ${10} == "True" ]]; then
    # Add admin path
    echo ""
    echo "========================"
    echo "= Adding admin regions =";
    echo "========================"
    mjolnir_admin="--mjolnir-admin ${PWD}/valhalla_tiles/admins.sqlite";
else
    echo ""
    echo "=========================="
    echo "= Skipping admin regions =";
    echo "=========================="
fi

if [[ ${11} == "True" ]]; then
    echo ""
    echo "========================"
    echo "= Adding timezone data =";
    echo "========================"
    mjolnir_timezone="--mjolnir-timezone ${PWD}/valhalla_tiles/timezones.sqlite";
else
    echo ""
    echo "=========================="
    echo "= Skipping timezone data =";
    echo "=========================="
fi

echo ""
echo "========================="
echo "= Build the config file =";
echo "========================="

valhalla_build_config --mjolnir-tile-dir ${PWD}/valhalla_tiles --mjolnir-tile-extract ${PWD}/valhalla_tiles.tar ${mjolnir_timezone} ${mjolnir_admin} ${additional_data_elevation} > ${2};

# Build the desired modules with the config file
if [[ ${10} == "True" ]]; then
    # Build the admin regions
    echo ""
    echo "==========================="
    echo "= Build the admin regions =";
    echo "==========================="
    valhalla_build_admins --config ${2} ${tile_files};
fi

if [[ ${11} == "True" ]]; then
    # Build the time zones
    echo ""
    echo "==========================="
    echo "= Build the timezone data =";
    echo "==========================="
    ./valhalla_build_timezones ${2}
fi

# Finally build the tiles
echo ""
echo "========================="
echo "= Build the tile files. ="
echo "========================="
valhalla_build_tiles -c ${2} ${tile_files}
# Tar up the tiles in the valhalla_tiles folder
find valhalla_tiles | sort -n | tar cf "valhalla_tiles.tar" --no-recursion -T -

echo "Successfully build files: ${tile_files}"
add_hashes ${1} "${tile_files}"
