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
    nneq = ARGV[2]
    ARGC = 2
}
NR == 4{
    tmp = 1
    for (i=1;i<=nneq && tmp != 0;i++){
	ind = 1
	for (;(l0 = substr($0,ind,3)) && (m0 = substr($0,ind+3,2));){
	    lms[i]++
	    l[i,lms[i]] = l0+0
	    m[i,lms[i]] = m0+0
	    ind += 5
	}
	tmp = getline
    }
}
END{
    for (i=1;i<=nneq;i++){
	print lms[i]
	for (j=1;j<=lms[i];j++){
	    print l[i,j]
	    print m[i,j]
	}
    }
}
