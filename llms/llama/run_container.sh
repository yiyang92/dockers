#!/bin/bash

volumes="-v /home/lyy92/Projects:/home/lyy92/Projects "
volumes+="-v /home/lyy92/Downloads:/home/lyy92/Downloads "
volumes+="-v /home/lyy92/data:/home/lyy92/data "

docker run -idt --gpus='all' --add-host=host.docker.internal:host-gateway $volumes llama_dev
