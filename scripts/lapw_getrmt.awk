#! /usr/bin/gawk -f
#
# This file is part of runwien.awk
#
# Copyright (c) 2007 Alberto Otero <aoterodelaroza@gmail.com> and 
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
NR == 2 { 
    nneq = substr($0,28,3)
    nneq = nneq + 0
}
NR == 5 {
    for (i=1;i<=nneq;i++){
	getline
	mult = substr($0,16,2) +0
	for (j=1;j<=mult-1;j++){
	    getline
	}
	getline
	print substr($0,41,10)
	getline
	getline
	getline
	getline
    }
}
