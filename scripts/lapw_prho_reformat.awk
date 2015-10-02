#! /usr/bin/gawk -f
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
BEGIN{
    filename = ARGV[1]
    lx = ARGV[2]
    ly = ARGV[3]
    costheta = ARGV[4]
    npx = ARGV[5]
    npy = ARGV[6]
    scale = ARGV[7]
    zmin = ARGV[8]
    zmax = ARGV[9]
    ARGC = 2
    
    stepx = lx / (npx-1)
    stepy = ly / (npy-1)
    sintheta = sqrt(1 - costheta^2)

    ix = 0
    iy = 1
}
/^( |\t)*$/{ix = 0; iy++ ; print ; next}
{
    ix++
    x = (ix-1) * stepx + (iy-1) * stepy * costheta
    y = (iy-1) * (stepy * sintheta)
    if (scale == "log")
	z = log($1)
    else
	z = $1
    if (zmax != "a" && z > zmax)
	z = zmax
    if (zmin != "a" && z < zmin)
	z = zmin
    printf "%15.10f %15.10f %20.10f\n",x,y,z
}
