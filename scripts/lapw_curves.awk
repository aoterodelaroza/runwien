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

BEGIN { nfile = 0; ite = 0 }

FNR==1 {
   if (nfile > 0) {
      fite[nfile] = ite
      fene[nfile] = ene[ite]
      fdis[nfile] = dis[ite]
      ffer[nfile] = fer[ite]
      fnto[nfile] = nto[ite]
      }
   nfile++
   file[nfile] = FILENAME
   ite = 0
   }

/^:ITE/ { ite++ }
/^:ENE/ { ene[ite] = $9 }
/^:DIS/ { dis[ite] = $5 }
/^:FER/ { fer[ite] = $10 }
/:NTO  :/ { nto[ite] = $6 }

END {
   fite[nfile] = ite
   fene[nfile] = ene[ite]
   fdis[nfile] = dis[ite]
   ffer[nfile] = fer[ite]
   fnto[nfile] = nto[ite]
   printf "%4s %9s %9s %12s %12s %s\n","Ite","Nto","Dis","Fer","Ene","File"
   for (f=1; f<=nfile; f++) {
      printf "%4i ", fite[f]
      printf "%9.6f ", fnto[f]
      printf "%9.6f ", fdis[f]
      printf "%12.6f ", ffer[f]
      printf "%12.6f ", fene[f]
      printf " %s ", file[f]
      printf "\n"
   }
}
