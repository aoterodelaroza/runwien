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
    atom = ARGV[2]
    orbs = ARGV[3]
    globale = ARGV[4]
    globalapw = ARGV[5]
    for (i=1;i<=orbs;i++){
	l[i] = ARGV[5+(i-1)*5+1]
	energy[i] = ARGV[5+(i-1)*5+2]
	var[i] = ARGV[5+(i-1)*5+3]
	cont[i] = ARGV[5+(i-1)*5+4]
	apw[i] = ARGV[5+(i-1)*5+5]
    }
    ARGC = 2
}
/global/ || /GLOBAL/{
    atomcount++
    if (atomcount == atom){
	temp = $2
	$1 = globale
	$2 = orbs
	$3 = globalapw
    }
    else{
	print $0 > "tempfile_script"
	next
    }
    print > "tempfile_script"
    for (i=1;i<=orbs;i++){
	printf "%2i%10.5f%10.5f%4s%2i\n",l[i],energy[i],var[i],cont[i]?"CONT":"STOP",apw[i] > "tempfile_script"
    }
    for (i=1;i<=temp;i++){
	getline
    }
    next
}
{print > "tempfile_script"}
END{
    system("mv tempfile_script " filename)
}
