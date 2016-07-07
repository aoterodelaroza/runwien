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
/gmin/{ gmin = $NF }
/gmax/{ gmax = $NF }
/KXMAX,KYMAX,KZMAX/{ kxmax = $2; kymax = $3; kzmax = $4}
/PLANE WAVES GENERATED/{ pw = $1 }
END{
    print "[info|prescf] gmin = " gmin ", gmax = " gmax
    print "[info|prescf] kmax = (" kxmax","kymax","kzmax")"
    print "[info|prescf] number of plane waves = " pw
}
