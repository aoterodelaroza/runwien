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
    rootdir = ARGV[1]
    
    struct = rootdir "/" rootdir ".struct"
    
    ARGV[1] = struct
}
NR == 1 { print ; next}
NR == 2 { 
    print substr($0,1,4)
    nneq = substr($0,28,3) + 0
    print nneq
    print $NF
    next
}
NR == 3 {
    if ($0 ~ /RELA/)
	print "yes"
    else
	print "no"
    next
}
NR == 4 {
    print substr($0,1,10)
    print substr($0,11,10)
    print substr($0,21,10)
    print substr($0,31,10)
    print substr($0,41,10)
    print substr($0,51,10)
    next
}
NR == 5{
    for (i=1;i<=nneq;i++){
	print substr($0,5,4)
	printf "%.10f\n",substr($0,13,10)
	printf "%.10f\n",substr($0,26,10)
	printf "%.10f\n",substr($0,39,10)
	getline
	mult = substr($0,16,2) + 0
	print mult
	print substr($0,35,2)
	for (j=1;j<=mult-1;j++){
	    getline
	    printf "%.10f\n",substr($0,13,10)
	    printf "%.10f\n",substr($0,26,10)
	    printf "%.10f\n",substr($0,39,10)
	}
	getline
	name = substr($0,1,10)
	gsub(/[0-9]+/,"",name)
	print name
	print substr($0,16,5)
	print substr($0,26,10)
	print substr($0,41,10)
	print substr($0,56,5)
	getline ; getline ; getline; getline
    }
    next
}
