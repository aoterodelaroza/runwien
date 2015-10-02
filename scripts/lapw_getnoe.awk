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
    ecoreval = ARGV[2]
    atom = ARGV[3]
    ARGC = 2
}
/RHFS/{this = $1}
/OCCUPANCY    ENERGY\(RYD\)         \(R4\)/{
    if (this == atom){
	getline
	ecore = ""
	eval = ""
	for(getline;$0 !~ /^ *$/;getline){
	    if ($3 > ecoreval)
		eval += $2
	    else
		ecore += $2
	}
    }
}
END{
    print ecore
    print eval
}
