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
    nms["h"] = nms["he"] = nms["li"] = nms["be"] = nms["b"] = nms["c"] = \
    nms["n"] = nms["o"] = nms["f"] = nms["ne"] = nms["na"] = nms["mg"] = \
    nms["al"] = nms["si"] = nms["p"] = nms["s"] = nms["cl"] = nms["ar"] = \
    nms["k"] = nms["ca"] = nms["sc"] = nms["ti"] = nms["v"] = nms["cr"] = \
    nms["mn"] = nms["fe"] = nms["co"] = nms["ni"] = nms["cu"] = nms["zn"] = \
    nms["ga"] = nms["ge"] = nms["as"] = nms["se"] = nms["br"] = nms["kr"] = \
    nms["rb"] = nms["sr"] = nms["y"] = nms["zr"] = nms["nb"] = nms["mo"] = \
    nms["tc"] = nms["ru"] = nms["rh"] = nms["pd"] = nms["ag"] = nms["cd"] = \
    nms["in"] = nms["sn"] = nms["sb"] = nms["te"] = nms["i"] = nms["xe"] = \
    nms["cs"] = nms["ba"] = nms["la"] = nms["ce"] = nms["pr"] = nms["nd"] = \
    nms["pm"] = nms["sm"] = nms["eu"] = nms["gd"] = nms["tb"] = nms["dy"] = \
    nms["ho"] = nms["er"] = nms["tm"] = nms["yb"] = nms["lu"] = nms["hf"] = \
    nms["ta"] = nms["w"] = nms["re"] = nms["os"] = nms["ir"] = nms["pt"] = \
    nms["au"] = nms["hg"] = nms["tl"] = nms["pb"] = nms["bi"] = nms["po"] = \
    nms["at"] = nms["rn"] = nms["fr"] = nms["ra"] = nms["ac"] = nms["th"] = \
    nms["pa"] = nms["u"] = nms["np"] = nms["pu"] = nms["am"] = nms["cm"] = \
    nms["bk"] = nms["cf"] = nms["es"] = nms["fm"] = nms["md"] = nms["no"] = \
    nms["lr"] = 1
}
NR == 1 { print }
NR == 2 { 
    lat = toupper(substr($0,1,3));
    gsub(" ","",lat)
    print lat
    nneq = substr($0,28,3)
    gsub(":","",nneq) ## not clear here... fix
    nneq = nneq + 0
    print nneq
}
NR == 3 { 
    if ($0 ~ /RELA/)
	print "yes"
    else
	print "no"
}
NR == 4 {
    print substr($0,1,10)
    print substr($0,11,10)
    print substr($0,21,10)
    print substr($0,31,10)
    print substr($0,41,10)
    print substr($0,51,10)
}
NR == 5 {
    for (i=1;i<=nneq;i++){
	print substr($0,6,3)
	print substr($0,13,10)
	print substr($0,26,10)
	print substr($0,39,10)
	getline
	mult = substr($0,16,2) +0
	print mult
	print substr($0,35,2)
	for (j=1;j<=mult-1;j++){
	    getline
	    print substr($0,13,10)
	    print substr($0,26,10)
	    print substr($0,39,10)
	}
	getline
	atom = substr($0,1,10)
	gsub(/^ */,"",atom)
	gsub(/ *$/,"",atom)
	print atom
	atom = substr(atom,1,2)
	if (tolower(atom) in nms)
	    print atom
	else{
	    atom = substr(atom,1,1)
	    print atom
	}
	print substr($0,16,5)
	print substr($0,26,10)
	print substr($0,41,10)
	getline
	getline
	getline
	getline
    }
}
