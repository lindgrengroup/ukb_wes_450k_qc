#!/bin/bash

# instance_type="mem1_ssd1_v2_x8" # DEFAULT
instance_type="mem1_ssd1_v2_x8"
instance_count="100"
name="hail-cluster-${instance_count}x"
duration="60"

dx run \
  dxjupyterlab_spark_cluster \
  --instance-type="${instance_type}" \
  --instance-count="${instance_count}" \
  --name="${name}" \
  --priority="low" \
  --yes \
  -iduration="${duration}" \
  -ifeature="HAIL-0.2.78" \
  --brief

