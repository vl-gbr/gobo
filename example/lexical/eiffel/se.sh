#!/bin/sh

# system:     "Eiffel scanner"
# compiler:   "SmallEiffel -0.76"
# author:     "Eric Bezault <ericb@gobosoft.com>"
# copyright:  "Copyright (c) 1997-2000, Eric Bezault and others"
# license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
# date:       "$Date$"
# revision:   "$Revision$"


echo ${GOBO}/example/lexical/eiffel/>		loadpath.se
echo ${GOBO}/library/lexical/skeleton/>>	loadpath.se
echo ${GOBO}/library/utility/loadpath.se>>	loadpath.se
echo ${GOBO}/library/kernel/loadpath.se>>	loadpath.se

export geoptions="-boost -no_split -no_style_warning -no_gc"
compile $geoptions -o eiffel_scanner EIFFEL_SCANNER benchmark
