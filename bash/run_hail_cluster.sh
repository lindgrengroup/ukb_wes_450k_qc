#!/bin/bash

# instance_type="mem1_ssd1_v2_x8" # DEFAULT
instance_type="mem1_ssd1_v2_x36" # BIG
# instance_type="mem1_ssd1_v2_x16" # big
# instance_type="mem1_ssd1_v2_x4" # small
# instance_type="mem1_ssd1_v2_x2" # smallest
# instance_type="mem2_ssd1_v2_x2" # smallest, more mem (for plotting)
# instance_type="mem3_ssd1_v2_x2" # smallest, even more mem (for plotting)

instance_count="32" # BIG
# instance_count="16" # Big
# instance_count="8" # medium
# instance_count="4" # small
# instance_count="2" # smallest


priority="low"
# priority="high"


name="hail-${priority}-${instance_count}-${instance_type}"
duration="240"

if [ "${priority}" = "high" ]; then
  echo "** WARNING: PRIORITY set to HIGH **"
fi

dx run \
  dxjupyterlab_spark_cluster \
  --instance-type="${instance_type}" \
  --instance-count="${instance_count}" \
  --name="${name}" \
  --priority="${priority}" \
  --yes \
  -iduration="${duration}" \
  -ifeature="HAIL-0.2.78" \
  --brief \
  --destination "/data/"

