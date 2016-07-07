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
BEGIN{
    runtype = ARGV[1]
    for (i=1;i<=ARGC-2;i++){
	ARGV[i] = ARGV[i+1]
    }
    ARGC = ARGC-1
}
/FINAL REPORT/{ 
    flag = "finalreport"
    filename = FILENAME
    cps = 0
    ncps = 0
    bcps = 0
    rcps = 0
    ccps = 0
    nnms = 0
}
$1 ~ /[0-9]+/ && flag == "finalreport"{
    cps++
    pg[$1] = $2
    if (length($3) > 3)
	target = $4
    else
	target = $5
    if (target ~ /Nucleus/){
	if ($10 ~ /Nm/){
	    nnms++
	    type[$1] = "nnm"
	}
	else{
	    ncps++
	    type[$1] = "ncp"
	}
    }
    else if (target ~ /Bond/){
	bcps++
	type[$1] = "bcp"
    }
    else if (target ~ /Ring/){
	rcps++
	type[$1] = "rcp"
    }
    else if (target ~ /Cage/){
	ccps++
	type[$1] = "ccp"
    }
    if (length($3) > 3){
	x[$1] = $6
	y[$1] = $7
	z[$1] = $8
	mult[$1] = $9
    }
    else{
	x[$1] = $7
	y[$1] = $8
	z[$1] = $9
	mult[$1] = $10
    }
}
/Morse Sum equals/ && flag == "finalreport"{
    morsesum = $5
    flag = ""
}
/ CRIT\. POINT\. No:/{
    cpnum = $4
    flag = "critpoints"
}
/ModGradient , Rho, Laplacian/ && flag == "critpoints"{
    grad[cpnum] = $6
    rho[cpnum] = $7
    if (type[cpnum] == "ncp"){
	lap[cpnum] = 0.0
    }
    else
	lap[cpnum] = $8
}
/timer:/ && flag == "critpoints"{
    flag = ""
    #
    if (runtype == "summary"){
	print "filename  : ", filename
	printf "%3s %6s %4s %4s %10s %10s %10s %10s %10s %10s\n","num","pgroup","type","mult","x","y","z","rho","grad","lap"
	for (i=1;i<=cps;i++){
	    printf "%3i %6s %4s %4i %10.7f %10.7f %10.7f %10.7f %10.7f %10.7f\n",i,pg[i],type[i],mult[i],x[i],y[i],z[i],rho[i],grad[i],lap[i]
	}
	print "morse sum equals : " morsesum
	printf "\n"
    }
    if (runtype == "planarity"){
	rhomin = 1e25
	rhomax = 0
	for (i=1;i<=cps;i++){
	    if (rho[i]<rhomin){
		rhomin = rho[i]
	    }
	    if (rho[i]>rhomax && type[i] == "bcp"){
		rhomax = rho[i]
	    }
	}
	if (rhomax)
	    planarity = rhomin/rhomax
	else
	    planarity = "NaN"
	print planarity
    }
    if (runtype == "morsesum"){
	print morsesum
    }
    if (runtype == "topology"){
	string = ncps"["
	for (i=1;i<=ncps;i++){
	    current = 1000
	    for (j=1;j<=ncps;j++){
		if (used[j])
		    continue
		if (mult[j] <= current){
		    current = mult[j]
		    currentindex = j
		}
	    }
	    used[currentindex] = 1
	    string = string current
	    if (i<ncps)
		string = string ","
	}
	string = string "]("

	if (!nnms)
	    string = string "0)|"
	else{
	    string = string nnms"["
	    for (i=1;i<=nnms;i++){
		current = 1000
		for (j=ncps+1;j<=ncps+nnms;j++){
		    if (used[j])
			continue
		    if (mult[j] <= current){
			current = mult[j]
			currentindex = j
		    }
		}
		used[currentindex] = 1
		string = string current
		if (i<nnms)
		    string = string ","
	    }
	    string = string "])|"
	}

	string = string bcps"["
	for (i=1;i<=bcps;i++){
	    current = 1000
	    for (j=ncps+nnms+1;j<=ncps+nnms+bcps;j++){
		if (used[j])
		    continue
		if (mult[j] <= current){
		    current = mult[j]
		    currentindex = j
		}
	    }
	    used[currentindex] = 1
	    string = string current
	    if (i<bcps)
		string = string ","
	}
	string = string "]|"

	string = string rcps"["
	for (i=1;i<=rcps;i++){
	    current = 1000
	    for (j=ncps+nnms+bcps+1;j<=ncps+nnms+bcps+rcps;j++){
		if (used[j])
		    continue
		if (mult[j] <= current){
		    current = mult[j]
		    currentindex = j
		}
	    }
	    used[currentindex] = 1
	    string = string current
	    if (i<rcps)
		string = string ","
	}
	string = string "]|"

	string = string ccps"["
	for (i=1;i<=ccps;i++){
	    current = 1000
	    for (j=ncps+nnms+bcps+rcps+1;j<=ncps+nnms+bcps+rcps+ccps;j++){
		if (used[j])
		    continue
		if (mult[j] <= current){
		    current = mult[j]
		    currentindex = j
		}
	    }
	    used[currentindex] = 1
	    string = string current
	    if (i<ccps)
		string = string ","
	}
	string = string "]"
	print string
    }
}
