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
NR == 3{
    atom = 0
    for (;$0 !~ /K-VECTORS/;getline){
	atom++
	globe[atom] = $1
	globapw[atom] = $3
	orbitals[atom] = $2
	for (i=1;i<=orbitals[atom];i++){
	    getline
	    l[atom,i] = substr($0,1,2)
	    e[atom,i] = substr($0,3,10)
	    var[atom,i] = substr($0,13,10)
	    cont[atom,i] = substr($0,23,4)
	    apw[atom,i] = $NF
	}
    }
}
END{
    print atom
    for (i=1;i<=atom;i++){
	print globe[i]
	print globapw[i]
	print orbitals[i]
	for (j=1;j<=orbitals[i];j++){
	    print l[i,j] 
	    print e[i,j] 
	    print var[i,j]
	    print cont[i,j]
	    print apw[i,j]
	}
    }
}
