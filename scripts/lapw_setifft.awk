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
    filename = ARGV[1]
    ifft = ARGV[2]
    ARGC = 2
}
(NR == 2){
    if (tolower($2) == "eece" || tolower($2) == "hybr")
	$3 = sprintf("IFFT")
    else 
	$2 = sprintf("IFFT")
}
(NR == 3){
    $0 = sprintf("-1 -1 -1 %d 1",ifft)
}
{print > "tempfile_script"}
END{
    if (NR < 3)
	printf "-1 -1 -1 %d 1\n", ifft > "tempfile_script"
    close("tempfile_script")
    system("mv tempfile_script " filename)
}
