#!/bin/bash

wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
qemu-img resize focal-server-cloudimg-amd64.img 200G