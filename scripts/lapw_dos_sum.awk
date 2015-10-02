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
    enes = 0
    ene[0] = -3000000
}
/^#/{ next }
{
    if (enes == 0)
	fields = NF
    for (i=2;i<=NF;i++)
	dos[$1,i] += $i 
    if ($1 > ene[enes]){
	enes++
	ene[enes] = $1
    }
}
END{
    for (i=1;i<=enes;i++){
	string = ene[i] " "
	for (j=2;j<=fields;j++){
	    if (dos[ene[i],j] == 0)
		string = string " n/a "
	    else
		string = string " " sprintf("%.8f",dos[ene[i],j])
	}
	print string
    }
}
