#!/bin/bash

CODE_PATH=`pwd`

docker run -it \
	-p 8080:5173 \
	--mount type=bind,source="$CODE_PATH",target=/app \
	-w /app/olitracker \
	dev_vuejs:latest \
	npm run dev
