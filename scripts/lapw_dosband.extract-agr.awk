#! /usr/bin/gawk -f
#
# runwien.awk -- a wrapper for wien2k, a fplapw program
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
BEGIN {
    quote = "\""
}
/xaxis  tick major/ && !/grid on/ { nt++; xtick[nt] = $6 }
/xaxis  ticklabel/ {
    nsplit= split($0, asplit, quote)
    ltick[nt] = gensub(" ", "", "g", asplit[2])
    if (ltick[nt] ~ /\\x/) {
	ltick[nt] = gensub(/\\x./,"{/Symbol &}", "g", ltick[nt])
	ltick[nt] = gensub(/\\x/,"", "g", ltick[nt])
    }
}
END {
    fmt1 = "set arrow from %s, graph 0 to %s, graph 1 nohead\n"
    for (i=1; i<=nt; i++) {
	printf fmt1, xtick[i], xtick[i]
    }
    printf "set xtics (%s%s%s %s", quote, ltick[1], quote, xtick[1]
    for (i=2; i<=nt; i++) {
	printf ", %s%s%s %s", quote, ltick[i], quote, xtick[i]
    }
    printf ")\n"
}
