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
    ver = "unknown"
}
/:BAND/ && ver == "unknown"{
    ver = "old"
}
/:BAN[0-9]+/ && ver == "unknown"{
    ver = "new"
}
/ITERATION/{
    emin = emax = 0 ; notfirst = ""
}
/:BAN/ && !notfirst && ver == "new" {notfirst = 1; value1 = $3}
/:BAN/ && ($3 == value1) && ver == "new" {emin = $3}
/:BAN/ && ver == "new" {emax = $4}

/:BAN/ && !notfirst && ver == "old" {notfirst = 1; value1 = $3}
/:BAN/ && ($3 == value1) && ver == "old" {emin = $4}
/:BAN/ && ver == "old" {emax = $5}
END{
    print emax
}
