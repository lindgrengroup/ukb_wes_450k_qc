#!/bin/bash

docker pull wzhou88/saige:1.0.9
docker save -o saige_1.0.9.tar.gz wzhou88/saige:1.0.9

# make it readable for other users in your project
chmod a+r saige_1.0.9.tar.gz

# store it in your image folder on DNAnexus
dx upload saige_1.0.9.tar.gz \
  --path /docker_images/saige_1.0.9.tar.gz \
  --parents