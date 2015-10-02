#! /bin/bash
#
# This file is part of runwien.awk
#
# Copyright (c) 2007 Alberto Otero <alberto@carbono.quimica.uinovi.es> and 
#  Víctor Luaña <victor@carbono.quimica.uniovi.es>. Universidad de Oviedo.
# 
# runwien.awk is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version. 
# 
# runwien.awk is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if [ $# != 1 ] ; then
    echo ' Usage : lapw_structu2tess.sh root '
    exit 1
fi

struct="${1}.struct"
tess="${1}.tess"
pov="${1}.pov"
wrl="${1}.wrl"
tga="${1}.tga"
gif="${1}.gif"

if [ ! -f ${struct} ] ; then
    echo ' File not found!'
    echo ' Usage : lapw_structu2tess.sh root '
    exit 1
fi

cat > ${tess} <<EOF
set camangle 80 12 50
set zoom 2.0
set use_planes .false.
set background background {color rgb <1.0,1.0,1.0>}
molecule
   crystal
      struct ${struct}
      crystalbox all 0.25
   endcrystal
   environ 5 12.0
   set ball_texture Dull
   unitcell radius 0.1 rgb 1.0 0.5 0.5
   molmotif allmaincell jmol
   povray ${pov}
   vrml ${wrl}
endmolecule
run povray -D +ft +I${pov} +O${tga} +W400 +H400 +A
run convert ${tga} ${gif}
run rm ${tga} ${pov}
EOF

