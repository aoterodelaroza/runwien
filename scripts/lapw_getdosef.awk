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
    col = ARGV[2] + 1
    ARGC = 2
}
(NR==2){ ef = $2+0 }
/^#/{next}
($1 < ef){
    elo = $1 + 0
    nlo = $col + 0
}
($1 > ef){
    ehi = $1 + 0
    nhi = $col + 0
    exit
}
END{
    printf "%.14f\n", nlo + (ef-elo) * (nhi-nlo) / (ehi-elo)
}