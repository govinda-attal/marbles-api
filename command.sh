#!/bin/bash

cd $(ls | head -n1)

make_cmd=$1

make $make_cmd
