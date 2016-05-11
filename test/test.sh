#!/bin/bash
set -e
set -o pipefail

DATA_DIR=${DATA_DIR:-"/tmp"}
IMAGE_PATH="${DATA_DIR}/resin.img"
if [ -f "$IMAGE_PATH" ]; then
	echo "File in $IMAGE_PATH already exists, refusing to overwrite file. Please specify a different DATA_DIR."
	exit 1
fi

function cleanup {
	rm "$IMAGE_PATH"
	docker rmi test-resin-preload
}

trap cleanup EXIT

curl --compressed 'https://img.resin.io/api/v1/image/raspberry-pi' -o "$IMAGE_PATH"
docker build -t test-resin-preload .

# Pass both API_TOKEN and API_KEY so that test user can choose.
docker run --rm -e API_TOKEN="$API_TOKEN" -e API_KEY="$API_KEY" -e APP_ID="$APP_ID" -v "$IMAGE_PATH":/img/resin.img --privileged test-resin-preload
