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
    label[1] = "x"
    label[2] = "y"
    label[3] = "z"
}
/:ITE/ { nit[++it] = substr($0, 9, 3)+0 }
/:ENE/ { ene[it] = $9 }
/:POS/ { iat = substr($0, 5, 3)+0
    xyz[it,iat,1] = $6+0
    xyz[it,iat,2] = $7+0
    xyz[it,iat,3] = $8+0
    mul[it,iat] = $11+0
    if (iat > nat) { nat = iat }
}
/:FHF/ { iat = substr($0, 5, 3)+0
    fhf[it,iat,0] = $3+0
    fhf[it,iat,1] = $4+0
    fhf[it,iat,2] = $5+0
    fhf[it,iat,3] = $6+0
}
/:FOR/ { iat = substr($0, 5, 3)+0
    fxr[it,iat,0] = $3+0
    fxr[it,iat,1] = $4+0
    fxr[it,iat,2] = $5+0
    fxr[it,iat,3] = $6+0
}
/ATOMNUMBER/ {
    iat = $2+0
    atname[iat] = $3
}
/:WARNING/{
    warn[++warns] = $0
    gsub(/^ *:WARNING/,"",warn[warns])
}
END {
    # Determine fixed coordinates
    for (k=1;k<=3;k++){
	for (j=1;j<=nat;j++){
	    for (i=1;i<=it;i++){
		sumxyz[j,k] += xyz[i,j,k]
		sumxyz2[j,k] += xyz[i,j,k]^2
		sumf[j,k] += fxr[i,j,k]
		sumf2[j,k] += fxr[i,j,k]^2
	    }
	    sumxyz[j,k] /= it
	    sumxyz2[j,k] /= it
	    sumf[j,k] /= it
	    sumf2[j,k] /= it
	    xnotfixed[j,k] = ((sumxyz2[j,k] - sumxyz[j,k]^2) > 1e-15)?"y":""
	    fnotfixed[j,k] = ((sumf2[j,k] - sumf[j,k]^2) > 1e-15)?"y":""
	}
    }
    printf "[info|scf] Iterations: %d (%d--%d)\n", it, nit[1], nit[it]
    printf "[info|scf] Final E (Ry): %s    Initial E(Ry): %s\n", ene[it], ene[1]
    printf "[info|scf] Relaxation (Ry): %.6f\n", ene[it] - ene[1]
    printf "[info|scf] %4s | %*s |", "Ite", length(sprintf("%.6f",ene[1]))-1,"E (Ry)"
    for (j=1;j<=nat;j++){
	for (k=1;k<=3;k++){
	    if (xnotfixed[j,k])
		printf " %9s ",atname[j]"_"label[k]
	}
	for (k=1;k<=3;k++){
	    if (fnotfixed[j,k])
		printf "%9s |",atname[j] " F_" label[k]
	}
    }
    printf "\n"
    for (i=1;i<=it;i++){
	printf "[info|scf]"
	printf " %4d |", i
	printf "%.6f |", ene[i]
	for (j=1;j<=nat;j++){
	    for (k=1;k<=3;k++){
		if (xnotfixed[j,k])
		    printf " %9.5f ",xyz[i,j,k]
	    }
	    for (k=1;k<=3;k++){
		if (fnotfixed[j,k])
		    printf "%9.5f |",fxr[i,j,k]
	    }
	}
	printf "\n"
    }
    print "[info|scf] Warnings : "
    for (i=1;i<=warns;i++)
	print "[info|scf] " warn[i]
}
