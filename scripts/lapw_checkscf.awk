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
    const_warn_unknown = 1
    const_warn_notconv = 2
    const_warn_maxiter = 3
    const_warn_efermi  = 4
    const_warn_ghost   = 5
}
/^:WARN : QTL-B value/,/^:WARN : You should change the /{
    ghost = 1
    next
}
/^:WARN/{
    unknown = 1
}
$0 ~ /^:ENE/ && $0 !~ /WARNING/{
    ghost = unknown = 0
}
END{
    if (unknown)
	print const_warn_unknown
    if (ghost)
	print const_warn_ghost
}
