#!/bin/bash

cont_name="cuda_dev"
volumes="-v /home/lyy92/Projects:/home/lyy92/Projects "
volumes+="-v /home/lyy92/Downloads:/home/lyy92/Downloads "

docker run -it --gpus='all' $volumes  $cont_name
