#!/bin/bash

singularity shell \
--bind `pwd`:/wkdir \
container.simg
