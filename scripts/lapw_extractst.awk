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
    ARGC = 2
}
/RHFS/{atom=$1}
/OCCUPANCY    ENERGY\(RYD\)         \(R4\)/{
    getline
    for(getline;$0 !~ /^ *$/;getline){
	norb++
	orblabel[norb] = $1
	orbocc[norb] = $2
	orbenergy[norb] = $3
	orbr[norb] = $6
    }
}
/TOTAL CHARGE FOR SPIN/{
    if ($0 ~ /INSIDE SPHERE/)
	spherespin[$5] = $8
    else
	totalspin[$5] = $7
}
/TOTAL CORE-CHARGE OUTSIDE SPHERE/{
    coreleak = $NF
}
/ORTHOGONALITY INTEGRALS/{
    print "[info|init] atom : " atom
    printf "[info|init] %s%15.10f\n","core-valence energy : ",ecoreval
    print "[info|init] orbital description : "
    printf "[info|init] %5s%5s%15s%15s%10s\n","Label","Occ.","Energy (Ry)","<R> (bohr)","Type"
    for (i=1;i<=norb;i++)
	printf "[info|init] %5s%5i%15.8f%15.10f%10s\n",orblabel[i],orbocc[i],orbenergy[i],orbr[i],orbenergy[i]<ecoreval?"core":"valence"
    print "[info|init] spin charge partition : "
    printf "[info|init] %5s%15s%15s%15s\n","","inside sphere","outside sphere","total"
    printf "[info|init] %5s%15.10f%15.10f%15.10f\n","alpha",spherespin[1],totalspin[1]-spherespin[1],totalspin[1]
    printf "[info|init] %5s%15.10f%15.10f%15.10f\n","beta",spherespin[2],totalspin[2]-spherespin[2],totalspin[2]
    printf "[info|init] %s%s%s%15.10f\n","core leaking (",atom,") : ",coreleak
    norb = 0
}
