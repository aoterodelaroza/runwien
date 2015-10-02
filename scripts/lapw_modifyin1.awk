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
    neq = ARGV[2]
    rkmax = ARGV[3]
    emin = ARGV[4]
    emax = ARGV[5]
    lmax = ARGV[6]
    lnsmax = ARGV[7]
    ARGC = 2
}
NR == 2{
    if (rkmax != "auto")
	$1 = rkmax
    if (lmax != "auto")
	$2 = lmax
    if (lnsmax != "auto")
	$3 = lnsmax
}
NR == 3{
    for (j=1;j<=neq;j++){
	nchoi = $2+0
	print $0 > "tempfile_script"
	for (i=1;i<=nchoi;i++){
	    getline; 
	    print $0 > "tempfile_script"
	}
	getline
    }
    printf("%21s%10.1f%10.1f%s\n",substr($0,1,21),(emin != "auto")? emin : substr($0,22,10), \
	   (emax != "auto")? emax : substr($0,32,10), substr($0,42)) > "tempfile_script"
    next
}
{print > "tempfile_script"}
END{
    close("tempfile_script")
    system("mv tempfile_script " filename)
}
