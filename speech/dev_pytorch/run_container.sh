#!/bin/bash

docker run -it --gpus='all' -v /home/lyy92/Projects:/home/lyy92/Projects -v /home/lyy92/Downloads:/home/lyy92/Downloads pytorch_speech_dev
