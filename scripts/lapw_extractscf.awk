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
/:ITE/ {
    gsub(/^:ITE[0-9]*:/,"",$0)
    iteration = $1+0; 
    bands = 0
}
/:FER/ {fermie = $10}
/:NTO  :/{totalinterq = $6}
$0 ~ /:NTO/ && $0 ~ /SPHERE/{
    totalq[$6] = $8
}
/:BAN/{ bands++
    emin[bands]=$4
    emax[bands]=$5
}
/Energy to separate /{ ecoreval = $NF }
/:ENE/{
    energy = $9
    
    if (iteration == 1){
	printf "[info|scf] %-7s%-16s%-16s%-10s","Cycle","Fermi energy","Total energy","Inter. q"
	for (i in totalq)
	    printf "%-9s","sph. q " i
	printf "\n"
    }
    printf "[info|scf] %-6i %-15.10f %-15.10f %-9.6f ",iteration,fermie,energy,totalinterq
    for (i in totalq)
	    printf "%-9.6f",totalq[i]
    printf "\n"
}
END{
    print "[info|scf] Last iteration band structure:"
    printf "[info|scf] %6-s%-11s%-11s\n","Band","Emin","Emax"
    for (i=1;i<=bands;i++)
	printf "[info|scf] %5-i %-10.6f %-10.6f \n",i,emin[i],emax[i]
    print "[info|scf] Semicore-valence energy sep. :",ecoreval
    printf "[info|scf] %-60s\n","--------end of scf--------"
}
