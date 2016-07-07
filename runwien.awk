#! /usr/bin/gawk -f
#
# runwien.awk -- a wrapper for wien2k, a fplapw program
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
    # runwien.awk, version: 1.0.14
    global_version = "1.0.14"

    ######################################################################################
    # User-defined variables.
    # Tune these to the appropriate values.
    ######################################################################################

    # WIEN2k version
    # Selects the appropriate interface for WIEN2k.  Runwien.awk has
    # been tested for the versions indicated below. However, there are
    # only slight changes between them (from runwien's point of
    # view). If your WIEN2k version is not included in the list,
    # modify the variable to be the release date written as
    # yyyy-mm-dd.
    const_wien2k_version = 20110512
    # const_wien2k_version = 20090929
    # const_wien2k_version = 20090502
    # const_wien2k_version = 20080918
    # const_wien2k_version = 20080421
    # const_wien2k_version = 20070220
    # const_wien2k_version = 20060824

    # System keyword
    # The system keyword is a potential security risk so it is
    # disabled by default. If you want to use the system order in your
    # scripts, swap both following lines.
    #const_allow_system = "yes"
    const_allow_system = "no"

    # Verbose output
    # If "yes", runwien writes to stdout all the commands passed to the
    # 'system' call, and the output of the relevant programs.
    const_global_verbose = "yes"
    # const_global_verbose = "no"

    # Executable file names
    # Modify these to match your system's names. Full paths are also
    # accepted. The section of the program where they are checked for existence
    # is beside the definition.

    ## Gnuplot, critic (wien version), gibbs and rename.
    const_gnuplotexe = "gnuplot"            # global
    const_renameexe = "rename"              # global
    const_criticexe = "criticw"             # critic section
    const_gibbsexe = "gibbs"                # gibbs section
    ## Optional ancillary programs
    const_tesselexe = "tessel"              # scf section, mini only
    const_convertexe = "convert"            # scf section, mini only
    const_povrayexe = "povray"              # scf section, mini only
    const_gifsicleexe = "gifsicle"          # scf section, mini only
    

    ## wien2k executables used in runwien
    const_xlapwexe = "x_lapw"                   # global
    const_instgenlapwexe = "instgen_lapw"       # init section
    const_setrmtlapwexe = "setrmt_lapw"         # init section
    const_minlapwexe = "min_lapw"               # scf section
    const_runlapwexe = "run_lapw"               # scf section
    const_runsplapwexe = "runsp_lapw"           # scf section
    const_reformatexe = "reformat"              # dos section
    const_lapw5exe = "lapw5"                    # prho section
    const_lapw5cexe = "lapw5c"                  # prho section
    const_extractaimlapwexe = "extractaim_lapw" # aim section
    const_cif2structexe = "cif2struct"          # on call
    const_cleanlapwexe = "clean_lapw"           # on call
    const_spacegroupexe = "spacegroup"          # on call

    ## runwien script names (checked at the beginning of the run)
    const_lapwexistsexe            = "lapw_exists"
    const_lapwanalyzeglobalexe     = "lapw_analyze_global.awk"
    const_lapwchangermtexe	   = "lapw_changermt.awk"
    const_lapwcheckdayfileexe	   = "lapw_checkdayfile.awk"
    const_lapwcheckgminmaxexe	   = "lapw_checkgminmax.awk"
    const_lapwcheckscfexe	   = "lapw_checkscf.awk"
    const_lapwdosbandextractagrexe = "lapw_dosband.extract-agr.awk"
    const_lapwdosbandextracteneexe = "lapw_dosband.extract-ene.awk"
    const_lapwdosreformatexe	   = "lapw_dos_reformat.awk"
    const_lapwdossumexe		   = "lapw_dos_sum.awk"
    const_lapwextractstructexe	   = "lapw_extractstruct.awk"
    const_lapwgetbandemaxexe	   = "lapw_getbandemax.awk"
    const_lapwgetbandeminexe	   = "lapw_getbandemin.awk"
    const_lapwgetcomplexexe	   = "lapw_getcomplex.awk"
    const_lapwgetcorevalexe	   = "lapw_getcoreval.awk"
    const_lapwgetdirbexe	   = "lapw_getdirb.awk"
    const_lapwgetefermiexe	   = "lapw_getefermi.awk"
    const_lapwgetefreeatomexe	   = "lapw_getefreeatom.awk"
    const_lapwgetemaxin1exe	   = "lapw_getemaxin1.awk"
    const_lapwgeteminin1exe	   = "lapw_geteminin1.awk"
    const_lapwgeteminin2exe	   = "lapw_geteminin2.awk"
    const_lapwgetesemicorevalexe   = "lapw_getesemicoreval.awk"
    const_lapwgetetotalexe	   = "lapw_getetotal.awk"
    const_lapwgetgmaxexe	   = "lapw_getgmax.awk"
    const_lapwgetgminexe	   = "lapw_getgmin.awk"
    const_lapwgetibzkptsexe	   = "lapw_getibzkpts.awk"
    const_lapwgetiterationsexe	   = "lapw_getiterations.awk"
    const_lapwgetkptsexe	   = "lapw_getkpts.awk"
    const_lapwgetleakingexe	   = "lapw_getleaking.awk"
    const_lapwgetlmaxexe	   = "lapw_getlmax.awk"
    const_lapwgetlmsin2exe	   = "lapw_getlmsin2.awk"
    const_lapwgetlnsmaxexe	   = "lapw_getlnsmax.awk"
    const_lapwgetmixexe		   = "lapw_getmix.awk"
    const_lapwgetmmtotexe	   = "lapw_getmmtot.awk"
    const_lapwgetnoeexe		   = "lapw_getnoe.awk"
    const_lapwgetnptexe		   = "lapw_getnpt.awk"
    const_lapwgetorbsin1exe	   = "lapw_getorbsin1.awk"
    const_lapwgetpwbasisexe	   = "lapw_getpwbasis.awk"
    const_lapwgetpwsexe		   = "lapw_getpws.awk"
    const_lapwgetr0exe		   = "lapw_getr0.awk"
    const_lapwgetrkmaxexe	   = "lapw_getrkmax.awk"
    const_lapwgetrkmaxrealexe	   = "lapw_getrkmaxreal.awk"
    const_lapwgetrmsexe		   = "lapw_getrms.awk"
    const_lapwgetrmtexe		   = "lapw_getrmt.awk"
    const_lapwgetspgexe		   = "lapw_getspg.awk"
    const_lapwlapw5defmodifyexe	   = "lapw_lapw5defmodify.awk"
    const_lapwmodifyin0exe	   = "lapw_modifyin0.awk"
    const_lapwmodifyin1exe	   = "lapw_modifyin1.awk"
    const_lapwmodifyin1orbexe	   = "lapw_modifyin1orb.awk"
    const_lapwmodifyin2exe	   = "lapw_modifyin2.awk"
    const_lapwmodifyin2fermiexe	   = "lapw_modifyin2fermi.awk"
    const_lapwmodifyin2lmexe	   = "lapw_modifyin2lm.awk"
    const_lapwmodifyinmexe	   = "lapw_modifyinm.awk"
    const_lapwprhoreformatexe	   = "lapw_prho_reformat.awk"
    const_lapwsetefermiexe         = "lapw_setefermi.awk"
    const_lapwsetifftexe           = "lapw_setifft.awk"
    const_struct2tessexe           = "lapw_struct2tess.sh"
    const_lapwgetdosef             = "lapw_getdosef.awk"

    # Gnuplot external scripts (checked for existence on call)
    # Associate script names with ["x","y","z"] using standard names
    # for variables. These scripts are used by the 'print' keyword in
    # the sweep section.
    const_gnuplot["a","energy",""] = "lapw_plot_e_a.gnuplot"
    const_gnuplot["v","energy",""] = "lapw_plot_e_v.gnuplot"
    const_gnuplot["a","c","energy"] = "lapw_plot_e_c_a.gnuplot"
    const_gnuplot["v","c/a","energy"] = "lapw_plot_e_ca_v.gnuplot"

    # Data extracting scripts. (checked for existence at the beginning of the run).
    # These variables point to the name of the scripts that extract
    # information and print to stdout.
    const_scfsum         = "lapw_curves.awk"
    const_criticsum 	 = "lapw_extractcritic.awk summary"
    const_extractd	 = "lapw_extractd.awk"
    const_extractdayfile = "lapw_extractdayfile.awk"
    const_extractnn	 = "lapw_extractnn.awk"
    const_extracts	 = "lapw_extracts.awk"
    const_extractscf	 = "lapw_extractscf.awk"
    const_extractsgroup	 = "lapw_extractsgroup.awk"
    const_extractst      = "lapw_extractst.awk"
    const_extractmini    = "lapw_extractmini.awk"

    # Names of the summary files
    const_scfsumout     = "scfsummary.out"
    const_elasticsumout = "elasticsummary.out"
    const_criticsumout  = "criticsummary.out"
    const_sweepsumout   = "sweepsummary.out"
    const_sweeprunout   = "runwien.out"
    const_freerunout    = "runwien.out"
    const_elasticrunout = "runwien.out"
    const_synoutput     = "synopsis.out"

    ######################################################################################
    # END of user-defined variables.
    ######################################################################################

    if (checkexe(const_gnuplotexe)){
	temp_string = const_gnuplotexe " --version | awk '{print $2 $4}'"
	temp_string | getline const_gnuplotversion
	close(temp_string)
	gsub(/\./,"",const_gnuplotversion)
    }
    else
	const_gnuplotversion = "400"

    const_pi = 3.1415926535897932384626433832795

    const_rybohr3togpa = 14710.50498740275538944426
    const_rytoev = 13.60569193
    const_angtobohr = 1.88972613288564

    const_rhomb2hex[1,1] = -1/3
    const_rhomb2hex[1,2] = 1/3
    const_rhomb2hex[1,3] = 1/3
    const_rhomb2hex[2,1] = 2/3
    const_rhomb2hex[2,2] = 1/3
    const_rhomb2hex[2,3] = 1/3
    const_rhomb2hex[3,1] = -1/3
    const_rhomb2hex[3,2] = -2/3
    const_rhomb2hex[3,3] = 1/3

    const_hex2rhomb[1,1] = -1
    const_hex2rhomb[1,2] = 1
    const_hex2rhomb[1,3] = 0
    const_hex2rhomb[2,1] = 1
    const_hex2rhomb[2,2] = 0
    const_hex2rhomb[2,3] = -1
    const_hex2rhomb[3,1] = 1
    const_hex2rhomb[3,2] = 1
    const_hex2rhomb[3,3] = 1

    ## warning const definitions, repeated in lapw_checkdayfile.awk
    ## and lapw_checkscf.awk
    const_warn_unknown   = 1
    const_warn_notconv   = 2
    const_warn_maxiter   = 3
    const_warn_efermi    = 4
    const_warn_ghost     = 5
    const_warn_badclmini = 6
    # Define atom symbols, numbers, masses
    define_constants()

    # Elastic section constant definitions
    const_elastic_defs["cubic"] = 3
    const_elastic_defname["cubic",1] = "111000" ; const_elastic_zero["cubic",1] = "0.0"
    const_elastic_defname["cubic",2] = "001000"	; const_elastic_zero["cubic",2] = "0.0"
    const_elastic_defname["cubic",3] = "000111" ; const_elastic_zero["cubic",3] = "0.0"
    const_elastic_def["cubic",1,"a"] = 1
    const_elastic_def["cubic",1,"b"] = 1
    const_elastic_def["cubic",1,"c"] = 1
    const_elastic_def["cubic",1,"alpha"] = 0
    const_elastic_def["cubic",1,"beta"] = 0
    const_elastic_def["cubic",1,"gamma"] = 0
    const_elastic_def["cubic",2,"a"] = 0
    const_elastic_def["cubic",2,"b"] = 0
    const_elastic_def["cubic",2,"c"] = 1
    const_elastic_def["cubic",2,"alpha"] = 0
    const_elastic_def["cubic",2,"beta"] = 0
    const_elastic_def["cubic",2,"gamma"] = 0
    const_elastic_def["cubic",3,"a"] = 0
    const_elastic_def["cubic",3,"b"] = 0
    const_elastic_def["cubic",3,"c"] = 0
    const_elastic_def["cubic",3,"alpha"] = 1
    const_elastic_def["cubic",3,"beta"] = 1
    const_elastic_def["cubic",3,"gamma"] = 1
    const_elastic_defs["hexagonal"] = 5
    const_elastic_defname["hexagonal",1] = "111000" ; const_elastic_zero["hexagonal",1] = "0.0"
    const_elastic_defname["hexagonal",2] = "110000" ; const_elastic_zero["hexagonal",2] = "0.0"
    const_elastic_defname["hexagonal",3] = "001000" ; const_elastic_zero["hexagonal",3] = "0.0"
    const_elastic_defname["hexagonal",4] = "000110" ; const_elastic_zero["hexagonal",4] = "0.0"
    const_elastic_defname["hexagonal",5] = "000001" ; const_elastic_zero["hexagonal",5] = "-0.5"
    const_elastic_def["hexagonal",1,"a"] = 1
    const_elastic_def["hexagonal",1,"b"] = 1
    const_elastic_def["hexagonal",1,"c"] = 1
    const_elastic_def["hexagonal",1,"alpha"] = 0
    const_elastic_def["hexagonal",1,"beta"] = 0
    const_elastic_def["hexagonal",1,"gamma"] = 0
    const_elastic_def["hexagonal",2,"a"] = 1
    const_elastic_def["hexagonal",2,"b"] = 1
    const_elastic_def["hexagonal",2,"c"] = 0
    const_elastic_def["hexagonal",2,"alpha"] = 0
    const_elastic_def["hexagonal",2,"beta"] = 0
    const_elastic_def["hexagonal",2,"gamma"] = 0
    const_elastic_def["hexagonal",3,"a"] = 0
    const_elastic_def["hexagonal",3,"b"] = 0
    const_elastic_def["hexagonal",3,"c"] = 1
    const_elastic_def["hexagonal",3,"alpha"] = 0
    const_elastic_def["hexagonal",3,"beta"] = 0
    const_elastic_def["hexagonal",3,"gamma"] = 0
    const_elastic_def["hexagonal",4,"a"] = 0
    const_elastic_def["hexagonal",4,"b"] = 0
    const_elastic_def["hexagonal",4,"c"] = 0
    const_elastic_def["hexagonal",4,"alpha"] = 1
    const_elastic_def["hexagonal",4,"beta"] = 1
    const_elastic_def["hexagonal",4,"gamma"] = 0
    const_elastic_def["hexagonal",5,"a"] = 0
    const_elastic_def["hexagonal",5,"b"] = 0
    const_elastic_def["hexagonal",5,"c"] = 0
    const_elastic_def["hexagonal",5,"alpha"] = 0
    const_elastic_def["hexagonal",5,"beta"] = 0
    const_elastic_def["hexagonal",5,"gamma"] = 1
    const_elastic_defs["tetragonal1"] = 6
    const_elastic_defname["tetragonal1",1] = "111000" ; const_elastic_zero["tetragonal1",1] = "0.0"
    const_elastic_defname["tetragonal1",2] = "110000" ; const_elastic_zero["tetragonal1",2] = "0.0"
    const_elastic_defname["tetragonal1",3] = "001000" ; const_elastic_zero["tetragonal1",3] = "0.0"
    const_elastic_defname["tetragonal1",4] = "010000" ; const_elastic_zero["tetragonal1",4] = "0.0"
    const_elastic_defname["tetragonal1",5] = "000010" ; const_elastic_zero["tetragonal1",5] = "0.0"
    const_elastic_defname["tetragonal1",6] = "000001" ; const_elastic_zero["tetragonal1",6] = "0.0"
    const_elastic_def["tetragonal1",1,"a"] = 1
    const_elastic_def["tetragonal1",1,"b"] = 1
    const_elastic_def["tetragonal1",1,"c"] = 1
    const_elastic_def["tetragonal1",1,"alpha"] = 0
    const_elastic_def["tetragonal1",1,"beta"] = 0
    const_elastic_def["tetragonal1",1,"gamma"] = 0
    const_elastic_def["tetragonal1",2,"a"] = 1
    const_elastic_def["tetragonal1",2,"b"] = 1
    const_elastic_def["tetragonal1",2,"c"] = 0
    const_elastic_def["tetragonal1",2,"alpha"] = 0
    const_elastic_def["tetragonal1",2,"beta"] = 0
    const_elastic_def["tetragonal1",2,"gamma"] = 0
    const_elastic_def["tetragonal1",3,"a"] = 0
    const_elastic_def["tetragonal1",3,"b"] = 0
    const_elastic_def["tetragonal1",3,"c"] = 1
    const_elastic_def["tetragonal1",3,"alpha"] = 0
    const_elastic_def["tetragonal1",3,"beta"] = 0
    const_elastic_def["tetragonal1",3,"gamma"] = 0
    const_elastic_def["tetragonal1",4,"a"] = 0
    const_elastic_def["tetragonal1",4,"b"] = 1
    const_elastic_def["tetragonal1",4,"c"] = 0
    const_elastic_def["tetragonal1",4,"alpha"] = 0
    const_elastic_def["tetragonal1",4,"beta"] = 0
    const_elastic_def["tetragonal1",4,"gamma"] = 0
    const_elastic_def["tetragonal1",5,"a"] = 0
    const_elastic_def["tetragonal1",5,"b"] = 0
    const_elastic_def["tetragonal1",5,"c"] = 0
    const_elastic_def["tetragonal1",5,"alpha"] = 0
    const_elastic_def["tetragonal1",5,"beta"] = 1
    const_elastic_def["tetragonal1",5,"gamma"] = 0
    const_elastic_def["tetragonal1",6,"a"] = 0
    const_elastic_def["tetragonal1",6,"b"] = 0
    const_elastic_def["tetragonal1",6,"c"] = 0
    const_elastic_def["tetragonal1",6,"alpha"] = 0
    const_elastic_def["tetragonal1",6,"beta"] = 0
    const_elastic_def["tetragonal1",6,"gamma"] = 1

    # Functions for elastic fitting of data
    const_elastic_f[2] = "f(x) = c0 + (x-x0) * (c1 + (x-x0) * (c2))"
    const_elastic_f[4] = "f(x) = c0 + (x-x0) * (c1 + (x-x0) * (c2 + (x-x0) * (c3 + (x-x0) * (c4))))"
    const_elastic_f[6] = "f(x) = c0 + (x-x0) * (c1 + (x-x0) * (c2 + (x-x0) * (c3 + (x-x0) * (c4 + (x-x0) * (c5 + (x-x0) * (c6))))))"
    const_elastic_f[8] = "f(x) = c0 + (x-x0) * (c1 + (x-x0) * (c2 + (x-x0) * (c3 + (x-x0) * (c4 + (x-x0) * (c5 + (x-x0) * (c6 + (x-x0) * (c7 + (x-x0) * (c8))))))))"
    const_elastic_f_1[2] = "f(x) = c0 + (x-x0)**2 * c2"
    const_elastic_f_1[4] = "f(x) = c0 + (x-x0)**2 * (c2 + (x-x0) * (c3 + (x-x0) * (c4)))"
    const_elastic_f_1[6] = "f(x) = c0 + (x-x0)**2 * (c2 + (x-x0) * (c3 + (x-x0) * (c4 + (x-x0) * (c5 + (x-x0) * (c6)))))"
    const_elastic_f_1[8] = "f(x) = c0 + (x-x0)**2 * (c2 + (x-x0) * (c3 + (x-x0) * (c4 + (x-x0) * (c5 + (x-x0) * (c6 + (x-x0) * (c7 + (x-x0) * (c8)))))))"
    const_elastic_g[2] = "g(x) = 2 * c2 "
    const_elastic_g[4] = "g(x) = 2 * c2 + (x-x0) * (6 * c3 + (x-x0) * (12 * c4))"
    const_elastic_g[6] = "g(x) = 2 * c2 + (x-x0) * (6 * c3 + (x-x0) * (12 * c4 + (x-x0) * (20 * c5 + (x-x0) * (30 * c6))))"
    const_elastic_g[8] = "g(x) = 2 * c2 + (x-x0) * (6 * c3 + (x-x0) * (12 * c4 + (x-x0) * (20 * c5 + (x-x0) * (30 * c6 + (x-x0) * (42 * c7 + (x-x0) * (58 * c8))))))"

    # defined global vars
    const_global_var["elastic_forcefit"] = 1

    # global definitions
    "pwd" | getline global_pwd
    close("pwd")
    "hostname" | getline global_machine
    close("hostname")
    global_root = ARGV[1]
    gsub(/\.wien/,"",global_root)
    # Print copyright notice
    print "Welcome to runwien.awk, version : " global_version "..."
    print ""
    print "Copyright (c) 2007 Alberto Otero <aoterodelaroza@gmail.com> and "
    print " Víctor Luaña <victor@carbono.quimica.uniovi.es>. Universidad de Oviedo."
    print "									     "
    print "runwien.awk is free software: you can redistribute it and/or modify   "
    print "it under the terms of the GNU General Public License as published by  "
    print "the Free Software Foundation, either version 3 of the License, or (at "
    print "your option) any later version. 					     "
    print "									     "
    print "runwien.awk is distributed in the hope that it will be useful,	     "
    print "but WITHOUT ANY WARRANTY; without even the implied warranty of	     "
    print "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	     "
    print "GNU General Public License for more details.			     "
    print "									     "
    print "You should have received a copy of the GNU General Public License     "
    print "along with this program.  If not, see <http://www.gnu.org/licenses/>. "
    print ""

    # check for runwien scritps, gnuplot, rename, extracting scripts
    print "[info|global] Checking for executables..."
    delete temp_array
    temp_array[const_lapwexistsexe] = temp_array[const_lapwanalyzeglobalexe] = temp_array[const_lapwchangermtexe] = \
    temp_array[const_lapwcheckdayfileexe] = temp_array[const_lapwcheckgminmaxexe] = temp_array[const_lapwcheckscfexe] =\
    temp_array[const_lapwdosbandextractagrexe] = temp_array[const_lapwdosbandextracteneexe] = temp_array[const_lapwdosreformatexe] =\
    temp_array[const_lapwdossumexe] = temp_array[const_lapwextractstructexe] = temp_array[const_lapwgetbandemaxexe] =\
    temp_array[const_lapwgetbandeminexe] = temp_array[const_lapwgetcomplexexe] = temp_array[const_lapwgetcorevalexe] =\
    temp_array[const_lapwgetdirbexe] = temp_array[const_lapwgetefermiexe] = temp_array[const_lapwgetefreeatomexe] =\
    temp_array[const_lapwgetemaxin1exe] = temp_array[const_lapwgeteminin1exe] = temp_array[const_lapwgeteminin2exe] =\
    temp_array[const_lapwgetesemicorevalexe] = temp_array[const_lapwgetetotalexe] = temp_array[const_lapwgetgmaxexe] =\
    temp_array[const_lapwgetgminexe] = temp_array[const_lapwgetibzkptsexe] = temp_array[const_lapwgetiterationsexe] =\
    temp_array[const_lapwgetkptsexe] = temp_array[const_lapwgetleakingexe] = temp_array[const_lapwgetlmaxexe] =\
    temp_array[const_lapwgetlmsin2exe] = temp_array[const_lapwgetlnsmaxexe] = temp_array[const_lapwgetmixexe] =\
    temp_array[const_lapwgetmmtotexe] = temp_array[const_lapwgetnoeexe] = temp_array[const_lapwgetnptexe] =\
    temp_array[const_lapwgetorbsin1exe] = temp_array[const_lapwgetpwbasisexe] = temp_array[const_lapwgetpwsexe] =\
    temp_array[const_lapwgetr0exe] = temp_array[const_lapwgetrkmaxexe] = temp_array[const_lapwgetrkmaxrealexe] =\
    temp_array[const_lapwgetrmsexe] = temp_array[const_lapwgetrmtexe] = temp_array[const_lapwgetspgexe] =\
    temp_array[const_lapwlapw5defmodifyexe] = temp_array[const_lapwmodifyin0exe] = temp_array[const_lapwmodifyin1exe] =\
    temp_array[const_lapwmodifyin1orbexe] = temp_array[const_lapwmodifyin2exe] = temp_array[const_lapwmodifyin2fermiexe] =\
    temp_array[const_lapwmodifyin2lmexe] = temp_array[const_lapwmodifyinmexe] = temp_array[const_lapwprhoreformatexe] =\
    temp_array[const_lapwsetefermiexe] = temp_array[const_lapwsetifftexe] = \
    temp_array[const_scfsum] = temp_array[const_criticsum] = temp_array[const_extractd] =\
    temp_array[const_extractdayfile] = temp_array[const_extractnn] = temp_array[const_extracts] =\
    temp_array[const_extractscf] = temp_array[const_extractsgroup] = temp_array[const_extractst] =\
    temp_array[const_extractmini] = \
    temp_array[const_gnuplotexe] = temp_array[const_renameexe] = temp_array[const_xlapwexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|global] Runwien script not found: " i
	    exit 1
	}
    }

    # Check directory / root consistency
    print "[info|global] Checking root consistency..."
    temp_val = split(global_pwd,temp_array,"/")
    if (temp_array[temp_val] != global_root){
	print "[error|global] Directory is not equal to file's root."
	print "[error|global] This will lead to problems when running wien."
	exit 1
    }
    # Create check dir
    print "[info|global] Creating check directory..."
    mysystem("mkdir " global_root "-check > /dev/null 2>&1")
}
# Do not read comments or blank lines
/^( |\t)*#/||/^( |\t)*$/{next}
# Save original capped line in the variable "capline" and convert $0 to lowercase
# Split capped line into global_capfield array
{ global_capline = $0 ; $0 = tolower($0); split(global_capline,global_capfield," ")}
# Set section, set initial values, required at input reading time
/^( |\t)*general( |\t)*$/ && !global_section {
    global_section = "general"
    general_alsos = 1
    next
}
/^( |\t)*initialization( |\t)*$/ && !global_section { global_section = "initialization";next}
/^( |\t)*initialization( |\t)*default( |\t)*$/ && !global_section {
    global_section = "initialization"
    $0 = "end initialization"
}
/^( |\t)*prescf( |\t)*$/ && !global_section { global_section = "prescf";next}
/^( |\t)*prescf( |\t)*default( |\t)*$/ && !global_section {
    global_section = "prescf"
    $0 = "end prescf"
}
/^( |\t)*scf( |\t)*$/ && !global_section { global_section = "scf";next}
/^( |\t)*scf( |\t)*default( |\t)*$/ && !global_section {
    global_section = "scf"
    $0 = "end scf"
}
/^( |\t)*spinorbit( |\t)*$/ && !global_section { 
    global_section = "spinorbit"
    so_addlos = ""
    so_excludes = ""
    so_newemax = ""
    next
}
/^( |\t)*spinorbit( |\t)*default( |\t)*$/ && !global_section {
    global_section = "spinorbit"
    so_addlos = ""
    so_excludes = ""
    so_newemax = ""
    $0 = "end scf"
}
/^( |\t)*elastic( |\t)*$/ && !global_section { 
    global_section = "elastic"
    elastic_ldaus = ""
    next
}
/^( |\t)*elastic( |\t)*default( |\t)*$/ && !global_section {
    global_section = "elastic"
    elastic_ldaus = ""
    $0 = "end elastic"
}
/^( |\t)*free( |\t)*$/ && !global_section {
    global_section = "free"
    free_atom = ""
    next
}
/^( |\t)*free( |\t)*default( |\t)*$/ && !global_section {
    global_section = "free"
    $0 = "end free"
}
/^( |\t)*printrho( |\t)*$/ && !global_section { global_section = "printrho";next}
/^( |\t)*printrho( |\t)*default( |\t)*$/ && !global_section {
    global_section = "printrho"
    $0 = "end printrho"
}
/^( |\t)*dosplot( |\t)*$/ && !global_section { global_section = "dosplot";next}
/^( |\t)*dosplot( |\t)*default( |\t)*$/ && !global_section {
    global_section = "dosplot"
    dos_joins = 0
    $0 = "end dosplot"
}
/^( |\t)*rxplot( |\t)*$/ && !global_section { global_section = "rxplot";next}
/^( |\t)*rxplot( |\t)*default( |\t)*$/ && !global_section {
    global_section = "rxplot"
    $0 = "end rxplot"
}
/^( |\t)*bandplot( |\t)*$/ && !global_section { global_section = "bandplot";next}
/^( |\t)*bandplot( |\t)*default( |\t)*$/ && !global_section {
    global_section = "bandplot"
    $0 = "end bandplot"
}
/^( |\t)*kdos( |\t)*$/ && !global_section { global_section = "kdos";next}
/^( |\t)*kdos( |\t)*default( |\t)*$/ && !global_section {
    global_section = "kdos"
    kdos_nkdos = 0
    $0 = "end kdos"
}
/^( |\t)*aim( |\t)*$/ && !global_section { global_section = "aim";next}
/^( |\t)*aim( |\t)*default( |\t)*$/ && !global_section {
    global_section = "aim"
    $0 = "end aim"
}
/^( |\t)*critic( |\t)*$/ && !global_section { global_section = "critic";next}
/^( |\t)*critic( |\t)*default( |\t)*$/ && !global_section {
    global_section = "critic"
    $0 = "end critic"
}
/^( |\t)*sweep( |\t)*$/ && !global_section {
    global_section = "sweep"
    sweep_ldaus = ""
    sweep_alsos = 1
    next
}
/^( |\t)*gibbs( |\t)*$/ && !global_section { global_section = "gibbs";next}
/^( |\t)*gibbs( |\t)*default( |\t)*$/ && !global_section {
    global_section = "gibbs"
    $0 = "end gibbs"
}
/^( |\t)*synopsis( |\t)*$/ && !global_section { global_section = "synopsis";next}
/^( |\t)*synopsis( |\t)*default( |\t)*$/ && !global_section {
    global_section = "synopsis"
    $0 = "end synopsis"
}
# (iglobali) Global keywords, outside any section
/^( |\t)*set/ && !global_section {
    if (!($2"" in const_global_var))
	print "[warn|global] Global variable " $2 " is not defined."
    if ($3 == "0" || $3 == "false" || $3 == ".false." || $3 == "f"){
	print "[info|global] Setting variable " $2 " to: false "
	global_var[$2""] = ""
    }
    else{
	print "[info|global] Setting variable " $2 " to: true "
	global_var[$2""] = 1
    }
    next
}
/^( |\t)*exit/ && !global_section {
    print "[info|global] Caught an exit, bye..."
    exit
}
/^( |\t)*clean( |\t)*$/ && !global_section {
    print "[info|global] Cleaning .vector* and .help* files..."
    for (i=1;i<=general_iterations;i++){
	mysystem("rm -f " global_root sprintf("%0*d",general_pad,i) "/" global_root sprintf("%0*d",general_pad,i) ".vector* > /dev/null 2>&1")
	mysystem("rm -f " global_root sprintf("%0*d",general_pad,i) "/" global_root sprintf("%0*d",general_pad,i) ".help* > /dev/null 2>&1")
    }
    print "[info|global] General iterations : " general_iterations " cleaned"
    if (sweep_run){
	for (i=1;i<=sweep_iterations;i++){
	    sweep_root = global_root "-sweep"
	    mysystem("rm -f " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/"  sweep_root sprintf("%0*d",sweep_pad,i) "1/" sweep_root sprintf("%0*d",sweep_pad,i) "1.vector* > /dev/null 2>&1")
	    mysystem("rm -f " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/"  sweep_root sprintf("%0*d",sweep_pad,i) "1/" sweep_root sprintf("%0*d",sweep_pad,i) "1.help* > /dev/null 2>&1")
	}
	print "[info|global] Sweep iterations : " sweep_iterations " cleaned"
    }
    next
}
/^( |\t)*clean( |\t)*full( |\t)*$/ && !global_section {
    print "[info|global] Full-cleaning files..."
    ## Saved files...
    temp_string = "clmsum|clmup|clmdn|struct|in1|in2|in1c|in2c|inm|klist|outputst|outputd|scf|dayfile|incritic|outputcritic|ingibbs|outputgibbs|ps|eps|pdf|index|out|outputkgen"
    print "#! /bin/bash" > "clean-script"
    print "shopt -s extglob" > "clean-script"
    for (i=1;i<=general_iterations;i++){
	print "cd " global_root sprintf("%0*d",general_pad,i) > "clean-script"
	print "rm -f " global_root sprintf("%0*d",general_pad,i) ".!(" temp_string ") > /dev/null 2>&1" > "clean-script"
	print "cd .." > "clean-script"
    }
    if (sweep_run){
	for (i=1;i<=sweep_iterations;i++){
	    sweep_root = global_root "-sweep"
	    print "cd " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/"  sweep_root sprintf("%0*d",sweep_pad,i) "1/" > "clean-script"
	    print "rm -f "  sweep_root sprintf("%0*d",sweep_pad,i) "1.!(" temp_string ") > /dev/null 2>&1" > "clean-script"
	    print "cd ../../.." > "clean-script"
	}
    }
    close("clean-script")
    mysystem("chmod u+x clean-script")
    mysystem("./clean-script")
    mysystem("rm -f clean-script")
    print "[info|global] General iterations : " general_iterations " cleaned"
    print "[info|global] Sweep iterations : " sweep_iterations " cleaned"
    next
}
/^( |\t)*clean( |\t)*wien( |\t)*$/ && !global_section {
    print "[info|global] Wien2k-cleaning files..."
    if (!checkexe(const_cleanlapwexe)){
	print "[error|global] clean_lapw executable not found."
	exit 1
    }
    print "#! /bin/bash" > "clean-script"
    for (i=1;i<=general_iterations;i++){
	print "cd " global_root sprintf("%0*d",general_pad,i) > "clean-script"
	print const_cleanlapwexe " -s > /dev/null 2>&1" > "clean-script"
	print "cd .." > "clean-script"
    }
    if (sweep_run){
	for (i=1;i<=sweep_iterations;i++){
	    sweep_root = global_root "-sweep"
	    print "cd " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/"  sweep_root sprintf("%0*d",sweep_pad,i) "1/" > "clean-script"
	    print const_cleanlapwexe " -s > /dev/null 2>&1" > "clean-script"
	    print "cd ../../.." > "clean-script"
	}
    }
    close("clean-script")
    mysystem("chmod u+x clean-script")
    mysystem("./clean-script")
    mysystem("rm -f clean-script")
    print "[info|global] General iterations : " general_iterations " cleaned"
    print "[info|global] Sweep iterations : " sweep_iterations " cleaned"
    next
}
/^( |\t)*undo/ && !global_section {
    temp_string = rm_keyword("undo",$0)
    if (temp_string == "gibbs"){
	print "[info|global] Undoing gibbs..."
	mysystem("rm -rf " global_root "-gibbs/ > /dev/null 2>&1")
	mysystem("rm -f " global_root "-check/gibbs.check > /dev/null 2>&1")
    }
    else if (temp_string == "elastic"){
	print "[info|global] Undoing elastic..."
	mysystem("rm -rf " global_root "-elastic > /dev/null 2>&1")
	mysystem("rm -f " global_root "-check/elastic.check > /dev/null 2>&1")
    }
    else if (temp_string == "free"){
	print "[info|global] Undoing free..."
	mysystem("rm -rf " global_root "-free > /dev/null 2>&1")
	mysystem("rm -f " global_root "-check/free.check > /dev/null 2>&1")
    }
    else if (temp_string == "critic"){
	print "[info|global] Undoing critic..."
	print "#! /bin/bash" > "clean-script"
	print "for i in " global_root "*/ ; do" > "clean-script"
	print "cd ${i}" > "clean-script"
	print "rm -f *.incritic > /dev/null 2>&1" > "clean-script"
	print "rm -f *.outputcritic > /dev/null 2>&1" > "clean-script"
	print "cd .." > "clean-script"
	print "done" > "clean-script"
	close("clean-script")
	mysystem("chmod u+x clean-script")
	mysystem("./clean-script")
	mysystem("rm -f clean-script")
	mysystem("rm -f " global_root "-check/critic.check > /dev/null 2>&1")
    }
    else if (temp_string == "sweep"){
	print "[info|global] Undoing sweep..."
	mysystem("rm -rf " global_root "-sweep > /dev/null 2>&1")
	mysystem("rm -f " global_root "-check/sweep.check > /dev/null 2>&1")
    }
    else{
	print "[warn|global] undo section not recognized."
	print "[warn|global] must be one of critic, sweep, gibbs, elastic, free."
	print "[warn|global] ignoring undo keyword."
    }
    next
}
/^( |\t)*loadcheck/ && !global_section {
    if (general_run || sweep_run){
	print "[error|global] Loading previous calculations must be done before running any section."
	print "[error|global] loadcheck line must go before general and sweep section."
	exit 1
    }
    print "[info|global] Reading checks..."
    if (checkexists(global_root "-check/global.check")){
	print "[info|global] Reading global section check..."
	global_loadcheck(global_root "-check/global.check")
    }
    if (checkexists(global_root "-check/general.check")){
	print "[info|global] Reading general section check..."
	general_loadcheck(global_root "-check/general.check")
    }
    if (checkexists(global_root "-check/init.check")){
	print "[info|global] Reading initialization section check..."
	init_loadcheck(global_root "-check/init.check")
    }
    if (checkexists(global_root "-check/prescf.check") && $0 !~ "without_prescf"){
	print "[info|global] Reading prescf section check..."
	prescf_loadcheck(global_root "-check/prescf.check")
    }
    if (checkexists(global_root "-check/scf.check") && $0 !~ "without_scf"){
	print "[info|global] Reading scf section check..."
	scf_loadcheck(global_root "-check/scf.check")
    }
    if (checkexists(global_root "-check/so.check") && $0 !~ "without_so"){
	print "[info|global] Reading spinorbit section check..."
	so_loadcheck(global_root "-check/so.check")
    }
    if (checkexists(global_root "-check/elastic.check") && $0 !~ "without_elastic"){
	print "[info|global] Reading elastic section check..."
	elastic_loadcheck(global_root "-check/elastic.check")
    }
    if (checkexists(global_root "-check/free.check") && $0 !~ "without_free"){
	print "[info|global] Reading free section check..."
	free_loadcheck(global_root "-check/free.check")
    }
    if (checkexists(global_root "-check/prho.check") && $0 !~ "without_prho"){
	print "[info|global] Reading printrho section check..."
	prho_loadcheck(global_root "-check/prho.check")
    }
    if (checkexists(global_root "-check/dos.check") && $0 !~ "without_dos"){
	print "[info|global] Reading dosplot section check..."
	dos_loadcheck(global_root "-check/dos.check")
    }
    if (checkexists(global_root "-check/rx.check") && $0 !~ "without_rx"){
	print "[info|global] Reading rxplot section check..."
	rx_loadcheck(global_root "-check/rx.check")
    }
    if (checkexists(global_root "-check/band.check") && $0 !~ "without_band"){
	print "[info|global] Reading bandplot section check..."
	band_loadcheck(global_root "-check/band.check")
    }
    if (checkexists(global_root "-check/kdos.check") && $0 !~ "without_kdos"){
	print "[info|global] Reading kdos section check..."
	kdos_loadcheck(global_root "-check/kdos.check")
    }
    if (checkexists(global_root "-check/aim.check") && $0 !~ "without_aim"){
	print "[info|global] Reading aim section check..."
	aim_loadcheck(global_root "-check/aim.check")
    }
    if (checkexists(global_root "-check/critic.check") && $0 !~ "without_critic"){
	print "[info|global] Reading critic section check..."
	critic_loadcheck(global_root "-check/critic.check")
    }
    if (checkexists(global_root "-check/sweep.check") && $0 !~ "without_sweep"){
	print "[info|global] Reading sweep section check..."
	sweep_loadcheck(global_root "-check/sweep.check")
    }
    if (checkexists(global_root "-check/gibbs.check") && $0 !~ "without_gibbs"){
	print "[info|global] Reading gibbs section check..."
	gibbs_loadcheck(global_root "-check/gibbs.check")
    }
    if (checkexists(global_root "-check/syn.check") && $0 !~ "without_syn"){
	print "[info|global] Reading synopsis section check..."
	syn_loadcheck(global_root "-check/syn.check")
    }
    print "[info|global] Saving old iterations..."
    # Save old general iterations
    general_olditerations = general_iterations
    # Save old sweep iterations
    if (sweep_iterations){
	sweep_olditerations = sweep_iterations
    }
    # Reread if required
    if ($2 == "reread"){
	print "[info|global] Rereading structure information..."
	global_reread()
    }
    next
}
/^( |\t)*do( |\t)+/ && !global_section {
    $0 = rm_keyword("do",$0)
    # Interpretation of do data is deferred until I know how many
    # old and new iterations I have.
    global_dolines++
    global_doline[global_dolines] = $0
    global_dotype[global_dolines] = "do"
    next
}
/^( |\t)*except/ && !global_section {
    $0 = rm_keyword("except",$0)
    # Interpretation of except data is deferred until I know how many
    # old and new iterations I have.
    global_dolines++
    global_doline[global_dolines] = $0
    global_dotype[global_dolines] = "except"
    next
}
/^( |\t)*system/ && !global_section && const_allow_system == "yes"{
    $0 = rm_keyword("system",$0)
    mysystem($0)
    next
}
/^( |\t)*parallel/ && !global_section {
    temp_string = rm_keyword(global_capfield[1],global_capline)
    if (temp_string ~ /^ *$/)
	global_parallel = ""
    else{
	global_parallel = "-p"
	global_machines = temp_string
	if (!checkexists(global_machines)){
	    print "[error|global] .machines file not found : "
	    print "[error|global] " global_machines
	    exit 1
	}
    }
    next
}
/^( |\t)*duplicate/ && !global_section {
    $0 = rm_keyword("duplicate",$0)
    temp_val = general_iterations
    list_parser($0)
    for (i=1;i<=global_niter;i++){
	for(x=1;x<=global_num[i];x++){
	    j = global_ini[i] + (x-1)*global_incr[i]
	    if (j < 1 || j > temp_val || !general_done[j]){
		print "[warn|global] Duplicate: iteration not found or not initialized : " j
		continue
	    }
	    # Increase iterations and repad if necessary
	    general_iterations++
	    general_oldpad = general_pad
	    general_pad = int(0.4343*log(general_iterations))+1
	    if (general_pad != general_oldpad){
		print "[info|global] Padding has changed, renaming..."
		for (k=1;k<=general_iterations-1;k++){
		    general_filename[k] = global_root sprintf("%0*d",general_pad,k) ".struct"
		    mysystem("mv -f " global_root sprintf("%0*d",general_oldpad,k) "/ " global_root sprintf("%0*d",general_pad,k) " > /dev/null 2>&1")
		    mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,k) "/"global_root sprintf("%0*d",general_pad,k)"/' " global_root sprintf("%0*d",general_pad,k)"/*")
		    mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,k) "/"global_root sprintf("%0*d",general_pad,k)"/' " global_root sprintf("%0*d",general_pad,k)"/*/*")
		    mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,k) "/"global_root sprintf("%0*d",general_pad,k)"/' " global_root sprintf("%0*d",general_pad,k)"/*/*/*")
		    mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,k) "/"global_root sprintf("%0*d",general_pad,k)"/' " global_root sprintf("%0*d",general_pad,k)"/*/*/*/*")
		}
	    }
	    # Duplicate structure number j and rename new files
	    print "[info|global] Duplicating : " j " -> " general_iterations
	    temp_name_old = general_filename[j]
	    gsub(".struct","",temp_name_old)
	    temp_root_old = temp_name_old "/"

	    general_filename[general_iterations] = global_root sprintf("%0*d",general_pad,general_iterations) ".struct"
	    temp_name = general_filename[general_iterations]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    
	    mysystem("cp -r " temp_root_old " " temp_root " > /dev/null 2>&1")
	    mysystem(temp_prepath const_renameexe " 's/" temp_name_old "/" temp_name "/' " "*")
	    mysystem(temp_prepath const_renameexe " 's/" temp_name_old "/" temp_name "/' " "*/*")
	    mysystem(temp_prepath const_renameexe " 's/" temp_name_old "/" temp_name "/' " "*/*/*")
	    mysystem(temp_prepath const_renameexe " 's/" temp_name_old "/" temp_name "/' " "*/*/*/*")
	    # Assign values of the new structure equal to the old one
	    # Save in the checkpoints
	    ## global
	    global_savecheck(global_root "-check/global.check")
	    ## general
	    for (k=1;k<=global_nneq;k++){
		temp_idstring = "npt" k
		general_index[temp_idstring,general_iterations] = general_iterations
		general_val[temp_idstring,general_iterations] = general_val[temp_idstring,general_index[temp_idstring,j]]
		temp_idstring = "rmt" k
		general_index[temp_idstring,general_iterations] = general_iterations
		general_val[temp_idstring,general_iterations] = general_val[temp_idstring,general_index[temp_idstring,j]]
		temp_idstring = "r0" k
		general_index[temp_idstring,general_iterations] = general_iterations
		general_val[temp_idstring,general_iterations] = general_val[temp_idstring,general_index[temp_idstring,j]]
	    }
	    general_index["rkmax",general_iterations] = general_iterations
	    general_val["rkmax",general_iterations] = general_val["rkmax",general_index["rkmax",j]]
	    general_index["lmax",general_iterations] = general_iterations
	    general_val["lmax",general_iterations] = general_val["lmax",general_index["lmax",j]]
	    general_index["lnsmax",general_iterations] = general_iterations
	    general_val["lnsmax",general_iterations] = general_val["lnsmax",general_index["lnsmax",j]]
	    general_index["gmax",general_iterations] = general_iterations
	    general_val["gmax",general_iterations] = general_val["gmax",general_index["gmax",j]]
	    general_index["mix",general_iterations] = general_iterations
	    general_val["mix",general_iterations] = general_val["mix",general_index["mix",j]]
	    general_index["kpts",general_iterations] = general_iterations
	    general_val["kpts",general_iterations] = general_val["kpts",general_index["kpts",j]]
	    if (global_ldau){
		for (k=1;k<=global_ldaus;k++){
		    temp_idstring = "u" k
		    general_index[temp_idstring,general_iterations] = general_iterations
		    general_val[temp_idstring,general_iterations] = general_val[temp_idstring,general_index[temp_idstring,j]]
		    temp_idstring = "j" k
		    general_index[temp_idstring,general_iterations] = general_iterations
		    general_val[temp_idstring,general_iterations] = general_val[temp_idstring,general_index[temp_idstring,j]]
		}
	    }
	    general_spacefill[general_iterations] = general_spacefill[j]
	    general_done[general_iterations] = general_done[j]
	    general_savecheck(global_root "-check/general.check")
	    ## init
	    if (init_done[j]){
		init_time[general_iterations] = init_time[j]
		init_done[general_iterations] = init_done[j]
		for (k=1;k<=global_nneq;k++)
		    init_coreleak[general_iterations] = init_coreleak[j]
		init_savecheck(global_root "-check/init.check")
	    }
	    ## prescf
	    if (prescf_done[j]){
		prescf_ldau_not[general_iterations] = prescf_ldau_not[j]
		prescf_ibzkpts[general_iterations] = prescf_ibzkpts[j]
		prescf_gmin[general_iterations] = prescf_gmin[j]
		prescf_pws[general_iterations] = prescf_pws[j]
		prescf_time[general_iterations] = prescf_time[j]
		prescf_done[general_iterations] = prescf_done[j]
		prescf_savecheck(global_root "-check/prescf.check")
	    }
	    ## scf
	    if (scf_done[j]){
		scf_bandemin[general_iterations] = scf_bandemin[j]
		scf_bandemax[general_iterations] = scf_bandemax[j]
		scf_efermi[general_iterations] = scf_efermi[j]
		scf_energy[general_iterations] = scf_energy[j]
		scf_molenergy[general_iterations] = scf_molenergy[j]
		scf_esemicoreval[general_iterations] = scf_esemicoreval[j]
		scf_dirbs[general_iterations] = scf_dirbs[j]
		for (k=1;k<=scf_dirbs[j];k++)
		    scf_dirb[general_iterations,k] = scf_dirb[j,k]
		scf_rkmaxreal[general_iterations] = scf_rkmaxreal[j]
		scf_mmtot[general_iterations] = scf_mmtot[j]
		scf_time[general_iterations] = scf_time[j]
		scf_noiter[general_iterations] = scf_noiter[j]
		scf_basissize[general_iterations] = scf_basissize[j]
		scf_los[general_iterations] = scf_los[j]
		scf_warns[general_iterations] = scf_warns[j]
		for (k=1;k<=scf_warns[j];k++)
		    scf_warn[general_iterations,k] = scf_warn[j,k]
		scf_done[general_iterations] = scf_done[j]
		scf_savecheck(global_root "-check/scf.check")
	    }
	    ## so
	    if (so_done[j]){
		so_bandemin[general_iterations] = so_bandemin[j]
		so_bandemax[general_iterations] = so_bandemax[j]
		so_efermi[general_iterations] = so_efermi[j]
		so_energy[general_iterations] = so_energy[j]
		so_molenergy[general_iterations] = so_molenergy[j]
		so_mmtot[general_iterations] = so_mmtot[j]
		so_time[general_iterations] = so_time[j]
		so_noiter[general_iterations] = so_noiter[j]
		so_done[general_iterations] = so_done[j]
		so_savecheck(global_root "-check/so.check")
	    }
	    ## prho
	    if (prho_done[j]){
		prho_time[general_iterations] = prho_time[j]
		prho_done[general_iterations] = prho_done[j]
		prho_savecheck(global_root "-check/prho.check")
	    }
	    ## dos
	    if (dos_done[j]){
		dos_time[general_iterations] = dos_time[j]
		dos_done[general_iterations] = dos_done[j]
		dos_savecheck(global_root "-check/dos.check")
	    }
	    ## rx
	    if (rx_done[j]){
		rx_time[general_iterations] = rx_time[j]
		rx_done[general_iterations] = rx_done[j]
		rx_savecheck(global_root "-check/rx.check")
	    }
	    ## band
	    if (band_done[j]){
		band_time[general_iterations] = band_time[j]
		band_done[general_iterations] = band_done[j]
		band_savecheck(global_root "-check/band.check")
	    }
	    ## kdos
	    if (kdos_done[j]){
		kdos_time[general_iterations] = kdos_time[j]
		kdos_done[general_iterations] = kdos_done[j]
		kdos_savecheck(global_root "-check/kdos.check")
	    }
	    ## aim
	    if (aim_done[j]){
		aim_time[general_iterations] = aim_time[j]
		aim_done[general_iterations] = aim_done[j]
		aim_savecheck(global_root "-check/aim.check")
	    }
	    ## critic
	    if (critic_done[j]){
		critic_time[general_iterations] = critic_time[j]
		critic_planarity[general_iterations] = critic_planarity[j]
		critic_morsesum[general_iterations] = critic_morsesum[j]
		critic_topology[general_iterations] = critic_topology[j]
		critic_done[general_iterations] = critic_done[j]
		critic_savecheck(global_root "-check/critic.check")
	    }
	    ## syn
	    if (syn_run){
		syn_time[general_iterations] = syn_time[j]
		syn_savecheck(global_root "-check/syn.check")
	    }
	}
    }
    next
}
# (igenerali) General section parameters input
/^( |\t)*do( |\t)+/ && global_section == "general" {
    $0 = rm_keyword("do",$0)
    # Interpretation of do data is deferred until I know how many
    # old and new iterations I have.
    general_dolines++
    general_doline[general_dolines] = $0
    general_dotype[general_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "general" {
    $0 = rm_keyword("except",$0)
    # Interpretation of except data is deferred until I know how many
    # old and new iterations I have.
    general_dolines++
    general_doline[general_dolines] = $0
    general_dotype[general_dolines] = "except"
    next
}
/^( |\t)*title/ && global_section=="general"{
    temp_string = rm_keyword(global_capfield[1],global_capline)
    # check consistency with loaded calculations
    if (general_title){
	print "[warn|general] title is set by a loaded calculation."
	print "[warn|general] ignoring the new value..."
	next
    }
    else
	general_title = temp_string
    next
}
/^( |\t)*lattice/ && global_section=="general"{
    temp_string = toupper(rm_keyword("lattice",$0))
    # check consistency with loaded calculations
    if (global_lattice){
	print "[warn|general] lattice is set by a loaded calculation."
	print "[warn|general] ignoring the new value..."
	next
    }
    if (global_spgroup){
	print "[error|general] lattice is incompatible with spglist."
	exit 1
    }
    else
	global_lattice = temp_string
    next
}
/^( |\t)*equiv( |\t)*list( |\t)*/,/^( |\t)*end( |\t)*equiv( |\t)*list( |\t)*$/{
    if (global_section=="general") {
	if ($0 ~ /^( |\t)*end( |\t)*equiv( |\t)*list( |\t)*$/) {next}
	if ($0 ~ /equiv/) {
	    if (general_olditerations){
		print "[warn|general] equivalent atom list is set by a loaded calculation."
		print "[warn|general] ignoring the new equiv list..."
		next
	    }
	    if (global_spgroup){
		print "[error|general] equiv list is incompatible with spglist."
		exit 1
	    }
	    global_nneq++
	    global_label[global_nneq] = global_nneq
	    temp_string = tolower(substr($3,1,2))
	    sub("^.",toupper(substr(temp_string,1,1)),temp_string)
	    if (temp_string in const_atomicmass)
		global_atom[global_nneq] = temp_string
	    else{
		temp_string = toupper(substr($3,1,1))
		if (temp_string in const_atomicmass)
		    global_atom[global_nneq] = temp_string
		else{
		    print "[error|general] Atom not recognized : " $3
		    exit 1
		}
	    }
	    global_atomfullnm[global_nneq] = rm_keyword("equiv",$0)
	    global_atomfullnm[global_nneq] = rm_keyword("list",global_atomfullnm[global_nneq])
	    sub("^.",toupper(substr(global_atomfullnm[global_nneq],1,1)),global_atomfullnm[global_nneq])
	    next
	}
	if (general_olditerations)
	    next
	global_mult[global_nneq]++
	global_nneq_x[global_nneq,global_mult[global_nneq]] = $1
	global_nneq_y[global_nneq,global_mult[global_nneq]] = $2
	global_nneq_z[global_nneq,global_mult[global_nneq]] = $3
	next
    }
}
/^( |\t)*spglist( |\t)*/,/^( |\t)*end( |\t)*spglist( |\t)*$/{
    if (global_section=="general") {
	if ($0 ~ /^( |\t)*end( |\t)*spglist( |\t)*$/) {next}
	if ($0 ~ /spglist/) {
	    if (general_olditerations){
		print "[warn|general] equivalent atom list is set by a loaded calculation."
		print "[warn|general] ignoring the spglist environment..."
		next
	    }
	    if (global_nneq > 0 || global_lattice){
		print "[error|general] spglist is incompatible with other structure "
		print "[error|general] specification methods (equiv list, lattice, other spglist,...). "
		exit 1
	    }
	    if ($0 ~ /rhomb( |\t)*$/)
		global_spg_rhomb = 1
	    else
		global_spg_rhomb = -1
	    gsub( /rhomb( |\t)*$/,"",$0)
	    global_spgroup = rm_keyword("spglist",$0)
	    gsub(" ","",global_spgroup)
	    if (const_spglat1[global_spgroup] != "R" && const_spglat2[global_spgroup] != "R" && global_spg_rhomb == 1){
		print "[error|general] rhomb specification is only valid in a R lattice."
		exit 1
	    }
	    next
	}
	if (general_olditerations)
	    next
	global_nneq++
	temp_string = tolower(substr($1,1,2))
	sub("^.",toupper(substr(temp_string,1,1)),temp_string)
	if (temp_string in const_atomicmass)
	    global_atom[global_nneq] = temp_string
	else{
	    temp_string = toupper(substr($1,1,1))
	    if (temp_string in const_atomicmass)
		global_atom[global_nneq] = temp_string
	    else{
		print "[error|general] Atom not recognized : " $1
		exit 1
	    }
	}
	global_atomfullnm[global_nneq] = $1
	sub("^.",toupper(substr(global_atomfullnm[global_nneq],1,1)),global_atomfullnm[global_nneq])

	global_nneq_x[global_nneq,1] = $2
	global_nneq_y[global_nneq,1] = $3
	global_nneq_z[global_nneq,1] = $4
	# Transform coords to hex
	if (global_spg_rhomb == 1){
	    temp_x = global_nneq_x[global_nneq,1] * const_rhomb2hex[1,1] + global_nneq_y[global_nneq,1] * const_rhomb2hex[2,1] + global_nneq_z[global_nneq,1] * const_rhomb2hex[3,1]
	    temp_y = global_nneq_x[global_nneq,1] * const_rhomb2hex[1,2] + global_nneq_y[global_nneq,1] * const_rhomb2hex[2,2] + global_nneq_z[global_nneq,1] * const_rhomb2hex[3,2]
	    temp_z = global_nneq_x[global_nneq,1] * const_rhomb2hex[1,3] + global_nneq_y[global_nneq,1] * const_rhomb2hex[2,3] + global_nneq_z[global_nneq,1] * const_rhomb2hex[3,3]
	    if (temp_x >= 1.0)
		temp_x -= 1.0
	    if (temp_x <= 0.0)
		temp_x += 1.0
	    if (temp_y >= 1.0)
		temp_y -= 1.0
	    if (temp_x <= 0.0)
		temp_y += 1.0
	    if (temp_z >= 1.0)
		temp_z -= 1.0
	    if (temp_z <= 0.0)
		temp_z += 1.0
	    global_nneq_x[global_nneq,1] = temp_x
	    global_nneq_y[global_nneq,1] = temp_y
	    global_nneq_z[global_nneq,1] = temp_z
	    print "[info|general] New coords for atom", global_nneq,":",temp_x,temp_y,temp_z
	}
	next
    }
}
/^( |\t)*spinpolarized/ && global_section=="general"{
    temp_string = $2
    # check consistency with loaded calculations
    if (global_spinpolarized){
	print "[warn|general] spinpolarized is set by a loaded calculation."
	print "[warn|general] ignoring the new value..."
	next
    }
    else
	global_spinpolarized = temp_string
    next
}
/^( |\t)*relativistic/ && global_section=="general"{
    temp_string = $2
    # check consistency with loaded calculations
    if (general_relativistic){
	print "[warn|general] relativistic is set by a loaded calculation."
	print "[warn|general] ignoring the new value..."
	next
    }
    else
	general_relativistic = temp_string
    next
}
/^( |\t)*cell( |\t)*parameters/ && global_section=="general"{
    if ($3 ~ /angstrom/){
	temp_a = $4 * const_angtobohr
	temp_b = $5 * const_angtobohr
	temp_c = $6 * const_angtobohr 
	temp_alpha = $7
	temp_beta = $8
	temp_gamma = $9
    } 
    else{
	temp_a = $3
	temp_b = $4
	temp_c = $5
	temp_alpha = $6
	temp_beta = $7
	temp_gamma = $8
    }
    # check consistency with loaded calculations
    if (global_a){
	print "[warn|general] cell parameters are set by a loaded calculation."
	print "[warn|general] ignoring the new values..."
	next
    }
    else{
	global_a = temp_a
	global_b = temp_b
	global_c = temp_c
	global_alpha = temp_alpha
	global_beta = temp_beta
	global_gamma = temp_gamma
    }
    next
}
/^( |\t)*also/ && global_section=="general"{
    general_alsos++
    next
}
/^( |\t)*npt/ && global_section=="general"{
    if (NF == 2){
	print "[warn|general] Only 2 fields in npt input!"
	print "[warn|general] I assume the second is a parse list and it refers to "
	print "[warn|general]   the first non-equivalent atom."
	general_npt[1,general_alsos] = rm_keyword("npt",$0)
    }
    else{
	temp_string = $2
	general_npt[$2,general_alsos] = rm_keyword("npt",$0)
	general_npt[temp_string,general_alsos] = rm_keyword(temp_string,general_npt[temp_string,general_alsos])
    }
    general_donew = 1
    next
}
/^( |\t)*rmt/ && global_section=="general"{
    if (NF == 2){
	print "[warn|general] Only 2 fields in rmt input!"
	print "[warn|general] I assume the second is a parse list and it refers to "
	print "[warn|general]   the first non-equivalent atom."
	general_rmt[1,general_alsos] = rm_keyword("rmt",$0)
    }
    else{
	temp_string = $2
	general_rmt[$2,general_alsos] = rm_keyword("rmt",$0)
	general_rmt[temp_string,general_alsos] = rm_keyword(temp_string,general_rmt[temp_string,general_alsos])
    }
    general_donew = 1
    next
}
/^( |\t)*r0/ && global_section=="general"{
    if (NF == 2){
	print "[warn|general] Only 2 fields in r0 input!"
	print "[warn|general] I assume the second is a parse list and it refers to "
	print "[warn|general]   the first non-equivalent atom."
	general_r0[1,general_alsos] = rm_keyword("r0",$0)
    }
    else{
	temp_string = $2
	general_r0[$2,general_alsos] = rm_keyword("r0",$0)
	general_r0[temp_string,general_alsos] = rm_keyword(temp_string,general_r0[temp_string,general_alsos])
    }
    general_donew = 1
    next
}
/^( |\t)*rkmax/ && global_section=="general"{
    general_rkmax[general_alsos] = rm_keyword("rkmax",$0)
    general_donew = 1
    next
}
/^( |\t)*lmax/ && global_section=="general"{
    general_lmax[general_alsos] = rm_keyword("lmax",$0)
    general_donew = 1
    next
}
/^( |\t)*lnsmax/ && global_section=="general"{
    general_lnsmax[general_alsos] = rm_keyword("lnsmax",$0)
    general_donew = 1
    next
}
/^( |\t)*gmax/ && global_section=="general"{
    general_gmax[general_alsos] = rm_keyword("gmax",$0)
    general_donew = 1
    next
}
/^( |\t)*mix/ && global_section=="general"{
    general_mix[general_alsos] = rm_keyword("mix",$0)
    general_donew = 1
    next
}
/^( |\t)*kpts/ && global_section=="general"{
    general_kpts[general_alsos] = rm_keyword("kpts",$0)
    general_donew = 1
    next
}
/^( |\t)*link/ && global_section=="general"{
    for (i=3;i<=NF;i++){
	general_linked[$i] = $2
    }
    next
}
/^( |\t)*loadcif/ && global_section=="general"{
    if (general_olditerations){
	print "[warn|general] you can not load a .cif while there are old calculations."
	next
    }
    general_ciffile = global_capfield[2]
    next
}
/^( |\t)*loadstruct/ && global_section=="general"{
    if (general_olditerations){
	print "[warn|general] you can not load a .struct while there are old calculations."
	next
    }
    general_structfile = global_capfield[2]
    next
}
/^( |\t)*lda\+u( |\t)*/,/^( |\t)*end( |\t)*lda\+u( |\t)*$/{
    if (global_section=="general") {
	if ($0 ~ /^( |\t)*end( |\t)*lda\+u( |\t)*$/) {
	    if (global_ldaus+0 == 0){
		print "[warn|general] lda+u must be activated for at least one atom and l."
		print "[warn|general] deactivating the usage of lda+u..."
		global_ldautype = ""
	    }
	    next
	}
	if ($0 ~ /lda\+u/) {
	    if (general_olditerations){
		print "[warn|general] lda+u is set by a loaded calculation."
		print "[warn|general] ignoring the new lda+u list..."
		next
	    }
	    global_ldautype = $2
	    if (global_ldautype != "sic" && global_ldautype != "amf" && global_ldautype != "hmf"){
		print "[error|general] lda+u type must be one of: sic, amf, hmf."
		exit 1
	    }
	    global_ldau = "-orb"
	    next
	}
	if (general_olditerations)
	    next
	global_ldaus++
	global_ldau_atom[global_ldaus] = $1
	global_ldau_l[global_ldaus] = $2
	if (global_ldau_l[global_ldaus] == "s")
	    global_ldau_l[global_ldaus] = 0
	else if (global_ldau_l[global_ldaus] == "p")
	    global_ldau_l[global_ldaus] = 1
	else if (global_ldau_l[global_ldaus] == "d")
	    global_ldau_l[global_ldaus] = 2
	else if (global_ldau_l[global_ldaus] == "f")
	    global_ldau_l[global_ldaus] = 3
	global_ldau_defu[global_ldaus] = $3
	if ($0 ~ "ev")
	    global_ldau_defu[global_ldaus] /= const_rytoev
	global_ldau_defj[global_ldaus] = $4
	if ($0 ~ "ev")
	    global_ldau_defj[global_ldaus] /= const_rytoev
	next
    }
}
/^( |\t)*u( |\t)+/ && global_section=="general"{
    if (NF == 2){
	print "[warn|general] Only 2 fields in U input!"
	print "[warn|general] I assume the second is a parse list and it refers to "
	print "[warn|general]   the first LDA+U line."
	general_u[1,general_alsos] = rm_keyword("u",$0)
    }
    else{
	temp_string = $2
	if (temp_string != "*" && temp_string+0 < 1){
	    print "[error|general] Wrong LDA+U line number in U input."
	    exit 1
	}
	general_u[temp_string,general_alsos] = rm_keyword("u",$0)
	general_u[temp_string,general_alsos] = rm_keyword(temp_string,general_u[temp_string,general_alsos])
	if ($0 ~ "ev")
	    general_uev[temp_string,general_alsos] = 1
    }
    general_donew = 1
    next
}
/^( |\t)*j( |\t)+/ && global_section=="general"{
    if (NF == 2){
	print "[warn|general] Only 2 fields in J input!"
	print "[warn|general] I assume the second is a parse list and it refers to "
	print "[warn|general]   the first LDA+U line."
	general_j[1,general_alsos] = rm_keyword("j",$0)
    }
    else{
	temp_string = $2
	if (temp_string != "*" && temp_string+0 < 1){
	    print "[error|general] Wrong LDA+U line number in J input."
	    exit 1
	}
	general_j[temp_string,general_alsos] = rm_keyword("j",$0)
	general_j[temp_string,general_alsos] = rm_keyword(temp_string,general_j[temp_string,general_alsos])
	if ($0 ~ "ev")
	    general_jev[temp_string,general_alsos] = 1
    }
    general_donew = 1
    next
}
# (iiniti) Initialization section parameters input
/^( |\t)*do( |\t)+/ && global_section == "initialization" {
    $0 = rm_keyword("do",$0)
    init_dolines++
    init_doline[init_dolines] = $0
    init_dotype[init_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "initialization" {
    $0 = rm_keyword("except",$0)
    init_dolines++
    init_doline[init_dolines] = $0
    init_dotype[init_dolines] = "except"
    next
}
/^( |\t)*sgroup/ && global_section == "initialization" {
    init_dosgroup = 1
    next
}
/^( |\t)*xcpotential/ && global_section=="initialization"{
    temp_string = rm_keyword("xcpotential",$0)
    # check consistency with loaded calculations
    if (init_potential){
	print "[warn|init] xcpotential is set by a loaded calculation."
	next
    }
    else
	init_potential = temp_string
    next
}
/^( |\t)*ecoreval/ && global_section=="initialization"{
    temp_string = $2
    # check consistency with loaded calculations
    if (init_ecoreval){
	print "[warn|init] ecoreval is set by a loaded calculation."
	next
    }
    else
	init_ecoreval = temp_string
    next
}
/^( |\t)*energymin/ && global_section=="initialization"{
    temp_string = $2
    # check consistency with loaded calculations
    if (init_energymin){
	print "[warn|init] energymin is set by a loaded calculation."
	next
    }
    else
	init_energymin = temp_string
    next
}
/^( |\t)*energymax/ && global_section=="initialization"{
    temp_string = $2
    # check consistency with loaded calculations
    if (init_energymax){
	print "[warn|init] energymax is set by a loaded calculation."
	next
    }
    else
	init_energymax = temp_string
    next
}
/^( |\t)*nnfactor/ && global_section=="initialization"{
    temp_string = $2
    # check consistency with loaded calculations
    if (init_nnfactor){
	print "[warn|init] nnfactor is set by a loaded calculation."
	next
    }
    else
	init_nnfactor = temp_string
    next
}
/^( |\t)*orbitals( |\t)*/,/^( |\t)*end( |\t)*orbitals( |\t)*$/{
    if (global_section=="initialization") {
	if ($0 ~ /^( |\t)*end( |\t)*orbitals( |\t)*$/) {
	    next
	}
	if ($0 ~ /orbitals/) {
	    # check not loaded
	    if (general_olditerations){
		print "[warn|init] orbitals list is set by a loaded calculation."
		next
	    }
	    # check input is consistent
	    if ($2 > global_nneq || $2 <= 0){
		print "[error|init] orbitals do not refer to any non-equivalent atom"
		print "[error|init] Correct .wien input"
		exit 1
	    }
	    if (NF != 4){
		print "[error|init] Wrong input in orbital specification"
		exit 1
	    }
	    # temp_inputvalue stays until end of environment
	    temp_inputvalue = $2
	    init_orbital_globe[temp_inputvalue] = $3
	    init_orbital_globapw[temp_inputvalue] = $4
	    next
	}
	if (general_olditerations)
	    next
	init_orbitals[temp_inputvalue]++
	init_orbital_l[temp_inputvalue,init_orbitals[temp_inputvalue]] = $1
	init_orbital_energy[temp_inputvalue,init_orbitals[temp_inputvalue]] = $2
	init_orbital_var[temp_inputvalue,init_orbitals[temp_inputvalue]] = $3
	init_orbital_cont[temp_inputvalue,init_orbitals[temp_inputvalue]] = $4
	init_orbital_apw[temp_inputvalue,init_orbitals[temp_inputvalue]] = $5
	next
    }
}
/^( |\t)*lm( |\t)*list( |\t)*/ && global_section == "initialization" && $4{
    # syntax: lm list atom.i lmax.i
    # checks if lmax.i is present, and prevents from running the next environ.
    init_lms[$3+0] = ($4+0) " lmax"
    next
}
/^( |\t)*lm( |\t)*list( |\t)*/,/^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/{
    # syntax: lm list atom.i
    #            l1 m1 l2 m2 ...
    #         end lm list
    if (global_section=="initialization") {
	if ($0 ~ /^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/) {
	    next
	}
	if ($0 ~ /^( |\t)*lm( |\t)*list( |\t)*/){
	    # check not loaded
	    if (general_olditerations){
		print "[warn|init] lm list is set by a loaded calculation."
		next
	    }
	    # check input is consistent
	    if (!$3 || $3 > global_nneq || $3 <= 0){
		print "[error|init] lms do not refer to any non-equivalent atom"
		print "[error|init] Correct .wien input"
		exit 1
	    }
	    if (NF != 3){
		print "[error|init] Wrong input in lm specification"
		exit 1
	    }
	    # temp_inputvalue stays until end of environment
	    temp_inputvalue = $3
	    temp_endvalue = $4
	    next
	}
	if (general_olditerations)
	    next
	if (int(NF/2) != NF/2){
	    print "[error|init] Wrong number of fields in lm specification."
	    print "[error|init] number of fields must be even."
	    exit 1
	}
	for (i=1;i<=NF/2;i++){
	    init_lms[temp_inputvalue]++
	    init_lm_l[temp_inputvalue,init_lms[temp_inputvalue]] = $(2*i-1)
	    init_lm_m[temp_inputvalue,init_lms[temp_inputvalue]] = $(2*i)
	}
	next
    }
}
/^( |\t)*fermi/ && global_section=="initialization"{
    temp_fermi = $2
    temp_fermival = $3
    # check consistency with loaded calculations
    if (init_fermi){
	print "[warn|init] fermi is set by a loaded calculation."
	next
    }
    else{
	init_fermi = temp_fermi
	init_fermival = temp_fermival
    }
    # check input consistency
    if (init_fermi != "root" && init_fermi != "temp" &&\
	init_fermi != "temps" && init_fermi != "gauss" &&\
	init_fermi != "tetra" && init_fermi != "all"){
	print "[error|init] fermi method not recognized."
	print "[error|init] must be one of root, temp, temps, gauss, tetra, all."
	exit 1
    }
    next
}
/^( |\t)*ifft/ && global_section=="initialization"{
    temp_string = $2
    # check consistency with loaded calculations
    if (init_ifft){
	print "[warn|init] ifft is set by a loaded calculation."
	next
    }
    else
	init_ifft = temp_string
    next
}
# (iprescfi) Prescf section parameters input
/^( |\t)*do( |\t)+/ && global_section == "prescf" {
    $0 = rm_keyword("do",$0)
    prescf_dolines++
    prescf_doline[prescf_dolines] = $0
    prescf_dotype[prescf_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "prescf" {
    $0 = rm_keyword("except",$0)
    prescf_dolines++
    prescf_doline[prescf_dolines] = $0
    prescf_dotype[prescf_dolines] = "except"
    next
}
/^( |\t)*kgenoutput/ && global_section=="prescf"{
    temp_string = $2
    # check consistency with loaded calculations
    if (prescf_kgenoutput){
	print "[warn|prescf] kgenoutput is set by a loaded calculation."
	next
    }
    else
	prescf_kgenoutput = temp_string
    next
}
/^( |\t)*kgenshift/ && global_section=="prescf"{
    temp_string = $2
    # check consistency with loaded calculations
    if (prescf_kgenshift){
	print "[warn|prescf] kgenshift is set by a loaded calculation."
	next
    }
    else
	prescf_kgenshift = temp_string
    next
}
/^( |\t)*nice/ && global_section=="prescf"{
    prescf_nice = $2
    next
}
# (iscfi) Scf section parameters input
/^( |\t)*do( |\t)+/ && global_section == "scf" {
    $0 = rm_keyword("do",$0)
    scf_dolines++
    scf_doline[scf_dolines] = $0
    scf_dotype[scf_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "scf" {
    $0 = rm_keyword("except",$0)
    scf_dolines++
    scf_doline[scf_dolines] = $0
    scf_dotype[scf_dolines] = "except"
    next
}
/^( |\t)*reuse/ && global_section=="scf"{
    scf_reusemode = $2
    if (scf_reusemode !~ /(chain|fixed|first|any|path)/){
	print "[error|scf] Unknown reuse keyword."
	print "[error|scf] Must be one of chain, fixed, first, any, path."
	exit 1
    }
    if (scf_reusemode ~ /fixed|path/)
	scf_reuseval = global_capfield[3]
    next
}
/^( |\t)*max( |\t)*iterations/ && global_section=="scf"{
    temp_string = rm_keyword("max",$0)
    temp_string = rm_keyword("iterations",temp_string)
    # check consistency with loaded calculations
    if (scf_miter){
	print "[warn|scf] max iterations is set by a loaded calculation."
	next
    }
    else
	scf_miter = temp_string
    next
}
/^( |\t)*charge( |\t)*conv/ && global_section=="scf"{
    temp_string = rm_keyword("charge",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (scf_cc){
	print "[warn|scf] charge conv is set by a loaded calculation."
	next
    }
    else
	scf_cc = temp_string
    next
}
/^( |\t)*energy( |\t)*conv/ && global_section=="scf"{
    temp_string = rm_keyword("energy",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (scf_ec){
	print "[warn|scf] energy conv is set by a loaded calculation."
	next
    }
    else
	scf_ec = temp_string
    next
}
/^( |\t)*force( |\t)*conv/ && global_section=="scf"{
    temp_string = rm_keyword("force",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (scf_fc){
	print "[warn|scf] force conv is set by a loaded calculation."
	next
    }
    else
	scf_fc = temp_string
    next
}
/^( |\t)*nice/ && global_section=="scf"{
    scf_nice = 1
    next
}
/^( |\t)*itdiag/ && global_section=="scf"{
    temp_string = $2
    # check consistency with loaded calculations
    if (scf_itdiag){
	print "[warn|scf] itdiag is set by a loaded calculation."
	next
    }
    else
	if (temp_string)
	    scf_itdiag = temp_string
	else
	    scf_itdiag = 3
    next
}
/^( |\t)*new( |\t)*in1/ && global_section=="scf"{
    temp_string = $3
    # check consistency with loaded calculations
    if (scf_in1new){
	print "[warn|scf] new in1 is set by a loaded calculation."
	next
    }
    else
	scf_in1new = temp_string
    next
}
/^( |\t)*nosummary/ && global_section=="scf"{
    scf_nosummary = 1
    next
}
/^( |\t)*noinit( |\t)*$/ && global_section=="scf"{
    scf_noinit = 1
    next
}
/^( |\t)*mini/ && global_section=="scf"{
    if ($2)
	scf_mini = rm_keyword("mini",$0)
    else
	scf_mini = "defline"
    next
}
/^( |\t)*ftolmini/ && global_section=="scf"{
    scf_miniftol = $2 + 0
    next
}
#/^( |\t)*analyze/ && global_section=="scf"{
#    for (i=2;i<=NF;i++){
#	scf_analyze[$i] = 1
#    }
#    next
#}
#/^( |\t)*calcelf/ && global_section=="scf"{
#    scf_calcelf = 1
#    next
#}
# (isoi) Spinorbit section parameters input
/^( |\t)*do( |\t)+/ && global_section == "spinorbit" {
    $0 = rm_keyword("do",$0)
    so_dolines++
    so_doline[so_dolines] = $0
    so_dotype[so_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "spinorbit" {
    $0 = rm_keyword("except",$0)
    so_dolines++
    so_doline[so_dolines] = $0
    so_dotype[so_dolines] = "except"
    next
}
/^( |\t)*direction/ && global_section=="spinorbit"{
    so_h = $2+0
    so_k = $3+0
    so_l = $4+0
    next
}
/^( |\t)*addlo/ && global_section=="spinorbit"{
    so_addlos++
    so_addlo_atom[so_addlos] = $2+0
    so_addlo_e[so_addlos] = $3+0
    if (!(so_addlo_e[so_addlos]""))
	so_addlo_e[so_addlos] = -4.97
    so_addlo_de[so_addlos] = $4+0
    if (!(so_addlo_de[so_addlos]""))
	so_addlo_de[so_addlos] = 0.005
    next
}
/^( |\t)*exclude/ && global_section=="spinorbit"{
    for (i=2;i<=NF;i++){
	so_excludes++
	so_exclude[so_excludes] = $i
    }
    next
}
/^( |\t)*newemax/ && global_section=="spinorbit"{
    so_newemax = $2+0
    next
}
/^( |\t)*newkpts/ && global_section=="spinorbit"{
    so_newkpts = $2
    next
}
/^( |\t)*max( |\t)*iterations/ && global_section=="so"{
    temp_string = rm_keyword("max",$0)
    temp_string = rm_keyword("iterations",temp_string)
    # check consistency with loaded calculations
    if (so_miter){
	print "[warn|so] max iterations is set by a loaded calculation."
	next
    }
    else
	so_miter = temp_string
    next
}
/^( |\t)*charge( |\t)*conv/ && global_section=="so"{
    temp_string = rm_keyword("charge",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (so_cc){
	print "[warn|so] charge conv is set by a loaded calculation."
	next
    }
    else
	so_cc = temp_string
    next
}
/^( |\t)*energy( |\t)*conv/ && global_section=="so"{
    temp_string = rm_keyword("energy",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (so_ec){
	print "[warn|so] energy conv is set by a loaded calculation."
	next
    }
    else
	so_ec = temp_string
    next
}
/^( |\t)*force( |\t)*conv/ && global_section=="so"{
    temp_string = rm_keyword("force",$0)
    temp_string = rm_keyword("conv",temp_string)
    # check consistency with loaded calculations
    if (so_fc){
	print "[warn|so] force conv is set by a loaded calculation."
	next
    }
    else
	so_fc = temp_string
    next
}
/^( |\t)*nice/ && global_section=="so"{
    so_nice = 1
    next
}
/^( |\t)*itdiag/ && global_section=="so"{
    temp_string = $2
    # check consistency with loaded calculations
    if (so_itdiag){
	print "[warn|so] itdiag is set by a loaded calculation."
	next
    }
    else
	if (temp_string)
	    so_itdiag = temp_string
	else
	    so_itdiag = 3
    next
}
/^( |\t)*new( |\t)*in1/ && global_section=="so"{
    temp_string = $3
    # check consistency with loaded calculations
    if (so_in1new){
	print "[warn|so] new in1 is set by a loaded calculation."
	next
    }
    else
	so_in1new = temp_string
    next
}
# (ielastici) Elastic section parameters input
/^( |\t)*reference( |\t)*struct/ && global_section=="elastic"{
    elastic_ref = rm_keyword("reference",$0)
    elastic_ref = rm_keyword("struct",elastic_ref)
    next
}
/^( |\t)*deformation/ && global_section=="elastic"{
    for (i=2;i<=6;i+=2){
	if ($i ~ /^ *$/)
	    ;
	else if ($i == "points")
	    elastic_points = $(i+1)
	else if ($i == "maxlength")
	    elastic_maxlength = $(i+1)
	else if ($i == "maxangle")
	    elastic_maxangle = $(i+1)
	else{
	    print "[error|elastic] Wrong input in deformation keyword."
	    print "[error|elastic] Fields 2, 4, 6 must be one of points, maxlength, maxangle."
	    exit 1
	}
    }
    next
}
/^( |\t)*polyorder/ && global_section=="elastic"{
    elastic_polyorder = $2 + 0
    if (elastic_polyorder != "2" && elastic_polyorder != "4" && elastic_polyorder != "6" && elastic_polyorder != "8"){
	print "[error|elastic] Polynomial order not supported."
	print "[error|elastic] Must be one of 2, 4, 6, 8."
	exit 1
    }
    next
}
/^( |\t)*fixmin/ && global_section=="elastic"{
    elastic_fixmin = $2
    if (elastic_fixmin != "yes" && elastic_fixmin != "no"){
	print "[error|elastic] fixmin must be one of yes, no."
	exit 1
    }
    next
}
/^( |\t)*term1/ && global_section=="elastic"{
    elastic_term1 = $2
    if (elastic_term1 != "yes" && elastic_term1 != "no"){
	print "[error|elastic] fixmin must be one of yes, no."
	exit 1
    }
    next
}
/^( |\t)*npt/ && global_section=="elastic"{
    if (NF == 3)
	elastic_npt[$2] = $3
    else
	elastic_npt[1] = $2
    next
}
/^( |\t)*rmt/ && global_section=="elastic"{
    if (NF == 3)
	elastic_rmt[$2] = $3
    else
	elastic_rmt[1] = $2
    next
}
/^( |\t)*r0/ && global_section=="elastic"{
    if (NF == 3)
	elastic_r0[$2] = $3
    else
	elastic_r0[1] = $2
    next
}
/^( |\t)*rkmax/ && global_section=="elastic"{
    elastic_rkmax = $2
    next
}
/^( |\t)*lmax/ && global_section=="elastic"{
    elastic_lmax = $2
    next
}
/^( |\t)*lnsmax/ && global_section=="elastic"{
    elastic_lnsmax = $2
    next
}
/^( |\t)*gmax/ && global_section=="elastic"{
    elastic_gmax = $2
    next
}
/^( |\t)*mix/ && global_section=="elastic"{
    elastic_mix = $2
    next
}
/^( |\t)*kpts/ && global_section=="elastic"{
    elastic_kpts = $2
    next
}
/^( |\t)*xcpotential/ && global_section=="elastic"{
    $0 = rm_keyword("xcpotential",$0)
    if ($0 != "lsda" && $0 != "ggapbe96" && $0 != "ggapw91" && $0 != "ggawc06" && $0 != "ggapbesol"){
	print "[error|elastic] Xcpotential keyword must be one of lsda, ggapbe96, ggapw91, ggawc06, ggapbesol."
	exit 1
    }
    elastic_potential = $0
    next
}
/^( |\t)*ecoreval/ && global_section=="elastic"{
    elastic_ecoreval = $2
    next
}
/^( |\t)*ifft/ && global_section=="elastic"{
    elastic_ifft = $2
    next
}
/^( |\t)*energymin/ && global_section=="elastic"{
    elastic_energymin = $2
    next
}
/^( |\t)*energymax/ && global_section=="elastic"{
    elastic_energymax = $2
    next
}
/^( |\t)*orbitals( |\t)*/,/^( |\t)*end( |\t)*orbitals( |\t)*$/{
    if (global_section=="elastic") {
	if ($0 ~ /^( |\t)*end( |\t)*orbitals( |\t)*$/) {
	    next
	}
	if ($0 ~ /orbitals/) {
	    if (!$2 || $2 > global_nneq){
		print "[error|elastic] Orbitals do not refer to any non-equivalent atom"
		print "[error|elastic] Correct .wien input"
		exit 1
	    }
	    if (NF != 4){
		print "[error|elastic] Wrong input in orbital specification"
		exit 1
	    }
	    temp_val = $2
	    elastic_orbital_globe[temp_val] = $3
	    elastic_orbital_globapw[temp_val] = $4
	    next
	}
	elastic_orbitals[temp_val]++
	elastic_orbital_l[temp_val,elastic_orbitals[temp_val]] = $1
	elastic_orbital_energy[temp_val,elastic_orbitals[temp_val]] = $2
	elastic_orbital_var[temp_val,elastic_orbitals[temp_val]] = $3
	elastic_orbital_cont[temp_val,elastic_orbitals[temp_val]] = $4
	elastic_orbital_apw[temp_val,elastic_orbitals[temp_val]] = $5
	next
    }
}
/^( |\t)*lm( |\t)*list( |\t)*/ && global_section == "elastic" && $4{
    elastic_lms[$3+0] = ($4+0) " lmax"
    next
}
/^( |\t)*lm( |\t)*list( |\t)*/,/^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/{
    if (global_section=="elastic") {
	print "[warn|elastic] A lm list is not permitted in elastic."
	print "[warn|elastic] The lm list spec. depends on the deformation."
	next
    }
}
/^( |\t)*fermi/ && global_section=="elastic"{
    elastic_fermi = $2
    elastic_fermival = $3
    if (elastic_fermi != "root" && elastic_fermi != "temp" &&\
	elastic_fermi != "temps" && elastic_fermi != "gauss" &&\
	elastic_fermi != "tetra" && elastic_fermi != "all"){
	print "[error|elastic] fermi method not recognized."
	print "[error|elastic] must be one of root, temp, temps, gauss, tetra, all."
	exit 1
    }
    next
}
/^( |\t)*nice/ && global_section=="elastic"{
    elastic_nice = $2
    next
}
/^( |\t)*itdiag/ && global_section=="elastic"{
    if ($2)
	elastic_itdiag = $2
    else
	elastic_itdiag = 3
    next
}
/^( |\t)*max( |\t)*iterations/ && global_section=="elastic"{
    elastic_miter = rm_keyword("max",$0)
    elastic_miter = rm_keyword("iterations",elastic_miter)
    next
}
/^( |\t)*charge( |\t)*conv/ && global_section=="elastic"{
    elastic_cc = rm_keyword("charge",$0)
    elastic_cc = rm_keyword("conv",elastic_cc)
    next
}
/^( |\t)*energy( |\t)*conv/ && global_section=="elastic"{
    elastic_ec = rm_keyword("energy",$0)
    elastic_ec = rm_keyword("conv",elastic_ec)
    next
}
/^( |\t)*force( |\t)*conv/ && global_section=="elastic"{
    elastic_fc = rm_keyword("force",$0)
    elastic_fc = rm_keyword("conv",elastic_fc)
    next
}
/^( |\t)*new( |\t)*in1/ && global_section=="elastic"{
    elastic_in1new = $3
    next
}
/^( |\t)*reuse/ && global_section=="elastic"{
    elastic_reusemode = $2
    if (elastic_reusemode != "chain" && elastic_reusemode != "path" && elastic_reusemode != "detect"){
	print "[error|elastic] Reuse keyword must be one of chain, path and detect."
	exit 1
    }
    if (elastic_reusemode == "path")
	elastic_reuseval = $3
    next
}
/^( |\t)*noreuse/ && global_section=="elastic"{
    elastic_noreuse = 1
    next
}
/^( |\t)*clean/ && global_section=="elastic"{
    elastic_clean = rm_keyword("",$0)
    next
}
/^( |\t)*nosend/ && global_section=="elastic"{
    elastic_nosend = 1
    next
}
/^( |\t)*mini/ && global_section=="elastic"{
    if ($2)
	elastic_mini = rm_keyword("mini",$0)
    else
	elastic_mini = "defline"
    next
}
/^( |\t)*lda\+u( |\t)*/,/^( |\t)*end( |\t)*lda\+u( |\t)*$/{
    if (global_section=="elastic") {
	if ($0 ~ /^( |\t)*end( |\t)*lda\+u( |\t)*$/) {
	    if (elastic_ldaus+0 == 0){
		print "[warn|elastic] lda+u must be activated for at least one atom and l."
		print "[warn|elastic] deactivating the usage of lda+u..."
		elastic_ldautype = ""
	    }
	    next
	}
	if ($0 ~ /lda\+u/) {
	    elastic_ldautype = $2
	    if (elastic_ldautype != "sic" && elastic_ldautype != "amf" && elastic_ldautype != "hmf"){
		print "[error|elastic] lda+u type must be one of: sic, amf, hmf."
		exit 1
	    }
	    elastic_ldau = "-orb"
	    next
	}
	elastic_ldaus++
	elastic_ldau_atom[elastic_ldaus] = $1
	elastic_ldau_l[elastic_ldaus] = $2
	if (elastic_ldau_l[elastic_ldaus] == "s")
	    elastic_ldau_l[elastic_ldaus] = 0
	else if (elastic_ldau_l[elastic_ldaus] == "p")
	    elastic_ldau_l[elastic_ldaus] = 1
	else if (elastic_ldau_l[elastic_ldaus] == "d")
	    elastic_ldau_l[elastic_ldaus] = 2
	else if (elastic_ldau_l[elastic_ldaus] == "f")
	    elastic_ldau_l[elastic_ldaus] = 3
	elastic_ldau_defu[elastic_ldaus] = $3
	if ($0 ~ "ev")
	    elastic_ldau_defu[elastic_ldaus] /= const_rytoev
	elastic_ldau_defj[elastic_ldaus] = $4
	if ($0 ~ "ev")
	    elastic_ldau_defj[elastic_ldaus] /= const_rytoev
	next
    }
}
/^( |\t)*spinorbit/ && global_section=="elastic"{
    elastic_so_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*spinorbit/ ; getline){
	elastic_so_lines++
	elastic_so_line[elastic_so_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*tetragonal/ && global_section=="elastic"{
    elastic_tetragonal = $2 + 0
    if ($2 != 1 && $2 != 2){
	print "[error|elastic] Tetragonal keyword must be followed by 1 or 2."
	exit 1
    }
    next
}
# (ifreei) Free section parameters input
/^( |\t)*atom/ && global_section=="free"{
    free_atom = $2
    if (!isin(free_atom,global_atomname)){
	print "[error|free] Atom not recognized. Must be an atom name."
	exit 1
    }
    next
}
/^( |\t)*global/ && global_section=="free"{
    free_atom = ""
    next
}
/^( |\t)*do( |\t)+/ && global_section == "free" {
    $0 = rm_keyword("do",$0)
    free_dolines++
    free_doline[free_dolines] = $0
    free_dotype[free_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "free" {
    $0 = rm_keyword("except",$0)
    free_dolines++
    free_doline[free_dolines] = $0
    free_dotype[free_dolines] = "except"
    next
}
/^( |\t)*reference( |\t)*struct/ && global_section=="free"{
    temp_string = rm_keyword("reference",$0)
    temp_string = rm_keyword("struct",temp_string)
    if (free_atom)
	free_ref[free_atom] = temp_string
    else
	for (i=1;i<=global_atomnames;i++)
	    free_ref[global_atomname[i]] = temp_string
    next
}
/^( |\t)*cell/ && global_section=="free"{
    if (free_atom)
	free_cell[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_cell[global_atomname[i]] = $2
    next
}
/^( |\t)*spinpolarized/ && global_section=="free"{
    if (free_atom)
	free_spinpolarized[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_spinpolarized[free_atom] = $2
    next
}
/^( |\t)*npt/ && global_section=="free"{
    if (free_atom)
	free_npt[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_npt[global_atomname[i]] = $2
    next
}
/^( |\t)*rmt/ && global_section=="free"{
    if (free_atom)
	free_rmt[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_rmt[global_atomname[i]] = $2
    next
}
/^( |\t)*r0/ && global_section=="free"{
    if (free_atom)
	free_r0[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_r0[global_atomname[i]] = $2
    next
}
/^( |\t)*rkmax/ && global_section=="free"{
    if (free_atom)
	free_rkmax[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_rkmax[global_atomname[i]] = $2
    next
}
/^( |\t)*lmax/ && global_section=="free"{
    if (free_atom)
	free_lmax[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_lmax[global_atomname[i]] = $2
    next
}
/^( |\t)*lnsmax/ && global_section=="free"{
    if (free_atom)
	free_lnsmax[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_lnsmax[global_atomname[i]] = $2
    next
}
/^( |\t)*gmax/ && global_section=="free"{
    if (free_atom)
	free_gmax[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_gmax[global_atomname[i]] = $2
    next
}
/^( |\t)*mix/ && global_section=="free"{
    if (free_atom)
	free_mix[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_mix[global_atomname[i]] = $2
    next
}
/^( |\t)*xcpotential/ && global_section=="free"{
    $0 = rm_keyword("xcpotential",$0)
    if ($0 != "lsda" && $0 != "ggapbe96" && $0 != "ggapw91" && $0 != "ggawc06" && $0 != "ggapbesol"){
	print "[error|free] Xcpotential keyword must be one of lsda, ggapbe96, ggapw91, ggawc06, ggapbesol."
	exit 1
    }
    if (free_atom)
	free_potential[free_atom] = $0
    else
	for (i=1;i<=global_atomnames;i++)
	    free_potential[global_atomname[i]] = $0
    next
}
/^( |\t)*ecoreval/ && global_section=="free"{
    if (free_atom)
	free_ecoreval[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_ecoreval[global_atomname[i]] = $2
    next
}
/^( |\t)*energymin/ && global_section=="free"{
    if (free_atom)
	free_energymin[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_energymin[global_atomname[i]] = $2
    next
}
/^( |\t)*energymax/ && global_section=="free"{
    if (free_atom)
	free_energymax[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_energymax[global_atomname[i]] = $2
    next
}
/^( |\t)*orbitals( |\t)*/,/^( |\t)*end( |\t)*orbitals( |\t)*$/{
    if (global_section=="free") {
	if ($0 ~ /^( |\t)*end( |\t)*orbitals( |\t)*$/)
	    next
	if ($0 ~ /orbitals/) {
	    if (free_atom){
		free_orbital_globe[free_atom] = $2
		free_orbital_globapw[free_atom] = $3
	    }
	    else{
		for (i=1;i<=global_atomnames;i++){
		    free_orbital_globe[global_atomname[i]] = $2
		    free_orbital_globapw[global_atomname[i]] = $3
		}
	    }
	    next
	}
	if (free_atom){
	    free_orbitals[free_atom]++
	    free_orbital_l[free_atom,free_orbitals[free_atom]] = $1
	    free_orbital_energy[free_atom,free_orbitals[free_atom]] = $2
	    free_orbital_var[free_atom,free_orbitals[free_atom]] = $3
	    free_orbital_cont[free_atom,free_orbitals[free_atom]] = $4
	    free_orbital_apw[free_atom,free_orbitals[free_atom]] = $5
	}
	else{
	    for (i=1;i<=global_atomnames;i++){
		free_orbitals[global_atomname[i]]++
		free_orbital_l[global_atomname[i],free_orbitals[global_atomname[i]]] = $1
		free_orbital_energy[global_atomname[i],free_orbitals[global_atomname[i]]] = $2
		free_orbital_var[global_atomname[i],free_orbitals[global_atomname[i]]] = $3
		free_orbital_cont[global_atomname[i],free_orbitals[global_atomname[i]]] = $4
		free_orbital_apw[global_atomname[i],free_orbitals[global_atomname[i]]] = $5
	    }
	}
	next
    }
}
/^( |\t)*lm( |\t)*list( |\t)*/,/^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/{
    if (global_section=="free") {
	if ($0 ~ /^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/)
	    next
	if ($0 ~ /^( |\t)*lm( |\t)*list( |\t)*/)
	    next
	if (int(NF/2) != NF/2){
	    print "[error|free] Wrong number of fields in lm specification."
	    print "[error|free] number of fields must be even."
	    exit 1
	}
	if (free_atom){
	    for (i=1;i<=NF/2;i++){
		free_lms[free_atom]++
		free_lm_l[free_atom,free_lms[free_atom]] = $(2*i-1)
		free_lm_m[free_atom,free_lms[free_atom]] = $(2*i)
	    }
	}
	else{
	    for (i=1;i<=global_atomnames;i++){
		for (j=1;j<=NF/2;j++){
		    free_lms[global_atomname[i]]++
		    free_lm_l[global_atomname[i],free_lms[global_atomname[i]]] = $(2*j-1)
		    free_lm_m[global_atomname[i],free_lms[global_atomname[i]]] = $(2*j)
		}
	    }
	}
	next
    }
}
/^( |\t)*fermi/ && global_section=="free"{
    if ($2 != "root" && $2 != "temp" &&\
	$2 != "temps" && $2 != "gauss" &&\
	$2 != "tetra" && $2 != "all"){
	print "[error|free] fermi method not recognized."
	print "[error|free] must be one of root, temp, temps, gauss, tetra, all."
	exit 1
    }
    if (free_atom){
	free_fermi[free_atom] = $2
	free_fermival[free_atom] = $3
    }
    else{
	for (i=1;i<=global_atomnames;i++){
	    free_fermi[global_atomname[i]] = $2
	    free_fermival[global_atomname[i]] = $3
	}
    }
    next
}
/^( |\t)*nice/ && global_section=="free"{
    if (free_atom)
	free_nice[free_atom] = $2
    else
	for (i=1;i<=global_atomnames;i++)
	    free_nice[global_atomname[i]] = $2
    next
}
/^( |\t)*max( |\t)*iterations/ && global_section=="free"{
    if (free_atom)
	free_miter[free_atom] = $3
    else
	for (i=1;i<=global_atomnames;i++)
	    free_miter[global_atomname[i]] = $3
    next
}
/^( |\t)*charge( |\t)*conv/ && global_section=="free"{
    if (free_atom)
	free_cc[free_atom] = $3
    else
	for (i=1;i<=global_atomnames;i++)
	    free_cc[global_atomname[i]] = $3
    next
}
/^( |\t)*energy( |\t)*conv/ && global_section=="free"{
    if (free_atom)
	free_ec[free_atom] = $3
    else
	for (i=1;i<=global_atomnames;i++)
	    free_ec[global_atomname[i]] = $3
    next
}
/^( |\t)*force( |\t)*conv/ && global_section=="free"{
    if (free_atom)
	free_fc[free_atom] = $3
    else
	for (i=1;i<=global_atomnames;i++)
	    free_fc[global_atomname[i]] = $3
    next
}
/^( |\t)*itdiag/ && global_section=="free"{
    if (free_atom)
	if ($2)
	    free_itdiag[free_atom] = $2
	else
	    free_itdiag[free_atom] = 3
    else
	for (i=1;i<=global_atomnames;i++)
	    if ($2)
		free_itdiag[global_atomname[i]] = $2
	    else
		free_itdiag[global_atomname[i]] = 3
    next
}
/^( |\t)*new( |\t)*in1/ && global_section=="free"{
    if (free_atom)
	free_in1new[free_atom] = $3
    else
	for (i=1;i<=global_atomnames;i++)
	    free_in1new[global_atomname[i]] = $3
    next
}
/^( |\t)*clean/ && global_section=="free"{
    free_clean = rm_keyword("",$0)
    next
}
/^( |\t)*nosend/ && global_section=="free"{
    if (free_atom)
	free_nosend[free_atom] = 1
    else
	for (i=1;i<=global_atomnames;i++)
	    free_nosend[global_atomname[i]] = 1
    next
}

# (iprhoi) Printrho section parameters input
/^( |\t)*do( |\t)+/ && global_section == "printrho" {
    $0 = rm_keyword("do",$0)
    prho_dolines++
    prho_doline[prho_dolines] = $0
    prho_dotype[prho_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "printrho" {
    $0 = rm_keyword("except",$0)
    prho_dolines++
    prho_doline[prho_dolines] = $0
    prho_dotype[prho_dolines] = "except"
    next
}
/^( |\t)*rho/ && global_section=="printrho"{
    prho_rho = rm_keyword("rho",$0)
    if (prho_rho != "totalrho" && prho_rho != "valrho" && prho_rho != "vcoul" &&\
	prho_rho != "vxc" && prho_rho != "vtotal" && prho_rho != "spin" &&\
	prho_rho != "atomic" && prho_rho != "deform"){
	print "[error|prho] Rho plot not recognized."
	print "[error|prho] possible options are totalrho, valrho,... (see manual)"
	exit 1
    }
    if (prho_rho == "spin" && global_spinpolarized == "no"){
	print "[error|prho] Can not plot spin density differences in a non-spinpolarized calculation."
	exit 1
    }
    next
}
/^( |\t)*energymin/ && global_section=="printrho"{
    prho_emin = $2
    next
}
/^( |\t)*origin/ && global_section=="printrho"{
    prho_x0 = $2
    prho_y0 = $3
    prho_z0 = $4
    prho_den0 = $5
    next
}
/^( |\t)*xend/ && global_section=="printrho"{
    prho_xend_x = $2
    prho_xend_y = $3
    prho_xend_z = $4
    prho_xend_den = $5
    next
}
/^( |\t)*yend/ && global_section=="printrho"{
    prho_yend_x = $2
    prho_yend_y = $3
    prho_yend_z = $4
    prho_yend_den = $5
    next
}
/^( |\t)*nshells/ && global_section=="printrho"{
    prho_nsh_x = $2
    prho_nsh_y = $3
    prho_nsh_z = $4
    next
}
/^( |\t)*npt/ && global_section=="printrho"{
    prho_npt_x = $2
    prho_npt_y = $3
    next
}
/^( |\t)*zmin/ && global_section=="printrho"{
    prho_zmin = $2
    next
}
/^( |\t)*zmax/ && global_section=="printrho"{
    prho_zmax = $2
    next
}
/^( |\t)*dc/ && global_section=="printrho"{
    prho_dc = $2
    next
}
/^( |\t)*type/ && global_section=="printrho"{
    prho_type = rm_keyword("type",$0)
    if (prho_type != "3d" && prho_type  != "c"){
	print "[error|prho] Type of density plot not recognized."
	print "[error|prho] possible options are c and 3d"
	exit 1
    }
    next
}
/^( |\t)*scale/ && global_section=="printrho"{
    prho_scale = rm_keyword("scale",$0)
    if (prho_scale != "normal" && prho_scale  != "log"){
	print "[error|prho] Scale not recognized."
	print "[error|prho] possible options are normal and log"
	exit 1
    }
    if (prho_scale == "log" && (prho_rho == "vcoul" || prho_rho == "vxc" || \
				prho_rho == "vtotal" || prho_rho == "spin" ||\
				prho_rho == "deform")){
	print "[error|prho] Logarithmic scale can only be used with densities."
	exit 1
    }
    next
}
/^( |\t)*nolabels/ && global_section=="printrho"{
    prho_nolabels = 1
    next
}
# (idosi) Dosplot section parameters input
/^( |\t)*do( |\t)+/ && global_section == "dosplot" {
    $0 = rm_keyword("do",$0)
    dos_dolines++
    dos_doline[dos_dolines] = $0
    dos_dotype[dos_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "dosplot" {
    $0 = rm_keyword("except",$0)
    dos_dolines++
    dos_doline[dos_dolines] = $0
    dos_dotype[dos_dolines] = "except"
    next
}
/^( |\t)*plotunits/ && global_section=="dosplot"{
    dos_plotunits = $2
    if (dos_plotunits != "ry" && dos_plotunits != "ev"){
	print "[error|dos] Plotunits keyword not recognized."
	print "[error|dos] Must be Ry or eV."
	exit 1
    }
    next
}
/^( |\t)*de/ && global_section=="dosplot"{
    dos_de = $2
    if ($3 == "ev")
	dos_de = dos_de / const_rytoev
    next
}
/^( |\t)*broad/ && global_section=="dosplot"{
    dos_broad = $2
    next
}
/^( |\t)*dos( |\t)*list( |\t)*$/,/^( |\t)*end( |\t)*dos( |\t)*list( |\t)*$/{
    if (global_section=="dosplot") {
	if ($0 ~ /^( |\t)*dos( |\t)*list( |\t)*$/){
	    dos_ndos = 0
	}
	if ($0 ~ /dos/) {next}
	dos_ndos++
	dos_dos_atom[dos_ndos] = $1
	dos_dos_descr[dos_ndos] = $2
	$0 = rm_keyword(dos_dos_atom[dos_ndos],$0)
	$0 = rm_keyword(dos_dos_descr[dos_ndos],$0)
	dos_dos_label[dos_ndos] = $0
	next
    }
}
/^( |\t)*spin/ && global_section=="dosplot"{
    dos_spin = $2
    if (global_spinpolarized == "no"){
	print "[error|dos] Spin keyword does not make sense in a non-spinpolarized calculation."
	exit 1
    }
    if (dos_spin != "merge" && dos_spin != "new" && dos_spin != "no"){
	print "[error|dos] Spin option not recognized."
	print "[error|dos] Must be one of merge, new, no."
	exit 1
    }
    next
}
/^( |\t)*join/ && global_section=="dosplot"{
    $0 = rm_keyword("join",$0)
    dos_joins++
    dos_join_n[dos_joins] = NF
    for (i=1;i<=NF;i++){
	if ($i ~ /up/){
	    if (global_spinpolarized == "no")
		print "[warn|dos] Bad join keyword: can not use up in non-spinpolarized calculations."
	    else
		dos_join_flag[dos_joins,i] = "up"
	}
	else if ($i ~ /dn/)
	    if (global_spinpolarized == "no")
		print "[warn|dos] Bad join keyword: can not use dn in non-spinpolarized calculations."
	    else
		dos_join_flag[dos_joins,i] = "dn"
	else
	    dos_join_flag[dos_joins,i] = ""
	if ($i ~ /\*/){
	    $i = $i + 0
	    if (dos_dos_atom[$i] < 1 || dos_dos_atom[$i] > global_nneq){
		print "[warn|dos] Bad join keyword: atom's plot does not have an associated multiplicity."
		dos_join_mult[dos_joins,i] = 1
	    }
	    else
		dos_join_mult[dos_joins,i] = global_mult[dos_dos_atom[$i]]
	}
	else
	    dos_join_mult[dos_joins,i] = 1
	dos_join[dos_joins,i] = $i + 0
    }
    next
}
/^( |\t)*energymin/ && global_section=="dosplot"{
    dos_energymin = $2
    if ($3 == "ev")
	dos_energymin = dos_energymin / const_rytoev
    next
}
/^( |\t)*energymax/ && global_section=="dosplot"{
    dos_energymax = $2
    if ($3 == "ev")
	dos_energymax = dos_energymax / const_rytoev
    next
}
/^( |\t)*plotxmin/ && global_section=="dosplot"{
    dos_plotxmin = $2
    if ($3 == "ev")
	dos_plotxmin = dos_plotxmin / const_rytoev
    next
}
/^( |\t)*plotxmax/ && global_section=="dosplot"{
    dos_plotxmax = $2
    if ($3 == "ev")
	dos_plotxmax = dos_plotxmax / const_rytoev
    next
}
/^( |\t)*in1maxenergy/ && global_section=="dosplot"{
    dos_in1maxenergy = $2
    if ($3 == "ev")
	dos_in1maxenergy = dos_in1maxenergy / const_rytoev
    next
}
# (irxi) Rxplot section parameters input
/^( |\t)*do( |\t)+/ && global_section == "rxplot" {
    $0 = rm_keyword("do",$0)
    rx_dolines++
    rx_doline[rx_dolines] = $0
    rx_dotype[rx_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "rxplot" {
    $0 = rm_keyword("except",$0)
    rx_dolines++
    rx_doline[rx_dolines] = $0
    rx_dotype[rx_dolines] = "except"
    next
}
/^( |\t)*atom/ && global_section=="rxplot"{
    rx_atom = $2
    next
}
/^( |\t)*n/ && global_section=="rxplot"{
    rx_n = $2
    next
}
/^( |\t)*l/ && global_section=="rxplot"{
    rx_l = $2
    next
}
/^( |\t)*plotxmin/ && global_section=="rxplot"{
    rx_plotxmin = $2
    next
}
/^( |\t)*plotxmax/ && global_section=="rxplot"{
    rx_plotxmax = $2
    next
}
/^( |\t)*de/ && global_section=="rxplot"{
    rx_de = $2
    next
}
/^( |\t)*type/ && global_section=="rxplot"{
    rx_type = $2
    if (rx_type != "abs" && rx_type != "emis"){
	print "[error|rx] Type option not recognized."
	print "[error|rx] Must be one of abs, emis."
	exit 1
    }
    next
}
/^( |\t)*in1maxenergy/ && global_section=="rxplot"{
    rx_in1maxenergy = $2
    next
}
# (ibandi) Bandplot section parameters input
/^( |\t)*do( |\t)+/ && global_section == "bandplot" {
    $0 = rm_keyword("do",$0)
    band_dolines++
    band_doline[band_dolines] = $0
    band_dotype[band_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "bandplot" {
    $0 = rm_keyword("except",$0)
    band_dolines++
    band_doline[band_dolines] = $0
    band_dotype[band_dolines] = "except"
    next
}
/^( |\t)*klist/ && global_section=="bandplot"{
    $0 = rm_keyword("klist",$0)
    if ($1 == "template"){
	gsub(/\.klist$/,"",$2)
	if (!checkexists("$WIENROOT/SRC_templates/" $2 ".klist ")){
	    print "[error|band] Template file not found: " $2 ".klist ."
	    print "[error|band] Check $WIENROOT/SRC_templates for available klist files."
	    exit 1
	}
	band_klist = ENVIRON["WIENROOT"] "/SRC_templates/" $2 ".klist"
    }
    else if ($1 == "file"){
	gsub(/\.klist$/,"",$2)
	if (!checkexists($2 ".klist")){
	    print "[error|band] File not found: " $2 ".klist"
	    print "[error|band] Check $WIENROOT/SRC_templates for available klist files."
	    exit 1
	}
	band_klist = $2 ".klist"
    }
    else{
	print "[error|band] Klist option not recognized."
	print "[error|band] Must be one of file, template."
	exit 1
    }
    next
}
/^( |\t)*in1maxenergy/ && global_section=="bandplot"{
    band_in1maxenergy = $2
    if ($3 == "ev")
	band_in1maxenergy = band_in1maxenergy / const_rytoev
    next
}
# (ikdosi) Kdos section parameters input
/^( |\t)*do( |\t)+/ && global_section == "kdos" {
    $0 = rm_keyword("do",$0)
    kdos_dolines++
    kdos_doline[kdos_dolines] = $0
    kdos_dotype[kdos_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "kdos" {
    $0 = rm_keyword("except",$0)
    kdos_dolines++
    kdos_doline[kdos_dolines] = $0
    kdos_dotype[kdos_dolines] = "except"
    next
}
/^( |\t)*plotxmin/ && global_section=="kdos"{
    kdos_plotxmin = $2
    if ($3 == "ry")
	kdos_plotxmin = kdos_plotxmin * const_rytoev
    next
}
/^( |\t)*plotxmax/ && global_section=="kdos"{
    kdos_plotxmax = $2
    if ($3 == "ry")
	kdos_plotxmax = kdos_plotxmax * const_rytoev
    next
}
/^( |\t)*plotymax/ && global_section=="kdos"{
    kdos_plotymax = $2
    next
}
/^( |\t)*kdos/ && global_section=="kdos"{
     kdos_nkdos++
     kdos_dos[kdos_nkdos] = $2
     if ($3 != "" && global_spinpolarized == "no")
	 print "[warn|kdos] This is not a spinpolarized calc., band field ignored."
     kdos_band[kdos_nkdos] = $3
     next
}
# (iaimi) Aim section parameters input
/^( |\t)*do( |\t)+/ && global_section == "aim" {
    $0 = rm_keyword("do",$0)
    aim_dolines++
    aim_doline[aim_dolines] = $0
    aim_dotype[aim_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "aim" {
    $0 = rm_keyword("except",$0)
    aim_dolines++
    aim_doline[aim_dolines] = $0
    aim_dotype[aim_dolines] = "except"
    next
}
/^( |\t)*atom/ && global_section=="aim"{
    aim_atom = $2 + 0
    if (aim_atom < 1){
	print "[error|aim] Bad non-equivalent atom number in atom keyword."
	exit 1
    }
    next
}
/^( |\t)*uses/ && global_section=="aim"{
    aim_uses = $2
    if (aim_uses != "two" && aim_uses != "thre" && aim_uses != "four" && aim_uses != "all"){
	print "[error|aim] Uses keyword must be one of two, thre, four, all"
	exit 1
    }
    next
}
/^( |\t)*nshells/ && global_section=="aim"{
    aim_nsh_x = $2 +0
    aim_nsh_y = $3 +0
    aim_nsh_z = $4 +0
    next
}
# (icritici) Critic section parameters input
/^( |\t)*do( |\t)+/ && global_section == "critic" {
    $0 = rm_keyword("do",$0)
    critic_dolines++
    critic_doline[critic_dolines] = $0
    critic_dotype[critic_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "critic" {
    $0 = rm_keyword("except",$0)
    critic_dolines++
    critic_doline[critic_dolines] = $0
    critic_dotype[critic_dolines] = "except"
    next
}
/^( |\t)*line/ && global_section=="critic"{
    if ($2 ~ /atom/){
	critic_linetype1 = "atom"
	critic_lineatom1 = $3
	critic_linemult1 = $4
    }
    else{
	critic_linetype1 = "coord"
	critic_linex1 = $2
	critic_liney1 = $3
	critic_linez1 = $4
    }
    if ($5 ~ /atom/){
	critic_linetype2 = "atom"
	critic_lineatom2 = $6
	critic_linemult2 = $7
    }
    else{
	critic_linetype2 = "coord"
	critic_linex2 = $5
	critic_liney2 = $6
	critic_linez2 = $7
    }
    critic_linepoints = $8
    next
}
/^( |\t)*nice/ && global_section=="critic"{
    critic_nice = 1
    next
}
/^( |\t)*integrals/ && global_section=="critic"{
    critic_integrals = 1
    if ($2)
	critic_integrals_nr = $2 + 0
    if ($3)
	critic_integrals_nt = $3 + 0
    if ($4)
	critic_integrals_np = $4 + 0
    next
}
/^( |\t)*basinplot/ && global_section=="critic"{
    critic_basinplot = 1
    critic_basin_level = $2
    critic_basin_delta = $3
    critic_basin_theta = $4
    critic_basin_phi = $5
    next
}
/^( |\t)*noiws/ && global_section=="critic"{
    if ($2)
	critic_iws = "NOIWS " $2
    else
	critic_iws = "NOIWS 3"
    next
}
/^( |\t)*iws/ && global_section=="critic"{
    if ($2)
	critic_iws = "IWS " $2
    else
	critic_iws = "IWS 3"
    next
}
/^( |\t)*newton/ && global_section=="critic"{
    if ($2)
	critic_newton = $2
    else
	critic_newton = "1.e-15"
    next
}
/^( |\t)*grdvec( |\t)*$/,/^( |\t)*end( |\t)*grdvec( |\t)*$/{
    if (global_section == "critic"){
	if ($0 ~ /^( |\t)*grdvec( |\t)*$/){
	    critic_grdvec_lines = 0
	}
	critic_grdvec_lines++
	critic_grdvec_line[critic_grdvec_lines] = $0
	if ($0 ~ /^( |\t)*end( |\t)*grdvec( |\t)*$/)
	    critic_grdvec_line[critic_grdvec_lines] = "ENDGRDVEC"
	if ($0 ~ /^( |\t)*files/){
	    critic_grdvec_filename = rm_keyword("files",$0)
	}
	next
    }
}
/^( |\t)*doplot/ && global_section=="critic"{
    critic_doplot = $0
    next
}
/^( |\t)*use/ && global_section=="critic"{
    critic_use = $2
    if (critic_use != "rho" && critic_use != "valrho" && critic_use != "atomic"){
	print "[error|critic] Use keyword must be one of rho, valrho, atomic."
	exit 1
    }
    next
}
/^( |\t)*nosummary/ && global_section=="critic"{
    critic_nosummary = 1
    next
}
# (isweepi) Sweep section parameters input
/^( |\t)*do( |\t)+/ && global_section == "sweep"{
    $0 = rm_keyword("do",$0)
    sweep_dolines++
    sweep_doline[sweep_dolines] = $0
    sweep_dotype[sweep_dolines] = "do"
    next
}
/^( |\t)*except/ && global_section == "sweep"{
    $0 = rm_keyword("except",$0)
    sweep_dolines++
    sweep_doline[sweep_dolines] = $0
    sweep_dotype[sweep_dolines] = "except"
    next
}
/^( |\t)*reference( |\t)*struct/ && global_section=="sweep"{
    temp_string = rm_keyword("reference",$0)
    temp_string = rm_keyword("struct",temp_string)
    if (sweep_ref){
	print "[warn|sweep] reference struct is set by a loaded calculation."
	next
    }
    else
	sweep_ref = temp_string
    next
}
/^( |\t)*npt/ && global_section=="sweep"{
    if (sweep_olditerations){
	print "[warn|sweep] npt is set by a loaded calculation."
	next
    }
    if (NF == 3)
	sweep_npt[$2] = $3
    else
	sweep_npt[1] = $2
    next
}
/^( |\t)*rmt/ && global_section=="sweep"{
    if (sweep_olditerations){
	print "[warn|sweep] rmt is set by a loaded calculation."
	next
    }
    if (NF == 3)
	sweep_rmt[$2] = $3
    else
	sweep_rmt[1] = $2
    next
}
/^( |\t)*r0/ && global_section=="sweep"{
    if (sweep_olditerations){
	print "[warn|sweep] r0 is set by a loaded calculation."
	next
    }
    if (NF == 3)
	sweep_r0[$2] = $3
    else
	sweep_r0[1] = $2
    next
}
/^( |\t)*rkmax/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_rkmax){
	print "[warn|sweep] rkmax is set by a loaded calculation."
	next
    }
    else
	sweep_rkmax = temp_string
    next
}
/^( |\t)*lmax/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_lmax){
	print "[warn|sweep] lmax is set by a loaded calculation."
	next
    }
    else
	sweep_lmax = temp_string
    next
}
/^( |\t)*lnsmax/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_lnsmax){
	print "[warn|sweep] lnsmax is set by a loaded calculation."
	next
    }
    else
	sweep_lnsmax = temp_string
    next
}
/^( |\t)*gmax/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_gmax){
	print "[warn|sweep] gmax is set by a loaded calculation."
	next
    }
    else
	sweep_gmax = temp_string
    next
}
/^( |\t)*mix/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_mix){
	print "[warn|sweep] mix is set by a loaded calculation."
	next
    }
    else
	sweep_mix = temp_string
    next
}
/^( |\t)*kpts/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_kpts){
	print "[warn|sweep] kpts is set by a loaded calculation."
	next
    }
    else
	sweep_kpts = temp_string
    next
}
/^( |\t)*also/ && global_section=="sweep"{
    sweep_alsos++
    next
}
/^( |\t)*with/ && global_section=="sweep"{
    temp_string = $2
    sweep_with[sweep_alsos,temp_string] = rm_keyword("with",$0)
    sweep_with[sweep_alsos,temp_string] = rm_keyword(temp_string,sweep_with[sweep_alsos,temp_string])
    next
}
/^( |\t)*print/ && global_section=="sweep"{
    sweep_prints++
    if ($6){
	if ($6 !~ /(a|b|c|alpha|beta|gamma|v|c\/a|c\/b|b\/a)/){
	    print "[warn|sweep] bad print variable... removing print"
	    sweep_prints--
	    next
	}
	if ($4 !~ /(a|b|c|alpha|beta|gamma|v|c\/a|c\/b|b\/a)/){
	    print "[warn|sweep] bad print variable... removing print"
	    sweep_prints--
	    next
	}
	if ($2 !~ /(a|b|c|alpha|beta|gamma|v|c\/a|c\/b|b\/a|energy|topology|planarity|efermi)/){
	    print "[warn|sweep] bad print variable... removing print"
	    sweep_prints--
	    next
	}
	sweep_print_x[sweep_prints] = $6
	sweep_print_y[sweep_prints] = $4
	sweep_print_z[sweep_prints] = $2
    }
    else{
	if ($4 !~ /(a|b|c|alpha|beta|gamma|v|c\/a|c\/b|b\/a)/){
	    print "[warn|sweep] bad print variable... removing print"
	    sweep_prints--
	    next
	}
	if ($2 !~ /(a|b|c|alpha|beta|gamma|v|c\/a|c\/b|b\/a|energy|topology|planarity|efermi)/){
	    print "[warn|sweep] bad print variable... removing print"
	    sweep_prints--
	    next
	}
	sweep_print_x[sweep_prints] = $4
	sweep_print_y[sweep_prints] = $2
    }
    next
}
/^( |\t)*xcpotential/ && global_section=="sweep"{
    temp_string = rm_keyword("xcpotential",$0)
    if (sweep_potential){
	print "[warn|sweep] xcpotential is set by a loaded calculation."
	next
    }
    else
	sweep_potential = temp_string
    next
}
/^( |\t)*ecoreval/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_ecoreval){
	print "[warn|sweep] ecoreval is set by a loaded calculation."
	next
    }
    else
	sweep_ecoreval = temp_string
    next
}
/^( |\t)*ifft/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_ifft){
	print "[warn|sweep] ifft is set by a loaded calculation."
	next
    }
    else
	sweep_ifft = temp_string
    next
}
/^( |\t)*energymin/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_energymin){
	print "[warn|sweep] energymin is set by a loaded calculation."
	next
    }
    else
	sweep_energymin = temp_string
    next
}
/^( |\t)*energymax/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_energymax){
	print "[warn|sweep] energymax is set by a loaded calculation."
	next
    }
    else
	sweep_energymax = temp_string
    next
}
/^( |\t)*orbitals( |\t)*/,/^( |\t)*end( |\t)*orbitals( |\t)*$/{
    if (global_section=="sweep") {
	if ($0 ~ /^( |\t)*end( |\t)*orbitals( |\t)*$/) {
	    next
	}
	if ($0 ~ /orbitals/) {
	    if (sweep_olditerations){
		print "[warn|sweep] orbitals is set by a loaded calculation."
		next
	    }
	    if (!$2 || $2 > global_nneq){
		print "[error|sweep] Orbitals do not refer to any non-equivalent atom"
		print "[error|sweep] Correct .wien input"
		exit 1
	    }
	    if (NF != 4){
		print "[error|sweep] Wrong input in orbital specification"
		exit 1
	    }
	    temp_val = $2
	    sweep_orbital_globe[temp_val] = $3
	    sweep_orbital_globapw[temp_val] = $4
	    next
	}
	if (sweep_olditerations)
	    next
	sweep_orbitals[temp_val]++
	sweep_orbital_l[temp_val,sweep_orbitals[temp_val]] = $1
	sweep_orbital_energy[temp_val,sweep_orbitals[temp_val]] = $2
	sweep_orbital_var[temp_val,sweep_orbitals[temp_val]] = $3
	sweep_orbital_cont[temp_val,sweep_orbitals[temp_val]] = $4
	sweep_orbital_apw[temp_val,sweep_orbitals[temp_val]] = $5
	next
    }
}
/^( |\t)*lm( |\t)*list( |\t)*/,/^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/{
    if (global_section=="sweep") {
	if ($0 ~ /^( |\t)*end( |\t)*lm( |\t)*list( |\t)*$/) {
	    next
	}
	if ($0 ~ /^( |\t)*lm( |\t)*list( |\t)*/){
	    if (sweep_olditerations){
		print "[warn|sweep] lm list is set by a loaded calculation."
		next
	    }
	    if (!$3 || $3 > global_nneq || $3 <= 0){
		print "[error|sweep] lms do not refer to any non-equivalent atom"
		print "[error|sweep] Correct .wien input"
		exit 1
	    }
	    if (NF != 3){
		print "[error|sweep] Wrong input in lm specification"
		exit 1
	    }
	    temp_val = $3
	    next
	}
	if (sweep_olditerations)
	    next
	if (int(NF/2) != NF/2){
	    print "[error|sweep] Wrong number of fields in lm specification."
	    print "[error|sweep] number of fields must be even."
	    exit 1
	}
	for (i=1;i<=NF/2;i++){
	    sweep_lms[temp_val]++
	    sweep_lm_l[temp_val,sweep_lms[temp_val]] = $(2*i-1)
	    sweep_lm_m[temp_val,sweep_lms[temp_val]] = $(2*i)
	}
	next
    }
}
/^( |\t)*fermi/ && global_section=="sweep"{
    if (sweep_olditerations){
	print "[warn|sweep] fermi is set by a loaded calculation."
	next
    }
    sweep_fermi = $2
    sweep_fermival = $3
    if (sweep_fermi != "root" && sweep_fermi != "temp" &&\
	sweep_fermi != "temps" && sweep_fermi != "gauss" &&\
	sweep_fermi != "tetra" && sweep_fermi != "all"){
	print "[error|sweep] fermi method not recognized."
	print "[error|sweep] must be one of root, temp, temps, gauss, tetra, all."
	exit 1
    }
    next
}
/^( |\t)*nice/ && global_section=="sweep"{
    sweep_nice = $2
    next
}
/^( |\t)*itdiag/ && global_section=="sweep"{
    temp_string = $2
    if (sweep_itdiag){
	print "[warn|sweep] itdiag is set by a loaded calculation."
	next
    }
    else
	if (temp_string)
	    sweep_itdiag = temp_string
	else
	    sweep_itdiag = 3
    next
}
/^( |\t)*max( |\t)*iterations/ && global_section=="sweep"{
    temp_string = rm_keyword("max",$0)
    temp_string = rm_keyword("iterations",temp_string)
    if (sweep_miter){
	print "[warn|sweep] max iterations is set by a loaded calculation."
	next
    }
    else
	sweep_miter = temp_string
    next
}
/^( |\t)*charge( |\t)*conv/ && global_section=="sweep"{
    temp_string = rm_keyword("charge",$0)
    temp_string = rm_keyword("conv",temp_string)
    if (sweep_cc){
	print "[warn|sweep] charge conv is set by a loaded calculation."
	next
    }
    else
	sweep_cc = temp_string+0
    next
}
/^( |\t)*energy( |\t)*conv/ && global_section=="sweep"{
    temp_string = rm_keyword("energy",$0)
    temp_string = rm_keyword("conv",temp_string)
    if (sweep_ec){
	print "[warn|sweep] energy conv is set by a loaded calculation."
	next
    }
    else
	sweep_ec = temp_string+0
    next
}
/^( |\t)*force( |\t)*conv/ && global_section=="sweep"{
    temp_string = rm_keyword("force",$0)
    temp_string = rm_keyword("conv",temp_string)
    if (sweep_fc){
	print "[warn|sweep] force conv is set by a loaded calculation."
	next
    }
    else
	sweep_fc = temp_string+0
    next
}
/^( |\t)*new( |\t)*in1/ && global_section=="sweep"{
    temp_string = $3
    if (sweep_in1new){
	print "[warn|sweep] new in1 is set by a loaded calculation."
	next
    }
    else
	sweep_in1new = temp_string
    next
}
/^( |\t)*reuse/ && global_section=="sweep"{
    sweep_reusemode = $2
    if (sweep_reusemode != "chain" && sweep_reusemode != "reference" && sweep_reusemode != "path" && sweep_reusemode != "detect"){
	print "[error|sweep] Reuse keyword must be one of chain, reference, path and detect."
	exit 1
    }
    if (sweep_reusemode == "path")
	sweep_reuseval = $3
    next
}
/^( |\t)*noreuse/ && global_section=="sweep"{
    sweep_noreuse = 1
    next
}
/^( |\t)*spinorbit/ && global_section=="sweep"{
    if (NF > 1){
	sweep_so_doall = ""
	$0 = rm_keyword("spinorbit",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_so_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_so_doall = 1
    }
    sweep_so_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*spinorbit/ ; getline){
	sweep_so_lines++
	sweep_so_line[sweep_so_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*elastic/ && global_section=="sweep"{
    if (NF > 1){
	sweep_elastic_doall = ""
	$0 = rm_keyword("elastic",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_elastic_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_elastic_doall = 1
    }
    sweep_elastic_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*elastic/ ; getline){
	sweep_elastic_lines++
	sweep_elastic_line[sweep_elastic_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*printrho/ && global_section=="sweep"{
    if (NF > 1){
	sweep_prho_doall = ""
	$0 = rm_keyword("printrho",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_prho_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_prho_doall = 1
    }
    sweep_prho_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*printrho/ ; getline){
	sweep_prho_lines++
	sweep_prho_line[sweep_prho_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*dosplot/ && global_section=="sweep"{
    if (NF > 1){
	sweep_dos_doall = ""
	$0 = rm_keyword("dosplot",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_dos_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_dos_doall = 1
    }
    sweep_dos_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*dosplot/ ; getline){
	sweep_dos_lines++
	sweep_dos_line[sweep_dos_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*rxplot/ && global_section=="sweep"{
    if (NF > 1){
	sweep_rx_doall = ""
	$0 = rm_keyword("rxplot",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_rx_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_rx_doall = 1
    }
    sweep_rx_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*rxplot/ ; getline){
	sweep_rx_lines++
	sweep_rx_line[sweep_rx_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*bandplot/ && global_section=="sweep"{
    if (NF > 1){
	sweep_band_doall = ""
	$0 = rm_keyword("bandplot",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_band_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_band_doall = 1
    }
    sweep_bandplot_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*bandplot/ ; getline){
	sweep_band_lines++
	sweep_band_line[sweep_band_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*kdos/ && global_section=="sweep"{
    if (NF > 1){
	sweep_kdos_doall = ""
	$0 = rm_keyword("kdos",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_kdos_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_kdos_doall = 1
    }
    sweep_kdos_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*kdos/ ; getline){
	sweep_kdos_lines++
	sweep_kdos_line[sweep_kdos_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*aim/ && global_section=="sweep"{
    if (NF > 1){
	sweep_aim_doall = ""
	$0 = rm_keyword("aim",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_aim_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_aim_doall = 1
    }
    sweep_aim_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*aim/ ; getline){
	sweep_aim_lines++
	sweep_aim_line[sweep_aim_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*critic/ && global_section=="sweep"{
    if (NF > 1){
	sweep_critic_doall = ""
	$0 = rm_keyword("critic",$0)
	list_parser($0)
	for (i=1;i<=global_niter;i++){
	    for(x=1;x<=global_num[i];x++){
		j = global_ini[i] + (x-1)*global_incr[i]
		sweep_critic_do[j+0] = 1
	    }
	}
    }
    else{
	sweep_critic_doall = 1
    }
    sweep_critic_lines = 0
    for (getline ; $0 !~ /( |\t)*end( |\t)*critic/ ; getline){
	sweep_critic_lines++
	sweep_critic_line[sweep_critic_lines] = "  " rm_keyword("",$0)
    }
    next
}
/^( |\t)*nosummary/ && global_section=="sweep"{
    sweep_nosummary = 1
    next
}
/^( |\t)*clean/ && global_section=="sweep"{
    sweep_clean = rm_keyword("",$0)
    next
}
/^( |\t)*mini/ && global_section=="sweep"{
    if ($2)
	sweep_mini = rm_keyword("mini",$0)
    else
	sweep_mini = "defline"
    next
}
/^( |\t)*lda\+u( |\t)*/,/^( |\t)*end( |\t)*lda\+u( |\t)*$/{
    if (global_section=="sweep") {
	if ($0 ~ /^( |\t)*end( |\t)*lda\+u( |\t)*$/) {
	    if (sweep_ldaus+0 == 0){
		print "[warn|sweep] lda+u must be activated for at least one atom and l."
		print "[warn|sweep] deactivating the usage of lda+u..."
		sweep_ldautype = ""
	    }
	    next
	}
	if ($0 ~ /lda\+u/) {
	    sweep_ldautype = $2
	    if (sweep_ldautype != "sic" && sweep_ldautype != "amf" && sweep_ldautype != "hmf"){
		print "[error|sweep] lda+u type must be one of: sic, amf, hmf."
		exit 1
	    }
	    sweep_ldau = "-orb"
	    next
	}
	sweep_ldaus++
	sweep_ldau_atom[sweep_ldaus] = $1
	sweep_ldau_l[sweep_ldaus] = $2
	if (sweep_ldau_l[sweep_ldaus] == "s")
	    sweep_ldau_l[sweep_ldaus] = 0
	else if (sweep_ldau_l[sweep_ldaus] == "p")
	    sweep_ldau_l[sweep_ldaus] = 1
	else if (sweep_ldau_l[sweep_ldaus] == "d")
	    sweep_ldau_l[sweep_ldaus] = 2
	else if (sweep_ldau_l[sweep_ldaus] == "f")
	    sweep_ldau_l[sweep_ldaus] = 3
	sweep_ldau_defu[sweep_ldaus] = $3
	if ($0 ~ "ev")
	    sweep_ldau_defu[sweep_ldaus] /= const_rytoev
	sweep_ldau_defj[sweep_ldaus] = $4
	if ($0 ~ "ev")
	    sweep_ldau_defj[sweep_ldaus] /= const_rytoev
	next
    }
}
# (igibbsi) Gibbs section parameters input
/^( |\t)*eos/ && global_section=="gibbs"{
    gibbs_eos = $2
    if (gibbs_eos != "numerical" && gibbs_eos != "vinet" && gibbs_eos != "birch" && gibbs_eos != "numerical+vinet" && gibbs_eos != "numerical+birch" && gibbs_eos != "bcnt" && gibbs_eos != "numerical+bcnt"){
	print "[error|sweep] Wrong eos specification in gibbs section."
	exit 1
    }
    if (gibbs_eos == "bcnt" || gibbs_eos == "numerical+bcnt"){
	gibbs_bcnt = $3
    }
    next
}
/^( |\t)*debye/ && global_section=="gibbs"{
    gibbs_debye = $2
    if (gibbs_debye != "static" && gibbs_debye != "debyestatic" && gibbs_debye != "debyeiter" && gibbs_debye != "debyestaticbv"){
	print "[error|sweep] Wrong debye specification in gibbs section."
	exit 1
    }
    gibbs_poisson = $3
    next
}
/^( |\t)*pressure/ && global_section=="gibbs"{
    temp_string = rm_keyword("pressure",$0)
    list_parser(temp_string)
    for (i=1;i<=global_niter;i++){
	for(x=1;x<=global_num[i];x++){
	    j = global_ini[i] + (x-1)*global_incr[i]
	    gibbs_ps++
	    gibbs_p[gibbs_ps] = j
	}
    }
    next
}
/^( |\t)*temperature/ && global_section=="gibbs"{
    temp_string = rm_keyword("temperature",$0)
    list_parser(temp_string)
    for (i=1;i<=global_niter;i++){
	for(x=1;x<=global_num[i];x++){
	    j = global_ini[i] + (x-1)*global_incr[i]
	    gibbs_ts++
	    gibbs_t[gibbs_ts] = j
	}
    }
    next
}
/^( |\t)*free( |\t)energy/ && global_section=="gibbs"{
    gibbs_freeenergy = $3
    next
}
# (isyni) Synopsis section parameters input
/^( |\t)*output/ && global_section=="synopsis"{
    syn_output = $2
    next
}
/^( |\t)*exhaustive/ && global_section == "synopsis"{
    if ($2){
	list_parser($2)
	if (global_niter > 0){
	    for (i=1;i<=global_niter;i++){
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    syn_exhaustive_general_n++
		    syn_exhaustive_general[syn_exhaustive_general_n] = j
		}
	    }
	}
    }
    else{
	for (i=1;i<=general_iterations;i++){
	    syn_exhaustive_general_n++
	    syn_exhaustive_general[syn_exhaustive_general_n] = i
	}
    }
    next
}
# (xgeneralx) General section final tasks
/^( |\t)*end( |\t)*general( |\t)*$/ && global_section=="general"{
    global_section = ""
    general_run = 1
    # Get initial time
    general_totaltime = systime()
    # Stdout header
    print ""
    print "[info|general] Runwien.awk lapw calculation using wien2k, version: "  global_version
    print "[info|general] date : " date()
    print "[info|general] machine : " global_machine
    print "[info|general] root : " global_root
    print ""
    print "[info|general] Beginning of general section at " date()
    # Generate atom positions and multiplicities from space group information
    if (global_spgroup){
	# Check conditions
	if (!checkexe(const_spacegroupexe)){
	    print "[error|general] spacegroup executable not found."
	    exit 1
	}
	if (general_ciffile || general_structfile){
	    print "[error|general] loadcif and loadstruct are incompatible with spglist keyword."
	    exit 1
	}
	if (!global_a || !global_b || !global_c || !global_alpha || !global_beta || !global_gamma){
	    print "[error|general] cell parameters are not set."
	    exit 1
	}
	if (!const_spglat1[global_spgroup] && !const_spglat2[global_spgroup]){
	    print "[error|general] space group symbol not found : " global_spgroup
	    print "[error|general] check the runwien user's guide for information on spg labels."
	    exit 1
	}
	# Stdout message and lattice
	if (const_spglat1[global_spgroup]){
	    print "[info|general] Parsing space group symbol " global_spgroup " , lattice " const_spglat1[global_spgroup]
	    global_lattice = const_spglat1[global_spgroup]
	}
	else{
	    print "[info|general] Parsing space group symbol " global_spgroup " , lattice " const_spglat2[global_spgroup]
	    global_lattice = const_spglat2[global_spgroup]
	}
	# Transform cell lengths to hex
	if (global_spg_rhomb == 1){
	    if (global_a != global_b || global_a != global_c || global_alpha != global_beta || global_alpha != global_gamma){
		print "[error|general] spglist: rhomb specification is not correct"
		print "[error|general] the cell parameters do not correspond to a rhomb. setup"
		exit 1
	    }
	    global_a = 2 * cos(0.5*(const_pi-global_alpha*const_pi/180))*global_a
	    global_c = 3*sqrt(global_b^2 - global_a^2/3)
	    global_b = global_a
	    global_alpha = global_beta = 90
	    global_gamma = 120
	    print "[info|general] New cell lengths (hex) :",global_a,global_b,global_c,global_alpha,global_beta,global_gamma
	}
	# Build input for spacegroup, and run
	temp_file = global_pwd "/tempfile"
	temp_output = global_pwd "/tempoutput"
	print "#! /bin/bash" > temp_file
	print const_spacegroupexe " << --eof-- > " temp_output " 2>&1" > temp_file
	printf "%.10f %.10f %.10f %.10f %.10f %.10f\n",global_a, global_b, global_c, global_alpha, global_beta, global_gamma > temp_file
	print global_spgroup > temp_file
	for (i=1;i<=global_nneq;i++){
	    print global_atom[i] > temp_file
	    printf "%.10f %.10f %.10f\n", global_nneq_x[i,1], global_nneq_y[i,1], global_nneq_z[i,1] > temp_file
	}
	printf "\n" > temp_file
	print "--eof--" > temp_file
	close(temp_file)
	mysystem("chmod u+x " temp_file)
	mysystem(temp_file)
	mysystem("rm -f " temp_file)
	# Parse output
	temp_val = getline < temp_output
	for (i=0;temp_val;){
	    if (tolower($0) ~ /error/){
		print "[error|general] error in spacegroup execution."
		print "[error|general] check the output of spacegroup : " temp_output
		close(temp_output)
		exit 1
	    }
	    temp_string = "Coordinates of the " i+1 ".. atom"
	    if ($0 ~ temp_string){
		i++
		global_mult[i] = 1
		global_nneq_x[i,1] = $(NF-2)
		global_nneq_y[i,1] = $(NF-1)
		global_nneq_z[i,1] = $NF
		if (global_lattice == "R"){
		    temp_x = global_nneq_x[i,1] * const_hex2rhomb[1,1] + global_nneq_y[i,1] * const_hex2rhomb[2,1] + global_nneq_z[i,1] * const_hex2rhomb[3,1]
		    temp_y = global_nneq_x[i,1] * const_hex2rhomb[1,2] + global_nneq_y[i,1] * const_hex2rhomb[2,2] + global_nneq_z[i,1] * const_hex2rhomb[3,2]
		    temp_z = global_nneq_x[i,1] * const_hex2rhomb[1,3] + global_nneq_y[i,1] * const_hex2rhomb[2,3] + global_nneq_z[i,1] * const_hex2rhomb[3,3]
		    if (temp_x >= 1.0)
			temp_x -= 1.0
		    if (temp_x <= 0.0)
			temp_x += 1.0
		    if (temp_y >= 1.0)
			temp_y -= 1.0
		    if (temp_x <= 0.0)
			temp_y += 1.0
		    if (temp_z >= 1.0)
			temp_z -= 1.0
		    if (temp_z <= 0.0)
			temp_z += 1.0
		    global_nneq_x[i,1] = temp_x
		    global_nneq_y[i,1] = temp_y
		    global_nneq_z[i,1] = temp_z
		}
		for (temp_val = getline < temp_output;$0 !~ "Name" && temp_val;temp_val = getline < temp_output){
		    if (tolower($0) ~ /error/){
			print "[error|general] error in spacegroup execution."
			print "[error|general] check the output of spacegroup : " temp_output
			close(temp_output)
			exit 1
		    }
		    global_mult[i]++
		    global_nneq_x[i,global_mult[i]] = $(NF-2)
		    global_nneq_y[i,global_mult[i]] = $(NF-1)
		    global_nneq_z[i,global_mult[i]] = $NF
		    if (global_lattice == "R"){
			temp_x = global_nneq_x[i,global_mult[i]] * const_hex2rhomb[1,1] + global_nneq_y[i,global_mult[i]] * const_hex2rhomb[2,1] + global_nneq_z[i,global_mult[i]] * const_hex2rhomb[3,1]
			temp_y = global_nneq_x[i,global_mult[i]] * const_hex2rhomb[1,2] + global_nneq_y[i,global_mult[i]] * const_hex2rhomb[2,2] + global_nneq_z[i,global_mult[i]] * const_hex2rhomb[3,2]
			temp_z = global_nneq_x[i,global_mult[i]] * const_hex2rhomb[1,3] + global_nneq_y[i,global_mult[i]] * const_hex2rhomb[2,3] + global_nneq_z[i,global_mult[i]] * const_hex2rhomb[3,3]
			if (temp_x >= 1.0)
			    temp_x -= 1.0
			if (temp_x <= 0.0)
			    temp_x += 1.0
			if (temp_y >= 1.0)
			    temp_y -= 1.0
			if (temp_x <= 0.0)
			    temp_y += 1.0
			if (temp_z >= 1.0)
			    temp_z -= 1.0
			if (temp_z <= 0.0)
			    temp_z += 1.0
			global_nneq_x[i,global_mult[i]] = temp_x
			global_nneq_y[i,global_mult[i]] = temp_y
			global_nneq_z[i,global_mult[i]] = temp_z
		    }
		}
	    }
	    else
		temp_val = getline < temp_output
	}
	close(temp_output)
	mysystem("rm -f " temp_output)
    }
    # Verify needed parameters are set
    print "[info|general] Verifying compulsory parameters..."
    if (!general_ciffile && !general_structfile && (!global_lattice || !global_nneq || !global_a || !global_b || !global_c || !global_alpha || !global_beta || !global_gamma)){
	print "[error|general] missing parameter in general section"
	exit 1
    }
    # If using cif file, load data from it
    if (general_ciffile){
	## Get direct info from cif file
	print "[info|general] Extracting info from .cif file..."
	## Check existence
  	if (!checkexists(general_ciffile)){
  	    print "[error|general] .cif file does not exist"
  	    print "[error|general] Check .cif address is correctly set in .wien"
  	    exit 1
 	}
	## Check cif2struct exists
	print "[info|general] Checking for cif2struct..."
	if (!checkexe(const_cif2structexe)){
	    print "[error|global] cif2struct executable not found."
	    exit 1
	}
	## Extract data
	global_extractcif(general_ciffile,0)
    }
    # If using struct file, load data from it
    else if (general_structfile){
	print "[info|general] Extracting info from .struct file..."
	## Check existence
  	if (!checkexists(general_structfile)){
  	    print "[error|general] .struct file does not exist"
  	    print "[error|general] Check .struct address is correctly set in .wien"
  	    exit 1
 	}
	global_extractstruct(general_structfile,0)
	general_extractstruct(general_structfile,0)
    }
    # All parameters are determined in input, calculate global-derived quantities
    else {
	global_system = getsystem(global_a,global_b,global_c,global_alpha,global_beta,global_gamma)
	global_v = volume(global_a,global_b,global_c,global_alpha,global_beta,global_gamma)
	global_cosalpha = cos(global_alpha*const_pi/180.0)
	global_cosbeta = cos(global_beta*const_pi/180.0)
	global_cosgamma = cos(global_gamma*const_pi/180.0)

	global_metric[1,1] = global_a * global_a
	global_metric[1,2] = global_a * global_b * global_cosgamma
	global_metric[1,3] = global_a * global_c * global_cosbeta
	global_metric[2,2] = global_b * global_b
	global_metric[2,3] = global_b * global_c * global_cosalpha
	global_metric[3,3] = global_c * global_c

	global_metric[2,1] = global_metric[1,2]
	global_metric[3,1] = global_metric[1,3]
	global_metric[3,2] = global_metric[2,3]

	global_ca = global_c/global_a
	global_cb = global_c/global_b
	global_ba = global_b/global_a
	global_gcdmult = global_mult[1]
	for (i=2;i<=global_nneq;i++){
	    global_gcdmult = gcd(global_gcdmult,global_mult[i])
	}
	global_molformula = ""
	global_molmass = 0
	delete global_numberatoms
	for (i=1;i<=global_nneq;i++){
	    global_molatoms[i] = global_mult[i] / global_gcdmult
	    global_molformula = global_molformula global_atom[i] global_molatoms[i]
	    global_molmass += global_molatoms[i]*const_atomicmass[global_atom[i]]
	    global_numberatoms[global_atom[i]] += global_mult[i]
	    if (!isin(tolower(global_atom[i]),global_atomname)){
		global_atomnames++
		global_atomname[global_atomnames] = tolower(global_atom[i])
		global_atomrepr[global_atomnames] = i
	    }
	}
	global_molv = global_v / global_gcdmult
	if (global_lattice == "P" || global_lattice == "S")
	    global_molv = global_molv / 1
	else if (global_lattice == "F")
	    global_molv = global_molv / 4
	else if (global_lattice == "B")
	    global_molv = global_molv / 2
	else if (global_lattice == "CXY")
	    global_molv = global_molv / 2
	else if (global_lattice == "CYZ")
	    global_molv = global_molv / 2
	else if (global_lattice == "CXZ")
	    global_molv = global_molv / 2
	else if (global_lattice == "R")
	    global_molv = global_molv / 1
	else if (global_lattice == "H")
	    global_molv = global_molv / 1
    }
    # Structure related checks
    print "[info|general] Checking input dependent on the structure..."
    ## lda+u
    if (global_ldau){
	# check atom identifiers
	for (i=1;i<=global_ldaus;i++)
	    if (global_ldau_atom[i] < 1 || global_ldau_atom[i] > global_nneq){
		print "[error|general] Incorrect atom specification in LDA+U."
		print "[error|general] in line : " i
		exit 1
	    }
	# check spin polarization
	if (!global_spinpolarized || global_spinpolarized == "no"){
	    print "[error|general] LDA+U requires spin polarization"
	    exit 1
	}
    }
    # Set default variables and apply "*" to npt, rmt, r0, ...
    print "[info|general] Setting default variables if missing..."
    if (!general_title){
	general_title = "runwien.awk lapw calculation, v." global_version
    }
    if (!general_relativistic && !general_structfile){
	general_relativistic = "yes"
    }
    if (!global_spinpolarized){
	global_spinpolarized = "no"
    }
    for (i=1;i<=general_alsos;i++){
	for (j=1;j<=global_nneq;j++){
	    if (general_rmt["*",i])
		general_rmt[j,i] = general_rmt["*",i]
	    if (!general_rmt[j,i] && !general_structfile)
		general_rmt[j,i] = "auto"
	    if (general_r0["*",i])
		general_r0[j,i] = general_r0["*",i]
	    if (!general_r0[j,i] && !general_structfile)
		general_r0[j,i] = 0.0001
	    if (general_npt["*",i])
		general_npt[j,i] = general_npt["*",i]
	    if (!general_npt[j,i] && !general_structfile)
		general_npt[j,i] = 781
	}
	if (!general_rkmax[i])
	    general_rkmax[i] = "auto"
	if (!general_lmax[i])
	    general_lmax[i] = "auto"
	if (!general_lnsmax[i])
	    general_lnsmax[i] = "auto"
	if (!general_gmax[i])
	    general_gmax[i] = "auto"
	if (!general_mix[i])
	    general_mix[i] = "auto"
	if (!general_kpts[i] || general_kpts[i] == "auto")
	    general_kpts[i] = 1000
	if (global_ldau)
	    for (j=1;j<=global_ldaus;j++){
		if(general_u["*",i])
		    general_u[j,i] = general_u["*",i]
		if(general_j["*",i])
		    general_j[j,i] = general_j["*",i]
		if(!general_u[j,i])
		    general_u[j,i] = "auto"
		if(!general_j[j,i])
		    general_j[j,i] = "auto"
	    }
    }
    for (i=1;i<=global_nneq;i++){
	if (!global_isplit[i])
	    global_isplit[i] = 2
    }
    if (global_so){
	if (!global_soh && !global_sok && !global_sol){
	    global_soh = global_sok = 0
	    global_sol = 1
	}
	if (!global_sonewemax)
	    global_sonewemax = 5.0
	if (!global_sonewkpts)
	    global_sonewkpts = "100%"
    }
    # Check if the user wants to create new structures.
    if (general_donew || general_olditerations == 0){
	# For each also...
	for (k=1;k<=general_alsos;k++){
	    ## Parse expressions for varying parameters,
	    ## Check expressions are ok (the regexp means a comma-separated
	    ## list with items of the form a[/a[/a]] where a is a floating
	    ## point or exponential number. In rmt, it also can appear an %
	    ## symbol. In npt, lmax, lnsmax, kpts numbers are restricted to
	    ## positive integers.
	    print "[info|general] Parsing expressions for variable parameters, also #"k"..."
	    for (l=1;l<=global_nneq;l++){
		if (general_rmt[l,k] !~ /([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto))?(,(([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?%?|auto))?))*/){
		    print "[error|general] wrong line in rmt specification"
		    exit 1
		}
		list_parser(general_rmt[l,k])
		temp_idstring = "rmt" l
		for (i=1;i<=global_niter;i++){
		    if (global_flag[i] == "auto"){
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = "auto"
			general_flag[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = "auto"
			continue
		    }
		    for(x=1;x<=global_num[i];x++){
			j = global_ini[i] + (x-1)*global_incr[i]
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = j
			general_flag[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = global_flag[i]
		    }
		}
		if (general_r0[l,k] !~ /([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(,(([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?))*/){
		    print "[error|general] wrong line in r0 specification"
		    exit 1
		}
		list_parser(general_r0[l,k])
		temp_idstring = "r0" l
		for (i=1;i<=global_niter;i++){
		    if (global_flag[i] == "auto"){
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = 0.0001
			continue
		    }
		    for(x=1;x<=global_num[i];x++){
			j = global_ini[i] + (x-1)*global_incr[i]
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = j
		    }
		}
		if (general_npt[l,k] !~ /([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?(,(([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?))*/){
		    print "[error|general] wrong line in npt specification"
		    exit 1
		}
		list_parser(general_npt[l,k])
		temp_idstring = "npt" l
		for (i=1;i<=global_niter;i++){
		    if (global_flag[i] == "auto"){
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = 781
			continue
		    }
		    for(x=1;x<=global_num[i];x++){
			j = global_ini[i] + (x-1)*global_incr[i]
			general_newn[temp_idstring]++
			general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = j
		    }
		}
	    }
	    if(global_ldau)
		for (l=1;l<=global_ldaus;l++){
		    list_parser(general_u[l,k])
		    temp_idstring = "u" l
		    for (i=1;i<=global_niter;i++){
			if (global_flag[i] == "auto"){
			    general_newn[temp_idstring]++
			    general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = global_ldau_defu[l]
			    continue
			}
			for(x=1;x<=global_num[i];x++){
			    j = global_ini[i] + (x-1)*global_incr[i]
			    general_newn[temp_idstring]++
			    general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = j
			    if (general_uev[l,k])
				general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] /= const_rytoev
			}
		    }
		    list_parser(general_j[l,k])
		    temp_idstring = "j" l
		    for (i=1;i<=global_niter;i++){
			if (global_flag[i] == "auto"){
			    general_newn[temp_idstring]++
			    general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = global_ldau_defj[l]
			    continue
			}
			for(x=1;x<=global_num[i];x++){
			    j = global_ini[i] + (x-1)*global_incr[i]
			    general_newn[temp_idstring]++
			    general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] = j
			    if (general_jev[l,k])
				general_val[temp_idstring,general_n[temp_idstring]+general_newn[temp_idstring]] /= const_rytoev
			}
		    }
		}
	    if (general_rkmax[k] !~ /([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(,(([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?))*/){
		print "[error|general] wrong line in rkmax specification"
		exit 1
	    }
	    list_parser(general_rkmax[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){
		    general_newn["rkmax"]++
		    general_val["rkmax",general_n["rkmax"]+general_newn["rkmax"]] = "auto"
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["rkmax"]++
		    general_val["rkmax",general_n["rkmax"]+general_newn["rkmax"]] = j
		}
	    }
	    if (general_lmax[k] !~ /([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?(,(([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?))*/){
		print "[error|general] wrong line in lmax specification"
		exit 1
	    }
	    list_parser(general_lmax[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){
		    general_newn["lmax"]++
		    general_val["lmax",general_n["lmax"]+general_newn["lmax"]] = "auto"
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["lmax"]++
		    general_val["lmax",general_n["lmax"]+general_newn["lmax"]] = j
		}
	    }
	    if (general_lnsmax[k] !~ /([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?(,(([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?))*/){
		print "[error|general] wrong line in lnsmax specification"
		exit 1
	    }
	    list_parser(general_lnsmax[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){
		    general_newn["lnsmax"]++
		    general_val["lnsmax",general_n["lnsmax"]+general_newn["lnsmax"]] = "auto"
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["lnsmax"]++
		    general_val["lnsmax",general_n["lnsmax"]+general_newn["lnsmax"]] = j
		}
	    }
	    if (general_gmax[k] !~ /([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(,(([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?))*/){
		print "[error|general] wrong line in gmax specification"
		exit 1
	    }
	    list_parser(general_gmax[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){
		    general_newn["gmax"]++
		    general_val["gmax",general_n["gmax"]+general_newn["gmax"]] = "auto"
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["gmax"]++
		    general_val["gmax",general_n["gmax"]+general_newn["gmax"]] = j
		}
	    }
	    if (general_mix[k] !~ /([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(,(([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto)(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?(\/([+-]?([0-9]*\.?[0-9]*|\.[0-9]+)([eEdD][+-]?[0-9]+)?|auto))?))*/){
		print "[error|general] wrong line in mix specification"
		exit 1
	    }
	    list_parser(general_mix[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){
		    general_newn["mix"]++
		    general_val["mix",general_n["mix"]+general_newn["mix"]] = "auto"
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["mix"]++
		    general_val["mix",general_n["mix"]+general_newn["mix"]] = j
		}
	    }
	    if (general_kpts[k] !~ /([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?(,(([+]?[0-9]*|auto)(\/([+]?[0-9]*|auto))?(\/([+]?[0-9]*|auto))?))*/){
		print "[error|general] wrong line in kpts specification"
		exit 1
	    }
	    list_parser(general_kpts[k])
	    for (i=1;i<=global_niter;i++){
		if (global_flag[i] == "auto"){ # Set default value
		    general_newn["kpts"]++
		    general_val["kpts",general_n["kpts"]+general_newn["kpts"]] = 1000
		    continue
		}
		for(x=1;x<=global_num[i];x++){
		    j = global_ini[i] + (x-1)*global_incr[i]
		    general_newn["kpts"]++
		    general_val["kpts",general_n["kpts"]+general_newn["kpts"]] = j
		}
	    }
	    ## Ensure linked parameters have same number of possibiliites
	    print "[info|general] Probing linked parameters for also " k "..."
	    for (i in general_linked){
		if (general_linked[i]){
		    if (general_newn[i] != general_newn[general_linked[i]]){
			print "[error|general] " i " does not link with " general_linked[i]
			print "[error|general] Number of cases is not the same. Fix .wien input"
			exit 1
		    }
		}
	    }
	    ### Create iteration counter from all variable options
	    ### Note i-1 = (i_l(i)-1) + (i_(l-1)(i)-1) * k_l + (i_(l-2)(i)-1) * k_l *k_(l-1) + ... + (i_1(i)-1) * k_l*...*k_2
	    ### where i_k is a mapping from general iterations space to k-th space
	    ### and k_i is the cardinal of i-th space. This equation makes the product
	    ### all i_k mappings a 1-to-1 application from I (general_iterations) to
	    ### K_1x...xK_l.
	    print "[info|general] Creating iteration counter for also " k "..."
	    general_newiterations = 1
	    for (i in general_newn)
		general_newiterations = general_newiterations * general_newn[i]
	    for (i in general_linked){
		if (general_linked[i]){
		    general_newiterations = general_newiterations / general_newn[i]
		}
	    }
	    for (i=1;i<=general_newiterations;i++){
		temp_val = i - 1
		for (j=1;j<=global_nneq;j++){
		    temp_idstring = "rmt" j
		    if (!general_linked[temp_idstring]){
			general_index[temp_idstring,general_iterations+i] = general_n[temp_idstring] + (temp_val % general_newn[temp_idstring]) + 1
			temp_val = int(temp_val/general_newn[temp_idstring])
		    }
		}
		for (j=1;j<=global_nneq;j++){
		    temp_idstring = "r0" j
		    if (!general_linked[temp_idstring]){
			general_index[temp_idstring,general_iterations+i] = general_n[temp_idstring] + (temp_val % general_newn[temp_idstring]) + 1
			temp_val = int(temp_val/general_newn[temp_idstring])
		    }
		}
		for (j=1;j<=global_nneq;j++){
		    temp_idstring = "npt" j
		    if (!general_linked[temp_idstring]){
			general_index[temp_idstring,general_iterations+i] = general_n[temp_idstring] + (temp_val % general_newn[temp_idstring]) + 1
			temp_val = int(temp_val/general_newn[temp_idstring])
		    }
		}
		if (!general_linked["rkmax"]){
		    general_index["rkmax",general_iterations+i] = general_n["rkmax"] + (temp_val % general_newn["rkmax"]) + 1
		    temp_val = int(temp_val/general_newn["rkmax"])
		}
		if (!general_linked["lmax"]){
		    general_index["lmax",general_iterations+i] = general_n["lmax"] + (temp_val % general_newn["lmax"]) + 1
		    temp_val = int(temp_val/general_newn["lmax"])
		}
		if (!general_linked["lnsmax"]){
		    general_index["lnsmax",general_iterations+i] = general_n["lnsmax"] + (temp_val % general_newn["lnsmax"]) + 1
		    temp_val = int(temp_val/general_newn["lnsmax"])
		}
		if (!general_linked["gmax"]){
		    general_index["gmax",general_iterations+i] = general_n["gmax"] + (temp_val % general_newn["gmax"]) + 1
		    temp_val = int(temp_val/general_newn["gmax"])
		}
		if (!general_linked["mix"]){
		    general_index["mix",general_iterations+i] = general_n["mix"] + (temp_val % general_newn["mix"]) + 1
		    temp_val = int(temp_val/general_newn["mix"])
		}
		if (!general_linked["kpts"]){
		    general_index["kpts",general_iterations+i] = general_n["kpts"] + (temp_val % general_newn["kpts"]) + 1
		    temp_val = int(temp_val/general_newn["kpts"])
		}
		if (global_ldau){
		    for (j=1;j<=global_ldaus;j++){
			temp_idstring = "u" j
			if (!general_linked[temp_idstring]){
			    general_index[temp_idstring,general_iterations+i] = general_n[temp_idstring] + (temp_val % general_newn[temp_idstring]) + 1
			    temp_val = int(temp_val/general_newn[temp_idstring])
			}
		    }
		    for (j=1;j<=global_ldaus;j++){
			temp_idstring = "j" j
			if (!general_linked[temp_idstring]){
			    general_index[temp_idstring,general_iterations+i] = general_n[temp_idstring] + (temp_val % general_newn[temp_idstring]) + 1
			    temp_val = int(temp_val/general_newn[temp_idstring])
			}
		    }
		}
	    }
	    ## Actualization of general_n and general_iterations
	    general_iterations += general_newiterations
	    general_newiterations = 0
	    for (i in general_newn){
		general_n[i] += general_newn[i]
		general_newn[i] = 0
	    }
	}
	## Link parameters
	print "[info|general] Linking parameters..."
	for (i in general_linked){
	    if (general_linked[i]){
		for (j=general_olditerations+1;j<=general_iterations;j++)
		    general_index[i,j] = general_index[general_linked[i],j]
	    }
	}
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default for general.
    print "[info|general] Determining which structures to run..."
    if (!general_dolines){
	if (!global_dolines){
	    general_dolines = 1
	    general_doline[1] = "new"
	    general_dotype[1] = "do"
	}
	else{
	    general_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		general_doline[i] = global_doline[i]
		general_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to
    ## general_do[:]
    for (i=1;i<=general_dolines;i++){
	list_parser(general_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && general_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    general_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && general_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    general_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && general_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    general_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && general_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    general_do[k] = 1
		}
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (general_dotype[i] ~ /do/){
		    general_do[k] = 1
		}
		else{
		    general_do[k] = ""
		}
	    }
	}
    }
    # Calculate number of padding zeroes
    ## If general_pad alredy exists, it has been loaded. general_pad
    ## may change when adding more structures => directories need
    ## renaming. Recursive rename
    print "[info|general] Calculating padding zeroes..."
    if (!general_pad){
	general_pad = int(0.4343*log(general_iterations))+1
    }
    else{
	general_oldpad = general_pad
	general_pad = int(0.4343*log(general_iterations))+1
	if (general_pad != general_oldpad){
	    print "[info|general] Padding has changed, renaming..."
	    for (i=1;i<=general_olditerations;i++){
		general_filename[i] = global_root sprintf("%0*d",general_pad,i) ".struct"
		mysystem("mv -f " global_root sprintf("%0*d",general_oldpad,i) "/ " global_root sprintf("%0*d",general_pad,i) " > /dev/null 2>&1")
		mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,i) "/"global_root sprintf("%0*d",general_pad,i)"/' " global_root sprintf("%0*d",general_pad,i)"/*")
		mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,i) "/"global_root sprintf("%0*d",general_pad,i)"/' " global_root sprintf("%0*d",general_pad,i)"/*/*")
		mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,i) "/"global_root sprintf("%0*d",general_pad,i)"/' " global_root sprintf("%0*d",general_pad,i)"/*/*/*")
		mysystem(const_renameexe " 's/" global_root sprintf("%0*d",general_oldpad,i) "/"global_root sprintf("%0*d",general_pad,i)"/' " global_root sprintf("%0*d",general_pad,i)"/*/*/*/*")
	    }
	}
    }
    # Check if there are not-loaded old calculations
    for (i=1;i<=general_iterations;i++){
	general_curname = global_root sprintf("%0*d",general_pad,i) ".struct"
	gsub(".struct","",general_curname)
	# check there are no existing directories
	if (checkexists(general_curname) && i > general_olditerations){
	    print "[error|general] directory " general_curname " exists!"
	    print "[error|general] clean root from previous calculations or load."
	    print "[error|general] possibly you may want to load with reread."
	    exit 1
	}
    }
    # Initialize index file if there are no previous structures
    print "[info|general] Initializing index file..."
    general_indexfile = global_root ".index"
    ## Write index file header
    print ".struct index file -- generated by runwien.awk" > general_indexfile
    print "title:", general_title > general_indexfile
    print "root :", global_root > general_indexfile
    print "pwd  :", global_pwd > general_indexfile
    temp_format = "%-5s"
    temp_string = sprintf(temp_format," n ")
    for (i=1;i<=global_nneq;i++){
	temp_format = "%-7s"
	temp_string = temp_string sprintf(temp_format,"npt" i)
    }
    for (i=1;i<=global_nneq;i++){
	temp_format = "%-7s"
	temp_string = temp_string sprintf(temp_format,"rmt" i)
    }
    for (i=1;i<=global_nneq;i++){
	temp_format = "%-10s"
	temp_string = temp_string sprintf(temp_format,"r0" i)
    }
    if (global_ldau){
	for (i=1;i<=global_ldaus;i++){
	    temp_format = "%-7s"
	    temp_string = temp_string sprintf(temp_format,"U" i)
	}
	for (i=1;i<=global_ldaus;i++){
	    temp_format = "%-7s"
	    temp_string = temp_string sprintf(temp_format,"J" i)
	}
    }
    temp_format = "%-7s%-7s%-7s%-7s%-7s%-7s%-4s%-5s\n"
    temp_string = temp_string sprintf(temp_format,"rkmax","lmax","lnsmx","gmax","mix","kpts","do","done")
    print temp_string  > general_indexfile
    # For each structure, create .struct
    for (i=1;i<=general_iterations;i++){
	general_filename[i] = global_root sprintf("%0*d",general_pad,i) ".struct"
	if (general_do[i]){
	    ## Give name to struct file, header
	    print "[info|general] Creating struct file and index line for structure #" i
	    ## Generate struct file
	    printf "%-80s\n",general_title > general_filename[i]
	    printf "%-3s%23s%-3i\n",global_lattice," LATTICE,NONEQUIV.ATOMS: ",global_nneq > general_filename[i]
	    if (general_relativistic == "yes")
		printf "%13s%4s\n","MODE OF CALC=","RELA" > general_filename[i]
	    else
		printf "%13s%4s\n","MODE OF CALC=","NREL" > general_filename[i]
	    printf "%-10.6f%-10.6f%-10.6f%-10.6f%-10.6f%-10.6f\n",global_a,global_b,global_c,global_alpha,global_beta,global_gamma > general_filename[i]
	    for (c=1;c<=global_nneq;c++){
		printf "%4s%4i%4s%10.8f%3s%10.8f%3s%10.8f\n","ATOM",global_label[c],": X=",global_nneq_x[c,1]," Y=",global_nneq_y[c,1]," Z=",global_nneq_z[c,1] > general_filename[i]
		printf "%15s%2i%17s%2i\n","   MULT= ",global_mult[c]," ISPLIT = ", global_isplit[c] > general_filename[i]
		for (d=2;d<=global_mult[c];d++){
		    printf "%4s%4i%4s%10.8f%3s%10.8f%3s%10.8f\n","    ",global_label[c],": X=",global_nneq_x[c,d]," Y=",global_nneq_y[c,d]," Z=",global_nneq_z[c,d] > general_filename[i]
		}
		temp_idstring = "r0" c
		temp_idstring2 = "npt" c
		printf "%-10s%5s%5i%5s%10.8f%5s%10.5f%5s%5.2f\n",global_atomfullnm[c],"NPT=",general_val[temp_idstring2,general_index[temp_idstring2,i]],"R0=",general_val[temp_idstring,general_index[temp_idstring,i]],"RMT=",0,"Z:",const_atomicnumber[global_atom[c]] > general_filename[i]
		printf "%-20s%10.7f%10.7f%10.7f\n","LOCAL ROT MATRIX:",1.0,0.0,0.0 > general_filename[i]
		printf "%20s%10.7f%10.7f%10.7f\n","",0.0,1.0,0.0 > general_filename[i]
		printf "%20s%10.7f%10.7f%10.7f\n","",0.0,0.0,1.0 > general_filename[i]
	    }
	    printf "%4i%s\n",0,"   NUMBER OF SYMMETRY OPERATIONS" > general_filename[i]
	    close(general_filename[i])
	}
    }
    # For each structure, create line in .index
    for (i=1;i<=general_iterations;i++){
	# Build line
	temp_format = "%-4i " # file number
	temp_string = sprintf(temp_format,i)
	for (j=1;j<=global_nneq;j++){ # npts
	    temp_idstring = "npt" j
	    temp_format = "%-6i "
	    temp_string = temp_string sprintf(temp_format,general_val[temp_idstring,general_index[temp_idstring,i]])
	}
	for (j=1;j<=global_nneq;j++){ # rmts
	    temp_idstring = "rmt" j
	    if (general_flag[temp_idstring,general_index[temp_idstring,i]] ~ "normal")
		temp_format = "%-6.3f "
	    else if (general_flag[temp_idstring,general_index[temp_idstring,i]] ~ "auto")
		temp_format = "%-6s "
	    else
		temp_format = "%-5.2f%% "
	    temp_string = temp_string sprintf(temp_format,general_val[temp_idstring,general_index[temp_idstring,i]])
	}
	for (j=1;j<=global_nneq;j++){
	    temp_idstring = "r0" j
	    temp_format = "%-9.7f "
	    temp_string = temp_string sprintf(temp_format,general_val[temp_idstring,general_index[temp_idstring,i]])
	}
	if (global_ldau){
	    for (j=1;j<=global_ldaus;j++){ # Us
		temp_idstring = "u" j
		temp_format = "%-6.3f "
		temp_string = temp_string sprintf(temp_format,general_val[temp_idstring,general_index[temp_idstring,i]])
	    }
	    for (j=1;j<=global_ldaus;j++){ # Js
		temp_idstring = "j" j
		temp_format = "%-6.3f "
		temp_string = temp_string sprintf(temp_format,general_val[temp_idstring,general_index[temp_idstring,i]])
	    }
	}
	if (general_val["rkmax",general_index["rkmax",i]] ~ "auto") # rkmax
	    temp_format = "%-6s "
	else
	    temp_format = "%-6.3f "
	temp_string = temp_string sprintf(temp_format,general_val["rkmax",general_index["rkmax",i]])

	if (general_val["lmax",general_index["lmax",i]] ~ "auto") # lmax
	    temp_format = "%-6s "
	else
	    temp_format = "%-6i "
	temp_string = temp_string sprintf(temp_format,general_val["lmax",general_index["lmax",i]])

	if (general_val["lnsmax",general_index["lnsmax",i]] ~ "auto") # lnsmax
	    temp_format = "%-6s "
	else
	    temp_format = "%-6i "
	temp_string = temp_string sprintf(temp_format,general_val["lnsmax",general_index["lnsmax",i]])

	if (general_val["gmax",general_index["gmax",i]] ~ "auto") # gmax
	    temp_format = "%-6s "
	else
	    temp_format = "%-6.3f "
	temp_string = temp_string sprintf(temp_format,general_val["gmax",general_index["gmax",i]])

	if (general_val["mix",general_index["mix",i]] ~ "auto") # mix factor
	    temp_format = "%-6s "
	else
	    temp_format = "%-6.3f "
	temp_string = temp_string sprintf(temp_format,general_val["mix",general_index["mix",i]])

	if (general_val["kpts",general_index["kpts",i]] ~ "auto") # kpts
	    temp_format = "%-6s "
	else
	    temp_format = "%-6i "
	temp_string = temp_string sprintf(temp_format,general_val["kpts",general_index["kpts",i]])

	temp_format = "%-3s "
	if (general_do[i])
	    temp_string = temp_string sprintf(temp_format,"yes")
	else
	    temp_string = temp_string sprintf(temp_format,"no")

	temp_format = "%-4s "
	if (general_done[i])
	    temp_string = temp_string sprintf(temp_format,"yes")
	else
	    temp_string = temp_string sprintf(temp_format,"no")

	print temp_string >> general_indexfile
    }
    close(general_indexfile)
    ## Write down index file
    if (!isin(general_indexfile,global_file_index)){
	global_file_index_n++
	global_file_index[global_file_index_n] = general_indexfile
    }

    ## Generate directory structure and put struct files
    print "[info|general] Creating directory tree structure and moving .struct..."
    print "[info|general] Marking as done..."
    for (i=1;i<=general_iterations;i++){
	if (general_do[i]){
	    ### Name directory
	    general_curname = general_filename[i]
	    gsub(".struct","",general_curname)
	    ### Create dir and move files
	    mysystem("mkdir " general_curname " > /dev/null 2>&1")
	    mysystem("mv -f " general_filename[i] " " general_curname)
	    ## Mark structure as done
	    general_done[i] = 1
	}
    }
    # Get end time
    general_totaltime = systime() - general_totaltime
    # Generate checkpoint
    print "[info|general] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    general_savecheck(global_root "-check/general.check")
    # End message
    print "[info|general] General section ended succesfully..."
    printf "\n"
    next
}
# (xinitx) Initialization section final tasks
/^( |\t)*end( |\t)*initialization( |\t)*$/ && global_section=="initialization"{
    global_section = ""
    init_run = 1
    print ""
    print "[info|init] Beginning of initialization section at " date()
    # Verify needed sections were run
    print "[info|init] Verifying needed sections were run..."
    if (!general_run){
	print "[error|init] cannot run initialization."
	print "[error|init] general section has not been run or loaded."
	exit 1
    }
    print "[info|init] Checking for executables..."
    delete temp_array
    temp_array[const_instgenlapwexe] = temp_array[const_setrmtlapwexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|init] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    init_totaltime = systime()
    # Set default variables
    print "[info|init] Setting default variables if missing..."
    if (!init_potential){
	init_potential="ggapbe96"
    }
    if (!init_ecoreval){
	init_ecoreval=-6.0
    }
    if (!init_energymin){
	init_energymin = "auto"
    }
    if (!init_energymax){
	init_energymax = "auto"
    }
    if (!init_nnfactor){
	init_nnfactor = 2
    }
    if (!init_fermi){
	init_fermi = "tetra"
    }
    if (!init_fermival){
	init_fermival = 0.0
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|init] Determining which structures to run..."
    if (!init_dolines){
	if (!global_dolines){
	    init_dolines = 1
	    init_doline[1] = "new"
	    init_dotype[1] = "do"
	}
	else{
	    init_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		init_doline[i] = global_doline[i]
		init_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=init_dolines;i++){
	list_parser(init_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && init_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    init_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && init_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    init_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && init_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    init_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && init_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    init_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (init_dotype[i] ~ /do/){
		    init_do[k] = 1
		}
		else{
		    init_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|init] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i])
	    if (init_do[i]){
		print "[warn|init] structure " i " cannot be run..."
		init_do[i] = ""
	    }
    }
    # Make initialization for each structure
    for (i=1;i<=general_iterations;i++){
	if (init_do[i]){
	    # Time count
	    init_time[i] = systime()
	    # Load structure + heading
	    # Prepare tempfiles with structure names and paths
	    print "[info|init] --------------------------------------------------------------------"
	    print "[info|init] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    # Set rmt, check rmt is < rmtmax given by setrmt_lapw
	    print "[info|init] Calculating muffin tin radius..."
	    temp_file = global_pwd "/" temp_root temp_name ".outputsetrmt"
	    mysystem(temp_prepath const_setrmtlapwexe " " temp_name " > " temp_file " 2>&1")
	    ## run until the place where proposed rmt are
	    for(getline temp_string < temp_file;temp_string !~ "atom  Z   RMT-max   RMT";getline temp_string < temp_file)
		;
	    ## get wien's rmt
	    for (;getline temp_string < temp_file;){
		split(temp_string,temp_array)
		init_nneq_rmtset[temp_array[1]+0] = temp_array[4]
	    }
	    close(temp_file)

	    for (j=1;j<=global_nneq;j++){
		temp_idstring = "rmt" j
		# rmt is given as is, with % or accept auto
		if (general_flag[temp_idstring,general_index[temp_idstring,i]] == "normal")
		    init_nneq_rmtset[j] = general_val[temp_idstring,general_index[temp_idstring,i]]
		else if (general_flag[temp_idstring,general_index[temp_idstring,i]] ~ "%")
		    init_nneq_rmtset[j] = init_nneq_rmtset[j]*(100+general_val[temp_idstring,general_index[temp_idstring,i]])/100
		# else -> use wien's value (auto)
		# write to the struct file
		mysystem(temp_prepath const_lapwchangermtexe " " temp_name ".struct " j " " init_nneq_rmtset[j])
	    }
	    temp_file = global_pwd "/" temp_root "tempfile"
	    # Print rmt's to stdout and reassign to general_index
	    print "[info|init] Rmt values are set to: (Symbol | representative coords | rmt)"
	    general_spacefill[i] = 0
	    for (j=1;j<=global_nneq;j++){
		print "[info|init]",global_atomfullnm[j],global_nneq_x[j,1],global_nneq_y[j,1],global_nneq_z[j,1],init_nneq_rmtset[j]
		temp_idstring = "rmt" j
		general_val[temp_idstring,general_index[temp_idstring,i]] = init_nneq_rmtset[j]
		general_flag[temp_idstring,general_index[temp_idstring,i]] = "normal"
		general_spacefill[i] += 4.0/3.0*const_pi*(general_val[temp_idstring,general_index[temp_idstring,i]])^3*global_mult[j]
	    }
	    general_spacefill[i] /= global_v

	    # Check mt collision
	    temp_file = global_pwd "/" temp_root "tempfile"
	    mysystem(temp_prepath const_setrmtlapwexe " " temp_name " > " temp_file " 2>&1")
	    ## run until the place where proposed rmt are
	    for(getline temp_string < temp_file;temp_string !~ "atom  Z   RMT-max   RMT";getline temp_string < temp_file){
		## if 2rmt>dnn delete structure
		if (temp_string ~ /SUMS/ && temp_string ~ / GT /){
		    init_done[i] = ""
		    init_time[i] = 0
		    print "[warn|init] Structure #" i" has been deleted:"
		    print "[warn|init] rmt sum is greater than nn distance"
		    break
		}
	    }
	    close(temp_file)
	    mysystem("rm -f " temp_file)
	    if (temp_string ~ /SUMS/ && temp_string ~ / GT /)
		continue

	    # Run nn
	    print "[info|init] Running nn program..."
	    mysystem(temp_prepath "echo "init_nnfactor" | " const_xlapwexe " nn > /dev/null 2>&1")
	    mysystem(temp_prepath const_extractnn" " temp_name ".outputnn")

	    # Run sgroup
	    print "[info|init] Running sgroup..."
	    mysystem(temp_prepath const_xlapwexe " sgroup > errfile 2>&1")
	    if (checkerror(temp_root "errfile","checkword","duplicated atoms")){
		mysystem(temp_prepath "mv -f errfile " temp_name ".sgroup.err")
		init_done[i] = ""
		print "[warn|init] Structure #" i" has been deleted:"
		print "[warn|init] Error : sgroup found duplicated atoms in input"
		print "[warn|init] Check the precision of the atom coordinates in .cif,"
		print "[warn|init] .struct or .wien: low precision may get atoms out "
		print "[warn|init] of special positions."
		init_time[i] = 0
		continue
	    }
	    if (checkerror(temp_root "errfile","checkword","error:")){
		mysystem(temp_prepath "mv -f errfile " temp_name ".sgroup.err")
		init_done[i] = ""
		print "[warn|init] Structure #" i" has been deleted:"
		print "[warn|init] Error : sgroup found an error in .struct"
		print "[warn|init] Check cell parameters are correctly set."
		init_time[i] = 0
		continue
	    }
	    mysystem(temp_prepath "mv -f errfile " temp_name ".sgroup.err")
	    mysystem(temp_prepath const_extractsgroup" " temp_name ".outputsgroup")
	    # Copy new .struct from sgroup
	    if (init_dosgroup){
		print "[info|init] Copying new .struct file from sgroup..."
		mysystem(temp_prepath "mv -f " temp_name ".struct_sgroup " temp_name ".struct")
		# Recover information for global
		print "[info|init] Re-reading global information from struct file..."
		global_extractstruct(temp_root temp_name ".struct",1)
	    }
	    # Get spg information from sgroup
	    temp_string = const_lapwgetspgexe " " temp_root temp_name ".outputsgroup"
	    temp_string | getline global_spg
	    close(temp_string)
	    # Get local symmetries from sgroup
	    temp_string = "grep -A 1 'Sort number' " temp_root temp_name ".outputsgroup | grep 'point group' | cut -f 2 -d':' | awk '{print $1}'"
	    for (j=1;j<=global_nneq;j++)
		temp_string | getline global_lsym[j]
	    close(temp_string)
	    # Run symmetry and copy new .struct
	    print "[info|init] Running symmetry and creating new .struct..."
	    mysystem(temp_prepath const_xlapwexe " symmetry > errfile 2>&1")
	    ## No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".symmetry.err")
	    mysystem(temp_prepath "cp -f " temp_name ".struct_st " temp_name ".struct")
	    mysystem(temp_prepath const_extracts " " temp_name ".outputs")
	    # Recover information for global
	    print "[info|init] Re-reading global information from struct file..."
	    global_extractstruct(temp_root temp_name ".struct",1)
	    # Create .inst file with instgen_lapw
	    print "[info|init] Creating .inst file..."
	    mysystem(temp_prepath "rm -f " temp_name ".inst") ## .inst must not exist
	    mysystem(temp_prepath const_instgenlapwexe " > /dev/null 2>&1")
	    if (checkerror(temp_root temp_name ".inst","checkword","WARNING")){
		init_done[i] = ""
		print "[warn|init] Structure #" i" has been deleted:"
		print "[warn|init] Error in instgen_lapw"
		print "[warn|init] This is probably due to a bad atom symbol."
		init_time[i] = 0
		continue
	    }
	    # Run lstart
	    print "[info|init] Running lstart..."
	    temp_string = temp_root "lstart-script"
	    print const_xlapwexe " lstart << --eof--" > temp_string
	    if (init_potential == "lsda")
		print "5" > temp_string
	    else if (init_potential == "ggawc06")
		print "11" > temp_string
	    else if (init_potential == "ggapbe96")
		print "13" > temp_string
	    else if (init_potential == "ggapw91")
		print "14" > temp_string
	    else if (init_potential == "ggapbesol")
		print "19" > temp_string
	    print init_ecoreval > temp_string
	    print "--eof--" > temp_string
	    close(temp_string)
	    mysystem(temp_prepath "chmod u+x lstart-script")
	    mysystem(temp_prepath "./lstart-script > errfile 2>&1")
	    if (checkerror(temp_root "errfile","checkword","error")){
		print "[error|init] lstart has failed with an unknown error."
		print "[error|init] this could possibly indicate a problem with .struct"
		print "[error|init] generated with sgroup."
		mysystem(temp_prepath "mv -f errfile " temp_name ".lstart.err")
		exit 1
	    }
	    if (checkerror(temp_root "errfile","checkword","WARNING")){
		if (checkerror(temp_root "errfile","checkword","CORE electrons leak out")){
		    print "[warn|init] Core electrons leak out of the muffin tin sphere."
		    print "[warn|init] This can lead to problems in the calculation (error in dstart)."
		}
	    }
	    mysystem(temp_prepath "mv -f errfile " temp_name ".lstart.err")
	    mysystem(temp_prepath "rm -f lstart-script")
	    mysystem(temp_prepath const_extractst" " temp_name ".outputst " init_ecoreval)
	    # Set the IFFT parameter
	    if (init_ifft > 0)
		mysystem(temp_prepath const_lapwsetifftexe " " temp_name ".in0_st " init_ifft)	    # Edit first input file, .in1_st
	    print "[info|init] Editing input file .in1_st..."
	    mysystem(temp_prepath const_lapwmodifyin1exe " " temp_name ".in1_st " global_nneq " " general_val["rkmax",general_index["rkmax",i]] " " init_energymin " " init_energymax " " general_val["lmax",general_index["lmax",i]] " " general_val["lnsmax",general_index["lnsmax",i]])
	    ## No error checks for now --
	    # Edit second input file, .in2_st
	    print "[info|init] Creating and editing input file .in2_st..."
	    mysystem(temp_prepath "cat " temp_name ".in2_ls " temp_name ".in2_sy > " temp_name ".in2_st")
	    mysystem(temp_prepath const_lapwmodifyin2exe " " temp_name ".in2_st " general_val["gmax",general_index["gmax",i]] " auto")
	    ## No error checks for now --
	    # Edit third input file, .inm_st
	    print "[info|init] Editing input file .inm_st..."
	    mysystem(temp_prepath const_lapwmodifyinmexe " " temp_name ".inm_st " general_val["mix",general_index["mix",i]])
	    ## No error checks for now --
	    # Renaming input files
	    print "[info|init] Renaming input files..."
	    mysystem(temp_prepath "mv -f " temp_name ".in0_st " temp_name ".in0 ")
	    mysystem(temp_prepath "mv -f " temp_name ".in1_st " temp_name ".in1 ")
	    mysystem(temp_prepath "mv -f " temp_name ".in2_st " temp_name ".in2 ")
	    mysystem(temp_prepath "mv -f " temp_name ".inc_st " temp_name ".inc ")
	    mysystem(temp_prepath "mv -f " temp_name ".inm_st " temp_name ".inm ")
	    if (checkexists(temp_root temp_name ".in1c_st")){
		mysystem(temp_prepath "mv -f " temp_name ".in1c_st " temp_name ".in1c ")
	    }
	    if (checkexists(temp_root temp_name ".in2c_st")){
		mysystem(temp_prepath "mv -f " temp_name ".in2c_st " temp_name ".in2c ")
	    }
	    # Modifying orbitals in .in1
	    print "[info|init] Modifying orbitals in .in1 file..."
	    for (j=1;j<=global_nneq;j++){
		if (init_orbitals[j]){
		    print "[info|init] Modifying orbitals for atom " j " with:"
		    temp_string = j " " init_orbitals[j] " " init_orbital_globe[j] " " init_orbital_globapw[j]
		    for (k=1;k<=init_orbitals[j];k++){
			temp_string = temp_string " " init_orbital_l[j,k] " " init_orbital_energy[j,k] " " init_orbital_var[j,k] " "\
			    init_orbital_cont[j,k] " " init_orbital_apw[j,k]
		    }
		    print "[info|init] " temp_string
		    mysystem(temp_prepath const_lapwmodifyin1orbexe " " temp_name ".in1 " temp_string)
		}
	    }
	    # Modifying lm list in .in2
	    print "[info|init] Modifying lm list in .in2 file..."
	    for (j=1;j<=global_nneq;j++){
		if (init_lms[j]){
		    if (init_lms[j] ~ /lmax/){
			init_lms[j] += 0
			temp_string = const_lmlist[global_lsym[j]]
			temp_val = split(temp_string,temp_array," ")
			
			temp_string = ""
			for(k=1;abs(temp_array[k])+0<=init_lms[j] && k <= temp_val;k+=2)
			    temp_string = temp_string " " temp_array[k] " " temp_array[k+1]
			temp_string = j " " int((k-1)/2) " " temp_string
		    } 
		    else{
			temp_string = j " " init_lms[j]
			for (k=1;k<=init_lms[j];k++){
			    temp_string = temp_string " " init_lm_l[j,k] " " init_lm_m[j,k]
			}
		    }
		    mysystem(temp_prepath const_lapwmodifyin2lmexe " " temp_name ".in2 " temp_string)
		}
	    }
	    # Modifying fermi method in .in2
	    mysystem(temp_prepath const_lapwmodifyin2fermiexe " " temp_name ".in2 " init_fermi " " init_fermival)
	    # Recover information for general section
	    print "[info|init] Re-reading general information..."
	    temp_string = const_lapwgetnptexe " " temp_root temp_name ".struct"
	    for (j=1;j<=global_nneq;j++){
		temp_idstring = "npt" j
		temp_string | getline general_val[temp_idstring,general_index[temp_idstring,i]]
	    }
	    close(temp_string)
	    general_spacefill[i] = 0
	    temp_string = const_lapwgetrmtexe " " temp_root temp_name ".struct"
	    for (j=1;j<=global_nneq;j++){
		temp_idstring = "rmt" j
		temp_string | getline general_val[temp_idstring,general_index[temp_idstring,i]]
		general_flag[temp_idstring,general_index[temp_idstring,i]] = "normal"
		general_spacefill[i] += 4.0/3.0*const_pi*(general_val[temp_idstring,general_index[temp_idstring,i]])^3*global_mult[j]
	    }
	    general_spacefill[i] /= global_v
	    close(temp_string)
	    temp_string = const_lapwgetr0exe " " temp_root temp_name ".struct"
	    for (j=1;j<=global_nneq;j++){
		temp_idstring = "r0" j
		temp_string | getline general_val[temp_idstring,general_index[temp_idstring,i]]
	    }
	    close(temp_string)
	    temp_string = const_lapwgetrkmaxexe " " temp_root temp_name ".in1"
	    temp_string | getline general_val["rkmax",general_index["rkmax",i]]
	    close(temp_string)
	    temp_string = const_lapwgetlmaxexe " " temp_root temp_name ".in1"
	    temp_string | getline general_val["lmax",general_index["lmax",i]]
	    close(temp_string)
	    temp_string = const_lapwgetlnsmaxexe " " temp_root temp_name ".in1"
	    temp_string | getline general_val["lnsmax",general_index["lnsmax",i]]
	    close(temp_string)
	    temp_string = const_lapwgetgmaxexe " " temp_root temp_name ".in2"
	    temp_string | getline general_val["gmax",general_index["gmax",i]]
	    close(temp_string)
	    temp_string = const_lapwgetmixexe " " temp_root temp_name ".inm"
	    temp_string | getline general_val["mix",general_index["mix",i]]
	    close(temp_string)
	    # Recover information for init section
	    print "[info|init] Re-reading initialization information..."
	    temp_string = const_lapwgeteminin1exe " " temp_root temp_name ".in1"
	    temp_string | getline init_energymin
	    close(temp_string)
	    temp_string = const_lapwgetemaxin1exe " " temp_root temp_name ".in1"
	    temp_string | getline init_energymax
	    close(temp_string)
	    temp_string = const_lapwgetorbsin1exe " " temp_root temp_name ".in1 > " temp_file
	    mysystem(temp_string)
	    close(temp_string)
	    getline temp_val < temp_file
	    for (j=1;j<=temp_val;j++){
		getline init_orbital_globe[j] < temp_file
		getline init_orbital_globapw[j] < temp_file
		getline init_orbitals[j] < temp_file
		for (k=1;k<=init_orbitals[j];k++){
		    getline init_orbital_l[j,k]  < temp_file
		    getline init_orbital_energy[j,k] < temp_file
		    getline init_orbital_var[j,k]  < temp_file
		    getline init_orbital_cont[j,k] < temp_file
		    getline init_orbital_apw[j,k]  < temp_file
		}
	    }
	    close(temp_file)
	    mysystem("rm -f " temp_file)
	    temp_string = const_lapwgeteminin2exe " " temp_root temp_name ".in2"
	    temp_string | getline init_eminin2
	    close(temp_string)
	    temp_string = const_lapwgetlmsin2exe " " temp_root temp_name ".in2 " global_nneq " > " temp_file
	    mysystem(temp_string)
	    close(temp_string)
	    for (j=1;j<=global_nneq;j++){
		getline init_lms[j] < temp_file
		for (k=1;k<=init_lms[j];k++){
		    getline init_lm_l[j,k] < temp_file
		    getline init_lm_m[j,k] < temp_file
		}
	    }
	    close(temp_file)
	    mysystem("rm -f " temp_file)
	    print "[info|init] Reading and calculating initialization result variables..."
	    init_frtotalenergy = 0
	    for(j=1;j<=global_nneq;j++){
		temp_string = const_lapwgetefreeatomexe " " temp_root temp_name ".outputst " global_atom[j]
		temp_string | getline init_fratenergy[global_atom[j]]
		close(temp_string)
		init_frtotalenergy += global_molatoms[j] * init_fratenergy[global_atom[j]]
	    }
	    delete init_noe
	    delete init_noecore
	    delete init_noeval
	    init_totalecore = 0
	    init_totaleval = 0
	    for(j=1;j<=global_nneq;j++){
		mysystem(const_lapwgetnoeexe " " temp_root temp_name ".outputst " init_ecoreval " " global_atom[j] " > " temp_file " 2>&1")
		getline init_noecore[global_atom[j]] < temp_file
		getline init_noeval[global_atom[j]] < temp_file
		init_noe[global_atom[j]] = init_noecore[global_atom[j]] + init_noeval[global_atom[j]]
		init_totalecore += init_noecore[global_atom[j]] * global_mult[j]
		init_totaleval += init_noeval[global_atom[j]] * global_mult[j]
		close(temp_file)
		mysystem("rm -f " temp_file)
	    }
	    init_totale = init_totalecore + init_totaleval
	    delete init_corevalstring
	    for(j=1;j<=global_nneq;j++){
		temp_string = const_lapwgetcorevalexe " " temp_root temp_name ".outputst " init_ecoreval " " global_atom[j]
		temp_string | getline init_corevalstring[global_atom[j]]
		close(temp_string)
	    }
	    for(j=1;j<=global_nneq;j++){
		temp_string = const_lapwgetleakingexe " " temp_root temp_name ".outputst " j
		temp_string | getline init_coreleak[i,j]
		close(temp_string)
	    }
	    # Delete .in1 and .in2 if complex calculation
	    if (global_complex){
		mysystem(temp_prepath "mv -f " temp_name ".in1 " temp_name ".in1c ")
		mysystem(temp_prepath "mv -f " temp_name ".in2 " temp_name ".in2c ")
	    }
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|init] Marking as done..."
	    init_done[i] = 1
	    # Time count
	    init_time[i] = systime() - init_time[i]
	    # Generate checkpoint
	    print "[info|init] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    general_savecheck(global_root "-check/general.check")
	    init_savecheck(global_root "-check/init.check")
    	}
    }
    # Get end time
    init_totaltime = systime() - init_totaltime
    # Generate checkpoint
    print "[info|init] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    general_savecheck(global_root "-check/general.check")
    init_savecheck(global_root "-check/init.check")
    # End message
    print "[info|init] Initialization section ended successfully..."
    printf "\n"
    next
}
# (xprescfx) Prescf section final tasks
/^( |\t)*end( |\t)*prescf( |\t)*$/ && global_section=="prescf"{
    global_section = ""
    prescf_run = 1
    print ""
    print "[info|prescf] Beginning of prescf section at " date()
    # Verify needed sections were run
    print "[info|prescf] Verifying needed sections were run..."
    if (!general_run || !init_run){
	print "[error|prescf] cannot run prescf."
	print "[error|prescf] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    prescf_totaltime = systime()
    # Set default variables
    print "[info|prescf] Setting default variables if missing..."
    if (!prescf_kgenoutput){
	prescf_kgenoutput = "short"
    }
    if (!prescf_kgenshift){
	prescf_kgenshift = "yes"
    }
    if (!prescf_nice){
	prescf_nice = 0
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|prescf] Determining which structures to run..."
    if (!prescf_dolines){
	if (!global_dolines){
	    prescf_dolines = 1
	    prescf_doline[1] = "new"
	    prescf_dotype[1] = "do"
	}
	else{
	    prescf_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		prescf_doline[i] = global_doline[i]
		prescf_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=prescf_dolines;i++){
	list_parser(prescf_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && prescf_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    prescf_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && prescf_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    prescf_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && prescf_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    prescf_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && prescf_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    prescf_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (prescf_dotype[i] ~ /do/){
		    prescf_do[k] = 1
		}
		else{
		    prescf_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|prescf] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i])
	    if (prescf_do[i]){
		print "[warn|prescf] structure " i " cannot be run..."
		prescf_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (prescf_do[i]){
	    # Time count
	    prescf_time[i] = systime()
	    # Load structure + heading
	    print "[info|prescf] --------------------------------------------------------------------"
	    print "[info|prescf] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    ## Run kgen
	    print "[info|prescf] Running kgen..."
	    temp_string = temp_root "kgen-script"
	    ### Newer versions of wien2k do not ask for inversion unless -so
	    prescf_askinversion = prescf_askoutput = prescf_askshift = ""
	    if (const_wien2k_version < 20080421){
		print const_xlapwexe " kgen << --eof--" > temp_string
		printf "1\n1\n1\n1\n--eof--" >> temp_string
		close(temp_string)
		mysystem(temp_prepath "chmod u+x kgen-script")
		mysystem(temp_prepath "./kgen-script > errfile 2>&1")
		if (checkerror(temp_root "errfile","checkword","add inversion"))
		    prescf_askinversion = 1
		if (checkerror(temp_root "errfile","checkword","Shift of k-mesh allowed"))
		    prescf_askshift = 1
		mysystem(temp_prepath "rm -f errfile")
		mysystem(temp_prepath "rm -f kgen-script")
		prescf_askoutput = 1
	    }
	    else{
		print const_xlapwexe " kgen << --eof--" > temp_string
		printf "1\n1\n--eof--" >> temp_string
		close(temp_string)
		mysystem(temp_prepath "chmod u+x kgen-script")
		mysystem(temp_prepath "./kgen-script > errfile 2>&1")
		if (checkerror(temp_root "errfile","checkword","Shift of k-mesh allowed"))
		    prescf_askshift = 1
		mysystem(temp_prepath "rm -f errfile")
		mysystem(temp_prepath "rm -f kgen-script")
	    }
	    print const_xlapwexe " kgen << --eof--" > temp_string
	    if (prescf_askinversion)
		print "1" > temp_string
	    print general_val["kpts",general_index["kpts",i]] > temp_string
	    if (prescf_askoutput)
		if (prescf_kgenoutput == "long")
		    print "1" > temp_string
		else
		    print "0" > temp_string
	    if (prescf_askshift)
		if (prescf_kgenshift == "no")
		    print "0" > temp_string
		else
		    print "1" > temp_string
	    print "--eof--" > temp_string
	    close(temp_string)
	    mysystem(temp_prepath "chmod u+x kgen-script")
	    mysystem(temp_prepath "./kgen-script > errfile 2>&1")
	    ### No error checks for now
	    mysystem(temp_prepath "mv -f errfile " temp_name ".kgen.err")
	    mysystem(temp_prepath "rm -f kgen-script")
	    ## Run dstart
	    print "[info|prescf] Running dstart..."
	    if (global_spinpolarized != "yes")
		mysystem(temp_prepath "nice -n " prescf_nice " " const_xlapwexe " dstart " global_complex " > errfile 2>&1")
	    else{
		mysystem(temp_prepath "nice -n " prescf_nice " " const_xlapwexe " dstart " global_complex " > errfile 2>&1")
		mysystem(temp_prepath "nice -n " prescf_nice " " const_xlapwexe " dstart " global_complex " -up > errfile 2>&1")
		mysystem(temp_prepath "nice -n " prescf_nice " " const_xlapwexe " dstart " global_complex " -dn > errfile 2>&1")
	    }
	    ### Check gmin < gmax
	    temp_val = const_lapwcheckgminmaxexe " " temp_root temp_name ".outputd"
	    temp_val | getline temp_string
	    close(temp_val)
	    split(temp_string,temp_array," ")
	    if (temp_array[1]>=temp_array[2]){
		mysystem(temp_prepath "mv -f errfile " temp_name ".dstart.err")
		prescf_done[i] = ""
		print "[error|prescf] Structure #" i" has been deleted:"
		print "[error|prescf] dstart generated a gmin >= gmax"
		print "[error|prescf] Try with a larger gmax."
		print "[error|prescf] Perhaps rmt is too small."
		print "[error|prescf] Make sure you have run initialization first."
		prescf_time[i] = 0
		continue
	    }
	    if (checkerror(temp_root "errfile","checkword","error")){
		mysystem(temp_prepath "mv -f errfile " temp_name ".dstart.err")
		prescf_done[i] = ""
		print "[error|prescf] dstart has failed with an unknown error."
		print "[error|prescf] this could possibly indicate a problem with .struct"
		print "[error|prescf] generated with sgroup."
		prescf_time[i] = 0
		continue
	    }
	    mysystem(temp_prepath "mv -f errfile " temp_name ".dstart.err")
	    mysystem(temp_prepath const_extractd " " temp_name ".outputd")
	    # Save a copy of crystalline atomic density for future use
	    print "[info|prescf] Saving atomic densities..."
	    if (global_spinpolarized == "no")
		mysystem(temp_prepath "cp -f " temp_name ".clmsum " temp_name ".clmsum.atomic")
	    else{
		mysystem(temp_prepath "cp -f " temp_name ".clmsum " temp_name ".clmsum.atomic")
		mysystem(temp_prepath "cp -f " temp_name ".clmup " temp_name ".clmup.atomic")
		mysystem(temp_prepath "cp -f " temp_name ".clmdn " temp_name ".clmdn.atomic")
	    }
	    # Create .inorb and .indm if using LDA+U
	    if (global_ldau){
		# Write .inorb
		print "[info|prescf] Writing .inorb and .indm files..."
		temp_filename = global_pwd "/" temp_root temp_name ".inorb"
		# Count atoms and orbitals to fit orb and lapwdm input
		#    -> temp_val is the number of atoms for wich +U is set
		delete temp_array
		delete temp_item
		temp_items = ""
		temp_val = ""
		for (j=1;j<=global_ldaus;j++)
		    if (!(global_ldau_atom[j] in temp_array)){
			temp_array[global_ldau_atom[j]] = 1
			temp_val++
		    }
		printf "1 %i 0\n",temp_val > temp_filename
		print "PRATT,1.0" > temp_filename
		for (j in temp_array){
		    temp_val2 = ""
		    temp_string = ""
		    for (k=1;k<=global_ldaus;k++)
			if (global_ldau_atom[k] == j){
			    temp_val2++
			    temp_string = sprintf("%s %i",temp_string,global_ldau_l[k])
			    temp_items++
			    temp_item[temp_items] = k
			}
		    printf "%i %i %s\n",j,temp_val2,temp_string > temp_filename
		}
		if (global_ldautype == "amf")
		    print "0" > temp_filename
		else if (global_ldautype == "hmf")
		    print "2" > temp_filename
		else # sic 
		    print "1" > temp_filename
		for (j=1;j<=temp_items;j++){
		    temp_string = "u" temp_item[j]
		    printf "%f\n",general_val[temp_string,general_index[temp_string,i]] > temp_filename
		    temp_string = "j" temp_item[j]
		    printf "%f\n",general_val[temp_string,general_index[temp_string,i]] > temp_filename
		}
		close(temp_filename)
		# Write .indm
		temp_filename = global_pwd "/" temp_root temp_name ".indm"
		print "-9.0" > temp_filename
		print temp_val > temp_filename
		for (j in temp_array){
		    temp_val2 = ""
		    temp_string = ""
		    for (k=1;k<=global_ldaus;k++)
			if (global_ldau_atom[k] == j){
			    temp_val2++
			    temp_string = sprintf("%s %i",temp_string,global_ldau_l[k])
			}
		    printf "%i %i %s\n",j,temp_val2,temp_string > temp_filename
		}
		print "0 0" > temp_filename
		close(temp_filename)
		for (j=1;j<=temp_items;j++){
		    temp_string = "u" temp_item[j]
		    temp_string2 = "j" temp_item[j]
		    if (general_val[temp_string,general_index[temp_string,i]]+0 == 0 && \
			general_val[temp_string2,general_index[temp_string2,i]]+0 == 0){
			prescf_ldau_not[i] = 1
			print "[warn|prescf] Deactivating LDA+U for iteration " i " because of U = J = 0."
		    }
		}
	    }
	    # Recovering results from prescf files
	    print "[info|prescf] Recovering results from prescf files..."
	    temp_val = const_lapwgetibzkptsexe " " temp_root temp_name ".outputkgen"
	    temp_val | getline prescf_ibzkpts[i]
	    close(temp_val)
	    temp_val = const_lapwgetgminexe " " temp_root temp_name ".outputd"
	    temp_val | getline prescf_gmin[i]
	    close(temp_val)
	    temp_val = const_lapwgetpwsexe " " temp_root temp_name ".outputd"
	    temp_val | getline prescf_pws[i]
	    close(temp_val)
	    # Cleaning directory
	    clean(i)
	    # Marking as done
	    print "[info|prescf] Marking as done..."
	    prescf_done[i] = 1
	    # Time count
	    prescf_time[i] = systime() - prescf_time[i]
	    # Generate checkpoint
	    print "[info|prescf] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    prescf_savecheck(global_root "-check/prescf.check")
	}
    }
    # Get end time
    prescf_totaltime = systime() - prescf_totaltime
    # Generate checkpoint
    print "[info|prescf] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    prescf_savecheck(global_root "-check/prescf.check")
    # End message
    print "[info|prescf] Prescf section ended successfully..."
    printf "\n"
    next
}
# (xscfx) Scf section final tasks
/^( |\t)*end( |\t)*scf( |\t)*$/ && global_section=="scf"{
    global_section = ""
    scf_run = 1
    print ""
    print "[info|scf] Beginning of scf section at " date()
    # Verify needed sections were run
    print "[info|scf] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run){
	print "[error|scf] cannot run scf."
	print "[error|scf] needed section has not been run or loaded."
	exit 1
    }
    print "[info|scf] Checking for executables..."
    delete temp_array
    temp_array[const_minlapwexe] = temp_array[const_runlapwexe] = \
    temp_array[const_runsplapwexe] = temp_array[const_struct2tessexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|scf] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    scf_totaltime = systime()
    # Set default variables. Build the command string 
    print "[info|scf] Setting default variables if missing..."
    if (!scf_miter){
	scf_commandstring = " -i 30"
	scf_miter = 30
    }
    else
        scf_commandstring = " -i " scf_miter
    if (!scf_cc && !scf_ec && !scf_fc){
	scf_commandstring = scf_commandstring " -ec 0.00001"
	scf_ec = 0.00001
    }
    else{
	if(scf_cc)
	    scf_commandstring = scf_commandstring " -cc " sprintf("%f",scf_cc)
	if(scf_ec)
	    scf_commandstring = scf_commandstring " -ec " sprintf("%f",scf_ec)
	if(scf_fc)
	    scf_commandstring = scf_commandstring " -fc " sprintf("%f",scf_fc)
    }
    if (scf_itdiag)
	if (const_wien2k_version < 20070813)
	    scf_commandstring = scf_commandstring " -it " scf_itdiag " "
	else
	    scf_commandstring = scf_commandstring " -it "
    if (scf_in1new)
	scf_commandstring = scf_commandstring " -in1new " scf_in1new " "
    if (!scf_nice)
	scf_nice = 0
    # no initialization (-NI)
    if (scf_noinit){
      scf_initialcommandstring = scf_commandstring " -NI "
    }
    else{
      scf_initialcommandstring = scf_commandstring 
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|scf] Determining which structures to run..."
    if (!scf_dolines){
	if (!global_dolines){
	    scf_dolines = 1
	    scf_doline[1] = "new"
	    scf_dotype[1] = "do"
	}
	else{
	    scf_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		scf_doline[i] = global_doline[i]
		scf_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=scf_dolines;i++){
	list_parser(scf_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && scf_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    scf_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && scf_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    scf_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && scf_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    scf_do[k] = 1
		}
	    }
	    if (global_flag[j] ~ /old/ && scf_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    scf_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (scf_dotype[i] ~ /do/){
		    scf_do[k] = 1
		}
		else{
		    scf_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|scf] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i])
	    if (scf_do[i]){
		print "[warn|scf] structure " i " cannot be run..."
		scf_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (scf_do[i]){
	    # Time count
	    scf_time[i] = systime()
	    # Load structure + heading
	    print "[info|scf] --------------------------------------------------------------------"
	    print "[info|scf] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    # Initialize command string
	    scf_commandstring = scf_initialcommandstring
	    # Extrapolation / interpolation / renormalization
	    if (scf_reusemode){
		# Parse the mode and value
		print "[info|scf] Reusing old density files..."
		scf_reusepath = scf_reuseroot = ""
		# first is equivalent to fixed 1
		if (scf_reusemode == "first"){
		    scf_reusemode = "fixed"
		    scf_reuseval = 1
		}
		if (scf_reusemode == "chain"){
		    scf_reuseval = i-1
		    scf_reusepath = general_filename[scf_reuseval]
		    gsub(".struct","",scf_reusepath)
		    scf_reusepath = global_pwd "/" scf_reusepath
		    scf_reuseroot = scf_reusepath
		    gsub(/^.*\//,"",scf_reuseroot)
		    if (!scf_done[scf_reuseval]){
			scf_reusepath = scf_reuseroot = ""
		    }
		}
		if (scf_reusemode == "fixed" && scf_reuseval > 0 && scf_reuseval <= general_iterations){
		    scf_reuseval += 0
		    scf_reusepath = general_filename[scf_reuseval]
		    gsub(".struct","",scf_reusepath)
		    scf_reusepath = global_pwd "/" scf_reusepath
		    scf_reuseroot = scf_reusepath
		    gsub(/^.*\//,"",scf_reuseroot)
		    if (!scf_done[scf_reuseval]){
			scf_reusepath = scf_reuseroot = ""
		    }
		}
		else if (scf_reusemode == "any"){
		    for (j=general_iterations;j>0;j--){
			if (scf_done[j]){
			    scf_reusepath = general_filename[j]
			    gsub(".struct","",scf_reusepath)
			    scf_reusepath = global_pwd "/" scf_reusepath
			    scf_reuseroot = scf_reusepath
			    gsub(/^.*\//,"",scf_reuseroot)
			    break
			}
		    }
		}
		else if (scf_reusemode == "path"){
		    if (substr(scf_reuseval,1,1) == "/")
			scf_reusepath = scf_reuseval
		    else
			scf_reusepath = global_pwd "/" scf_reuseval
		    gsub(/\/( |\t)*$/,"",scf_reusepath)
		    scf_reuseroot = scf_reusepath
		    gsub(/^.*\//,"",scf_reuseroot)
		}
		if (global_spinpolarized != "yes"){
		    if (!checkexists(scf_reusepath "/" scf_reuseroot ".clmsum") || !checkexists(scf_reusepath "/" scf_reuseroot ".struct"))
			scf_reusepath = scf_reuseroot = ""
		} else {
		    if (!checkexists(scf_reusepath "/" scf_reuseroot ".clmup") || !checkexists(scf_reusepath "/" scf_reuseroot ".clmdn") || !checkexists(scf_reusepath "/" scf_reuseroot ".struct"))
			scf_reusepath = scf_reuseroot = ""
		}
		if (!scf_reusepath || !scf_reuseroot){
		    print "[warn|scf] The requested old density or struct file could not be acessed."
		    print "[warn|scf] Input clmsum : " scf_reusepath "/" scf_reuseroot ".clmsum"
		    print "[warn|scf] Input struct : " scf_reusepath "/" scf_reuseroot ".struct"
		    print "[warn|scf] Starting from superposition of atomic densities."
		}
		else{
		    print "[info|scf] Reusing density from path|root : " scf_reusepath " | " scf_reuseroot
		    # Compare struct files:
		    # If cell parameters or positions are different -> extrapolation with clmaddsub (new version)
		    #     or renormalization (old version). (scf_extrapol)
		    # Else, if some npt, rmt or r0 are differente, interpolate with clminter. (scf_interpol)
		    # Else, copy the clmsum directly
		    scf_extrapol = scf_interpol = ""
		    mysystem(const_lapwextractstructexe " " scf_reusepath "/" scf_reuseroot ".struct > tempfile1")
		    getline < "tempfile1"
		    getline temp_lattice < "tempfile1"
		    getline temp_nneq < "tempfile1"
		    getline < "tempfile1"
		    getline temp_a < "tempfile1"
		    getline temp_b < "tempfile1"
		    getline temp_c < "tempfile1"
		    getline temp_alpha < "tempfile1"
		    getline temp_beta < "tempfile1"
		    getline temp_gamma < "tempfile1"

		    if (temp_lattice != global_lattice || temp_nneq != global_nneq || temp_a != global_a || temp_b != global_b || temp_c != global_c || temp_alpha != global_alpha || temp_beta != global_beta || temp_gamma != global_gamma)
			scf_extrapol = 1
		    else{
			for (j=1;j<=temp_nneq;j++){
			    getline temp_label[j]    < "tempfile1"
			    getline temp_nneq_x[j,1]	< "tempfile1"
			    getline temp_nneq_y[j,1]	< "tempfile1"
			    getline temp_nneq_z[j,1]	< "tempfile1"
			    getline temp_mult[j]	< "tempfile1"
			    if (temp_nneq_x[j,1] != global_nneq_x[j,1] || temp_nneq_y[j,1] != global_nneq_y[j,1] || temp_nneq_z[j,1] != global_nneq_z[j,1] || temp_mult[j] != global_mult[j])
				scf_extrapol = 1
			    getline temp_isplit[j]   < "tempfile1"
			    for (k=2;k<=temp_mult[j];k++){
				getline temp_nneq_x[j,k] < "tempfile1"
				getline temp_nneq_y[j,k] < "tempfile1"
				getline temp_nneq_z[j,k] < "tempfile1"
				if (temp_nneq_x[j,k] != global_nneq_x[j,k] || temp_nneq_y[j,k] != global_nneq_y[j,k] || temp_nneq_z[j,k] != global_nneq_z[j,k])
				    scf_extrapol = 1
			    }
			    getline temp_atomfullnm[j] < "tempfile1"
			    getline temp_atom[j] < "tempfile1"
			    if (temp_atom[j] != global_atom[j])
				scf_extrapol = 1
			    getline temp_npt[j] < "tempfile1"
			    getline temp_r0[j] < "tempfile1"
			    getline temp_rmt[j] < "tempfile1"
			    if (temp_npt[j] != general_val["npt"j,general_index["npt"j,i]] || temp_r0[j] != general_val["r0"j,general_index["r0"j,i]] || temp_rmt[j] !=  general_val["rmt"j,general_index["rmt"j,i]] )
				scf_interpol = 1
			    if (scf_extrapol)
				break
			}
		    }
		    close("tempfile1")
		    mysystem("rm -f tempfile1")

		    if (scf_extrapol){
			if (const_wien2k_version > 20071214){
			    # Extrapolate total charge density
			    print "[info|scf] Extrapolating the charge density..."
			    if (global_spinpolarized == "yes"){
				mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmup ./old.clmup > /dev/null 2>&1")
				if (checkexists(scf_reusepath "/" scf_reuseroot ".clmup.atomic"))
				    mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmup.atomic ./old_super.clmup > /dev/null 2>&1")
				else
				    mysystem(temp_prepath "cp -f " scf_reusepath "/new_super.clmup ./old_super.clmup > /dev/null 2>&1")
				mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmdn ./old.clmdn > /dev/null 2>&1")
				if (checkexists(scf_reusepath "/" scf_reuseroot ".clmdn.atomic"))
				    mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmdn.atomic ./old_super.clmdn > /dev/null 2>&1")
				else
				    mysystem(temp_prepath "cp -f " scf_reusepath "/new_super.clmdn ./old_super.clmdn > /dev/null 2>&1")
				mysystem(temp_prepath "cp -f " temp_name ".clmdn.atomic ./new_super.clmdn > /dev/null 2>&1")
				mysystem(temp_prepath "cp -f " temp_name ".clmup.atomic ./new_super.clmup > /dev/null 2>&1")
				mysystem(temp_prepath const_xlapwexe " clmaddsub -up > " temp_name ".outputclmaddsubup 2>&1")
				mysystem(temp_prepath const_xlapwexe " clmaddsub -dn > " temp_name ".outputclmaddsubdn 2>&1")
				mysystem(temp_prepath "mv -f upclmaddsub.error " temp_name ".upclmaddsub.err")
				mysystem(temp_prepath "mv -f dnclmaddsub.error " temp_name ".dnclmaddsub.err")
			    }
			    else{
				mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmsum ./old.clmsum ")
				if (checkexists(scf_reusepath "/" scf_reuseroot ".clmsum.atomic"))
				    mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmsum.atomic ./old_super.clmsum > /dev/null 2>&1")
				else
				    mysystem(temp_prepath "cp -f " scf_reusepath "/new_super.clmsum ./old_super.clmsum > /dev/null 2>&1")
				mysystem(temp_prepath "cp -f " temp_name ".clmsum.atomic ./new_super.clmsum > /dev/null 2>&1")
				mysystem(temp_prepath const_xlapwexe " clmaddsub > " temp_name ".outputclmaddsub 2>&1")
				mysystem(temp_prepath "mv -f clmaddsub.error " temp_name ".clmaddsub.err")
			    }
			}
			else{
			    # Renormalize old charge density
			    print "[info|scf] Renormalizing the charge density..."
			    mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmsum ./" temp_name ".clmsum_old > /dev/null 2>&1")
			    mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmval ./" temp_name ".clmval > /dev/null 2>&1")
			    mysystem(temp_prepath const_lapwmodifyinmexe " " temp_name ".inm 0.0")
			    mysystem(temp_prepath const_xlapwexe " mixer > /dev/null 2>&1")
			    mysystem(temp_prepath const_lapwmodifyinmexe " " temp_name ".inm " general_val["mix",general_index["mix",i]])
			    if (scf_commandstring !~ "-NI")
				scf_commandstring = scf_commandstring " -NI"
			}
		    }
		    else if (scf_interpol){
			# Interpolate to a new radial grid
			print "[info|scf] Interpolating to a new radial grid..."
			mysystem(temp_prepath "mv -f " temp_name ".struct ./" temp_name ".struct_new > /dev/null 2>&1")
			mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".struct ./" temp_name ".struct > /dev/null 2>&1")
			mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmsum ./" temp_name ".clmsum > /dev/null 2>&1")
			mysystem(temp_prepath const_xlapwexe " clminter > /dev/null 2>&1")
			mysystem(temp_prepath "mv -f " temp_name ".struct_new ./" temp_name ".struct > /dev/null 2>&1")
			mysystem(temp_prepath "mv -f " temp_name ".clmsum_new ./" temp_name ".clmsum > /dev/null 2>&1")
		    }
		    else{
			# Directly copy the clmsum file
			print "[info|scf] Copying the clmsum file..."
			mysystem(temp_prepath "cp -f " scf_reusepath "/" scf_reuseroot ".clmsum ./" temp_name ".clmsum > /dev/null 2>&1")
		    }
		}
	    }
	    # Copy .machines file and add flag if it is a parallel run
	    if (global_parallel){
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
		scf_commandstring = scf_commandstring " -p"
	    }
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # LDA+U calculation: use orb
	    if (global_ldau && !prescf_ldau_not[i])
		scf_commandstring = scf_commandstring " -orb "
	    # # Calculate the elf clmsum file
	    # if (scf_calcelf)
	    # 	mysystem(temp_prepath "sed 's/YES/NO/' " temp_name ".inm > " temp_name ".inm_vresp ")
	    # Run scf cycles
	    print "[info|scf] Running SCF calculation..."
	    print "[info|scf] using commands : " scf_commandstring
	    if (global_spinpolarized != "yes"){
		print "[info|scf] Non-spinpolarized calculation"
		mysystem(temp_prepath "nice -n " scf_nice " " const_runlapwexe " " scf_commandstring " > errfile 2>&1")
	    }
	    else{
		print "[info|scf] Spinpolarized calculation"
		mysystem(temp_prepath "nice -n " scf_nice " " const_runsplapwexe " " scf_commandstring " > errfile 2>&1")
	    }
	    ## No error checks for now, better in dayfile
	    mysystem(temp_prepath "mv -f errfile " temp_name ".scf.err")
	    ## Check scf errors in dayfile...
	    scf_warns[i] = 0
	    if (checkerror(temp_root temp_name ".dayfile","checkword","ABBRUCH: DIE EFG-MATRIX IST DIE NULLMATRIX !")){
		print "[warn|scf] Scf failed. The error occurs in lapw0 and may be caused by "
		print "[warn|scf] a wrong LM list specification or a bad initial clmsum file."
		scf_warns[i]++
		scf_warn[i,scf_warns[i]] = const_warn_badclmini
	    }
	    if (checkerror(temp_root temp_name ".dayfile","checkword","stop error")){
		scf_done[i] = ""
		print "[warn|scf] Structure #" i" has been deleted:"
		print "[warn|scf] Error in scf process."
		if (checkexists(temp_root temp_name ".scf.err")){
		    if (checkerror(temp_root temp_name ".scf.err","checkword","NN - Error")){
			print "[warn|scf] Scf failed, muffin tin collision?."
		    }
		    if (checkerror(temp_root temp_name ".scf.err","checkword","SECLIT - Error in Cholesky")){
			print "[warn|scf] Error in Cholesky factorization (lapw1)."
			print "[warn|scf] This is caused by linear dependencies in the basis."
			print "[warn|scf] Also, using full diagonalization may solve the problem."
		    }
		}
		if (checkexists(temp_root "lapw0.error")){
		    if (checkerror(temp_root "lapw0.error","checkword","Error in LAPW0"))
			print "[warn|scf] Error in lapw0 -> may be due to a bad lm list"
		}
		if (checkexists(temp_root temp_name ".lapw1.error")){
		    if (checkerror(temp_root "lapw1.error","checkword","Plane waves exhausted")){
			print "[warn|scf] Error in lapw1 -> plane waves exhausted"
			print "[warn|scf] May be due to low NMATMAX."
			print "[warn|scf] Check decimal precision in cif files."
		    }
		}
		scf_time[i] = 0
		scf_bandemin[i] = "n/a"
		scf_bandemax[i] = "n/a"
		scf_efermi[i] = "n/a"
		scf_energy[i] = "n/a"
		scf_molenergy[i] = "n/a"
		continue
	    }
	    if (checkexists(temp_root temp_name ".scf")){
		mysystem(const_extractscf " " temp_root temp_name ".scf")
#		for (j in scf_analyze){
#		    print "[info|prho] Analyzing " j "..."
#		    mysystem("grep '^:" toupper(j) "' " temp_root temp_name ".scf")
#		    if (j == "ene" || j == "fer" || j == "dis" || j == "mmtot"){
#			mysystem("grep '^:" toupper(j) "' " temp_root temp_name ".scf | awk '{print NR, $NF}' > " \
#				 temp_root temp_name ".analyze." j)
#			temp_string = temp_root temp_name ".analyze." j ".gnu"
#			print temp_string
#			print "set title '" general_title " (scf " i "," j ")'" > temp_string
#			print "set terminal postscript eps enhanced 'Helvetica' 20" > temp_string
#			print "set output '" temp_name ".analyze." j ".ps' " > temp_string
#			print "set ytics nomirror" > temp_string
#			print "set xtics nomirror" > temp_string
#			print "set xlabel 'Iteration'" > temp_string
#			print "set ylabel '" j "'" > temp_string
#			print "plot '" temp_name ".analyze." j "' w linespoints title '" j "'" > temp_string
#			close(temp_string)
#			mysystem(temp_prepath const_gnuplotexe " " temp_name ".analyze." j ".gnu" " > /dev/null 2>&1")
#		    }
#		    if (j == "qtl"){
#			mysystem("grep '^:" toupper(j) "' " temp_root temp_name ".scf | awk '{print NR, $NF}' > " \
#				 temp_root temp_name ".analyze." j)
#			
#		    }
#		}
	    }
	    mysystem(const_extractdayfile " " temp_root temp_name ".dayfile")
	    # ELF clmsum calc.
	    # if (scf_calcelf){
	    # 	mysystem(temp_prepath "cp -f " temp_name ".in0 " temp_name ".in0_orig")
	    # 	temp_string = temp_root temp_name ".in0"
	    # 
	    # 	# elf
	    # 	if (init_potential == "lsda")
	    # 	    print "TOT   27" > temp_string
	    # 	else
	    # 	    print "TOT   29" > temp_string
	    # 	print "R2V    IFFT" > temp_string
	    # 	print "  45  45  45   3.00  " > temp_string
	    # 	close(temp_string)
	    # 	mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
	    # 	mysystem(temp_prepath "mv -f errfile " temp_name ".elf.lapw0.err")
	    # 	mysystem(temp_prepath "mv -f " temp_name ".in0 " temp_name ".in0_elf")
	    # 	mysystem(temp_prepath "cp -f " temp_name ".r2v " temp_name ".elf")
	    # 
	    # 	# ked
	    # 	if (init_potential == "lsda")
	    # 	    print "TOT   30" > temp_string
	    # 	else
	    # 	    print "TOT   38" > temp_string
	    # 	print "R2V    IFFT" > temp_string
	    # 	print "  45  45  45   3.00  " > temp_string
	    # 	close(temp_string)
	    # 	mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
	    # 	mysystem(temp_prepath "mv -f errfile " temp_name ".ked.lapw0.err")
	    # 	mysystem(temp_prepath "mv -f " temp_name ".in0 " temp_name ".in0_ked")
	    # 	mysystem(temp_prepath "cp -f " temp_name ".r2v " temp_name ".ked")
	    # 
	    # 	mysystem(temp_prepath "cp -f " temp_name ".in0_orig " temp_name ".in0")
	    # }
	    ## Run mini
	    if (scf_mini){
		print "[info|scf] Running mini..."
		if (checkexists(temp_root temp_name ".scf_mini")){
		    print "[warn|scf] Detected an old .scf_mini file."
		    print "[warn|scf] I am deleting it to start from anew."
		    mysystem("rm -f " temp_root temp_name ".scf_mini > /dev/null 2>&1")
		}
		# run pairhess (without -nohess option) to initialize .inM
		mysystem(temp_prepath " " const_xlapwexe " pairhess > errfile 2>&1 ")
		mysystem(temp_prepath " mv -f errfile " temp_name ".pairhess.err")
		mysystem(temp_prepath " cp -f " temp_name ".inM_st " temp_name ".inM")
		mysystem(temp_prepath " cp -f .minpair .min_hess")
		mysystem(temp_prepath " cp -f .minpair .minrestart")
		# modify .inM to required ftol
		if (scf_miniftol){
		    temp_string = temp_root temp_name ".inM"
		    temp_string2 = temp_root temp_name ".inMnew"
		    getline < temp_string
		    temp_str1 = substr($0,1,4)
		    temp_str2 = sprintf("%5.2f",scf_miniftol)
		    temp_str3 = substr($0,10)
		    print temp_str1 temp_str2 temp_str3 > temp_string2
		    for (;getline < temp_string;){
			print $0 > temp_string2
		    }
		    close(temp_string)
		    close(temp_string2)
		    mysystem(" cp -f " temp_string2 " " temp_string)
		}
		# run it
		if (scf_mini == "defline"){
		    if (global_spinpolarized != "yes")
			mysystem(temp_prepath "nice -n " scf_nice " " const_minlapwexe " -j ' " const_runlapwexe " " scf_commandstring "' > errfile 2>&1")
		    else
			mysystem(temp_prepath "nice -n " scf_nice " " const_minlapwexe " -j ' " const_runsplapwexe " " scf_commandstring "' > errfile 2>&1")
		}
		else{
		    mysystem(temp_prepath "nice -n " scf_nice " " const_minlapwexe " " scf_mini " > errfile 2>&1")
		}
		# Activate mini flags and save old energy
		global_mini[i] = "yes"
		if (checkexists(temp_root temp_name ".scf")){
		    temp_string = const_lapwgetetotalexe " " temp_root temp_name ".scf"
		    temp_string | getline scf_premini_molenergy[i]
		    close(temp_string)
		    scf_premini_molenergy[i] = sprintf("%.10f",scf_premini_molenergy[i] / global_gcdmult)
		}
		if (checkexists(temp_root temp_name ".scf_mini")){
		    mysystem(temp_prepath " mv -f errfile " temp_name ".mini.err")
		    # print information to stdout
		    mysystem(temp_prepath const_extractmini " " temp_name ".scf_mini")
		    # build .tess files for tessel and plot cells
		    print "[info|scf] Plotting intermediate unit cells... "
		    temp_string = const_lapwgetiterationsexe " " temp_root temp_name ".scf_mini"
		    temp_string | getline temp_val
		    close(temp_string)
		    for (j=1;j<=temp_val+0;j++){
			temp_input = temp_name "_" j+0 ".struct"
			if (checkexists(temp_root temp_input))
			    mysystem(temp_prepath const_struct2tessexe " " temp_name "_" j+0)
		    }
		    if (checkexe(const_tesselexe) && checkexe(const_povrayexe) && checkexe(const_convertexe)){
			for (j=1;j<=temp_val+0;j++){
			    temp_input = temp_name "_" j+0 ".struct"
			    temp_output = temp_name "_" j+0 ".tess"
			    if (checkexists(temp_root temp_input))
				mysystem(temp_prepath const_tesselexe " " temp_output " > " temp_output ".err 2>&1")
			}
			if (checkexe(const_gifsicleexe)){
			    temp_string = temp_prepath const_gifsicleexe " --colors 256 "
			    for (j=1;j<=temp_val-1;j++){
				temp_input = temp_name "_" j+0 ".struct"
				if (checkexists(temp_root temp_input))
				    temp_string = temp_string " " temp_name "_" j+0 ".gif"
			    }
			    temp_string = temp_string " > " temp_name "_mini.gif"
			    mysystem(temp_string)
			}
			else{
			    print "[warn|scf] gifsicle executable not found."
			    print "[warn|scf] The .tess, .pov and .gif files have been generated."
			}
		    }
		    else{
			print "[warn|scf] One of tessel, povray or convert executables were not found."
			print "[warn|scf] The .tess files have been generated but not run."
		    }
		}
		else 
		    print "[warn|scf] .scf_mini file not found!!!"
	    }
	    # Get information from scf files
	    print "[info|scf] Extracting information from .scf..."
	    if (checkexists(temp_root temp_name ".scf")){
		temp_string = const_lapwgetbandeminexe " " temp_root temp_name ".scf"
		temp_string | getline scf_bandemin[i]
		close(temp_string)
		if (!(scf_bandemin[i]+0))
		    scf_bandemin[i] = "n/a"
		temp_string = const_lapwgetbandemaxexe " " temp_root temp_name ".scf"
		temp_string | getline scf_bandemax[i]
		close(temp_string)
		if (!(scf_bandemax[i]+0))
		    scf_bandemax[i] = "n/a"
		temp_string = const_lapwgetefermiexe " " temp_root temp_name ".scf"
		temp_string | getline scf_efermi[i]
		close(temp_string)
		temp_string = const_lapwgetetotalexe " " temp_root temp_name ".scf"
		temp_string | getline scf_energy[i]
		close(temp_string)
		scf_molenergy[i] = sprintf("%.10f",scf_energy[i] / global_gcdmult)
		temp_string = const_lapwgetiterationsexe " " temp_root temp_name ".scf"
		temp_string | getline scf_noiter[i]
		close(temp_string)
		mysystem(const_lapwgetpwbasisexe " " temp_root temp_name ".scf > " temp_file " 2>&1")
		getline scf_basissize[i] < temp_file
		getline scf_los[i] < temp_file
		close(temp_file)
		mysystem("rm -f " temp_file)
		temp_string = const_lapwgetesemicorevalexe " " temp_root temp_name ".scf"
		temp_string | getline scf_esemicoreval[i]
		close(temp_string)
		temp_string = const_lapwgetdirbexe " " temp_root temp_name ".scf"
		for (j=1;temp_string | getline scf_dirb[i,j];j++)
		    ;
		close(temp_string)
		scf_dirbs[i] = j-1
		temp_string = const_lapwgetrkmaxrealexe " " temp_root temp_name ".scf"
		temp_string | getline scf_rkmaxreal[i]
		close(temp_string)
		if (global_spinpolarized == "yes"){
		    temp_string = const_lapwgetmmtotexe " " temp_root temp_name ".scf"
		    temp_string | getline scf_mmtot[i]
		    close(temp_string)
		}
	    }
	    else{
		scf_bandemin[i] = "n/a"
		scf_bandemax[i] = "n/a"
		scf_efermi[i] = "n/a"
		scf_energy[i] = "n/a"
		scf_molenergy[i] = "n/a"
		scf_noiter[i] = "n/a"
		scf_basissize[i] = "n/a"
		scf_los[i] = "n/a"
		scf_esemicoreval[i] = "n/a"
		scf_dirbs[i] = 0
		scf_rkmaxreal[i] = "n/a"
		scf_mmtot[i] = "n/a"
	    }
	    # Extract warnings from .scf and dayfile
	    print "[info|scf] Validating scf output..."
	    if (scf_noiter[i]+0 >= scf_miter+0){
		scf_warns[i]++
		scf_warn[i,scf_warns[i]] = const_warn_maxiter
	    }
	    else{
		mysystem(const_lapwcheckdayfileexe " " temp_root temp_name ".dayfile > " temp_file)
		for (;getline temp_string < temp_file;){
		    scf_warns[i]++
		    scf_warn[i,scf_warns[i]] = temp_string
		}
		close(temp_file)
		mysystem("rm -rf " temp_file)
	    }
	    if (checkexists(temp_root temp_name ".scf")){
		if (abs(scf_efermi[i] - init_energymax) < 0.1){
		    scf_warns[i]++
		    scf_warn[i,scf_warns[i]] = const_warn_efermi
		}
		mysystem(const_lapwcheckscfexe " " temp_root temp_name ".scf > " temp_file)
		for (;getline temp_string < temp_file;){
		    scf_warns[i]++
		    scf_warn[i,scf_warns[i]] = temp_string
		}
		close(temp_file)
		mysystem("rm -rf " temp_file)
	    }
	    # Cleaning directory
	    clean(i)
	    # Marking as done
	    print "[info|scf] Marking as done..."
	    scf_done[i] = 1
	    # Time count
	    scf_time[i] = systime() - scf_time[i]
	    # Generate checkpoint -- useful if run is interrupted
	    print "[info|scf] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    scf_savecheck(global_root "-check/scf.check")
	}
    }
    if (!scf_nosummary){
	print "[info|scf] Pretty-printing summary..."
	mysystem(const_scfsum " */*.scf > " const_scfsumout " 2>&1")
	if (!isin(const_scfsumout,global_file_out)){
	    global_file_out_n++
	    global_file_out[global_file_out_n] = const_scfsumout
	}
    }
    # Get end time
    scf_totaltime = systime() - scf_totaltime
    # Generate checkpoint
    print "[info|scf] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    scf_savecheck(global_root "-check/scf.check")
    # End message
    print "[info|scf] Scf section ended successfully..."
    printf "\n"
    next
}
# (xsox) Spinorbit section final tasks
/^( |\t)*end( |\t)*spinorbit( |\t)*$/ && global_section=="spinorbit"{
    global_section = ""
    so_run = 1
    print ""
    print "[info|so] Beginning of spinorbit section at " date()
    # Verify needed sections were run
    print "[info|so] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|so] cannot run spinorbit."
	print "[error|so] needed section has not been run or loaded."
	exit 1
    }
    print "[info|so] Checking for executables..."
    delete temp_array
    temp_array[const_minlapwexe] = temp_array[const_runlapwexe] = \
    temp_array[const_runsplapwexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|so] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    so_totaltime = systime()
    # Set default variables. Build the command string 
    print "[info|so] Setting default variables if missing..."
    so_commandstring = ""
    if (!so_miter){
	if (scf_miter)
	    so_miter = scf_miter
	else
	    so_miter = 30
	so_commandstring = so_commandstring " -i " so_miter
    }
    if (!so_cc && !so_ec && !so_fc){
	if (!scf_cc && !scf_ec && !scf_fc)
	    so_ec = 0.00001
	else{
	    so_cc = scf_cc
	    so_ec = scf_ec
	    so_fc = scf_fc
	}
    }
    if(so_cc)
	so_commandstring = so_commandstring " -cc " sprintf("%f",so_cc)
    if(so_ec)
	so_commandstring = so_commandstring " -ec " sprintf("%f",so_ec)
    if(so_fc)
	so_commandstring = so_commandstring " -fc " sprintf("%f",so_fc)
    if (so_itdiag)
	if (const_wien2k_version < 20070813)
	    so_commandstring = so_commandstring " -it " so_itdiag " "
	else
	    so_commandstring = so_commandstring " -it "
    if (so_in1new)
	so_commandstring = so_commandstring " -in1new " so_in1new " "
    if (!so_nice)
	if (scf_nice)
	    so_nice = scf_nice
	else
	    so_nice = 0
    so_initialcommandstring = so_commandstring
    if (!so_h && !so_k && !so_l){
	so_h = 0
	so_k = 0
	so_l = 1
    }
    if (!so_newkpts)
	so_newkpts = "100%"
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|so] Determining which structures to run..."
    if (!so_dolines){
	if (!global_dolines){
	    so_dolines = 1
	    so_doline[1] = "new"
	    so_dotype[1] = "do"
	}
	else{
	    so_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		so_doline[i] = global_doline[i]
		so_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=so_dolines;i++){
	list_parser(so_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && so_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    so_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && so_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    so_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && so_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    so_do[k] = 1
		}
	    }
	    if (global_flag[j] ~ /old/ && so_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    so_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (so_dotype[i] ~ /do/){
		    so_do[k] = 1
		}
		else{
		    so_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|so] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (so_do[i]){
		print "[warn|so] structure " i " cannot be run..."
		so_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (so_do[i]){
	    # Time count
	    so_time[i] = systime()
	    # Load structure + heading
	    print "[info|so] --------------------------------------------------------------------"
	    print "[info|so] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    # Initialize command string
	    so_commandstring = so_initialcommandstring " -so "
	    # Copy .machines file and add flag if it is a parallel run
	    if (global_parallel){
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
		so_commandstring = so_commandstring " -p"
	    }
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # LDA+U calculation: use orb
	    if (global_ldau && !prescf_ldau_not[i])
		so_commandstring = so_commandstring " -orb "
	    # Write .inso
	    print "[info|so] Writing the .inso spin-orbit input file..."
	    temp_filename = temp_root temp_name ".inso"
	    print "WFFIL" > temp_filename
	    print " 4 1 0 " > temp_filename
	    print " -10.0000   1.50000 " > temp_filename
	    print so_h " " so_k " " so_l > temp_filename
	    print so_addlos > temp_filename
	    for (j=1;j<=so_addlos;j++){
		temp_string = so_addlo_atom[j] " " so_addlo_e[j]+0 " " so_addlo_de[j]+0
		temp_string = temp_string " " (so_addlo_de[j]?"":"STOP")
		print temp_string > temp_filename
	    }
	    temp_string = so_excludes
	    for (j=1;j<=so_excludes;j++)
		temp_string = temp_string " " so_exclude[j]
	    print temp_string > temp_filename
	    close(temp_filename)
	    # Change emax
	    if (so_newemax){
		print "[info|so] Modifying .in1 to expand eigenvalue window..."
		mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1" (global_complex?"c":"") " " global_nneq " auto auto " so_newemax " auto  auto")
	    }
	    # Generate new struct file if spinpolarized
	    if (global_spinpolarized){
		# Run symmetso
		print "[info|so] Running symmetso and copying new struct file..."
		mysystem(temp_prepath const_xlapwexe " symmetso " global_complex " > errfile 2>&1")
		mysystem(temp_prepath " mv -f errfile " temp_name ".symmetso.err")
		mysystem(temp_prepath " cp -f " temp_name ".struct_so " temp_name ".struct")
		if (checkempty(temp_root temp_name ".ksym")){
		    print "[info|so] ksym is empty... running kgen without so"
		    temp_val = ""
		} 
		else {
		    print "[info|so] ksym is not empty... running kgen with so"
		    temp_val = "-so"
		}
		# Parse kgen output
		temp_string = temp_root "kgen-script"
		print const_xlapwexe " kgen " temp_val " << --eof--" > temp_string
		printf "1\n1\n1\n1\n--eof--" >> temp_string
		close(temp_string)
		mysystem(temp_prepath "chmod u+x kgen-script")
		mysystem(temp_prepath "./kgen-script > errfile 2>&1")
		if (checkerror(temp_root "errfile","checkword","add inversion"))
		    temp_askinversion = 1
		if (checkerror(temp_root "errfile","checkword","Shift of k-mesh allowed"))
		    temp_askshift = 1
		mysystem(temp_prepath "rm -f errfile")
		mysystem(temp_prepath "rm -f kgen-script")
		temp_askoutput = ""
		if (const_wien2k_version < 20080421)
		    temp_askoutput = 1
		print const_xlapwexe " kgen " temp_val " << --eof--" > temp_string
		if (temp_askinversion)
		    print "1" > temp_string
		if (so_newkpts ~ /%/)
		    print general_val["kpts",general_index["kpts",i]]*(so_newkpts+0)/100 > temp_string
		else
		    print so_newkpts > temp_string
		if (temp_askoutput)
		    if (prescf_kgenoutput == "long")
			print "1" > temp_string
		    else
			print "0" > temp_string
		if (temp_askshift)
		    if (prescf_kgenshift == "no")
			print "0" > temp_string
		    else
			print "1" > temp_string
		print "--eof--" > temp_string
		close(temp_string)
		mysystem(temp_prepath "chmod u+x kgen-script")
		mysystem(temp_prepath "./kgen-script > errfile 2>&1")
		### No error checks for now
		mysystem(temp_prepath "rm -f errfile kgen-script > /dev/null 2>&1")
	    }
	    print "[info|so] Copying input files for SCF..."
	    mysystem(temp_prepath "cp -f " temp_name ".inc_so " temp_name ".inc > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".in2"(global_complex?"c":"")"_so " temp_name ".in2c > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".in1"(global_complex?"c":"")"_so " temp_name ".in1c > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".clmsum_so " temp_name ".clmsum > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".clmup_so " temp_name ".clmup > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".clmdn_so " temp_name ".clmdn > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".vspup_so " temp_name ".vspup > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".vspdn_so " temp_name ".vspdn > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".vnsup_so " temp_name ".vnsup > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".vnsdn_so " temp_name ".vnsdn > /dev/null 2>&1")
	    mysystem(temp_prepath "rm -f " temp_name ".recprlist > /dev/null 2>&1")
	    if (checkexists(global_pwd "/" temp_root temp_name ".indm"))
		mysystem(temp_prepath "cp -f " temp_name ".indm " temp_name ".indmc > /dev/null 2>&1")
	    
	    # Run scf cycles
	    print "[info|so] Saving pre-SO information..."
	    mysystem(temp_prepath "cp -f " temp_name ".scf " temp_name ".scf.noso > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".clmup " temp_name ".clmup.noso > /dev/null 2>&1")
	    mysystem(temp_prepath "cp -f " temp_name ".clmdn " temp_name ".clmdn.noso > /dev/null 2>&1")
	    print "[info|so] Running SCF calculation..."
	    print "[info|so] using commands : " so_commandstring
	    if (global_spinpolarized != "yes"){
		print "[info|so] Non-spinpolarized calculation"
		mysystem(temp_prepath "nice -n " so_nice " " const_runlapwexe " " so_commandstring " > errfile 2>&1")
	    }
	    else{
		print "[info|so] Spinpolarized calculation"
		mysystem(temp_prepath "nice -n " so_nice " " const_runsplapwexe " " so_commandstring " > errfile 2>&1")
	    }
	    ## No error checks for now, better in dayfile
	    mysystem(temp_prepath "mv -f errfile " temp_name ".scfso.err")
	    ## Check scf errors in dayfile...
	    if (checkerror(temp_root temp_name ".dayfile","checkword","stop error")){
		so_done[i] = ""
		print "[warn|so] Structure #" i" has been deleted:"
		print "[warn|so] Error in scf process."
		if (checkexists(temp_root temp_name ".scfso.err")){
		    if (checkerror(temp_root temp_name ".scfso.err","checkword","NN - Error")){
			print "[warn|so] Scf failed, muffin tin collision?."
		    }
		    if (checkerror(temp_root temp_name ".scfso.err","checkword","SECLIT - Error in Cholesky")){
			print "[warn|so] Error in Cholesky factorization (lapw1)."
			print "[warn|so] This is caused by linear dependencies in the basis."
			print "[warn|so] Also, using full diagonalization may solve the problem."
		    }
		}
		if (checkexists(temp_root "lapw0.error")){
		    if (checkerror(temp_root "lapw0.error","checkword","Error in LAPW0"))
			print "[warn|so] Error in lapw0 -> may be due to a bad lm list"
		}
		if (checkexists(temp_root temp_name ".lapw1.error")){
		    if (checkerror(temp_root "lapw1.error","checkword","Plane waves exhausted")){
			print "[warn|so] Error in lapw1 -> plane waves exhausted"
			print "[warn|so] May be due to low NMATMAX."
			print "[warn|so] Check decimal precision in cif files."
		    }
		}
		so_time[i] = 0
		so_bandemin[i] = "n/a"
		so_bandemax[i] = "n/a"
		so_efermi[i] = "n/a"
		so_energy[i] = "n/a"
		so_molenergy[i] = "n/a"
		continue
	    }
	    mysystem(const_extractdayfile " " temp_root temp_name ".dayfile")
	    mysystem(const_extractscf " " temp_root temp_name ".scf")
	    # Get information from scf files
	    print "[info|so] Extracting information from .scf..."
	    if (checkexists(temp_root temp_name ".scf")){
		temp_string = const_lapwgetbandeminexe " " temp_root temp_name ".scf"
		temp_string | getline so_bandemin[i]
		close(temp_string)
		if (!(so_bandemin[i]+0))
		    so_bandemin[i] = "n/a"
		temp_string = const_lapwgetbandemaxexe " " temp_root temp_name ".scf"
		temp_string | getline so_bandemax[i]
		close(temp_string)
		if (!(so_bandemax[i]+0))
		    so_bandemax[i] = "n/a"
		temp_string = const_lapwgetefermiexe " " temp_root temp_name ".scf"
		temp_string | getline so_efermi[i]
		close(temp_string)
		temp_string = const_lapwgetetotalexe " " temp_root temp_name ".scf"
		temp_string | getline so_energy[i]
		close(temp_string)
		so_molenergy[i] = sprintf("%.10f",so_energy[i] / global_gcdmult)
		temp_string = const_lapwgetiterationsexe " " temp_root temp_name ".scf"
		temp_string | getline so_noiter[i]
		close(temp_string)
		if (global_spinpolarized == "yes"){
		    temp_string = const_lapwgetmmtotexe " " temp_root temp_name ".scf"
		    temp_string | getline so_mmtot[i]
		    close(temp_string)
		}
	    }
	    else{
		so_bandemin[i] = "n/a"
		so_bandemax[i] = "n/a"
		so_efermi[i] = "n/a"
		so_energy[i] = "n/a"
		so_molenergy[i] = "n/a"
		so_noiter[i] = "n/a"
		so_mmtot[i] = "n/a"
	    }
	    # Cleaning directory
	    clean(i)
	    # Marking as done
	    print "[info|so] Marking as done..."
	    so_done[i] = 1
	    # Time count
	    so_time[i] = systime() - so_time[i]
	    # Generate checkpoint -- useful if run is interrupted
	    print "[info|so] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    so_savecheck(global_root "-check/so.check")
	}
    }
    # Get end time
    so_totaltime = systime() - so_totaltime
    # Generate checkpoint
    print "[info|so] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    so_savecheck(global_root "-check/so.check")
    # End message
    print "[info|so] Spinorbit section ended successfully..."
    printf "\n"
    next
}
# (xelasticx) Elastic section final tasks
/^( |\t)*end( |\t)*elastic( |\t)*$/ && global_section=="elastic"{
    global_section = ""
    elastic_run = 1
    print ""
    print "[info|elastic] Beginning of elastic section at " date()
    # Verify needed sections were run
    print "[info|elastic] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|elastic] cannot run elastic."
	print "[error|elastic] needed section has not been run or loaded."
	exit 1
    }
    # Verify lattice type is supported
    if (global_system != "cubic" && global_system != "hexagonal" && global_system != "tetragonal"){
	print "[error|elastic] Only cubic, hexagonal and tetragonal structures are supported."
	exit 1
    }
    elastic_system = global_system
    if (global_system == "tetragonal"){
	if (!elastic_tetragonal){
	    print "[error|elastic] Tetragonal systems need the TETRAGONAL {1|2} specification."
	    exit 1
	} else {
	    elastic_system = "tetragonal" elastic_tetragonal
	}
    }
    # Get initial time
    elastic_totaltime = systime()
    # Set default variables
    print "[info|elastic] Setting default variables if missing..."
    if (!elastic_ref){
	for (i=1;i<=general_iterations;i++){
	    if (general_done[i] && init_done[i]){
		elastic_ref = i
		break
	    }
	}
	if (!elastic_ref){
	    print "[error|free] there is no adequate reference structure."
	    print "[error|free] run general and init in at least one structure to take it as ref."
	    exit 1
	}
    }
    if (!elastic_polyorder)
	elastic_polyorder = 4
    if (!elastic_fixmin)
	elastic_fixmin = "no"
    if (!elastic_term1)
	elastic_term1 = "no"
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "npt" i
	if (!elastic_npt[i])
	    elastic_npt[i] = general_val[temp_idstring,general_index[temp_idstring,elastic_ref]]
    }
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "r0" i
	if (!elastic_r0[i])
	    elastic_r0[i] = general_val[temp_idstring,general_index[temp_idstring,elastic_ref]]
    }
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "rmt" i
	if (!elastic_rmt[i])
	    elastic_rmt[i] = general_val[temp_idstring,general_index[temp_idstring,elastic_ref]]
    }
    if (!elastic_rkmax)
	elastic_rkmax = general_val["rkmax",general_index["rkmax",elastic_ref]]
    if (!elastic_lmax)
	elastic_lmax = general_val["lmax",general_index["lmax",elastic_ref]]
    if (!elastic_lnsmax)
	elastic_lnsmax = general_val["lnsmax",general_index["lnsmax",elastic_ref]]
    if (!elastic_gmax)
	elastic_gmax = general_val["gmax",general_index["gmax",elastic_ref]]
    if (!elastic_mix)
	elastic_mix = general_val["mix",general_index["mix",elastic_ref]]
    if (!elastic_kpts)
	elastic_kpts = general_val["kpts",general_index["kpts",elastic_ref]]
    if (!elastic_potential)
	elastic_potential = init_potential
    if (!elastic_ecoreval)
	elastic_ecoreval = init_ecoreval
    if (!elastic_ifft)
	elastic_ifft = init_ifft
    if (!elastic_energymin)
	elastic_energymin = init_energymin
    if (!elastic_energymax)
	elastic_energymax = init_energymax
    if (!elastic_fermi)
	elastic_fermi = init_fermi
    if (!elastic_fermival)
	elastic_fermival = init_fermival
    if (!elastic_reusemode)
	elastic_reusemode = "detect"
    if (!elastic_miter)
	elastic_miter = scf_miter
    if (!elastic_cc && !elastic_ec && !elastic_fc){
	elastic_ec = scf_ec
	elastic_cc = scf_cc
	elastic_fc = scf_fc
    }
    for (i=1;i<=global_nneq;i++){
	if (!elastic_orbitals[i]){
	    if (init_orbitals[i]){
		elastic_orbitals[i] = init_orbitals[i]
		elastic_orbital_globe[i] = init_orbital_globe[i]
		elastic_orbital_globapw[i] = init_orbital_globapw[i]
		for (j=1;j<=elastic_orbitals[i];j++){
		    elastic_orbital_l[i,j] = init_orbital_l[i,j]
		    elastic_orbital_energy[i,j] = init_orbital_energy[i,j]
		    elastic_orbital_var[i,j] = init_orbital_var[i,j]
		    elastic_orbital_cont[i,j] = init_orbital_cont[i,j]
		    elastic_orbital_apw[i,j] = init_orbital_apw[i,j]
		}
	    }
	}
	if (!elastic_lms[i]){
	    if (init_lms[i]){
		if (init_lms[i] ~ /lmax/)
		    elastic_lms[i] = init_lms[i]
		else{
		    temp_val = -1
		    for (j=1;j<=init_lms[i];j++)
			temp_val = max(temp_val,init_lm_l[i,j])
		    elastic_lms[i] = temp_val " lmax"
		}
	    }
	}
    }
    if (!elastic_points)
	elastic_points = 7
    if (!elastic_maxlength)
	elastic_maxlength = 0.05
    if (!elastic_maxangle)
	elastic_maxangle = 5.0
    if (!elastic_ldau){
	if (global_ldau && !prescf_ldau_not[elastic_ref]){
	    elastic_ldau = global_ldau
	    elastic_ldautype = global_ldautype
	    elastic_ldaus = global_ldaus
	    for (i=1;i<=elastic_ldaus;i++){
		elastic_ldau_atom[i] = global_ldau_atom[i]
		elastic_ldau_l[i] = global_ldau_l[i]
		elastic_ldau_defu[i] = general_val["u"i,general_index["u"i,elastic_ref]]+0
		elastic_ldau_defj[i] = general_val["j"i,general_index["j"i,elastic_ref]]+0
	    }
	}
    }

    # Verify order is adequate for the number of points
    temp_val = elastic_polyorder + 2
    if (elastic_fixmin == "yes")
	temp_val--
    if (elastic_term1 != "yes")
	temp_val--
    if (elastic_points < temp_val){
	print "[error|elastic] The number of points is lower than number of parameters."
	print "[error|elastic]   Points = " elastic_points
	print "[error|elastic]   Parameters = " temp_val
	exit 1
    }

    # term1 => fixmin
    if (elastic_term1 == "yes"){
	if (elastic_fixmin != "yes"){
	    print "[warn|elastic] Term1 + fixmin is redundant."
	    print "[warn|elastic] Setting fixmin to 'yes'."
	    elastic_fixmin = "yes"
	}
    }

    # Calculate deformation steps
    print "[info|elastic] Calculating deformation steps..."
    elastic_lstepab = 2 * global_a * elastic_maxlength / (elastic_points - 1)
    elastic_lstepc = 2 * global_c * elastic_maxlength / (elastic_points - 1)
    elastic_astep = 2 * elastic_maxangle  / (elastic_points - 1)

    # Calculate padding zeroes
    print "[info|elastic] Calculating padding zeroes..."
    elastic_pad = int(0.4343*log(elastic_points))+1

    # Create directory
    print "[info|elastic] Creating elastic directory..."
    mysystem("mkdir " global_root "-elastic > /dev/null 2>&1")

    # Run over deformations
    for (i=1;i<=const_elastic_defs[elastic_system];i++){
	# Time count
	elastic_deftime[i] = systime()
	# Load structure + heading
	print "[info|elastic] ----------------------------------------------------------"
	print "[info|elastic] Calculating deformation : " const_elastic_defname[elastic_system,i]
	# Create deformation directory
	mysystem("mkdir " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] " > /dev/null 2>&1")

	# Run over points in this deformation
	for (j=1;j<=elastic_points;j++){
	    # Time count
	    elastic_time[i,j] = systime()
	    # Calculate deformations. Break symmetry
	    print "[info|elastic] Calculating point number " j "..."
	    if ((j - (elastic_points + 1) / 2) == 0){
		elastic_cell[i,j,"a"] = global_a + const_elastic_def[elastic_system,i,"a"] * 0.001
		elastic_cell[i,j,"b"] = global_b + const_elastic_def[elastic_system,i,"b"] * 0.001
		elastic_cell[i,j,"c"] = global_c + const_elastic_def[elastic_system,i,"c"] * 0.001
		elastic_cell[i,j,"alpha"] = global_alpha + const_elastic_def[elastic_system,i,"alpha"] * 0.05
		elastic_cell[i,j,"beta"]  = global_beta  + const_elastic_def[elastic_system,i,"beta"]  * 0.05
		elastic_cell[i,j,"gamma"] = global_gamma + const_elastic_def[elastic_system,i,"gamma"] * 0.05
	    }
	    else{
		elastic_cell[i,j,"a"] = global_a + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"a"] * elastic_lstepab
		elastic_cell[i,j,"b"] = global_b + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"b"] * elastic_lstepab
		elastic_cell[i,j,"c"] = global_c + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"c"] * elastic_lstepc
		elastic_cell[i,j,"alpha"] = global_alpha + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"alpha"] * elastic_astep
		elastic_cell[i,j,"beta"] = global_beta + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"beta"] * elastic_astep
		elastic_cell[i,j,"gamma"] = global_gamma + (j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,i,"gamma"] * elastic_astep
	    }
	    # Create point directory
	    mysystem("rm -rf " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) " > /dev/null 2>&1")
	    mysystem("mkdir " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) " > /dev/null 2>&1")
	    # Copy .machines file if parallel
	    if (global_parallel)
		mysystem("cp -f " global_machines " " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/machines")
	    # Create deformation input
	    elastic_filename = global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/" global_root sprintf("%0*d",elastic_pad,j) ".wien"

	    if (global_parallel)
		print "parallel " global_pwd "/" global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/machines" > elastic_filename
	    print "general" > elastic_filename
	    print "  lattice P " > elastic_filename
	    for (k=1;k<=global_nneq;k++){
		print "  equiv list " global_atomfullnm[k] > elastic_filename
		for (l=1;l<=global_mult[k];l++){
		    if (global_lattice == "P" || global_lattice == "S" || global_lattice == "R" || global_lattice == "H")
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
		    else if (global_lattice == "B"){
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l]+0.5,global_nneq_y[k,l]+0.5,global_nneq_z[k,l]+0.5 > elastic_filename
		    }
		    else if (global_lattice == "F"){
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l]+0.5,global_nneq_z[k,l]+0.5 > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l]+0.5,global_nneq_y[k,l],global_nneq_z[k,l]+0.5 > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l]+0.5,global_nneq_y[k,l]+0.5,global_nneq_z[k,l] > elastic_filename
		    }
		    else if (global_lattice == "CXY"){
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l]+0.5,global_nneq_y[k,l]+0.5,global_nneq_z[k,l] > elastic_filename
		    }
		    else if (global_lattice == "CYZ"){
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l]+0.5,global_nneq_z[k,l]+0.5 > elastic_filename
		    }
		    else if (global_lattice == "CXZ"){
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l],global_nneq_y[k,l],global_nneq_z[k,l] > elastic_filename
			printf "   %.10f %.10f %.10f\n",global_nneq_x[k,l]+0.5,global_nneq_y[k,l],global_nneq_z[k,l]+0.5 > elastic_filename
		    }
		}
		print "  end equiv list " > elastic_filename
	    }
	    printf "  %s %.10f %.10f %.10f %.10f %.10f %.10f\n","cell parameters", elastic_cell[i,j,"a"], elastic_cell[i,j,"b"], elastic_cell[i,j,"c"], elastic_cell[i,j,"alpha"], elastic_cell[i,j,"beta"], elastic_cell[i,j,"gamma"] > elastic_filename
	    if (global_spinpolarized == "yes")
		print "  spinpolarized yes" > elastic_filename
	    else
		print "  spinpolarized no" > elastic_filename
	    for (k=1;k<=global_nneq;k++)
		print "  rmt " k " " elastic_rmt[k] > elastic_filename
	    for (k=1;k<=global_nneq;k++)
		print "  r0 " k " " elastic_r0[k] > elastic_filename
	    for (k=1;k<=global_nneq;k++)
		print "  npt " k " " elastic_npt[k] > elastic_filename
	    print "  rkmax      " elastic_rkmax > elastic_filename
	    print "  lmax       " elastic_lmax > elastic_filename
	    print "  lnsmax     " elastic_lnsmax > elastic_filename
	    print "  gmax       " elastic_gmax > elastic_filename
	    print "  mix        " elastic_mix > elastic_filename
	    print "  kpts       " elastic_kpts > elastic_filename
	    if (elastic_ldau){
		print "  lda+u " elastic_ldautype > elastic_filename
		for (k=1;k<=elastic_ldaus;k++)
		    print "  " elastic_ldau_atom[k] " " elastic_ldau_l[k] " " elastic_ldau_defu[k] " " elastic_ldau_defj[k] > elastic_filename
		print "  end lda+u " elastic_ldautype > elastic_filename
	    }
	    print "end general" > elastic_filename
	    print "initialization" > elastic_filename
	    print "  sgroup " > elastic_filename
	    print "  xcpotential " elastic_potential > elastic_filename
	    print "  ecoreval " elastic_ecoreval > elastic_filename
	    print "  ifft " elastic_ifft > elastic_filename
	    print "  energymin "elastic_energymin > elastic_filename
	    print "  energymax "elastic_energymax > elastic_filename
	    print "  fermi " elastic_fermi " " elastic_fermival > elastic_filename
	    for (k=1;k<=global_nneq;k++){
		print "  orbitals " k " " elastic_orbital_globe[k] " " elastic_orbital_globapw[k] > elastic_filename
		for (l=1;l<=elastic_orbitals[k];l++){
		    print "   ",elastic_orbital_l[k,l],elastic_orbital_energy[k,l],elastic_orbital_var[k,l],elastic_orbital_cont[k,l],elastic_orbital_apw[k,l] > elastic_filename
		}
		print "  end orbitals " > elastic_filename
		# elastic_lms is always given as a lmax
		if (elastic_lms[k])
		    print "  lm list " k " " elastic_lms[k]+0 > elastic_filename
	    }
	    print "end initialization" > elastic_filename
	    print "prescf " > elastic_filename
	    if (elastic_nice)
		print "  nice " elastic_nice > elastic_filename
	    print "end prescf " > elastic_filename
	    print "scf " > elastic_filename
	    if (!elastic_noreuse){
		if (elastic_reusemode == "chain"){
		    if (j>1)
			print "  reuse path " global_pwd "/" global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j-1) "/" global_root sprintf("%0*d",elastic_pad,j-1) "1" > elastic_filename
		}
		else if (elastic_reusemode == "path"){
		    if (substr(elastic_reuseval,1,1) != "/")
			elastic_reuseval = global_pwd "/" elastic_reuseval
		    print "  reuse path " elastic_reuseval > elastic_filename
		}
		else{
		    # detect calculated points
		    temp_val = mysystem("ls -d " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] \
					"/*/*1/ > tempfile 2>&1")
		    if (temp_val == 0){
			temp_flag = ""
			for (;getline temp_string < "tempfile";){
			    temp_root = temp_string
			    gsub(/\/( |\t)*$/,"",temp_root)
			    gsub(/^.*\//,"",temp_root)
			    if (global_spinpolarized == "yes"){
				if (checkexists(temp_string temp_root ".clmdn") && checkexists(temp_string temp_root ".clmup") && checkexists(temp_string temp_root ".struct") && checkexists(temp_string temp_root ".scf")){
				    temp_flag = 1
				    break
				}
			    }
			    else
				if (checkexists(temp_string temp_root ".clmsum") && checkexists(temp_string temp_root ".struct") && checkexists(temp_string temp_root ".scf")){
				    temp_flag = 1
				    break
				}
			}
			if (temp_flag)
			    print "  reuse path " global_pwd "/" temp_string > elastic_filename
			else
			    print "[elastic|warn] No adequate elastic structure found for reusing."
			close("tempfile")
		    }
		    else
			print "[elastic|warn] No adequate elastic structure found for reusing."
		    mysystem("rm -f tempfile")
		}
	    }
	    if (elastic_itdiag)
		print "  itdiag " elastic_itdiag > elastic_filename
	    if (elastic_nice)
		print "  nice " elastic_nice > elastic_filename
	    print "  max iterations " elastic_miter > elastic_filename
	    if (elastic_cc)
		print "  charge conv " elastic_cc > elastic_filename
	    if (elastic_ec)
		print "  energy conv " elastic_ec > elastic_filename
	    if (elastic_fc)
		print "  force conv " elastic_fc > elastic_filename
	    if (elastic_in1new)
		print "  new in1 " elastic_in1new > elastic_filename
	    if (elastic_mini)
		if (elastic_mini == "defline")
		    print "  mini " > elastic_filename
		else
		    print "  mini " elastic_mini > elastic_filename
	    print "end scf " > elastic_filename
	    if (elastic_so_lines){
		print "spinorbit " > elastic_filename
		for (k=1;k<=elastic_so_lines;k++)
		    print elastic_so_line[k] > elastic_filename
		print "end spinorbit " > elastic_filename
	    }
	    print "synopsis " > elastic_filename
	    print " exhaustive " > elastic_filename
	    print "end synopsis " > elastic_filename
	    if (elastic_clean)
		print elastic_clean > elastic_filename
	    close(elastic_filename)

	    # Do it!
	    if (!elastic_nosend){
		print "cd " global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) > "elastic-script"
		print "runwien.awk " global_root sprintf("%0*d",elastic_pad,j) ".wien > "  const_elasticrunout > "elastic-script"
		close("elastic-script")
		mysystem("chmod u+x elastic-script")
		mysystem("./elastic-script")
		mysystem("rm -f elastic-script")
		if (checkexists(global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/synopsis.out" )){
		    if (!isin(global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/synopsis.out" ,global_file_out)){
			global_file_out_n++
			global_file_out[global_file_out_n] = global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/synopsis.out"
		    }
		}
	    }
	    # Get energy
	    elastic_filename = global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,i] "/" global_root sprintf("%0*d",elastic_pad,j) "/" global_root sprintf("%0*d",elastic_pad,j) "1/" global_root sprintf("%0*d",elastic_pad,j) "1.scf"
	    if (checkexists(elastic_filename)){
		temp_string = const_lapwgetetotalexe " " elastic_filename
		temp_string | getline elastic_energy[i,j]
		close(temp_string)
		elastic_energy[i,j] /= global_gcdmult
	    }
	    else
		elastic_energy[i,j] = ""
	    # Time count
	    elastic_time[i,j] = systime()
	    # Generate checkpoint
	    print "[info|elastic] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    elastic_savecheck(global_root "-check/elastic.check")
	}
	# Time count
	elastic_deftime[i] = systime() - elastic_deftime[i]
	# Generate checkpoint
	print "[info|elastic] Writing checkpoints..."
	global_savecheck(global_root "-check/global.check")
	elastic_savecheck(global_root "-check/elastic.check")
    }
    # Check all energies are known
    print "[info|elastic] Checking all energies are known..."
    elastic_goodenergy = 1
    for (i=1;i<=const_elastic_defs[elastic_system];i++)
	for (j=1;j<=elastic_points;j++)
	    if (!elastic_energy[i,j])
		elastic_goodenergy = ""
    # Print summary of elastic constants and energy curves
    print "[info|elastic] Calculating elastic constants..."
    elastic_fitall()
    
    ## Add summary to .out list
    if (!isin(elastic_sumout,global_file_out)){
	global_file_out_n++
	global_file_out[global_file_out_n] = elastic_sumout
    }

    # Write down ps files
    temp_command = "ls " global_root "-elastic/*.eps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    # Get end time
    elastic_totaltime = systime() - elastic_totaltime
    # Generate checkpoint
    print "[info|elastic] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    elastic_savecheck(global_root "-check/elastic.check")
    # End message
    print "[info|elastic] Elastic section ended successfully..."
    printf "\n"
    next
}
# (xfreex) Free section final tasks
/^( |\t)*end( |\t)*free( |\t)*$/ && global_section=="free"{
    global_section = ""
    free_run = 1
    print ""
    print "[info|free] Beginning of free section at " date()
    # Verify needed sections were run
    print "[info|free] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|free] cannot run free."
	print "[error|free] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    free_totaltime = systime()
    # Set default variables
    print "[info|free] Setting default variables if missing..."
    for (i=1;i<=global_atomnames;i++){
	temp_string = global_atomname[i]
	if (!free_ref[temp_string]){
	    for (i=1;i<=general_iterations;i++){
		if (general_done[i] && init_done[i]){
		    free_ref[temp_string] = i
		    break
		}
	    }
	    if (!free_ref[temp_string]){
		print "[error|free] there is no adequate reference structure."
		print "[error|free] run general and init in at least one structure to take it as ref."
		exit 1
	    }
	}
	if (!free_cell[temp_string])
	    free_cell[temp_string] = 25.0
	if (!free_spinpolarized[temp_string])
	    free_spinpolarized[temp_string] = global_spinpolarized
	if (!free_potential[temp_string])
	    free_potential[temp_string] = init_potential
	if (!free_ecoreval[temp_string])
	    free_ecoreval[temp_string] = init_ecoreval
	if (!free_energymin[temp_string])
	    free_energymin[temp_string] = init_energymin
	if (!free_energymax[temp_string])
	    free_energymax[temp_string] = init_energymax
	if (!free_fermi[temp_string])
	    free_fermi[temp_string] = init_fermi
	if (!free_fermival[temp_string])
	    free_fermival[temp_string] = init_fermival
	if (!free_orbitals[temp_string]){
	    if (init_orbitals[global_atomrepr[i]]){
		free_orbitals[temp_string] = init_orbitals[global_atomrepr[i]]
		free_orbital_globe[temp_string] = init_orbital_globe[global_atomrepr[i]]
		free_orbital_globapw[temp_string] = init_orbital_globapw[global_atomrepr[i]]
		for (j=1;j<=free_orbitals[temp_string];j++){
		    free_orbital_l[temp_string,j] = init_orbital_l[global_atomrepr[i],j]
		    free_orbital_energy[temp_string,j] = init_orbital_energy[global_atomrepr[i],j]
		    free_orbital_var[temp_string,j] = init_orbital_var[global_atomrepr[i],j]
		    free_orbital_cont[temp_string,j] = init_orbital_cont[global_atomrepr[i],j]
		    free_orbital_apw[temp_string,j] = init_orbital_apw[global_atomrepr[i],j]
		}
	    }
	}
	if (!free_miter[temp_string])
	    free_miter[temp_string] = scf_miter
	if (!free_cc[temp_string] && !free_ec[temp_string] && !free_fc[temp_string]){
	    free_ec[temp_string] = scf_ec
	    free_cc[temp_string] = scf_cc
	    free_fc[temp_string] = scf_fc
	}
	if (!free_npt[temp_string])
	    free_npt[temp_string] = general_val["npt" global_atomrepr[i],general_index["npt" global_atomrepr[i],free_ref[temp_string]]]
	if (!free_rmt[temp_string])
	    free_rmt[temp_string] = general_val["rmt" global_atomrepr[i],general_index["rmt" global_atomrepr[i],free_ref[temp_string]]]
	if (!free_r0[temp_string])
	    free_r0[temp_string] = general_val["r0" global_atomrepr[i],general_index["r0" global_atomrepr[i],free_ref[temp_string]]]
	if (!free_rkmax[temp_string])
	    free_rkmax[temp_string] = general_val["rkmax",general_index["rkmax",free_ref[temp_string]]]
	if (!free_lmax[temp_string])
	    free_lmax[temp_string] = general_val["lmax",general_index["lmax",free_ref[temp_string]]]
	if (!free_lnsmax[temp_string])
	    free_lnsmax[temp_string] = general_val["lnsmax",general_index["lnsmax",free_ref[temp_string]]]
	if (!free_gmax[temp_string])
	    free_gmax[temp_string] = general_val["gmax",general_index["gmax",free_ref[temp_string]]]
	if (!free_mix[temp_string])
	    free_mix[temp_string] = general_val["mix",general_index["mix",free_ref[temp_string]]]
    }
    # Use do and except keywords to determine which structures to run.
    # Default : only new (not calculated) structures
    print "[info|free] Determining which structures to run..."
    if (!free_dolines){
	free_dolines = 1
	free_doline[1] = "new"
	free_dotype[1] = "do"
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=free_dolines;i++){
	temp_val = split(free_doline[i],temp_array," ")
	for (j=1; j<=temp_val; j++){
	    if (temp_array[j] ~ /all/ && free_dotype[i] ~ /do/){
		for (k=1; k<=global_atomnames; k++){
		    free_do[global_atomname[k]] = 1
		}
		continue
	    }
	    if (temp_array[j] ~ /none/ && free_dotype[i] ~ /do/){
		for (k=1; k<=global_atomnames; k++){
		    free_do[global_atomname[k]] = ""
		}
		continue
	    }
	    if (temp_array[j] ~ /old/ && free_dotype[i] ~ /do/){
		for (k=1; k<=global_atomnames; k++){
		    if (free_done[global_atomname[k]]){
			free_do[global_atomname[k]] = 1
		    }
		}
		continue
	    }
	    if (temp_array[j] ~ /new/ && free_dotype[i] ~ /do/){
		for (k=1; k<=global_atomnames; k++){
		    if (!free_done[global_atomname[k]]){
			free_do[global_atomname[k]] = 1
		    }
		}
		continue
	    }
	    if (free_dotype[i] ~ /do/)
		free_do[temp_array[j]] = 1
	    else
		free_do[temp_array[j]] = ""
	}
    }
    # Run over different atoms
    for (i=1;i<=global_atomnames;i++){
	# Read atom name and do the calc. if required
	free_atomname = tolower(global_atomname[i])
	if (free_do[free_atomname]){
	    # Time count
	    free_time[free_atomname] = systime()
	    # Load structure + heading
	    print "[info|free] ----------------------------------------------------------"
	    print "[info|free] Calculating atom : " free_atomname
	    # Create (or clean) free directory
	    print "[info|free] Creating free directory..."
	    mysystem("mkdir " global_root "-free-" free_atomname "  > /dev/null 2>&1")
	    mysystem("rm -rf " global_root "-free-" free_atomname "/* > /dev/null 2>&1")
	    # Copy .machines file if parallel
	    if (global_parallel)
		mysystem("cp -f " global_machines " " global_root "-free-" free_atomname "/machines")
	    # Create free input
	    print "[info|free] Creating free .wien..."
	    free_filename = global_root "-free-" free_atomname "/" global_root "-free-" free_atomname ".wien"

	    if (global_parallel)
		print "parallel " global_pwd "/" global_root "-free-" free_atomname "/machines" > free_filename
	    print "general" > free_filename
	    print "  lattice F" > free_filename
	    print "  equiv list " free_atomname > free_filename
	    print "    0.00 0.00 0.00 " > free_filename
	    print "  end equiv list " > free_filename
	    print "  cell parameters " free_cell[free_atomname] " " free_cell[free_atomname] " " free_cell[free_atomname] " 90 90 90 " > free_filename
	    print "  title " general_title ", in vacuo " free_atomname " calc. " > free_filename
	    print "  spinpolarized " free_spinpolarized[free_atomname] > free_filename
	    print "  rmt 1 " free_rmt[free_atomname] > free_filename
	    print "  npt 1      " free_npt[free_atomname] > free_filename
	    print "  r0 1       " free_r0[free_atomname] > free_filename
	    print "  rkmax      " free_rkmax[free_atomname] > free_filename
	    print "  lmax       " free_lmax[free_atomname] > free_filename
	    print "  lnsmax     " free_lnsmax[free_atomname] > free_filename
	    print "  gmax       " free_gmax[free_atomname] > free_filename
	    print "  mix        " free_mix[free_atomname] > free_filename
	    print "  kpts         1 " > free_filename
	    print "end general" > free_filename
	    print "initialization" > free_filename
	    print "  xcpotential "free_potential[free_atomname] > free_filename
	    print "  ecoreval "free_ecoreval[free_atomname] > free_filename
	    print "  energymin "free_energymin[free_atomname] > free_filename
	    print "  energymax "free_energymax[free_atomname] > free_filename
	    print "  fermi " free_fermi[free_atomname] " " free_fermival[free_atomname] > free_filename
	    print "  orbitals 1 " free_orbital_globe[free_atomname] " " free_orbital_globapw[free_atomname]> free_filename
	    for (k=1;k<=free_orbitals[free_atomname];k++){
		print "   ",free_orbital_l[free_atomname,k],free_orbital_energy[free_atomname,k],free_orbital_var[free_atomname,k],free_orbital_cont[free_atomname,k],free_orbital_apw[free_atomname,k] > free_filename
	    }
	    print "  end orbitals " > free_filename
	    if (free_lms[free_atomname]){
		print "  lm list 1 " > free_filename
		temp_string = ""
		for (k=1;k<=free_lms[free_atomname];k++){
		    temp_string = temp_string "  " free_lm_l[free_atomname,k] " " free_lm_m[free_atomname,k]
		}
		print temp_string > free_filename
		print "  end lm list " > free_filename
	    }
	    print "end initialization" > free_filename
	    print "prescf " > free_filename
	    if (free_nice[free_atomname])
		print "  nice " free_nice[free_atomname] > free_filename
	    print "end prescf " > free_filename
	    print "scf " > free_filename
	    if (free_itdiag[free_atomname])
		print "  itdiag " free_itdiag[free_atomname] > free_filename
	    if (free_nice[free_atomname])
		print "  nice " free_nice[free_atomname] > free_filename
	    print "  max iterations " free_miter[free_atomname] > free_filename
	    if (free_cc[free_atomname])
		print "  charge conv " free_cc[free_atomname] > free_filename
	    if (free_ec[free_atomname])
		print "  energy conv " free_ec[free_atomname] > free_filename
	    if (free_fc[free_atomname])
		print "  force conv " free_fc[free_atomname] > free_filename
	    if (free_in1new[free_atomname])
		print "  new in1 " free_in1new[free_atomname] > free_filename
	    print "end scf " > free_filename
	    print "synopsis " > free_filename
	    print " exhaustive " > free_filename
	    print "end synopsis " > free_filename
	    if (free_clean)
		print free_clean > free_filename
	    close(free_filename)

	    # Run runwien.awk on the .wien
	    if (!free_nosend[free_atomname]){
		print "[info|free] Running free calculation..."
		## Build running script
		print "#! /bin/bash" > "free-script"
		print "cd " global_root "-free-" free_atomname "/" > "free-script"
		print "runwien.awk " global_root "-free-" free_atomname ".wien > " const_freerunout " 2>&1" > "free-script"
		close("free-script")
		mysystem("chmod u+x free-script")
		## Do it!
		mysystem("./free-script")
		mysystem("rm -f free-script")
		if (checkexists(global_root "-free-" free_atomname "/synopsis.out")){
		    if (!isin(global_root "-free-" free_atomname "/synopsis.out",global_file_out)){
			global_file_out_n++
			global_file_out[global_file_out_n] = global_root "-free-" free_atomname "/synopsis.out"
		    }
		}
	    }
	    # Extract info from scf file
	    print "[info|free] Extracting info from scf files..."
	    if (checkexists(global_root "-free-" free_atomname "/" global_root "-free-" free_atomname "1/" global_root "-free-" free_atomname "1.scf")){
		temp_string = const_lapwgetetotalexe " " global_root "-free-" free_atomname "/" global_root "-free-" free_atomname "1/" global_root "-free-" free_atomname "1.scf"
		temp_string | getline free_fratenergy[free_atomname]
		close(temp_string)
	    }
	    # Marking as done
	    print "[info|free] Marking as done..."
	    free_done[free_atomname] = 1
	    # Time count
	    free_time[free_atomname] = systime() - free_time[free_atomname]
	    # Generate checkpoint
	    print "[info|free] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    free_savecheck(global_root "-check/free.check")
	}
    }
    # Check if I can build up the dissociation energy
    free_frtotalenergy = 0
    for (i=1;i<=global_nneq;i++){
	free_frtotalenergy += global_molatoms[i] * free_fratenergy[tolower(global_atom[i])]
	if (!free_fratenergy[tolower(global_atom[i])]){
	    free_frtotalenergy = ""
	    break
	}
    }
    # Get end time
    free_totaltime = systime() - free_totaltime
    # Generate checkpoint
    print "[info|free] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    free_savecheck(global_root "-check/free.check")

    # End message
    print "[info|free] Free section ended successfully..."
    printf "\n"
    next
}
# (xprhox) Printrho section final tasks
/^( |\t)*end( |\t)*printrho( |\t)*$/ && global_section=="printrho"{
    global_section = ""
    prho_run = 1
    print ""
    print "[info|prho] Beginning of printrho section at " date()
    # Verify needed sections were run
    print "[info|prho] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|prho] cannot run printrho."
	print "[error|prho] needed section has not been run or loaded."
	exit 1
    }
    print "[info|prho] Checking for executables..."
    delete temp_array
    temp_array[const_lapw5exe] = temp_array[const_lapw5cexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|prho] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    prho_totaltime = systime()
    # Set default variales
    print "[info|prho] Setting default variables if missing..."
    if (!prho_rho){
	prho_rho = "totalrho"
    }
    if (!prho_nsh_x){
	prho_nsh_x = 3
	prho_nsh_y = 3
	prho_nsh_z = 3
    }
    if (!prho_npt_x){
	prho_npt_x = 100
	prho_npt_y = 100
    }
    if (!(prho_zmin "")){
	prho_zmin = "*"
    }
    if (!(prho_zmax "")){
	prho_zmax = "*"
    }
    if (!prho_type){
	prho_type = "3d"
    }
    if (!prho_scale){
	prho_scale = "normal"
    }
    if (!prho_dc){
	prho_dc = 20
    }
    ## Set default points for origin, xend, yend
    if (!prho_den0){
	prho_x0 = 0
	prho_y0 = 0
	prho_z0 = 0
	prho_den0 = 1
    }
    if (!prho_xend_den){
	prho_xend_x = 1
	prho_xend_y = 0
	prho_xend_z = 0
	prho_xend_den = 1
    }
    if (!prho_yend_den){
	prho_yend_x = 0
	prho_yend_y = 1
	prho_yend_z = 0
	prho_yend_den = 1
    }
    # Use do and not keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|prho] Determining which structures to run..."
    if (!prho_dolines){
	if (!global_dolines){
	    prho_dolines = 1
	    prho_doline[1] = "new"
	    prho_dotype[1] = "do"
	}
	else{
	    prho_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		prho_doline[i] = global_doline[i]
		prho_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=prho_dolines;i++){
	list_parser(prho_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && prho_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    prho_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && prho_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    prho_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && prho_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    prho_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && prho_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    prho_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (prho_dotype[i] ~ /do/){
		    prho_do[k] = 1
		}
		else{
		    prho_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|prho] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (prho_do[i]){
		print "[warn|prho] structure " i " cannot be run..."
		prho_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (prho_do[i]){
	    # Time count
	    prho_time[i] = systime()
	    # Load structure + heading
	    print "[info|prho] ----------------------------------------------------------"
	    print "[info|prho] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (global_complex || so_done[i])
		local_complex = "-c"
	    else
		local_complex = ""
	    if (global_ldau && !prescf_ldau_not[i])
		local_orb = "-orb"
	    else
		local_orb = ""
	    if (so_done[i])
		local_so = "-so"
	    else
		local_so = ""
	    # Copy .machines file if it is a parallel run
	    if (global_parallel)
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # Modify .in2 to the new emin and store old value, if it is provided
	    if ((prho_emin "")){
		print ("[info|prho] Modifying .in2 file...")
		mysystem(const_lapwmodifyin2exe " " temp_root temp_name ".in2"(local_complex?"c":"")" auto " prho_emin)
		# Recalculate valence desnity
		print "[info|prho] Recalculating valence density..."
		if (global_spinpolarized == "no"){
		    mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
		    if (local_orb)
			mysystem(temp_prepath const_xlapwexe " orb > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " > errfile 2>&1")
		}
		else{
		    mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
		    if (local_orb){
			mysystem(temp_prepath const_xlapwexe " orb " global_parallel " -up > errfile 2>&1")
			mysystem(temp_prepath const_xlapwexe " orb " global_parallel " -dn > errfile 2>&1")
		    }
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " -dn > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -dn > errfile 2>&1")
		}
		## No error checks for now
		mysystem(temp_prepath "mv -f errfile " temp_name ".prho.lapw2.err")
	    }
	    # Create potential files if necessary
	    if (prho_rho == "vcoul" || prho_rho == "vtotal" || prho_rho == "vxc"){
		print "[info|prho] Calculating potential with lapw0..."
		mysystem(const_lapwmodifyin0exe " " temp_root temp_name ".in0 1")
		mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
		mysystem(const_lapwmodifyin0exe " " temp_root temp_name ".in0 0")
		mysystem(temp_prepath "mv -f errfile " temp_name ".prho.lapw0.err")
		mysystem(temp_prepath "rm -f lapw0.def > /dev/null 2>&1")
	    }
	    # Calculate promolecular density if necessary. init is run so it is consistent
	    if (prho_rho == "atomic"){
		print "[info|prho] Calculating superposition of atomic densities..."
		temp_string = temp_root "lstart-script"
		print "x lstart -sigma << --eof--" > temp_string
		if (init_potential == "lsda")
		    print "5" > temp_string
		else if (init_potential == "ggawc06")
		    print "11" > temp_string
		else if (init_potential == "ggapbe96")
		    print "13" > temp_string
		else if (init_potential == "ggapw91")
		    print "14" > temp_string
		else if (init_potential == "ggapbesol")
		    print "19" > temp_string
		print init_ecoreval > temp_string
		print "--eof--" > temp_string
		close(temp_string)
		mysystem(temp_prepath "chmod u+x lstart-script")
		mysystem(temp_prepath "./lstart-script > /dev/null 2>&1")
		mysystem(temp_prepath "rm -f lstart-script")
	    }
	    # Create .in5 input file
	    print "[info|prho] Creating .in5"(local_complex?"c":"")" file..."
	    temp_string = temp_root temp_name ".in5"(local_complex?"c":"")
	    printf "%i %i %i %i \n", prho_x0,prho_y0,prho_z0,prho_den0 > temp_string
	    printf "%i %i %i %i \n", prho_xend_x,prho_xend_y,prho_xend_z,prho_xend_den > temp_string
	    printf "%i %i %i %i \n", prho_yend_x,prho_yend_y,prho_yend_z,prho_yend_den > temp_string
	    printf "%i %i %i \n", prho_nsh_x,prho_nsh_y,prho_nsh_z > temp_string
	    printf "%i %i \n", prho_npt_x,prho_npt_y > temp_string

	    if (global_spinpolarized == "yes"){
		if (prho_rho == "spin" || prho_rho == "deform")
		    print "RHO SUB " > temp_string
		else if (prho_rho == "vcoul" || prho_rho == "vxc" || prho_rho == "vtotal")
		    print "RHO     " > temp_string
		else
		    print "RHO ADD " > temp_string
	    }
	    else{
		if (prho_rho == "deform")
		    print "RHO SUB " > temp_string
		else if (prho_rho == "atomic")
		    print "RHO ADD " > temp_string
		else
		    print "RHO     " > temp_string
	    }

	    if (prho_rho == "valrho" || prho_rho == "vcoul" || prho_rho == "vxc" || prho_rho == "vtotal")
		print "ATU VAL NODEBUG" > temp_string
	    else if (prho_rho == "totalrho" || prho_rho == "spin" || prho_rho == "atomic" || prho_rho == "deform")
		print "ATU TOT NODEBUG" > temp_string
	    print "NOORTHO" > temp_string
	    close(temp_string)
	    # Create lapw5.def
	    print "[info|prho] Creating lapw5.def..."
	    mysystem(temp_prepath const_xlapwexe " lapw5 " local_complex " -d > /dev/null 2>&1")
	    if (global_spinpolarized == "yes"){
		if (prho_rho == "totalrho"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmdn")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmup")
		}
		else if (prho_rho == "valrho"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmvaldn")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmvalup")
		}
		else if (prho_rho == "vcoul")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".vcoul")
		else if (prho_rho == "vxc")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".r2v")
		else if (prho_rho == "vtotal")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".vtotal")
		else if (prho_rho == "spin"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmdn")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmup")
		}
		else if (prho_rho == "atomic"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmdn.atomic")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmup.atomic")
		}
		else if (prho_rho == "deform"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmsum")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmsum.atomic")
		}
	    }
	    else{
		if (prho_rho == "totalrho")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmsum")
		else if (prho_rho == "valrho")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmval")
		else if (prho_rho == "vcoul")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".vcoul")
		else if (prho_rho == "vxc")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".r2v")
		else if (prho_rho == "vtotal")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".vtotal")
		else if (prho_rho == "atomic")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmsum.atomic")
		else if (prho_rho == "deform"){
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 9 " temp_name ".clmsum")
		    mysystem(temp_prepath const_lapwlapw5defmodifyexe " lapw5.def 11 " temp_name ".clmsum.atomic")
		}
	    }
	    # Calculate rho plot
	    print "[info|prho] Calculating rho map..."
	    if (local_complex)
		mysystem(temp_prepath const_lapw5cexe " lapw5.def > errfile 2>&1")
	    else
		mysystem(temp_prepath const_lapw5exe " lapw5.def > errfile 2>&1")
	    ## No error checks for now
	    mysystem(temp_prepath "mv -f errfile " temp_name ".prho.lapw5.err")
	    mysystem(temp_prepath "rm -f lapw5.def > /dev/null 2>&1")
	    # Reformatting rho
	    print "[info|prho] Reformatting rho..."
	    temp_x0 = prho_x0 / prho_den0
	    temp_y0 = prho_y0 / prho_den0
	    temp_z0 = prho_z0 / prho_den0
	    temp_x1 = prho_xend_x / prho_xend_den
	    temp_y1 = prho_xend_y / prho_xend_den
	    temp_z1 = prho_xend_z / prho_xend_den
	    temp_x2 = prho_yend_x / prho_yend_den
	    temp_y2 = prho_yend_y / prho_yend_den
	    temp_z2 = prho_yend_z / prho_yend_den
	    temp_lx = distance(temp_x0,temp_y0,temp_z0,temp_x1,temp_y1,temp_z1)
	    temp_ly = distance(temp_x0,temp_y0,temp_z0,temp_x2,temp_y2,temp_z2)
	    ## scalar product of (x1-x0) and (x2-x0)
	    temp_val = 0.5*(temp_lx*temp_lx + temp_ly*temp_ly - distance(0,0,0,temp_x2-temp_x1,temp_y2-temp_y1,temp_z2-temp_z1)^2)
	    temp_val = temp_val / temp_lx / temp_ly

	    mysystem(temp_prepath const_reformatexe " < " temp_name ".rho > " temp_name ".rho.temp")
	    mysystem(const_lapwprhoreformatexe " " temp_root temp_name ".rho.temp " temp_lx " " temp_ly " " temp_val " " prho_npt_x " " prho_npt_y " " prho_scale " " (prho_zmin=="*"?"a":prho_zmin) " " (prho_zmax=="*"?"a":prho_zmax) " > " temp_root temp_name ".rhoplot." prho_rho ".xyz")
	    mysystem("rm -f " temp_root temp_name ".rho.temp")

	    # Plot to file
	    print "[info|prho] Plotting rho to file..."
	    print "set title '" general_title " (" prho_rho ")'" > temp_file
	    print "set style data lines" > temp_file
	    print "set noxtics" > temp_file
	    print "set noytics" > temp_file
	    print "set zrange [" prho_zmin ":" prho_zmax "]" > temp_file
	    print "set nokey" > temp_file
	    print "set hidden3d" > temp_file
	    print "set contour base" > temp_file
	    print "set cntrparam levels auto " prho_dc > temp_file
	    print "set size ratio -1" > temp_file
	    print "set view 60,30,1.2" > temp_file
	    if (prho_type == "c"){
		print "set lmargin 0" > temp_file
		print "set bmargin 0" > temp_file
		print "set tmargin 0" > temp_file
		print "set rmargin 0" > temp_file
		print "set nosurface" > temp_file
		print "set view 0,0,1" > temp_file
		if (!prho_nolabels){
		    print "set key" > temp_file
		}
	    }
	    print "set terminal postscript eps enhanced color 'Helvetica' 20" > temp_file
	    print "set output '" temp_name ".rhoplot." prho_rho ".ps'" > temp_file
	    print "splot '" temp_name ".rhoplot." prho_rho ".xyz' with lines lt 0" > temp_file
	    close(temp_file)
	    mysystem(temp_prepath const_gnuplotexe " " temp_file " > errfile 2>&1")
	    mysystem(temp_prepath "mv " temp_file " " temp_name ".rhoplot." prho_rho ".gnuplot")
	    ## No error checks for now
	    mysystem(temp_prepath "mv -f errfile " temp_name ".rhoplot.err")
	    # Put emin back in .in2
	    if ((prho_emin "")){
		print "[info|prho] Restoring .in2 file..."
		mysystem(temp_prepath const_lapwmodifyin2exe " " temp_name ".in2"(local_complex?"c":"")" auto " init_eminin2)
		# Recalculate density
		print "[info|prho] Recalculating density..."
		if (global_spinpolarized == "no"){
		    mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
		    if (local_orb)
			mysystem(temp_prepath const_xlapwexe " orb > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " > errfile 2>&1")
		}
		else{
		    mysystem(temp_prepath const_xlapwexe " lapw0 " global_parallel " > errfile 2>&1")
		    if (local_orb){
			mysystem(temp_prepath const_xlapwexe " orb " global_parallel " -up > errfile 2>&1")
			mysystem(temp_prepath const_xlapwexe " orb " global_parallel " -dn > errfile 2>&1")
		    }
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_orb " " local_complex " " global_parallel " -dn > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -up > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -dn > errfile 2>&1")
		}
		## No error checks for now
		mysystem(temp_prepath "mv -f errfile " temp_name ".prho2.lapw2.err")
	    }
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|prho] Marking as done..."
	    prho_done[i] = 1
	    # Time count
	    prho_time[i] = systime() - prho_time[i]
	    # Generate checkpoint
	    print "[info|prho] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    prho_savecheck(global_root "-check/prho.check")
	}
    }
    ## Write down ps and gnuplot files
    temp_command = "ls " global_root "*/*.rhoplot." prho_rho ".ps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    close(temp_string)
    temp_command = "ls " global_root "*/*.rhoplot." prho_rho ".gnuplot"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_gnuplot)){
	    global_file_gnuplot_n++
	    global_file_gnuplot[global_file_gnuplot_n] = temp_string
	}
    }
    close(temp_string)
    # Get end time
    prho_totaltime = systime() - prho_totaltime
    # Generate checkpoint
    print "[info|prho] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    prho_savecheck(global_root "-check/prho.check")
    # End message
    print "[info|prho] Printrho section ended successfully..."
    printf "\n"
    next
}
# (xdosx) Dosplot section final tasks
/^( |\t)*end( |\t)*dosplot( |\t)*$/ && global_section=="dosplot"{
    global_section = ""
    dos_run = 1
    print ""
    print "[info|dos] Beginning of dosplot section at " date()
    # Verify needed sections were run
    print "[info|dos] Verifying needed sections were run"
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|dos] cannot run dosplot."
	print "[error|dos] needed section has not been run or loaded."
	exit 1
    }
    print "[info|dos] Checking for executables..."
    delete temp_array
    temp_array[const_reformatexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|dos] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    dos_totaltime = systime()
    # Set default variales
    ## dos_plotxmin and dos_plotxmax defaults are structure dependent
    print "[info|dos] Setting default variables if missing..."
    if (!dos_plotunits){
	dos_plotunits = "ry"
    }
    if (!(dos_plotxmin "")){
	dos_plotxmin = "*"
    }
    if (!(dos_plotxmax "")){
	dos_plotxmax = "*"
    }
    if (!(dos_energymin "")){
	dos_energymin_flag = 1
    }
    if (!(dos_energymax "")){
	dos_energymax_flag = 1
    }
    if (!dos_de){
	dos_de = 0.0025
    }
    if (!dos_broad){
	dos_broad = 0.003
    }
    if (!dos_ndos){
	dos_ndos = 1
	dos_dos_atom[1] = "0"
	dos_dos_descr[1] = "1"
	dos_dos_label[1] = "tot"
    }
    if (!dos_spin){
	dos_spin = "new"
    }
    for (i=1;i<=dos_ndos;i++){
	if (!dos_dos_label[i])
	    dos_dos_label[i] = "unknown"
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|dos] Determining which structures to run..."
    if (!dos_dolines){
	if (!global_dolines){
	    dos_dolines = 1
	    dos_doline[1] = "new"
	    dos_dotype[1] = "do"
	}
	else{
	    dos_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		dos_doline[i] = global_doline[i]
		dos_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=dos_dolines;i++){
	list_parser(dos_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && dos_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    dos_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && dos_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    dos_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && dos_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    dos_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && dos_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    dos_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (dos_dotype[i] ~ /do/){
		    dos_do[k] = 1
		}
		else{
		    dos_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|dos] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (dos_do[i]){
		print "[warn|dos] structure " i " cannot be run..."
		dos_do[i] = ""
	    }
    }
    # Run over structures
    for (i=1;i<=general_iterations;i++){
	if (dos_do[i]){
	    # Time count
	    dos_time[i] = systime()
	    # Load structure + heading
	    print "[info|dos] ----------------------------------------------------------"
	    print "[info|dos] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (global_complex || so_done[i])
		local_complex = "-c"
	    else
		local_complex = ""
	    if (global_ldau && !prescf_ldau_not[i])
		local_orb = "-orb"
	    else
		local_orb = ""
	    if (so_done[i])
		local_so = "-so"
	    else
		local_so = ""
	    # Set default variables, structure dependent
	    print "[info|dos] Setting default variables for this structure..."
	    if (dos_energymin_flag || dos_energymax_flag){
		if (dos_energymin_flag)
		    if (so_bandemin[i]+0)
			dos_energymin = so_bandemin[i]
		    else
			dos_energymin = scf_bandemin[i]
		if (dos_energymax_flag)
		    if (so_bandemax[i]+0)
			dos_energymax = so_bandemax[i]
		    else
			dos_energymax = scf_bandemax[i]
	    }
	    if (!(dos_energymin+0))
		dos_energymin = -2.0
	    if (!(dos_energymax+0))
		dos_energymax = 1.0
	    # Copy .machines file if it is a parallel run
	    if (global_parallel)
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # Expand eigenvalue window
	    if (dos_in1maxenergy){
		print "[info|dos] Expanding eigenvalue window (lapw1)..."
		mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1" (local_complex?"c":"") " " global_nneq " auto auto " dos_in1maxenergy " auto  auto")
		if (global_spinpolarized == "no"){
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		}
		else{
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -dn > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -up > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		}
		## No error checks for now
		mysystem(temp_prepath "mv -f errfile " temp_name ".dos.lapw1.err")
	    }
	    else if (!checkvector(temp_name,temp_name)){
		print "[info|dos] .vector file not found, recalculating (lapw1)..."
		if (global_spinpolarized == "no"){
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
		}
		else{
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -dn > errfile 2>&1")
		    mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -up > errfile 2>&1")
		    if (local_so)
			mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
		}
		## No error checks for now
		mysystem(temp_prepath "mv -f errfile " temp_name ".dos.lapw1.err")
	    }

	    # Calculate partial charges
	    print "[info|dos] Calculating partial charges (lapw2 -qtl)..."
	    if (global_spinpolarized == "no"){
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl > errfile 2>&1")
	    }
	    else{
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl -up > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl -dn > errfile 2>&1")
	    }
	    if (checkerror(temp_root "errfile","checkword","FERMI - Error")){
		print "[warn|dos] Structure " i " failed in lapw2..."
		print "[warn|dos] Fermi error"
		dos_done[i] = ""
		dos_time[i] = 0
		continue
	    }
	    mysystem(temp_prepath "mv -f errfile " temp_name ".dos.lapw2.err")
	    # Creating tetra input file
	    print "[info|dos] Creating .int input file..."
	    temp_string = temp_root temp_name ".int"
	    print general_title > temp_string
	    print dos_energymin " " dos_de " " dos_energymax " " dos_broad > temp_string
	    print dos_ndos > temp_string
	    for (j=1;j<=dos_ndos;j++){
		printf "%5i%5i   %6s\n",dos_dos_atom[j],dos_dos_descr[j],dos_dos_label[j] > temp_string
	    }
	    close(temp_string)
	    # Running tetra
	    print "[info|dos] Running tetra..."
	    if (global_spinpolarized == "no")
		mysystem(temp_prepath const_xlapwexe " tetra > errfile 2>&1")
	    else{
		mysystem(temp_prepath const_xlapwexe " tetra -dn > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " tetra -up > errfile 2>&1")
	    }
	    ## No error checks for now
	    mysystem(temp_prepath "mv -f errfile " temp_name ".tetra.err")

	    # Eliminate zeros in .dosxx files -> allows gnuplot to shrink the x axis
	    temp_val = (dos_ndos-1) % 7
	    temp_val = (dos_ndos-1-temp_val) / 7 + 1
	    for (j=1;j<=temp_val;j++){
		if (global_spinpolarized == "no"){
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "ev > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "ev")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j " > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "")
		}
		else{
		    mysystem(temp_prepath const_lapwdossumexe " " temp_name ".dos" j "evup " temp_name ".dos" j "evdn > " temp_name ".dos" j "ev")
		    mysystem(temp_prepath const_lapwdossumexe " " temp_name ".dos" j "up " temp_name ".dos" j "dn > " temp_name ".dos" j)
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "evup > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "evup")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "up > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "up")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "evdn > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "evdn")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "dn > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "dn")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j "ev > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j "ev")
		    mysystem(temp_prepath const_lapwdosreformatexe " " temp_name ".dos" j " > " temp_file)
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dos" j)
		}
	    }
	    # Plotting dos
	    print "[info|dos] Making dos plots..."
	    for (j=0;j<dos_ndos;j++){
		temp_val = sprintf("%i",j % 7)
		temp_val2 = sprintf ("%i",(j-temp_val) / 7 + 1)
		temp_val = temp_val + 2

		# Compose gnuplot script
		print "set style data lines" > temp_file
		if (dos_plotunits == "ev")
		    print "set yzeroaxis lt 2" > temp_file
		else
		    print "set arrow from " scf_efermi[i] ",0 to first " scf_efermi[i] ", graph 1 nohead lt 2" > temp_file
		print "set terminal postscript eps enhanced color 'Helvetica' 20" > temp_file
		if (global_spinpolarized == "no"){
		    print "set title '" general_title " (" dos_dos_label[j+1] ")'" > temp_file
		    print "set output '" temp_name ".dosplot." j+1 ".ps'" > temp_file
		    if (dos_plotunits == "ev"){
			print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
			print "set xlabel 'E (eV)'" > temp_file
			print "plot '"temp_name ".dos" temp_val2 "ev' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
		    }
		    else{
			print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
			print "set xlabel 'E (Ry)'" > temp_file
			print "plot '"temp_name ".dos" temp_val2 "' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
		    }
		}
		else{
		    if (dos_spin == "no" || dos_spin == "new"){
			print "set title '" general_title " (" dos_dos_label[j+1] ",up)'" > temp_file
			print "set output '" temp_name ".dosplot." j+1 "up.ps'" > temp_file
			if (dos_plotunits == "ev"){
			    print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
			    print "set xlabel 'E (eV)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "evup' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			}
			else{
			    print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
			    print "set xlabel 'E (Ry)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "up' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			}
			print "set title '" general_title " (" dos_dos_label[j+1] ",dn)'" > temp_file
			print "set output '" temp_name ".dosplot." j+1 "dn.ps'" > temp_file
			if (dos_plotunits == "ev"){
			    print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
			    print "set xlabel 'E (eV)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "evdn' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			}
			else{
			    print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
			    print "set xlabel 'E (Ry)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "dn' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			}
			if (dos_spin == "new"){
			    print "set title '" general_title " (" dos_dos_label[j+1] ",total)'" > temp_file
			    print "set output '" temp_name ".dosplot." j+1 ".ps'" > temp_file
			    if (dos_plotunits == "ev"){
				print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
				print "set xlabel 'E (eV)'" > temp_file
				print "plot '"temp_name ".dos" temp_val2 "ev' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			    }
			    else{
				print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
				print "set xlabel 'E (Ry)'" > temp_file
				print "plot '"temp_name ".dos" temp_val2 "' using 1:" temp_val " title '" dos_dos_label[j+1] "'" > temp_file
			    }
			}
		    }
		    else{
			print "set title '" general_title " (" dos_dos_label[j+1] ")'" > temp_file
			print "set output '" temp_name ".dosplot." j+1 ".ps'" > temp_file
			if (dos_plotunits == "ev"){
			    print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
			    print "set xlabel 'E (eV)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "ev' using 1:" temp_val " title '" dos_dos_label[j+1] "', "\
				"'"temp_name ".dos" temp_val2 "evup' using 1:" temp_val " title '" dos_dos_label[j+1] "(up)', "\
				"'"temp_name ".dos" temp_val2 "evdn' using 1:" temp_val " title '" dos_dos_label[j+1] "(dn)'" > temp_file
			}
			else{
			    print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
			    print "set xlabel 'E (Ry)'" > temp_file
			    print "plot '"temp_name ".dos" temp_val2 "' using 1:" temp_val " title '" dos_dos_label[j+1] "', "\
				"'"temp_name ".dos" temp_val2 "up' using 1:" temp_val " title '" dos_dos_label[j+1] "(up)', "\
				"'"temp_name ".dos" temp_val2 "dn' using 1:" temp_val " title '" dos_dos_label[j+1] "(dn)'" > temp_file
			}

		    }
		}
		close(temp_file)

		mysystem(temp_prepath const_gnuplotexe " " temp_file " > errfile 2>&1")
		if (global_spinpolarized == "no")
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dosplot." j+1 ".gnuplot")
		else{
		    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dosplot." j+1 ".gnuplot")
		}
		# no error checks for now
		mysystem("rm -f errfile")
	    }
	    # Plotting joint dos
	    print "[info|dos] Making joint dos plots..."
	    for (j=1;j<=dos_joins;j++){
		print "set style data lines" > temp_file
		if (dos_plotunits == "ev")
		    print "set yzeroaxis lt 2" > temp_file
		else
		    print "set arrow from " scf_efermi[i] ",0 to first " scf_efermi[i] ", graph 1 nohead lt 2" > temp_file
		print "set terminal postscript eps enhanced color 'Helvetica' 20" > temp_file
		print "set title '" general_title " (join plot, " j ")'" > temp_file
		print "set output '" temp_name ".dosplot.join" j".ps'" > temp_file
		if (dos_plotunits == "ev"){
		    print "set xrange [" (dos_plotxmin=="*"?"*":dos_plotxmin*const_rytoev) ":" (dos_plotxmax=="*"?"*":dos_plotxmax*const_rytoev) "]" > temp_file
		    print "set xlabel 'E (eV)'" > temp_file
		}
		else{
		    print "set xrange [" dos_plotxmin ":" dos_plotxmax "]" > temp_file
		    print "set xlabel 'E (Ry)'" > temp_file
		}
		temp_string = "plot "
		for (k=1;k<=dos_join_n[j];k++){
		    if (k > 1)
			temp_string = temp_string " , "
		    temp_val = sprintf("%i",(dos_join[j,k]-1) % 7)
		    temp_val2 = sprintf("%i",((dos_join[j,k]-1)-temp_val) / 7 + 1)
		    temp_val = temp_val + 2
		    temp_string = temp_string "'"temp_name ".dos" temp_val2 (dos_plotunits=="ev"?"ev":"") dos_join_flag[j,k] "' using 1:($" temp_val ")*" dos_join_mult[j,k] " title '" dos_dos_label[dos_join[j,k]] "(" dos_join_flag[j,k] ")' w lines"
		}
		print temp_string > temp_file
		close(temp_file)

		mysystem(temp_prepath const_gnuplotexe " " temp_file " > errfile 2>&1")
		mysystem(temp_prepath "mv -f " temp_file " " temp_name ".dosplot.join" j ".gnuplot")
		# no error checks for now
		mysystem(temp_prepath "rm -f errfile")
	    }
	    # Extract N(ef)
	    print "[info|dos] Extracting DOS at the fermi level (Ry-1)..."
	    for (j=0;j<dos_ndos;j++){
		if (dos_dos_atom[j+1]+0 == 0 && dos_dos_descr[j+1]+0 == 1){
		    temp_val = sprintf("%i",j % 7)
		    temp_val2 = sprintf ("%i",(j-temp_val) / 7 + 1)
		    temp_val = temp_val + 2
		    temp_command = temp_prepath const_lapwgetdosef " " temp_name ".dos" temp_val2 " " (temp_val-1)
		    temp_command | getline dos_nef[i]
		    close(temp_command)
		    break
		}		
	    }	    
	    # Restore .in1
	    print "[info|dos] Restoring original .in1..."
	    mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1" (local_complex?"c":"") " " global_nneq " auto auto " init_energymax " auto  auto")
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|dos] Marking as done..."
	    dos_done[i] = 1
	    # Time count
	    dos_time[i] = systime() - dos_time[i]
	    # Generate checkpoint
	    print "[info|dos] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    dos_savecheck(global_root "-check/dos.check")
	}
    }
    ## Write down ps and gnuplot files
    temp_command = "ls " global_root "*/*.dosplot.*.ps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    close(temp_string)
    temp_command = "ls " global_root "*/*.dosplot.*.gnuplot"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_gnuplot)){
	    global_file_gnuplot_n++
	    global_file_gnuplot[global_file_gnuplot_n] = temp_string
	}
    }
    close(temp_string)
    # Get end time
    dos_totaltime = systime() - dos_totaltime
    # Generate checkpoint
    print "[info|dos] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    dos_savecheck(global_root "-check/dos.check")
    # End message
    print "[info|dos] Dosplot section ended successfully..."
    printf "\n"
    next
}
# (xrxx) Rxplot section final tasks
/^( |\t)*end( |\t)*rxplot( |\t)*$/ && global_section=="rxplot"{
    global_section = ""
    rx_run = 1
    print ""
    print "[info|rx] Beginning of rxplot section at " date()
    # Verify needed sections were run
    print "[info|rx] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|rx] cannot run rxplot."
	print "[error|rx] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    rx_totaltime = systime()
    # Set default variales
    print "[info|rx] Setting default variables if missing..."
    if (!rx_atom){
	rx_atom = 1
    }
    if (!rx_n){
	rx_n = 1
    }
    if (!(rx_l "")){
	rx_l = 0
    }
    if (!(rx_plotxmin "")){
	rx_plotxmin = -2.0
    }
    if (!(rx_plotxmax "")){
	rx_plotxmax = 15.0
    }
    if (!rx_de){
	rx_de = 0.02
    }
    if (!rx_type){
	rx_type = "abs"
    }
    if (!(rx_in1maxenergy "")){
	rx_in1maxenergy = 10.0
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|rx] Determining which structures to run..."
    if (!rx_dolines){
	if (!global_dolines){
	    rx_dolines = 1
	    rx_doline[1] = "new"
	    rx_dotype[1] = "do"
	}
	else{
	    rx_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		rx_doline[i] = global_doline[i]
		rx_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=rx_dolines;i++){
	list_parser(rx_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && rx_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    rx_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && rx_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    rx_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && rx_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    rx_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && rx_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    rx_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (rx_dotype[i] ~ /do/){
		    rx_do[k] = 1
		}
		else{
		    rx_do[k] = ""
		}
	    }
	}
    }
    # Convert type to uppercase
    rx_type = toupper(rx_type)
    # Verifying section requirements structure-wise
    print "[info|rx] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (rx_do[i]){
		print "[warn|rx] structure " i " cannot be run..."
		rx_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (rx_do[i]){
	    # Time count
	    rx_time[i] = systime()
	    # Load structure + heading
	    print "[info|rx] ----------------------------------------------------------"
	    print "[info|rx] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (global_complex || so_done[i])
		local_complex = "-c"
	    else
		local_complex = ""
	    if (global_ldau && !prescf_ldau_not[i])
		local_orb = "-orb"
	    else
		local_orb = ""
	    if (so_done[i])
		local_so = "-so"
	    else
		local_so = ""
	    # Copy .machines file if it is a parallel run
	    if (global_parallel)
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # Expand eigenvalue window
	    print "[info|rx] Expanding eigenvalue window (lapw1)..."
	    mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1"(local_complex?"c":"")" " global_nneq " auto auto " rx_in1maxenergy " auto  auto")
	    if (global_spinpolarized == "no")
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " > errfile 2>&1")
		if (local_so)
		    mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
	    else{
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -up > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -dn > errfile 2>&1")
		if (local_so)
		    mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
	    }
	    # Calculate partial charges
	    print "[info|rx] Calculating partial charges (lapw2 -qtl)..."
	    if (global_spinpolarized == "no"){
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl > errfile 2>&1")
	    }
	    else{
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl -up > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " lapw2 " local_so " " local_complex " " global_parallel " -qtl -dn > errfile 2>&1")
	    }
	    if (checkerror(temp_root "errfile","checkword","FERMI - Error")){
		print "[warn|rx] Structure " i " failed in lapw2..."
		print "[warn|rx] Fermi error"
		rx_done[i] = ""
		rx_time[i] = 0
		continue
	    }
	    mysystem(temp_prepath "mv -f errfile " temp_name ".rx.lapw2.err")
	    # Create .inxs
	    print "[info|rx] Creating .inxs input file..."
	    temp_string = temp_root temp_name ".inxs"
	    print general_title > temp_string
	    print rx_atom > temp_string
	    print rx_n > temp_string
	    print rx_l > temp_string
	    print "0,0.5,0.5" > temp_string
	    print rx_plotxmin,rx_de,rx_plotxmax > temp_string
	    printf "%4s\n",rx_type > temp_string
	    print "1.00" > temp_string
	    print "2.0" > temp_string
	    print "1.50" > temp_string
	    printf "%4s\n","AUTO" > temp_string
	    print "-6.93" > temp_string
	    print "-10.16" > temp_string
	    print "-13.9" > temp_string
	    close(temp_string)
	    # Calculate spectrum
	    print "[info|rx] Running xspec..."
	    if (global_spinpolarized == "no")
		mysystem(temp_prepath const_xlapwexe " xspec > errfile 2>&1")
	    else{
		mysystem(temp_prepath const_xlapwexe " xspec -up > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " xspec -dn > errfile 2>&1")
	    }
	    ## No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".xspec.err")
	    # Print spectrum
	    print "[info|rx] Printing spectra..."
	    print "set terminal postscript eps enhanced 'Helvetica' 20" > temp_file
	    print "set output '" temp_name ".unbroad.specplot.ps' " > temp_file
	    print "set title 'Unbroadened rx spectrum'" > temp_file
	    print "set style data lines " > temp_file
	    print "set xrange [" rx_plotxmin ":" rx_plotxmax "]" > temp_file
	    print "set noytics" > temp_file
	    print "set xlabel 'Energy (eV)'" > temp_file
	    if (global_spinpolarized == "no")
		print "plot '" temp_name ".txspec' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l "'" > temp_file
	    else{
		print "plot '" temp_name ".txspecdn' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l ",dn' , " \
		    "'" temp_name ".txspecup' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l ",up'" > temp_file
	    }
	    print "set output '" temp_name ".broad.specplot.ps' " > temp_file
	    print "set title 'Broadened rx spectrum'" > temp_file
	    if (global_spinpolarized == "no")
		print "plot '" temp_name ".xspec' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l "'" > temp_file
	    else{
		print "plot '" temp_name ".xspecdn' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l ",dn' , " \
		    "'" temp_name ".xspecup' title '" global_atomfullnm[rx_atom] " n = " rx_n " l = " rx_l ",up'" > temp_file
	    }
	    close(temp_file)
	    mysystem(temp_prepath const_gnuplotexe " " temp_file " > errfile 2>&1")
	    mysystem(temp_prepath "mv -f " temp_file " " temp_name ".rxplot.gnuplot")
	    # no error checks for now
	    mysystem(temp_prepath "rm -f errfile")
	    # Restore .in1
	    print "[info|rx] Restoring original .in1..."
	    mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1"(local_complex?"c":"")" " global_nneq " auto auto " init_energymax " auto  auto")
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|rx] Marking as done..."
	    rx_done[i] = 1
	    # Time count
	    rx_time[i] = systime() - rx_time[i]
	    # Generate checkpoint
	    print "[info|rx] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    rx_savecheck(global_root "-check/rx.check")
	}
    }
    ## Write down ps and gnuplot files
    temp_command = "ls " global_root "*/*.specplot.ps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    close(temp_string)
    temp_command = "ls " global_root "*/*.rxplot.gnuplot"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_gnuplot)){
	    global_file_gnuplot_n++
	    global_file_gnuplot[global_file_gnuplot_n] = temp_string
	}
    }
    close(temp_string)
    # Get end time
    rx_totaltime = systime() - rx_totaltime
    # Generate checkpoint
    print "[info|rx] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    rx_savecheck(global_root "-check/rx.check")
    # End message
    print "[info|rx] Rxplot section ended successfully..."
    printf "\n"
    next
}
# (xbandx) Bandplot section final tasks
/^( |\t)*end( |\t)*bandplot( |\t)*$/ && global_section=="bandplot"{
    global_section = ""
    band_run = 1
    print ""
    print "[info|band] Beginning of bandplot section at " date()
    # Verify needed sections were run
    print "[info|band] Verifying needed sections were run"
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|band] cannot run bandplot."
	print "[error|band] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    band_totaltime = systime()
    # Set default variales
    print "[info|band] Setting default variables if missing..."
    if (!band_klist){
	if (global_lattice == "B")
	    band_klist = ENVIRON["WIENROOT"] "/SRC_templates/bcc.klist"
	else if (global_lattice == "F")
	    band_klist = ENVIRON["WIENROOT"] "/SRC_templates/fcc.klist"
	else if (global_lattice == "P")
	    band_klist = ENVIRON["WIENROOT"] "/SRC_templates/simple_cubic.klist"
	else if (global_lattice == "H")
	    band_klist = ENVIRON["WIENROOT"] "/SRC_templates/hcp.klist"
	else{
	    print "[error|band] No adequate templates exist for this lattice type."
	    next
	}
    }
    if (!band_in1maxenergy)
	band_in1maxenergy = init_energymax
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|band] Determining which structures to run..."
    if (!band_dolines){
	if (!global_dolines){
	    band_dolines = 1
	    band_doline[1] = "new"
	    band_dotype[1] = "do"
	}
	else{
	    band_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		band_doline[i] = global_doline[i]
		band_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=band_dolines;i++){
	list_parser(band_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && band_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    band_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && band_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    band_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && band_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    band_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && band_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    band_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (band_dotype[i] ~ /do/){
		    band_do[k] = 1
		}
		else{
		    band_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|band] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (band_do[i]){
		print "[warn|band] structure " i " cannot be run..."
		band_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (band_do[i]){
	    # Time count
	    band_time[i] = systime()
	    # Load structure + heading
	    print "[info|band] ----------------------------------------------------------"
	    print "[info|band] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (global_complex || so_done[i])
		local_complex = "-c"
	    else
		local_complex = ""
	    if (global_ldau && !prescf_ldau_not[i])
		local_orb = "-orb"
	    else
		local_orb = ""
	    if (so_done[i])
		local_so = "-so"
	    else
		local_so = ""
	    # Bring template from wien src
	    print "[info|band] Copying .klist file to .klist_band ..."
	    mysystem("cp -f " band_klist " ./" temp_root temp_name ".klist_band")
	    # Copy .machines file if it is a parallel run
	    if (global_parallel)
		mysystem("cp -f " global_machines " " temp_root ".machines > /dev/null 2>&1")
	    else
		mysystem("rm -f " temp_root ".machines > /dev/null 2>&1")
	    # Calculate eigenvalues
	    print "[info|band] Calculating eigenvalues (opt. expanding window)..."
	    mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1" (local_complex?"c":"") " " global_nneq " auto auto " band_in1maxenergy " auto  auto")
	    if (global_spinpolarized == "no"){
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -band > errfile 2>&1")
		if (local_so)
		    mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " > errfile 2>&1")
	    }
	    else{
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -up -band > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " lapw1 " local_complex " " global_parallel " " local_orb " -dn -band > errfile 2>&1")
		if (local_so)
		    mysystem(temp_prepath const_xlapwexe " lapwso " local_orb " " local_complex " " global_parallel " -up > errfile 2>&1")
	    }
	    # No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".band.lapw1.err")
	    # Bring .insp template from wien src
	    print "[info|band] Copying template .insp from wien src directory..."
	    mysystem("cp -f $WIENROOT/SRC_templates/case.insp ./" temp_root temp_name ".insp")
	    # Modify template with correct fermi energy
	    print "[info|band] Setting correct fermi level in .insp..."
	    mysystem(const_lapwsetefermiexe " " temp_root temp_name ".insp " scf_efermi[i])
	    # Running spaghetti
	    print "[info|band] Running spaghetti..."
	    if (global_spinpolarized == "no" || local_so)
		mysystem(temp_prepath const_xlapwexe " spaghetti " local_so " " global_parallel " > errfile 2>&1")
	    else{
		mysystem(temp_prepath const_xlapwexe " spaghetti " local_so " " global_parallel " -up > errfile 2>&1")
		mysystem(temp_prepath const_xlapwexe " spaghetti " local_so " " global_parallel " -dn > errfile 2>&1")
	    }
	    ## No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".spaghetti.err")
	    # Renaming output
	    print "[info|band] Renaming spaghetti output..."
	    if (global_spinpolarized == "no" || local_so)
		mysystem(temp_prepath "mv -f " temp_name ".spaghetti_ps " temp_name ".spaghetti.ps")
	    else{
		mysystem(temp_prepath "mv -f " temp_name ".spaghettiup_ps " temp_name ".spaghettiup.ps")
		mysystem(temp_prepath "mv -f " temp_name ".spaghettidn_ps " temp_name ".spaghettidn.ps")
	    }
	    # Restore .in1
	    print "[info|band] Restoring original .in1..."
	    mysystem(const_lapwmodifyin1exe " " temp_root temp_name ".in1"(local_complex?"c":"")" " global_nneq " auto auto " init_energymax " auto  auto")
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|band] Marking as done..."
	    band_done[i] = 1
	    # Time count
	    band_time[i] = systime() - band_time[i]
	    # Generate checkpoint
	    print "[info|band] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    band_savecheck(global_root "-check/band.check")
	}
    }
    ## Write down ps files
    temp_command = "ls " global_root "*/*.spaghetti*.ps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    close(temp_string)
    # Get end time
    band_totaltime = systime() - band_totaltime
    # Generate checkpoint
    print "[info|band] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    band_savecheck(global_root "-check/band.check")
    # End message
    print "[info|band] Bandplot section ended successfully..."
    printf "\n"
    next
}
# (xkdosx) Kdos section final tasks
/^( |\t)*end( |\t)*kdos( |\t)*$/ && global_section=="kdos"{
    global_section = ""
    kdos_run = 1
    print ""
    print "[info|kdos] Beginning of kdos section at " date()
    # Verify needed sections were run
    print "[info|kdos] Verifying needed sections were run"
    if (!general_run || !init_run || !prescf_run || !scf_run || !dos_run || !band_run ){
	print "[error|kdos] cannot run kdos."
	print "[error|kdos] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    kdos_totaltime = systime()
    # Set default variales
    print "[info|kdos] Setting default variables if missing..."
    # Set default values for DOS plot x-limits
    if (!kdos_plotxmin || kdos_plotxmin == "*")
	if (dos_plotxmin+0 != 0)
	    kdos_plotxmin = dos_plotxmin * const_rytoev
	else
	    kdos_plotxmin = -12.0
    if (!kdos_plotxmax || kdos_plotxmax == "*")
	if (dos_plotxmax+0 != 0)
	    kdos_plotxmax = dos_plotxmax * const_rytoev
	else
	    kdos_plotxmax = 8.0

    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|kdos] Determining which structures to run..."
    if (!kdos_dolines){
	if (!global_dolines){
	    kdos_dolines = 1
	    kdos_doline[1] = "new"
	    kdos_dotype[1] = "do"
	}
	else{
	    kdos_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		kdos_doline[i] = global_doline[i]
		kdos_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=kdos_dolines;i++){
	list_parser(kdos_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && kdos_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    kdos_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && kdos_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    kdos_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && kdos_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    kdos_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && kdos_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    kdos_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (kdos_dotype[i] ~ /do/){
		    kdos_do[k] = 1
		}
		else{
		    kdos_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|kdos] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i] || !dos_done[i] || !band_done[i])
	    if (kdos_do[i]){
		print "[warn|kdos] structure " i " cannot be run..."
		kdos_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (kdos_do[i]){
	    # Time count
	    kdos_time[i] = systime()
	    # Load structure + heading
	    print "[info|kdos] ----------------------------------------------------------"
	    print "[info|kdos] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (so_done[i])
		local_so = "-so"
	    else
		local_so = ""
	    for (j=1; j<= kdos_nkdos; j++){
		# Assign file names (up.agr and dn.agr have the same output)
		temp_val = sprintf("%i",(kdos_dos[j]-1) % 7)
		temp_val2 = sprintf ("%i",((kdos_dos[j]-1)-temp_val) / 7 + 1)
		temp_val = temp_val + 2

		if (kdos_dos[j] ~ /up/ && global_spinpolarized == "yes")
		    kdos_dosfile = global_pwd "/" temp_name "/" temp_name ".dos" temp_val2 "evup"
		else if (kdos_dos[j] ~ /dn/ && global_spinpolarized == "yes")
		    kdos_dosfile = global_pwd "/" temp_name "/" temp_name ".dos" temp_val2 "evdn"
		else
		    kdos_dosfile = global_pwd "/" temp_name "/" temp_name ".dos" temp_val2 "ev"

		if (global_spinpolarized == "yes" && !local_so)
		    kdos_agrfile = global_pwd "/" temp_name "/" temp_name ".bandsup.agr"
		else
		    kdos_agrfile = global_pwd "/" temp_name "/" temp_name ".bands.agr"
		delete kdos_enefile
		if (global_spinpolarized == "yes" && !local_so){
		    if (kdos_band[j] == "up")
			kdos_enefile[1] = global_pwd "/" temp_name "/" temp_name ".spaghettiup_ene"
		    else if (kdos_band[j] == "dn")
			kdos_enefile[1] = global_pwd "/" temp_name "/" temp_name ".spaghettidn_ene"
		    else{
			kdos_enefile[1] = global_pwd "/" temp_name "/" temp_name ".spaghettiup_ene"
			kdos_enefile[2] = global_pwd "/" temp_name "/" temp_name ".spaghettidn_ene"
		    }
		}
		else
		    kdos_enefile[1] = global_pwd "/" temp_name "/" temp_name ".spaghetti_ene"
		# Check existence of files
		if (!checkexists(kdos_dosfile) || !checkexists(kdos_dosfile) || !checkexists(kdos_enefile[1]) || \
		    !checkexists(kdos_agrfile) || (kdos_enefile[2] && !checkexists(kdos_enefile[2]))){
		    print "[warn|kdos] some files required for kdos plot are missing..."
		    print "[warn|kdos] check these files "
		    print "[warn|kdos] DOS file     : ", kdos_dosfile
		    print "[warn|kdos] AGR file     : ", kdos_agrfile
		    print "[warn|kdos] ENE file (1) : ", kdos_enefile[1]
		    if (kdos_enefile[2])
			print "[warn|kdos] ENE file (2) : ", kdos_enefile[2]
		    kdos_done[i] = ""
		    kdos_time[i] = 0
		    continue
		}
		# Set default value for DOS plot y-limit
		if (!kdos_plotymax || kdos_plotymax == "*"){
		    temp_string = "cat " kdos_dosfile " | awk '($1+0<"kdos_plotxmax")&&($1+0 > "kdos_plotxmin"){print $" temp_val "}' | awk '$1+0>max{max=$1} ; END{print max}'"
		    temp_string | getline kdos_plotymax2
		    close(temp_string)
		}
		else
		    kdos_plotymax2 = kdos_plotymax
		# Create gnuplot script, header
		temp_string = global_pwd "/" temp_name "/" temp_name ".dosband." j ".gnuplot"
		if (const_gnuplotversion < 423)
		    print "set terminal postscript eps enhanced color solid 'Helvetica' 28" > temp_string
		else
		    print "set terminal postscript eps enhanced color solid size 10,7 'Helvetica' 28" > temp_string
		print "set output '" global_pwd "/" temp_name "/" temp_name ".dosband." j ".eps" "'" > temp_string
		print "unset key" > temp_string
		print "set multiplot" > temp_string
		print "set size 0.3,1.0" > temp_string
		print "set tmargin 0.5" > temp_string
		print "set rmargin 0.25" > temp_string
		print "set xtics autofreq" > temp_string
		print "set xrange [0:" kdos_plotymax2 "]" > temp_string
		print "set yrange [" kdos_plotxmin ":" kdos_plotxmax "]" > temp_string
		print "set ylabel '({/Symbol e}-{/Symbol e}_F) (eV)'" > temp_string
		print "set xlabel 'g({/Symbol e}) (e/eV)'" > temp_string
		print "set format x '%.1f'" > temp_string
		print "set xzeroaxis" > temp_string
		print "plot \"" kdos_dosfile "\" u " temp_val ":1 w lines \\" > temp_string
		print "	, \"< gawk '$1+0<=0' " kdos_dosfile "\" u " temp_val ":1 w filledcurves y1" > temp_string
		print "set xrange [*:*]" > temp_string
		print "set format x" > temp_string
		print "unset ylabel" > temp_string
		print "unset xlabel" > temp_string
		print "set size 0.7,1.0" > temp_string
		print "set origin 0.3,0.0" > temp_string
		print "clear" > temp_string
		print "set lmargin 0.25" > temp_string
		print "set rmargin 0.5" > temp_string
		print "set tmargin 0.5" > temp_string
		print "unset ytics" > temp_string
		print "set y2tics mirror autofreq" > temp_string
		print "set format y2 \"\"" > temp_string
		print "set y2range [" kdos_plotxmin ":" kdos_plotxmax"]" > temp_string
		print "set xlabel \" \"" > temp_string
		print "set xzeroaxis" > temp_string
		close(temp_string)
		# create gnuplot script, add arrows
		mysystem(temp_prepath const_lapwdosbandextractagrexe " " kdos_agrfile " >> " temp_string)
		# create gnuplot script, add energy bands plot line
		if (global_spinpolarized == "yes" && !local_so && kdos_enefile[2]){
		    print "plot '< " const_lapwdosbandextracteneexe " " kdos_enefile[1] "' u 4:5 w lines, " \
			"'< " const_lapwdosbandextracteneexe " " kdos_enefile[2] "' u 4:5 w lines">> temp_string
		}
		else
		    print "plot '< " const_lapwdosbandextracteneexe " " kdos_enefile[1] "' u 4:5 w lines" >> temp_string
		print "unset multiplot" >> temp_string
		close(temp_string)
		# run gnuplot
		mysystem(temp_prepath const_gnuplotexe " " temp_string)
	    }
	    # Marking as done...
	    print "[info|kdos] Marking as done..."
	    kdos_done[i] = 1
	    # Time count
	    kdos_time[i] = systime() - kdos_time[i]
	    # Generate checkpoint
	    print "[info|kdos] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    kdos_savecheck(global_root "-check/kdos.check")
	}
    }
    # Write down ps files
    temp_command = "ls " global_root "*/*.dosband.*.eps"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_ps)){
	    global_file_ps_n++
	    global_file_ps[global_file_ps_n] = temp_string
	}
    }
    # Get end time
    kdos_totaltime = systime() - kdos_totaltime
    # Generate checkpoint
    print "[info|kdos] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    kdos_savecheck(global_root "-check/kdos.check")
    # End message
    print "[info|kdos] Kdos section ended successfully..."
    printf "\n"
    next
}
# (xaimx) Aim section final tasks
/^( |\t)*end( |\t)*aim( |\t)*$/ && global_section=="aim"{
    global_section = ""
    aim_run = 1
    print ""
    print "[info|aim] Beginning of aim section at " date()
    # Verify needed sections were run
    print "[info|aim] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|aim] cannot run aim."
	print "[error|aim] needed section has not been run or loaded."
	exit 1
    }
    # Check for wien2k executables
    print "[info|global] Checking for WIEN2k executables..."
    delete temp_array
    temp_array[const_extractaimlapwexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|aim] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    aim_totaltime = systime()
    ## Set default variales
    print "[info|aim] Setting default variables if missing..."
    if (!aim_atom){
	aim_atom = 1
    }
    if (!aim_uses){
	aim_uses = "FOUR"
    }
    else{
	aim_uses = toupper(aim_uses)
    }
    if (!aim_nsh_x){
	aim_nsh_x = 3
	aim_nsh_y = 3
	aim_nsh_z = 3
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|aim] Determining which structures to run..."
    if (!aim_dolines){
	if (!global_dolines){
	    aim_dolines = 1
	    aim_doline[1] = "new"
	    aim_dotype[1] = "do"
	}
	else{
	    aim_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		aim_doline[i] = global_doline[i]
		aim_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=aim_dolines;i++){
	list_parser(aim_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && aim_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    aim_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && aim_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    aim_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && aim_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    aim_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && aim_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    aim_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (aim_dotype[i] ~ /do/){
		    aim_do[k] = 1
		}
		else{
		    aim_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|aim] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (aim_do[i]){
		print "[warn|aim] structure " i " cannot be run..."
		aim_do[i] = ""
	    }
    }
    # Run over structures...
    for (i=1;i<=general_iterations;i++){
	if (aim_do[i]){
	    # Time count
	    aim_time[i] = systime()
	    # Load structure + heading
	    print "[info|aim] ----------------------------------------------------------"
	    print "[info|aim] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    if (global_complex || so_done[i])
		local_complex = "-c"
	    else
		local_complex = ""
	    # Creating input file
	    print "[info|aim] Creating input file..."
	    temp_string = temp_root temp_name ".inaim"
	    print "CRIT" > temp_string
	    print aim_atom > temp_string
	    print aim_uses > temp_string
	    print aim_nsh_x " " aim_nsh_y " " aim_nsh_z > temp_string
	    print "END" > temp_string
	    close(temp_string)
	    # Run aim
	    print "[info|aim] Running aim..."
	    mysystem(temp_prepath const_xlapwexe " aim " local_complex " > errfile 2>&1")
	    ## No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".aim.err")
	    # Extract critical points
	    print "[info|aim] Extracting critical points..."
	    mysystem(temp_prepath const_extractaimlapwexe " " temp_name ".outputaim > errfile 2>&1")
	    ## No error checks for now --
	    mysystem(temp_prepath "mv -f errfile " temp_name ".extractaim.err")
	    # Move extracted critical points file
	    mysystem(temp_prepath "mv -f critical_points_ang " temp_name ".cp_ang")
	    mysystem(temp_prepath "rm -f critical_points")
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|aim] Marking as done..."
	    aim_done[i] = 1
	    # Time count
	    aim_time[i] = systime() - aim_time[i]
	    # Generate checkpoint
	    print "[info|aim] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    aim_savecheck(global_root "-check/aim.check")
	}
    }
    # Get end time
    aim_totaltime = systime() - aim_totaltime
    # Generate checkpoint
    print "[info|aim] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    aim_savecheck(global_root "-check/aim.check")
    # End message
    print "[info|aim] Aim section ended successfully..."
    printf "\n"
    next
}
# (xcriticx) Critic section final tasks
/^( |\t)*end( |\t)*critic( |\t)*$/ && global_section=="critic"{
    global_section = ""
    critic_run = 1
    print ""
    print "[info|critic] Beginning of critic section at " date()
    # Verify needed sections were run
    print "[info|critic] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|critic] cannot run critic."
	print "[error|critic] needed section has not been run or loaded."
	exit 1
    }
    # Check for executables
    print "[info|critic] Checking for executables..."
    delete temp_array
    temp_array[const_criticexe] = 1
    for (i in temp_array){
	if (!checkexe(i)){
	    print "[error|critic] Executable not found: " i
	    exit 1
	}
    }
    # Get initial time
    critic_totaltime = systime()
    # Set default variales
    print "[info|critic] Setting default variables if missing..."
    if (!critic_nice){
	critic_nice = 0
    }
    if (!critic_use){
	critic_use = "rho"
    }
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures. global acts as
    ## a default.
    print "[info|critic] Determining which structures to run..."
    if (!critic_dolines){
	if (!global_dolines){
	    critic_dolines = 1
	    critic_doline[1] = "new"
	    critic_dotype[1] = "do"
	}
	else{
	    critic_dolines = global_dolines
	    for (i=1;i<=general_iterations;i++){
		critic_doline[i] = global_doline[i]
		critic_dotype[i] = global_dotype[i]
	    }
	}
    }
    ## Parse all the lines, read all the fields and assign values to do
    for (i=1;i<=critic_dolines;i++){
	list_parser(critic_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && critic_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    critic_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && critic_dotype[i] ~ /do/){
		for (k=1;k<=general_iterations;k++){
		    critic_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && critic_dotype[i] ~ /do/){
		for (k=general_olditerations+1;k<=general_iterations;k++){
		    critic_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && critic_dotype[i] ~ /do/){
		for (k=1;k<=general_olditerations;k++){
		    critic_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (critic_dotype[i] ~ /do/){
		    critic_do[k] = 1
		}
		else{
		    critic_do[k] = ""
		}
	    }
	}
    }
    # Verifying section requirements structure-wise
    print "[info|critic] Verifying section requirements structure-wise..."
    for (i=1;i<=general_iterations;i++){
	if (!general_done[i] || !init_done[i] || !prescf_done[i] || !scf_done[i])
	    if (critic_do[i]){
		print "[warn|critic] structure " i " cannot be run..."
		critic_do[i] = ""
	    }
    }
    # Run through structures
    for (i=1;i<=general_iterations;i++){
	if (critic_do[i]){
	    # Time count
	    critic_time[i] = systime()
	    # Load structure + heading
	    print "[info|critic] ----------------------------------------------------------"
	    print "[info|critic] Loading structure #" i"..."
	    temp_name = general_filename[i]
	    gsub(".struct","",temp_name)
	    temp_root = temp_name "/"
	    temp_prepath = "cd " temp_name " ; "
	    temp_file = global_pwd "/" temp_root "tempfile"
	    # Creating input file
	    print "[info|critic] Creating .incritic input file..."
	    temp_string = temp_root temp_name ".incritic"
	    print "TITLE " general_title > temp_string
	    if (critic_iws){
		print critic_iws > temp_string
	    }
	    print "CRYSTAL" > temp_string
	    print "  STRUCT " temp_name ".struct" > temp_string
	    if (global_spinpolarized == "no"){
		if (critic_use == "rho")
		    print "  CLM " temp_name ".clmsum" > temp_string
		else if (critic_use == "valrho")
		    print "  CLM " temp_name ".clmval" > temp_string
		else
		    print "  CLM " temp_name ".clmsum.atomic" > temp_string
	    }
	    else{
		if (critic_use == "rho"){
		    print "  CLM " temp_name ".clmup" > temp_string
		    print "  CLMDOWN " temp_name ".clmdn" > temp_string
		}
		else if (critic_use == "valrho"){
		    print "  CLM " temp_name ".clmvalup" > temp_string
		    print "  CLMDOWN " temp_name ".clmvaldn" > temp_string
		}
		else{
		    print "  CLM " temp_name ".clmup.atomic" > temp_string
		    print "  CLMDOWN " temp_name ".clmdn.atomic" > temp_string
		}
	    }
	    print "ENDCRYSTAL" > temp_string
	    if (critic_linetype1){
		if (!critic_linepoints){
		    critic_linepoints = 201
		}
		if (critic_linetype1 == "atom"){
		    critic_linex1 = global_nneq_x[critic_lineatom1,critic_linemult1]
		    critic_liney1 = global_nneq_y[critic_lineatom1,critic_linemult1]
		    critic_linez1 = global_nneq_z[critic_lineatom1,critic_linemult1]
		}
		if (critic_linetype2 == "atom"){
		    critic_linex2 = global_nneq_x[critic_lineatom2,critic_linemult2]
		    critic_liney2 = global_nneq_y[critic_lineatom2,critic_linemult2]
		    critic_linez2 = global_nneq_z[critic_lineatom2,critic_linemult2]
		}
		print "LINE " critic_linex1 " " critic_liney1 " " critic_linez1 \
		    " " critic_linex2 " " critic_liney2 " " critic_linez2 " " \
		    critic_linepoints > temp_string
	    }
	    if (critic_newton){
		print "AUTO NEWTON " critic_newton > temp_string
	    }
	    if (critic_basinplot){
		print "BASINPLOT " critic_basin_level " " critic_basin_delta " " critic_basin_theta " " critic_basin_phi > temp_string
	    }
	    if (critic_integrals){
		print "INTEGRALS 0 " sprintf("%.15f",const_pi) " 0 " sprintf("%.15f",2*const_pi) " " critic_integrals_nr " " critic_integrals_nt " " critic_integrals_np > temp_string
	    }
	    if (critic_doplot){
		print critic_doplot > temp_string
	    }
	    if (critic_grdvec_lines){
		if (const_gnuplotversion < 423)
		    print "set oldgnuplot" > temp_string
		else
		    print "set newgnuplot" > temp_string
		for (j=1;j<=critic_grdvec_lines;j++){
		    print critic_grdvec_line[j] > temp_string
		}
	    }
	    close(temp_string)
	    # Running critic
	    print "[info|critic] Running critic..."
	    mysystem(temp_prepath "nice -n " critic_nice " " const_criticexe " " temp_name ".incritic > " temp_name ".outputcritic 2>&1")
	    ## No error checks for now --
	    temp_string = "lapw_extractcritic.awk topology " temp_root temp_name ".outputcritic"
	    temp_string | getline critic_topology[i]
	    close(temp_string)
	    temp_string = "lapw_extractcritic.awk planarity " temp_root temp_name ".outputcritic"
	    temp_string | getline critic_planarity[i]
	    close(temp_string)
	    temp_string = "lapw_extractcritic.awk morsesum " temp_root temp_name ".outputcritic"
	    temp_string | getline critic_morsesum[i]
	    close(temp_string)
	    # Run gnuplot on grdvec output
	    if (critic_grdvec_filename){
		mysystem(temp_prepath const_gnuplotexe " "critic_grdvec_filename ".gnu")
		# Write down ps file
		temp_string = temp_root critic_grdvec_filename ".eps"
		if (!isin(temp_string ,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = temp_string
		}
		# Write down gnu file
		temp_string = temp_root critic_grdvec_filename ".gnu"
		if (!isin(temp_string,global_file_gnuplot)){
		    global_file_gnuplot_n++
		    global_file_gnuplot[global_file_gnuplot_n] = temp_string
		}
	    }
	    # Cleaning directory
	    clean(i)
	    # Marking as done...
	    print "[info|critic] Marking as done..."
	    critic_done[i] = 1
	    # Time count
	    critic_time[i] = systime() - critic_time[i]
	    # Generate checkpoint
	    print "[info|critic] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    critic_savecheck(global_root "-check/critic.check")
	}
    }
    if (!critic_nosummary){
	print "[info|critic] Pretty-printing summary..."
	mysystem(const_criticsum " */*.outputcritic > " const_criticsumout " 2>&1")
	## Write down output file
	if (!isin(const_criticsumout,global_file_out)){
	    global_file_out_n++
	    global_file_out[global_file_out_n] = const_criticsumout
	}
    }
    # Get end time
    critic_totaltime = systime() - critic_totaltime
    # Generate checkpoint
    print "[info|critic] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    critic_savecheck(global_root "-check/critic.check")
    # End message
    print "[info|critic] Critic section ended successfully..."
    printf "\n"
    next
}
# (xsweepx) Sweep section final tasks
/^( |\t)*end( |\t)*sweep( |\t)*$/ && global_section=="sweep"{
    global_section = ""
    sweep_run = 1
    print ""
    print "[info|sweep] Beginning of sweep section at " date()
    # Verify needed sections were run
    print "[info|sweep] Verifying needed sections were run..."
    if (!general_run || !init_run || !prescf_run || !scf_run){
	print "[error|sweep] cannot run sweep."
	print "[error|sweep] needed section has not been run or loaded."
	exit 1
    }
    # Get initial time
    sweep_totaltime = systime()
    # Assign root name
    sweep_root = global_root "-sweep"
    # Set default variales
    print "[info|sweep] Setting missing and default variables..."
    if (!sweep_ref){
	for (i=1;i<=general_iterations;i++){
	    if (general_done[i] && init_done[i]){
		sweep_ref = i
		break
	    }
	}
	if (!sweep_ref){
	    print "[error|sweep] there is no adequate reference structure."
	    print "[error|sweep] run general and init in at least one structure to take it as ref."
	    exit 1
	}
    }
    if (!sweep_potential)
	sweep_potential = init_potential
    if (!sweep_ecoreval)
	sweep_ecoreval = init_ecoreval
    if (!sweep_ifft)
	sweep_ifft = init_ifft
    if (!sweep_energymin)
	sweep_energymin = init_energymin
    if (!sweep_energymax)
	sweep_energymax = init_energymax
    if (!sweep_fermi)
	sweep_fermi = init_fermi
    if (!sweep_fermival)
	sweep_fermival = init_fermival
    for (i=1;i<=global_nneq;i++){
	if (!sweep_orbitals[i]){
	    if (init_orbitals[i]){
		sweep_orbitals[i] = init_orbitals[i]
		sweep_orbital_globe[i] = init_orbital_globe[i]
		sweep_orbital_globapw[i] = init_orbital_globapw[i]
		for (j=1;j<=sweep_orbitals[i];j++){
		    sweep_orbital_l[i,j] = init_orbital_l[i,j]
		    sweep_orbital_energy[i,j] = init_orbital_energy[i,j]
		    sweep_orbital_var[i,j] = init_orbital_var[i,j]
		    sweep_orbital_cont[i,j] = init_orbital_cont[i,j]
		    sweep_orbital_apw[i,j] = init_orbital_apw[i,j]
		}
	    }
	}
	if (!sweep_lms[i]){
	    if (init_lms[i]){
		sweep_lms[i] = init_lms[i]
		for (j=1;j<=sweep_lms[i];j++){
		    sweep_lm_l[i,j] = init_lm_l[i,j]
		    sweep_lm_m[i,j] = init_lm_m[i,j]
		}
	    }
	}
    }
    if (!sweep_itdiag)
	sweep_itdiag = scf_itdiag
    if (!sweep_nice)
	sweep_nice = scf_nice
    if (!sweep_miter)
	sweep_miter = scf_miter
    if (!sweep_cc)
	sweep_cc = scf_cc
    if (!sweep_ec)
	sweep_ec = scf_ec
    if (!sweep_fc)
	sweep_fc = scf_fc
    if (!sweep_cc && !sweep_ec && !sweep_fc)
	sweep_ec = 0.00001
    if (!sweep_reusemode)
	sweep_reusemode = "chain"
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "npt" i
	if (!sweep_npt[i])
	    sweep_npt[i] = general_val[temp_idstring,general_index[temp_idstring,sweep_ref]]
    }
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "rmt" i
	if (!sweep_rmt[i])
	    sweep_rmt[i] = general_val[temp_idstring,general_index[temp_idstring,sweep_ref]]
    }
    for (i=1;i<=global_nneq;i++){
	temp_idstring = "r0" i
	if (!sweep_r0[i])
	    sweep_r0[i] = general_val[temp_idstring,general_index[temp_idstring,sweep_ref]]
    }
    if (!sweep_rkmax)
	sweep_rkmax = general_val["rkmax",general_index["rkmax",sweep_ref]]
    if (!sweep_lmax)
	sweep_lmax = general_val["lmax",general_index["lmax",sweep_ref]]
    if (!sweep_lnsmax)
	sweep_lnsmax = general_val["lnsmax",general_index["lnsmax",sweep_ref]]
    if (!sweep_gmax)
	sweep_gmax = general_val["gmax",general_index["gmax",sweep_ref]]
    if (!sweep_mix)
	sweep_mix = general_val["mix",general_index["mix",sweep_ref]]
    if (!sweep_kpts)
	sweep_kpts = general_val["kpts",general_index["kpts",sweep_ref]]
    if (!sweep_ldau){
	if (global_ldau && !prescf_ldau_not[sweep_ref]){
	    sweep_ldau = global_ldau
	    sweep_ldautype = global_ldautype
	    sweep_ldaus = global_ldaus
	    for (i=1;i<=sweep_ldaus;i++){
		sweep_ldau_atom[i] = global_ldau_atom[i]
		sweep_ldau_l[i] = global_ldau_l[i]
		sweep_ldau_defu[i] = general_val["u"i,general_index["u"i,sweep_ref]]+0
		sweep_ldau_defj[i] = general_val["j"i,general_index["j"i,sweep_ref]]+0
	    }
	}
    }
    # Determine number of structures. If there are new 'withs' append
    # at the end of the old iterations. If there are no old
    # iterations, error
    if (defined(sweep_with)){
	for (i=1;i<=sweep_alsos;i++){
	    print "[info|sweep] Setting default variables for also #" i"..."
	    if (!sweep_with[i,"a"])
		sweep_with[i,"a"] = global_a
	    if (!sweep_with[i,"b"])
		sweep_with[i,"b"] = global_b
	    if (!sweep_with[i,"c"])
		sweep_with[i,"c"] = global_c
	    if (!sweep_with[i,"alpha"])
		sweep_with[i,"alpha"] = global_alpha
	    if (!sweep_with[i,"beta"])
		sweep_with[i,"beta"] = global_beta
	    if (!sweep_with[i,"gamma"])
		sweep_with[i,"gamma"] = global_gamma
	    # Parse input for a,b,c,...
	    print "[info|sweep] Parsing input variables for also #" i"..."
	    list_parser(sweep_with[i,"a"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_a_n++
		    sweep_a_newval[sweep_a_n] = global_a
		    continue
		}
		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_a_n++
		    if (global_flag[j] == "%")
			sweep_a_newval[sweep_a_n] = global_a*(1+k/100)
		    else
			sweep_a_newval[sweep_a_n] = k
		}
	    }
	    list_parser(sweep_with[i,"b"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_b_n++
		    sweep_b_newval[sweep_b_n] = global_b
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_b_n++
		    if (global_flag[j] == "%")
			sweep_b_newval[sweep_b_n] = global_b*(1+k/100)
		    else
			sweep_b_newval[sweep_b_n] = k
		}
	    }
	    list_parser(sweep_with[i,"c"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_c_n++
		    sweep_c_newval[sweep_c_n] = global_c
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_c_n++
		    if (global_flag[j] == "%")
			sweep_c_newval[sweep_c_n] = global_c*(1+k/100)
		    else
			sweep_c_newval[sweep_c_n] = k
		}
	    }
	    list_parser(sweep_with[i,"alpha"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_alpha_n++
		    sweep_alpha_newval[sweep_alpha_n] = global_alpha
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_alpha_n++
		    if (global_flag[j] == "%")
			sweep_alpha_newval[sweep_alpha_n] = global_alpha*(1+k/100)
		    else
			sweep_alpha_newval[sweep_alpha_n] = k
		}
	    }
	    list_parser(sweep_with[i,"beta"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_beta_n++
		    sweep_beta_newval[sweep_beta_n] = global_beta
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_beta_n++
		    if (global_flag[j] == "%")
			sweep_beta_newval[sweep_beta_n] = global_beta*(1+k/100)
		    else
			sweep_beta_newval[sweep_beta_n] = k
		}
	    }
	    list_parser(sweep_with[i,"gamma"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_gamma_n++
		    sweep_gamma_newval[sweep_gamma_n] = global_gamma
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_gamma_n++
		    if (global_flag[j] == "%")
			sweep_gamma_newval[sweep_gamma_n] = global_gamma*(1+k/100)
		    else
			sweep_gamma_newval[sweep_gamma_n] = k
		}
	    }
	    list_parser(sweep_with[i,"v"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_v_n++
		    sweep_v_newval[sweep_v_n] = volume(global_a,global_b,global_c,global_alpha,global_beta,global_gamma)
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_v_n++
		    if (global_flag[j] == "%")
			sweep_v_newval[sweep_v_n] = global_v*(1+k/100)
		    else
			sweep_v_newval[sweep_v_n] = k
		}
	    }
	    list_parser(sweep_with[i,"c/a"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_ca_n++
		    sweep_ca_newval[sweep_ca_n] = global_c/global_a
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_ca_n++
		    if (global_flag[j] == "%")
			sweep_ca_newval[sweep_ca_n] = global_ca*(1+k/100)
		    else
			sweep_ca_newval[sweep_ca_n] = k
		}
	    }
	    list_parser(sweep_with[i,"c/b"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_cb_n++
		    sweep_cb_newval[sweep_cb_n] = global_c/global_b
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_cb_n++
		    if (global_flag[j] == "%")
			sweep_cb_newval[sweep_cb_n] = global_cb*(1+k/100)
		    else
			sweep_cb_newval[sweep_cb_n] = k
		}
	    }
	    list_parser(sweep_with[i,"b/a"])
	    for (j=1;j<=global_niter;j++){
		if (global_flag[j] == "auto"){ # Set default value
		    sweep_ba_n++
		    sweep_ba_newval[sweep_ba_n] = global_b/global_a
		    continue
		}
 		for(x=1;x<=global_num[j];x++){
		    k = global_ini[j] + (x-1)*global_incr[j]
		    sweep_ba_n++
		    if (global_flag[j] == "%")
			sweep_ba_newval[sweep_ba_n] = global_ba*(1+k/100)
		    else
			sweep_ba_newval[sweep_ba_n] = k
		}
	    }
	    # Create iteration counter, system-dependent
	    print "[info|sweep] Creating iteration counter for also #" i"..."
	    if (global_system == "cubic"){
		## input as volume
		if (sweep_with[i,"v"]){
		    for (j=1;j<=sweep_v_n;j++){
			sweep_a_val[sweep_iterations+j] = sweep_b_val[sweep_iterations+j] = sweep_c_val[sweep_iterations+j] = (sweep_v_newval[j])^(1.0/3.0)
			sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = 90.0
		    }
		    sweep_iterations += sweep_v_n
		}
		## input as cell-parameter a
		else{
		    for (j=1;j<=sweep_a_n;j++){
			sweep_a_val[sweep_iterations+j] = sweep_b_val[sweep_iterations+j] = sweep_c_val[sweep_iterations+j] = sweep_a_newval[j]
			sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = 90.0
		    }
		    sweep_iterations += sweep_a_n
		}
	    }
	    else if (global_system == "hexagonal"){
		## input as volume and c/a
		if (sweep_with[i,"v"] && sweep_with[i,"c/a"]){
		    for (j=1;j<=sweep_v_n;j++){
			for (k=1;k<=sweep_ca_n;k++){
			    sweep_iterations++
			    sweep_c_val[sweep_iterations] = (sweep_v_newval[j]*2*sweep_ca_newval[k]^2/sqrt(3))^(1./3.)
			    sweep_a_val[sweep_iterations] = sweep_b_val[sweep_iterations] = sqrt(2*sweep_v_newval[j]/sqrt(3)/ \
												 sweep_c_val[sweep_iterations])
			    sweep_alpha_val[sweep_iterations] = sweep_beta_val[sweep_iterations] = 90.0
			    sweep_gamma_val[sweep_iterations] = 120.0
			}
		    }
		}
		## input as a,c
		else{
		    for (j=sweep_a_n*sweep_c_n;j>=1;j--){
			temp_val = j-1
			sweep_c_val[sweep_iterations+j] = sweep_c_newval[(temp_val % sweep_c_n) + 1]
			temp_val = int(temp_val/sweep_c_n)
			sweep_a_val[sweep_iterations+j] = sweep_b_val[sweep_iterations+j] = sweep_a_newval[(temp_val % sweep_a_n) + 1]
			sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = 90.0
			sweep_gamma_val[sweep_iterations+j] = 120.0
		    }
		    sweep_iterations += sweep_a_n*sweep_c_n
		}
	    }
	    else if (global_system == "rhombohedric"){
		## input as a, alpha
		for (j=sweep_a_n*sweep_alpha_n;j>=1;j--){
		    temp_val = j-1
		    sweep_a_val[sweep_iterations+j] = sweep_b_val[sweep_iterations+j] = sweep_c_val[sweep_iterations+j] = sweep_a_newval[(temp_val%sweep_a_n)+1]
		    temp_val = int(temp_val/sweep_a_n)
		    sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = sweep_alpha_newval[(temp_val%sweep_alpha_n)+1]
		}
		sweep_iterations += sweep_a_n*sweep_alpha_n
	    }
	    else if (global_system == "tetragonal"){
		## input as volume and c/a
		if (sweep_with[i,"v"] && sweep_with[i,"c/a"]){
		    for (j=1;j<=sweep_v_n;j++){
			for (k=1;k<=sweep_ca_n;k++){
			    sweep_iterations++
			    sweep_b_val[sweep_iterations] =sweep_a_val[sweep_iterations] = (sweep_v_newval[j] / sweep_ca_newval[k])^(1./3.)
			    sweep_c_val[sweep_iterations] = sweep_ca_newval[k] * sweep_a_val[sweep_iterations]
			    sweep_alpha_val[sweep_iterations] = sweep_beta_val[sweep_iterations] = sweep_gamma_val[sweep_iterations] = 90.0
			}
		    }
		}
		else{
		    ## input as a, c
		    for (j=sweep_a_n*sweep_c_n;j>=1;j--){
			temp_val = j-1
			sweep_a_val[sweep_iterations+j] = sweep_b_val[sweep_iterations+j] = sweep_a_newval[(temp_val%sweep_a_n)+1]
			temp_val = int(temp_val/sweep_a_n)
			sweep_c_val[sweep_iterations+j] = sweep_c_newval[(temp_val%sweep_c_n)+1]
			sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = 90.0
		    }
		    sweep_iterations += sweep_a_n*sweep_c_n
		}
	    }
	    else if (global_system == "orthorhombic"){
		## input as a, b, c
		for (j=sweep_a_n*sweep_b_n*sweep_c_n;j>=1;j--){
		    temp_val = j-1
		    sweep_a_val[sweep_iterations+j] = sweep_a_newval[(temp_val%sweep_a_n)+1]
		    temp_val = int(temp_val/sweep_a_n)
		    sweep_b_val[sweep_iterations+j] = sweep_b_newval[(temp_val%sweep_b_n)+1]
		    temp_val = int(temp_val/sweep_b_n)
		    sweep_c_val[sweep_iterations+j] = sweep_c_newval[(temp_val%sweep_c_n)+1]
		    temp_val = int(temp_val/sweep_c_n)
		    sweep_alpha_val[sweep_iterations+j] = sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = 90.0
		}
		sweep_iterations += sweep_a_n*sweep_b_n*sweep_c_n
	    }
	    else if (global_system == "monoclinic"){
		## input as a, b, c, alpha
		for (j=sweep_a_n*sweep_b_n*sweep_c_n*sweep_alpha_n;j>=1;j--){
		    temp_val = j-1
		    sweep_a_val[sweep_iterations+j] = sweep_a_newval[(temp_val%sweep_a_n)+1]
		    temp_val = int(temp_val/sweep_a_n)
		    sweep_b_val[sweep_iterations+j] = sweep_b_newval[(temp_val%sweep_b_n)+1]
		    temp_val = int(temp_val/sweep_b_n)
		    sweep_c_val[sweep_iterations+j] = sweep_c_newval[(temp_val%sweep_c_n)+1]
		    temp_val = int(temp_val/sweep_c_n)
		    sweep_alpha_val[sweep_iterations+j] = sweep_alpha_newval[(temp_val%sweep_alpha_n)+1]
		    temp_val = int(temp_val/sweep_alpha_n)
		    sweep_beta_val[sweep_iterations+j] = sweep_gamma_val[sweep_iterations+j] = 90.0
		}
		sweep_iterations += sweep_a_n*sweep_b_n*sweep_c_n*sweep_alpha_n
	    }
	    else if (global_system == "triclinic"){
		## input as a, b, c, alpha, beta, gamma
		for (j=sweep_a_n*sweep_b_n*sweep_c_n*sweep_alpha_n*sweep_beta_n*sweep_gamma_n;j>=1;j--){
		    temp_val = j-1
		    sweep_a_val[sweep_iterations+j] = sweep_a_newval[(temp_val%sweep_a_n)+1]
		    temp_val = int(temp_val/sweep_a_n)
		    sweep_b_val[sweep_iterations+j] = sweep_b_newval[(temp_val%sweep_b_n)+1]
		    temp_val = int(temp_val/sweep_b_n)
		    sweep_c_val[sweep_iterations+j] = sweep_c_newval[(temp_val%sweep_c_n)+1]
		    temp_val = int(temp_val/sweep_c_n)
		    sweep_alpha_val[sweep_iterations+j] = sweep_alpha_newval[(temp_val%sweep_alpha_n)+1]
		    temp_val = int(temp_val/sweep_alpha_n)
		    sweep_beta_val[sweep_iterations+j] = sweep_beta_newval[(temp_val%sweep_beta_n)+1]
		    temp_val = int(temp_val/sweep_beta_n)
		    sweep_gamma_val[sweep_iterations+j] = sweep_gamma_newval[(temp_val%sweep_gamma_n)+1]
		    temp_val = int(temp_val/sweep_gamma_n)
		}
		sweep_iterations += sweep_a_n*sweep_b_n*sweep_c_n*sweep_alpha_n*sweep_beta_n*sweep_gamma_n
	    }
	    # Re-initialize temporal variables
	    sweep_a_n = sweep_b_n = sweep_c_n = sweep_alpha_n = sweep_beta_n = sweep_gamma_n = sweep_v_n = sweep_ca_n = sweep_cb_n = sweep_ba_n = 0
	    delete sweep_a_newval
	    delete sweep_b_newval
	    delete sweep_c_newval
	    delete sweep_alpha_newval
	    delete sweep_beta_newval
	    delete sweep_gamma_newval
	    delete sweep_v_newval
	    delete sweep_ca_newval
	    delete sweep_cb_newval
	    delete sweep_ba_newval
	}
    }
    else{
	if (!sweep_olditerations){
	    print "[error|sweep] there are no structures to calculate!"
	    print "[error|sweep] load old structures with loadcheck or specify them with 'with'"
	    exit 1
	}
    }
    # Calculate volume and fractions
    print "[info|sweep] Calculating structural information..."
    for (i=1;i<=sweep_iterations;i++){
	sweep_v_val[i] = volume(sweep_a_val[i],sweep_b_val[i],sweep_c_val[i],sweep_alpha_val[i],sweep_beta_val[i],sweep_gamma_val[i])
	sweep_molv[i] = sweep_v_val[i]/global_gcdmult
	if (global_lattice == "P" || global_lattice == "S")
	    sweep_molv[i] = sweep_molv[i] / 1
	else if (global_lattice == "F")
	    sweep_molv[i] = sweep_molv[i] / 4
	else if (global_lattice == "B")
	    sweep_molv[i] = sweep_molv[i] / 2
	else if (global_lattice == "CXY")
	    sweep_molv[i] = sweep_molv[i] / 2
	else if (global_lattice == "CYZ")
	    sweep_molv[i] = sweep_molv[i] / 2
	else if (global_lattice == "CXZ")
	    sweep_molv[i] = sweep_molv[i] / 2
	else if (global_lattice == "R")
	    sweep_molv[i] = sweep_molv[i] / 1
	else if (global_lattice == "H")
	    sweep_molv[i] = sweep_molv[i] / 1
	sweep_ca_val[i] = sweep_c_val[i]/sweep_a_val[i]
	sweep_cb_val[i] = sweep_c_val[i]/sweep_b_val[i]
	sweep_ba_val[i] = sweep_b_val[i]/sweep_a_val[i]
    }
    # Calculate number of padding zeroes
    print "[info|sweep] Calculating padding zeroes..."
    if (!sweep_pad){
	sweep_pad = int(0.4343*log(sweep_iterations))+1
    }
    else{
	sweep_oldpad = sweep_pad
	sweep_pad = int(0.4343*log(sweep_iterations))+1
	if (sweep_pad != sweep_oldpad){
	    print "[info|sweep] Padding has changed, renaming..."
	    for (i=1;i<=sweep_olditerations;i++){
		sweep_filename[i] = sweep_root sprintf("%0*d",sweep_pad,i) ".wien"
		mysystem("mv -f "  sweep_root "/" sweep_root sprintf("%0*d",sweep_oldpad,i) "/ " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i))
		mysystem(const_renameexe " 's/" sweep_root sprintf("%0*d",sweep_oldpad,i) "/"sweep_root sprintf("%0*d",sweep_pad,i)"/' " sweep_root "/"sweep_root sprintf("%0*d",sweep_pad,i)"/*")
		mysystem(const_renameexe " 's/" sweep_root sprintf("%0*d",sweep_oldpad,i) "/"sweep_root sprintf("%0*d",sweep_pad,i)"/' " sweep_root "/"sweep_root sprintf("%0*d",sweep_pad,i)"/*/*")
		mysystem(const_renameexe " 's/" sweep_root sprintf("%0*d",sweep_oldpad,i) "/"sweep_root sprintf("%0*d",sweep_pad,i)"/' " sweep_root "/"sweep_root sprintf("%0*d",sweep_pad,i)"/*/*/*")
	    }
	}
    }
    # Reference struct name
    sweep_refname = global_root sprintf("%0*d",general_pad,sweep_ref) "/" global_root sprintf("%0*d",general_pad,sweep_ref)
    # Initialize index file if this is the first time sweep is run
    sweep_indexfile = sweep_root ".index"
    print "[info|sweep] Initializing sweep-index file..."
    ## Write index file header
    print "sweep index file -- generated by runwien.awk" > sweep_indexfile
    print "title:", general_title > sweep_indexfile
    print "root :", sweep_root > sweep_indexfile
    print "pwd  :", global_pwd "/" sweep_root > sweep_indexfile
    print "ref structure :", sweep_ref > sweep_indexfile
    for (i=1;i<=global_nneq;i++)
	print "npt " i " :", sweep_npt[i] > sweep_indexfile
    for (i=1;i<=global_nneq;i++)
	print "rmt " i " :", sweep_rmt[i] > sweep_indexfile
    for (i=1;i<=global_nneq;i++)
	print "r0 " i " :", sweep_r0[i] > sweep_indexfile
    print "rkmax :", sweep_rkmax > sweep_indexfile
    print "lmax  :", sweep_lmax > sweep_indexfile
    print "lnsmax:", sweep_lnsmax > sweep_indexfile
    print "gmax  :", sweep_gmax > sweep_indexfile
    print "mix   :", sweep_mix > sweep_indexfile
    print "kpts  :", sweep_kpts > sweep_indexfile
    printf "%-20s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-4s%-5s\n","filename","a","b","c","alpha","beta","gamma","volume","b/a","c/a","c/b","do","done" > sweep_indexfile
    # Use do and except keywords to determine which structures to run.
    ## Default : if nothing is set, only new structures.
    ## caution! global_dolines doesnt act as default here
    print "[info|sweep] Determining which structures to run..."
    if (!sweep_dolines){
	sweep_dolines = 1
	sweep_doline[1] = "new"
	sweep_dotype[1] = "do"
    }
    ## Parse all do lines, read all the fields and assign values.
    for (i=1;i<=sweep_dolines;i++){
	list_parser(sweep_doline[i])
	for (j=1;j<=global_niter;j++){
	    if (global_flag[j] ~ /all/ && sweep_dotype[i] ~ /do/){
		for (k=1;k<=sweep_iterations;k++){
		    sweep_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /none/ && sweep_dotype[i] ~ /do/){
		for (k=1;k<=sweep_iterations;k++){
		    sweep_do[k] = ""
		}
		continue
	    }
	    if (global_flag[j] ~ /new/ && sweep_dotype[i] ~ /do/){
		for (k=sweep_olditerations+1;k<=sweep_iterations;k++){
		    sweep_do[k] = 1
		}
		continue
	    }
	    if (global_flag[j] ~ /old/ && sweep_dotype[i] ~ /do/){
		for (k=1;k<=sweep_olditerations;k++){
		    sweep_do[k] = 1
		}
		continue
	    }
	    for(x=1;x<=global_num[j];x++){
		k = global_ini[j] + (x-1)*global_incr[j]
		if (sweep_dotype[i] ~ /do/){
		    sweep_do[k] = 1
		}
		else{
		    sweep_do[k] = ""
		}
	    }
	}
    }
    # Run through structures creating .wien and index file
    for (i=1;i<=sweep_iterations;i++){
	print "[info|sweep] Creating sweep structure #" i" and index file line..."
	## Give name to wien file
 	sweep_filename[i] = sweep_root sprintf("%0*d",sweep_pad,i) ".wien"
 	## Line in sweep index file
	temp_format = "%-19s %-9f %-9f %-9f %-9f %-9f %-9f %-9f %-9f %-9f %-9f %-3s %-4s \n"
	temp_string = sweep_filename[i]
	gsub(".wien","",temp_string)
 	printf temp_format,temp_string,sweep_a_val[i],sweep_b_val[i],sweep_c_val[i],sweep_alpha_val[i],sweep_beta_val[i],sweep_gamma_val[i],\
	    sweep_molv[i], sweep_ba_val[i], sweep_ca_val[i],sweep_cb_val[i],sweep_do[i]?"yes":"no",sweep_done[i]?"yes":"no" >> sweep_indexfile
	## Generate .wien file for this structure
	if (global_parallel)
	    print "parallel " global_pwd "/" sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/machines" > sweep_filename[i]
	print "general" > sweep_filename[i]
	print "  loadstruct " global_root sprintf("%0*d",general_pad,sweep_ref) ".struct" > sweep_filename[i]
	printf "  cell parameters %.10f %.10f %.10f %.10f %.10f %.10f\n", sweep_a_val[i], sweep_b_val[i], \
	    sweep_c_val[i],sweep_alpha_val[i],sweep_beta_val[i],sweep_gamma_val[i] > sweep_filename[i]
	print "  title " general_title " sweep structure #" i > sweep_filename[i]
	if (global_spinpolarized == "yes")
	    print "  spinpolarized yes" > sweep_filename[i]
	else
	    print "  spinpolarized no" > sweep_filename[i]
	for (j=1;j<=global_nneq;j++)
	    print "  rmt " j " " sweep_rmt[j] > sweep_filename[i]
	for (j=1;j<=global_nneq;j++)
	    print "  r0 " j " " sweep_r0[j] > sweep_filename[i]
	for (j=1;j<=global_nneq;j++)
	    print "  npt " j " " sweep_npt[j] > sweep_filename[i]
	print "  rkmax      " sweep_rkmax > sweep_filename[i]
	print "  lmax       " sweep_lmax > sweep_filename[i]
	print "  lnsmax     " sweep_lnsmax > sweep_filename[i]
	print "  gmax       " sweep_gmax > sweep_filename[i]
	print "  mix  " sweep_mix > sweep_filename[i]
	print "  kpts    " sweep_kpts > sweep_filename[i]
	if (sweep_ldau){
	    print "  lda+u " sweep_ldautype > sweep_filename[i]
	    for (k=1;k<=sweep_ldaus;k++)
		print "  " sweep_ldau_atom[k] " " sweep_ldau_l[k] " " sweep_ldau_defu[k] " " sweep_ldau_defj[k] > sweep_filename[i]
	    print "  end lda+u " sweep_ldautype > sweep_filename[i]
	}
	print "end general" > sweep_filename[i]
	print "initialization" > sweep_filename[i]
	if (sweep_potential)
	    print "  xcpotential "sweep_potential > sweep_filename[i]
	if (sweep_ecoreval)
	    print "  ecoreval "sweep_ecoreval > sweep_filename[i]
	if (sweep_ifft)
	    print "  ifft "sweep_ifft > sweep_filename[i]
	if (sweep_energymin)
	    print "  energymin "sweep_energymin > sweep_filename[i]
	if (sweep_energymax)
	    print "  energymax "sweep_energymax > sweep_filename[i]
	if (sweep_fermi)
	    print "  fermi " sweep_fermi " " sweep_fermival > sweep_filename[i]
	for (j=1;j<=global_nneq;j++){
	    if (sweep_orbitals[j]){
		print "  orbitals " j " " sweep_orbital_globe[j] " " sweep_orbital_globapw[j]> sweep_filename[i]
		for (k=1;k<=sweep_orbitals[j];k++){
		    print "   ",sweep_orbital_l[j,k],sweep_orbital_energy[j,k],sweep_orbital_var[j,k],sweep_orbital_cont[j,k],sweep_orbital_apw[j,k] > sweep_filename[i]
		}
		print "  end orbitals " > sweep_filename[i]
	    }
	    if (sweep_lms[j]){
		print "  lm list " j > sweep_filename[i]
		temp_string = ""
		for (k=1;k<=sweep_lms[j];k++){
		    temp_string = temp_string "  " sweep_lm_l[j,k] " " sweep_lm_m[j,k]
		}
		print temp_string > sweep_filename[i]
		print "  end lm list " > sweep_filename[i]
	    }
	}
	print "end initialization" > sweep_filename[i]
	print "prescf " > sweep_filename[i]
	if (sweep_nice)
	    print "  nice " sweep_nice > sweep_filename[i]
	print "  kgenshift " prescf_kgenshift > sweep_filename[i]
	print "  kgenoutput " prescf_kgenoutput > sweep_filename[i]
	print "end prescf " > sweep_filename[i]
	print "scf " > sweep_filename[i]
	if (!sweep_noreuse){
	    if (sweep_reusemode == "reference")
		print "  reuse path " global_pwd "/" global_root sprintf("%0*d",general_pad,sweep_ref) > sweep_filename[i]
	    else if (sweep_reusemode == "chain"){
		if (i>1)
		    print "  reuse path " global_pwd "/" sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i-1) "/"  sweep_root sprintf("%0*d",sweep_pad,i-1) "1/" > sweep_filename[i]
	    }
	    else if (sweep_reusemode == "path"){
		if (substr(sweep_reuseval,1,1) != "/")
		    sweep_reuseval = global_pwd "/" sweep_reuseval
		print "  reuse path " sweep_reuseval > sweep_filename[i]
	    }
	    else{
		# detect calculated points
		temp_val = mysystem("ls -d " sweep_root "/*/*1/ > tempfile 2>&1")
		if (temp_val == 0){
		    temp_flag = ""
		    for (;getline temp_string < "tempfile";){
			temp_root = temp_string
			gsub(/\/( |\t)*$/,"",temp_root)
			gsub(/^.*\//,"",temp_root)
			if (global_spinpolarized == "yes"){
			    if (checkexists(temp_string temp_root ".clmdn") && checkexists(temp_string temp_root ".clmup") && checkexists(temp_string temp_root ".struct") && checkexists(temp_string temp_root ".scf")){
				temp_flag = 1
				break
			    }
			}
			else
			    if (checkexists(temp_string temp_root ".clmsum") && checkexists(temp_string temp_root ".struct") && checkexists(temp_string temp_root ".scf")){
				temp_flag = 1
				break
			    }
		    }
		    if (temp_flag)
			print "  reuse path " global_pwd "/" temp_string > sweep_filename[i]
		    else
			print "[sweep|warn] No adequate sweep structure found for reusing."
		    close("tempfile")
		}
		else
		    print "[sweep|warn] No adequate sweep structure found for reusing."
		mysystem("rm -f tempfile")
	    }
	}
	if (sweep_itdiag)
	    print "  itdiag " sweep_itdiag > sweep_filename[i]
	if (sweep_nice)
	    print "  nice " sweep_nice > sweep_filename[i]
	if (sweep_miter)
	    print "  max iterations " sweep_miter > sweep_filename[i]
	if (sweep_cc)
	    print "  charge conv " sweep_cc > sweep_filename[i]
	if (sweep_ec)
	    print "  energy conv " sweep_ec > sweep_filename[i]
	if (sweep_fc)
	    print "  force conv " sweep_fc > sweep_filename[i]
	if (sweep_in1new)
	    print "  new in1 " sweep_in1new > sweep_filename[i]
	if (sweep_mini)
	    if (sweep_mini == "defline")
		print "  mini " > sweep_filename[i]
	    else
		print "  mini " sweep_mini > sweep_filename[i]
	print "end scf " > sweep_filename[i]
	if (sweep_so_do[i] || sweep_so_doall){
	    print "spinorbit " > sweep_filename[i]
	    for (j=1;j<=sweep_so_lines;j++){
		print sweep_so_line[j] > sweep_filename[i]
	    }
	    print "end spinorbit " > sweep_filename[i]
	}
	if (sweep_elastic_do[i] || sweep_elastic_doall){
	    print "elastic " > sweep_filename[i]
	    for (j=1;j<=sweep_elastic_lines;j++){
		print sweep_elastic_line[j] > sweep_filename[i]
	    }
	    print "end elastic " > sweep_filename[i]
	}
	if (sweep_prho_do[i] || sweep_prho_doall){
	    print "printrho " > sweep_filename[i]
	    for (j=1;j<=sweep_prho_lines;j++){
		print sweep_prho_line[j] > sweep_filename[i]
	    }
	    print "end printrho " > sweep_filename[i]
	}
	if (sweep_dos_do[i] || sweep_dos_doall){
	    print "dosplot " > sweep_filename[i]
	    for (j=1;j<=sweep_dos_lines;j++){
		print sweep_dos_line[j] > sweep_filename[i]
	    }
	    print "end dosplot " > sweep_filename[i]
	}
	if (sweep_rx_do[i] || sweep_rx_doall){
	    print "rxplot " > sweep_filename[i]
	    for (j=1;j<=sweep_rx_lines;j++){
		print sweep_rx_line[j] > sweep_filename[i]
	    }
	    print "end rxplot " > sweep_filename[i]
	}
	if (sweep_band_do[i] || sweep_band_doall){
	    print "bandplot " > sweep_filename[i]
	    for (j=1;j<=sweep_band_lines;j++){
		print sweep_band_line[j] > sweep_filename[i]
	    }
	    print "end bandplot " > sweep_filename[i]
	}
	if (sweep_kdos_do[i] || sweep_kdos_doall){
	    print "kdos " > sweep_filename[i]
	    for (j=1;j<=sweep_kdos_lines;j++){
		print sweep_kdos_line[j] > sweep_filename[i]
	    }
	    print "end kdos " > sweep_filename[i]
	}
	if (sweep_aim_do[i] || sweep_aim_doall){
	    print "aim " > sweep_filename[i]
	    for (j=1;j<=sweep_aim_lines;j++){
		print sweep_aim_line[j] > sweep_filename[i]
	    }
	    print "end aim " > sweep_filename[i]
	}
	if (sweep_critic_do[i] || sweep_critic_doall){
	    print "critic " > sweep_filename[i]
	    for (j=1;j<=sweep_critic_lines;j++){
		print sweep_critic_line[j] > sweep_filename[i]
	    }
	    print "end critic " > sweep_filename[i]
	}
	print "synopsis " > sweep_filename[i]
	print "  exhaustive" > sweep_filename[i]
	print "end synopsis " > sweep_filename[i]
	if (sweep_clean)
	    print sweep_clean > sweep_filename[i]
	close(sweep_filename[i])
    }
    close(sweep_indexfile)
    # Generate directory
    print "[info|sweep] Creating directory tree structure and moving .wien..."
    mysystem("mkdir " sweep_root " > /dev/null 2>&1")
    for (i=1;i<=sweep_iterations;i++){
	## Name directory
	sweep_curname = sweep_root "/" sweep_filename[i]
	gsub(".wien","",sweep_curname)
	## Create dir and move files (errors caused by existing dirs
	## redirected to /dev/null)
	mysystem("mkdir " sweep_curname " > /dev/null 2>&1")
	mysystem("mv -f " sweep_indexfile " " sweep_root " > /dev/null 2>&1")
	## If recalculating or if the case does not exist, remove previous dir and copy the files. Else, delete them.
	if (sweep_do[i] || !checkexists(sweep_curname "/" sweep_filename[i])){
	    mysystem("rm -rf " sweep_curname "/*")
	    mysystem("mv -f " sweep_filename[i] " " sweep_curname)
	    ### Copy reference struct file
	    mysystem("cp -f "  sweep_refname ".struct " sweep_curname)
	}
	else{
	    mysystem("rm -f " sweep_filename[i])
	}
	# Copy .machines file if parallel
	if (global_parallel)
	    mysystem("cp -f " global_machines " " sweep_curname "/machines > /dev/null 2>&1")
    }
    # Write down index file
    if (!isin(sweep_root "/" sweep_indexfile,global_file_index)){
	global_file_index_n++
	global_file_index[global_file_index_n] = sweep_root "/" sweep_indexfile
    }
    # Do the calculations
    for (i=1;i<=sweep_iterations;i++){
	if (sweep_do[i]){
	    # Time count
	    sweep_time[i] = systime()
	    print "[info|sweep] Calculating sweep structure #" i"..."
	    # Create script to run calculation
	    sweep_curname = sweep_root sprintf("%0*d",sweep_pad,i)
	    print "#! /bin/bash " > "sweep-script"
	    print "cd " sweep_root "/" sweep_curname > "sweep-script"
	    print "runwien.awk " sweep_filename[i] " > " const_sweeprunout " 2>&1" > "sweep-script"
	    close("sweep-script")
	    mysystem("chmod u+x sweep-script")
	    # Do it!
	    mysystem("./sweep-script")
	    mysystem("rm -f sweep-script")
	    # Write down output file
	    if (!isin(sweep_root "/" sweep_curname "/" const_sweeprunout,global_file_out)){
		global_file_out_n++
		global_file_out[global_file_out_n] = sweep_root "/" sweep_curname "/" const_sweeprunout
	    }
	    # Extract info from each structure
	    print "[info|sweep] Extracting information from structure #" i"..."
	    sweep_curname = sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,i) "/" sweep_root sprintf("%0*d",sweep_pad,i) "1/" sweep_root sprintf("%0*d",sweep_pad,i) "1"
	    if (checkexists(sweep_curname ".scf")){
		temp_string = const_lapwgetetotalexe " " sweep_curname ".scf"
		temp_string | getline sweep_energy[i]
		close(temp_string)
		temp_string = const_lapwgetefermiexe " " sweep_curname ".scf"
		temp_string | getline sweep_efermi[i]
		close(temp_string)
		temp_string = const_lapwgetiterationsexe " " sweep_curname ".scf"
		temp_string | getline sweep_noiter[i]
		close(temp_string)
		sweep_molenergy[i] = sprintf("%.10f",sweep_energy[i] / global_gcdmult)
		sweep_warns[i] = 0
		if (sweep_noiter[i]+0 >= sweep_miter+0){
		    sweep_warns[i]++
		    sweep_warn[i,sweep_warns[i]] = const_warn_maxiter
		}
		else{
		    mysystem(const_lapwcheckdayfileexe " " sweep_curname ".dayfile > tempfile")
		    for (;getline temp_string < "tempfile";){
			sweep_warns[i]++
			sweep_warn[i,sweep_warns[i]] = temp_string
		    }
		    close("tempfile")
		    mysystem("rm -rf tempfile")
		}
		if (abs(sweep_efermi[i] - sweep_energymax) < 0.1){
		    sweep_warns[i]++
		    sweep_warn[i,sweep_warns[i]] = const_warn_efermi
		}
		mysystem(const_lapwcheckscfexe " " sweep_curname ".scf > tempfile")
		for (;getline temp_string < "tempfile";){
		    sweep_warns[i]++
		    sweep_warn[i,sweep_warns[i]] = temp_string
		}
		close("tempfile")
		mysystem("rm -rf tempfile")
	    }
	    else{
		sweep_energy[i] = "n/a"
		sweep_molenergy[i] = "n/a"
		sweep_efermi[i] = "n/a"
		sweep_noiter[i] = "n/a"
	    }
	    if (checkexists(sweep_curname ".outputcritic")){
		temp_string = "lapw_extractcritic.awk planarity " sweep_curname ".outputcritic"
		temp_string | getline sweep_planarity[i]
		close(temp_string)
		temp_string = "lapw_extractcritic.awk topology " sweep_curname ".outputcritic"
		temp_string | getline sweep_topology[i]
		close(temp_string)
		temp_string = "lapw_extractcritic.awk morsesum " sweep_curname ".outputcritic"
		temp_string | getline sweep_morsesum[i]
		close(temp_string)
	    }
	    else{
		sweep_planarity[i] = "n/a"
		sweep_morsesum[i] = "n/a"
		sweep_topology[i] = "n/a"
	    }
	    # Marking as done
	    print "[info|sweep] Marking as done..."
	    sweep_done[i] = 1
	    # Time count
	    sweep_time[i] = systime() - sweep_time[i]
	    # Generate checkpoint -- useful if run is interrupted
	    print "[info|sweep] Writing checkpoints..."
	    global_savecheck(global_root "-check/global.check")
	    sweep_savecheck(global_root "-check/sweep.check")
	}
    }
    # Create summary
    if (!sweep_nosummary){
	print "[info|sweep] Printing sweep summary file..."
	# Write index file header, if necessary
	print "sweep summary file" > const_sweepsumout
	print "title:", general_title > const_sweepsumout
	print "root :", sweep_root > const_sweepsumout
	print "pwd  :", global_pwd "/" sweep_root > const_sweepsumout
	print "ref structure :", sweep_ref > const_sweepsumout
	for (i=1;i<=global_nneq;i++)
	    print "npt " i " /bohr :", sweep_npt[i] > const_sweepsumout
	for (i=1;i<=global_nneq;i++)
	    print "rmt " i " /bohr :", sweep_rmt[i] > const_sweepsumout
	for (i=1;i<=global_nneq;i++)
	    print "r0 " i " /bohr :", sweep_r0[i] > const_sweepsumout
	print "rkmax      :", sweep_rkmax > const_sweepsumout
	print "lmax       :", sweep_lmax > const_sweepsumout
	print "lnsmax     :", sweep_lnsmax > const_sweepsumout
	print "gmax       :", sweep_gmax > const_sweepsumout
	print "mix        :", sweep_mix > const_sweepsumout
	print "kpts       :", sweep_kpts > const_sweepsumout
	if (sweep_ldau){
	    print "lda+u activated with lines : "
	    for (k=1;k<=sweep_ldaus;k++)
		print "   " sweep_ldau_atom[k] " " sweep_ldau_l[k] " " sweep_ldau_defu[k] " " sweep_ldau_defj[k] 
	}
	printf "%-20s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-4s%-15s%-15s%-10s%-6s%-20s\n","filename","a /bohr","b /bohr","c /bohr","alpha/ang","beta/ang","gamma/ang","v /bohr^3","b/a","c/a","c/b","it.","energy/ry","efermi/ry","planarity","morse","topology" > const_sweepsumout
	# Write structure's extracted information
	for (i=1;i<=sweep_iterations;i++){
	    temp_format = "%-19s %-9s %-9s %-9s %-9s %-9s %-9s %-9s %-9s %-9s %-9s %-3s %-14s %-14s %-9s %-5s %-20s \n"
	    temp_string = sweep_filename[i]
	    gsub(".wien","",temp_string)
	    if (sweep_done[i])
		printf temp_format,temp_string,sweep_a_val[i],sweep_b_val[i],sweep_c_val[i],sweep_alpha_val[i],sweep_beta_val[i],sweep_gamma_val[i],sweep_molv[i],sweep_ba_val[i],sweep_ca_val[i],sweep_cb_val[i],sweep_noiter[i],sweep_molenergy[i],sweep_efermi[i],sweep_planarity[i],sweep_morsesum[i], sweep_topology[i] >> const_sweepsumout
	    else
		print temp_string "     --- not done --- " >> const_sweepsumout
	}
	close(const_sweepsumout)
	if (!isin(const_sweepsumout,global_file_out)){
	    global_file_out_n++
	    global_file_out[global_file_out_n] = const_sweepsumout
	}
    }
    # Creating prints. Include old and new alike
    print "[info|sweep] Printing required plots..."
    for (i=1;i<=sweep_prints;i++){
	for (j=1;j<=sweep_iterations;j++){
	    if (sweep_done[j]){
		temp_string = ""
		if (sweep_print_x[i] == "a")
		    temp_string = temp_string sprintf("%.10f",sweep_a_val[j]) " "
		else if (sweep_print_x[i] == "b")
		    temp_string = temp_string sprintf("%.10f",sweep_b_val[j]) " "
		else if (sweep_print_x[i] == "c")
		    temp_string = temp_string sprintf("%.10f",sweep_c_val[j]) " "
		else if (sweep_print_x[i] == "alpha")
		    temp_string = temp_string sprintf("%.10f",sweep_alpha_val[j]) " "
		else if (sweep_print_x[i] == "beta")
		    temp_string = temp_string sprintf("%.10f",sweep_beta_val[j]) " "
		else if (sweep_print_x[i] == "gamma")
		    temp_string = temp_string sprintf("%.10f",sweep_gamma_val[j]) " "
		else if (sweep_print_x[i] == "v")
		    temp_string = temp_string sprintf("%.10f",sweep_molv[j]) " "
		else if (sweep_print_x[i] == "c/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ca_val[j]) " "
		else if (sweep_print_x[i] == "c/b")
		    temp_string = temp_string sprintf("%.10f",sweep_cb_val[j]) " "
		else if (sweep_print_x[i] == "b/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ba_val[j]) " "

		if (sweep_print_y[i] == "energy")
		    temp_string = temp_string sprintf("%.10f",sweep_molenergy[j]) " "
		else if (sweep_print_y[i] == "efermi")
		    temp_string = temp_string sprintf("%.10f",sweep_efermi[j]) " "
		else if (sweep_print_y[i] == "planarity")
		    temp_string = temp_string sprintf("%.10f",sweep_planarity[j]) " "
		else if (sweep_print_y[i] == "topology")
		    temp_string = temp_string sweep_topology[j] " "
		else if (sweep_print_y[i] == "a")
		    temp_string = temp_string sprintf("%.10f",sweep_a_val[j]) " "
		else if (sweep_print_y[i] == "b")
		    temp_string = temp_string sprintf("%.10f",sweep_b_val[j]) " "
		else if (sweep_print_y[i] == "c")
		    temp_string = temp_string sprintf("%.10f",sweep_c_val[j]) " "
		else if (sweep_print_y[i] == "alpha")
		    temp_string = temp_string sprintf("%.10f",sweep_alpha_val[j]) " "
		else if (sweep_print_y[i] == "beta")
		    temp_string = temp_string sprintf("%.10f",sweep_beta_val[j]) " "
		else if (sweep_print_y[i] == "gamma")
		    temp_string = temp_string sprintf("%.10f",sweep_gamma_val[j]) " "
		else if (sweep_print_y[i] == "v")
		    temp_string = temp_string sprintf("%.10f",sweep_molv[j]) " "
		else if (sweep_print_y[i] == "c/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ca_val[j]) " "
		else if (sweep_print_y[i] == "c/b")
		    temp_string = temp_string sprintf("%.10f",sweep_cb_val[j]) " "
		else if (sweep_print_y[i] == "b/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ba_val[j]) " "

		if (sweep_print_z[i] == "energy")
		    temp_string = temp_string sprintf("%.10f",sweep_molenergy[j])
		else if (sweep_print_z[i] == "efermi")
		    temp_string = temp_string sprintf("%.10f",sweep_efermi[j])
		else if (sweep_print_z[i] == "planarity")
		    temp_string = temp_string sprintf("%.10f",sweep_planarity[j])
		else if (sweep_print_z[i] == "topology")
		    temp_string = temp_string sweep_topology[j]
		else if (sweep_print_z[i] == "a")
		    temp_string = temp_string sprintf("%.10f",sweep_a_val[j])
		else if (sweep_print_z[i] == "b")
		    temp_string = temp_string sprintf("%.10f",sweep_b_val[j])
		else if (sweep_print_z[i] == "c")
		    temp_string = temp_string sprintf("%.10f",sweep_c_val[j])
		else if (sweep_print_z[i] == "alpha")
		    temp_string = temp_string sprintf("%.10f",sweep_alpha_val[j])
		else if (sweep_print_z[i] == "beta")
		    temp_string = temp_string sprintf("%.10f",sweep_beta_val[j])
		else if (sweep_print_z[i] == "gamma")
		    temp_string = temp_string sprintf("%.10f",sweep_gamma_val[j])
		else if (sweep_print_z[i] == "v")
		    temp_string = temp_string sprintf("%.10f",sweep_molv[j])
		else if (sweep_print_z[i] == "c/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ca_val[j])
		else if (sweep_print_z[i] == "c/b")
		    temp_string = temp_string sprintf("%.10f",sweep_cb_val[j])
		else if (sweep_print_z[i] == "b/a")
		    temp_string = temp_string sprintf("%.10f",sweep_ba_val[j])
		print temp_string > sweep_root ".print" i
	    }
	}
	close(sweep_root ".print" i)
	## Sort the file using the first field
	mysystem("sort -g -k 2 " sweep_root ".print" i " | sort -g -k 1 > tempfile 2>&1")
	mysystem("mv tempfile " sweep_root ".print" i)
	## Make gnuplot plots if external script is associated
	if (const_gnuplot[sweep_print_x[i],sweep_print_y[i],sweep_print_z[i]])
	    if (checkexe(const_gnuplot[sweep_print_x[i],sweep_print_y[i],sweep_print_z[i]]))
		mysystem(const_gnuplot[sweep_print_x[i],sweep_print_y[i],sweep_print_z[i]] " " sweep_root ".print" i )
    }
    # Write down sweep synopsis.out files
    temp_command = "ls " sweep_root "/*/synopsis.out"
    for (;temp_command | getline temp_string;){
	if (!isin(temp_string,global_file_out)){
	    global_file_out_n++
	    global_file_out[global_file_out_n] = temp_string
	}
    }
    close(temp_string)
    # Get end time
    sweep_totaltime = systime() - sweep_totaltime
    # Generate checkpoint
    print "[info|sweep] Writing checkpoints..."
    global_savecheck(global_root "-check/global.check")
    sweep_savecheck(global_root "-check/sweep.check")
    # End message
    print "[info|sweep] Sweep section ended successfully..."
    printf "\n"
    next
}
# (xgibbsx) Gibbs section final tasks
 /^( |\t)*end( |\t)*gibbs( |\t)*$/ && global_section=="gibbs"{
     global_section = ""
     gibbs_run = 1
     print ""
     print "[info|gibbs] Beginning of gibbs section at " date()
     # Verify needed sections were run
     print "[info|gibbs] Verifying needed sections were run..."
     if (!general_run || !init_run || !prescf_run || !scf_run || !sweep_run){
	 print "[error|gibbs] cannot run gibbs."
	 print "[error|gibbs] needed section has not been run or loaded."
	 exit 1
     }
     # Check for executables
     print "[info|gibbs] Checking for executables..."
     delete temp_array
     temp_array[const_gibbsexe] = 1
     for (i in temp_array){
	 if (!checkexe(i)){
	     print "[error|gibbs] Executable not found: " i
	     exit 1
	 }
     }
     # Get initial time
     gibbs_totaltime = systime()
     # Set default variales
     print "[info|gibbs] Setting default variables if missing..."
     if (!gibbs_eos){
 	gibbs_eos = "numerical"
     }
     if (gibbs_eos == "bcnt" || gibbs_eos == "numerical+bcnt"){
 	if (!gibbs_bcnt){
 	    gibbs_bcnt = 0
 	}
     }
     if (!gibbs_debye){
 	gibbs_debye = "debyestatic"
     }
     if (!gibbs_ps){
	 gibbs_ps = 1
	 gibbs_p[1] = 0
     }
     if (!gibbs_ts){
	 gibbs_ts = 1
	 gibbs_t[1] = 0
     }
     if (!gibbs_freeenergy){
	 if (free_frtotalenergy)
	     gibbs_freeenergy = free_frtotalenergy / 2
	 else
	     gibbs_freeenergy = init_frtotalenergy / 2
     }
     # Calculate number of atoms in molecular formula
     print "[info|gibbs] Calculating number of atoms in mol. formula..."
     gibbs_atoms = 0
     for (i=1;i<=global_nneq;i++){
	 gibbs_atoms += global_molatoms[i]
     }
     # Create gibbs input
     ## Note that energies must be Hy
     print "[info|gibbs] Creating gibbs input..."
     gibbs_filename = global_root ".ingibbs"
     print general_title > gibbs_filename
     print global_root ".outputgibbs"  > gibbs_filename
     print gibbs_atoms > gibbs_filename
     printf "%.10f\n",global_molmass > gibbs_filename
     printf "%.10f\n",gibbs_freeenergy > gibbs_filename
     if (gibbs_eos == "numerical")
	 print 0 > gibbs_filename
     else if (gibbs_eos == "vinet")
	 print 1 > gibbs_filename
     else if (gibbs_eos == "birch")
	 print 2 > gibbs_filename
     else if (gibbs_eos == "numerical+vinet")
	 print 3 > gibbs_filename
     else if (gibbs_eos == "numerical+birch")
	 print 4 > gibbs_filename
     else if (gibbs_eos == "bcnt"){
	 print 5 > gibbs_filename
	 print gibbs_bcnt > gibbs_filename
     }
     else if (gibbs_eos == "numerical+bcnt"){
	 print 6 > gibbs_filename
	 print gibbs_bcnt > gibbs_filename
     }
     if (gibbs_debye == "static")
	 print -1 > gibbs_filename
     else if (gibbs_debye == "debyestatic")
	 if (gibbs_poisson)
	     printf "0 %.10f\n",gibbs_poisson > gibbs_filename
	 else
	     print 0 > gibbs_filename
     else if (gibbs_debye == "debyeiter")
	 if (gibbs_poisson)
	     printf "2 %.10f\n",gibbs_poisson > gibbs_filename
	 else
	     print 2 > gibbs_filename
     else if (gibbs_debye == "debyestaticbv")
	 print 3 > gibbs_filename

     temp_string = gibbs_ps
     for (i=1;i<=gibbs_ps;i++){
	 temp_string = temp_string " " sprintf("%.10f",gibbs_p[i])
     }
     print temp_string > gibbs_filename
     if (gibbs_ts){
	 temp_string = gibbs_ts
	 for (i=1;i<=gibbs_ts;i++){
	     temp_string = temp_string " " sprintf("%.10f",gibbs_t[i])
	 }
	 print temp_string > gibbs_filename
     }
     else{
	 print "0" > gibbs_filename
     }
     temp_val = 0
     for (i=1;i<=sweep_iterations;i++){
	 if (sweep_done[i] && (sweep_molenergy[i]+0 != 0))
	     temp_val++
     }
     print temp_val > gibbs_filename
     for (i=1;i<=sweep_iterations;i++){
	 if (sweep_done[i] && (sweep_molenergy[i]+0 != 0))
	     printf "%.10f %.10f\n",sweep_molv[i],sweep_molenergy[i] / 2 > gibbs_filename
     }
     close(gibbs_filename)
     # Run gibbs
     print "[info|gibbs] Running gibbs..."
     mysystem(const_gibbsexe " < " gibbs_filename " > errfile 2>&1")
     if (checkerror("errfile","checkword","STOP")){
	 print "[warn|gibbs] Gibbs execution failed!"
	 if (checkerror("errfile","checkword","monotonic")){
	     ## Get maximum p allowed
	     print "[info|gibbs] Eliminating non-valid pressures..."
	     getline temp_string < "errfile"
	     getline temp_string < "errfile"
	     split(temp_string,temp_array," ")
	     temp_val = temp_array[2]
	     close("errfile")
	     ## Clean higher than temp_val pressures
	     delete temp_array
	     temp_val2 = 0
	     for (i=1;i<=gibbs_ps;i++){
		 if (gibbs_p[i] < temp_val){
		     temp_val2++
		     temp_array[temp_val2] = gibbs_p[i]
		 }
	     }
	     ## Copy new array
	     print "[info|gibbs] " gibbs_ps - temp_val2 " pressures eliminated."
	     gibbs_ps = temp_val2
	     delete gibbs_p
	     for (i=1;i<=gibbs_ps;i++){
		 gibbs_p[i] = temp_array[i]
	     }
	     ## Create new input file
	     print "[info|gibbs] Creating new .ingibbs"
	     temp_val = 0
	     for (;getline temp_string < gibbs_filename;){
		 temp_val++
		 if (temp_val == 8){
		     temp_val2 = gibbs_ps
		     for (i=1;i<=gibbs_ps;i++){
			 temp_val2 = temp_val2 " " sprintf("%.10f",gibbs_p[i])
		     }
		     print temp_val2 > "tempfile"
		 }
		 else
		     print temp_string > "tempfile"
	     }
	     close("tempfile")
	     mysystem("mv -f tempfile " gibbs_filename)
	     print "[info|gibbs] Rerunning gibbs..."
	     mysystem(const_gibbsexe " < " gibbs_filename " > errfile 2>&1")
	 }
	 else{
	     print "[warn|gibbs] Unknown error. Check errfile"
	 }
     }
     mysystem("mv -f errfile " global_root ".gibbs.err")
     # Move input and output to gibbs dir
     mysystem("mkdir " global_root "-gibbs > /dev/null 2>&1")
     mysystem("mv -f " global_root ".ingibbs " global_root "-gibbs/")
     mysystem("mv -f " global_root ".outputgibbs " global_root "-gibbs/")
     mysystem("mv -f " global_root ".gibbs.err " global_root "-gibbs/")
     # Get end time
     gibbs_totaltime = systime() - gibbs_totaltime
     # Generate checkpoint
     print "[info|gibbs] Writing checkpoints..."
     global_savecheck(global_root "-check/global.check")
     gibbs_savecheck(global_root "-check/gibbs.check")
     # End message
     print "[info|gibbs] Gibbs section ended successfully..."
     printf "\n"
     next
}
# (xsynx) Synopsis section final tasks
 /^( |\t)*end( |\t)*synopsis( |\t)*$/ && global_section=="synopsis"{
     global_section = ""
     syn_run = 1
     print ""
     print "[info|syn] Beginning of synopsis section at " date()
     # Set default variales
     print "[info|syn] Setting default variables if missing..."
     if (!syn_output){
	 syn_output = const_synoutput
     }
     # Write down file
     if (!isin(syn_output,global_file_out)){
	 global_file_out_n++
	 global_file_out[global_file_out_n] = syn_output
     }
     # Probe for variable parameters in general, etc. section
     print "[info|syn] Probing for variable parameters in general section..."
     for (i=1;i<=general_iterations;i++){
	 for (j=1;j<=global_nneq;j++){
	     temp_idstring = "npt" j
	     if (i>1 && !equal(general_val[temp_idstring,general_index[temp_idstring,i]],general_val[temp_idstring,general_index[temp_idstring,i-1]]))
		 syn_npt_variable[j] = 1
	     temp_idstring = "rmt" j
	     if (i>1 && !equal(general_val[temp_idstring,general_index[temp_idstring,i]],general_val[temp_idstring,general_index[temp_idstring,i-1]]))
		 syn_rmt_variable[j] = 1
	     temp_idstring = "r0" j
	     if (i>1 && !equal(general_val[temp_idstring,general_index[temp_idstring,i]],general_val[temp_idstring,general_index[temp_idstring,i-1]]))
		 syn_r0_variable[j] = 1
	 }
	 if (i>1 && !equal(general_val["rkmax",general_index["rkmax",i]],general_val["rkmax",general_index["rkmax",i-1]]))
	     syn_rkmax_variable = 1
	 if (i>1 && !equal(general_val["lmax",general_index["lmax",i]],general_val["lmax",general_index["lmax",i-1]]))
	     syn_lmax_variable = 1
	 if (i>1 && !equal(general_val["lnsmax",general_index["lnsmax",i]],general_val["lnsmax",general_index["lnsmax",i-1]]))
	     syn_lnsmax_variable = 1
	 if (i>1 && !equal(general_val["gmax",general_index["gmax",i]],general_val["gmax",general_index["gmax",i-1]]))
	     syn_gmax_variable = 1
	 if (i>1 && !equal(general_val["mix",general_index["mix",i]],general_val["mix",general_index["mix",i-1]]))
	     syn_mix_variable = 1
	 if (i>1 && !equal(general_val["kpts",general_index["kpts",i]],general_val["kpts",general_index["kpts",i-1]]))
	     syn_kpts_variable = 1
	 if (global_ldau)
	     for (j=1;j<=global_ldaus;j++){
		 temp_idstring = "u" j
		 if (i>1 && !equal(general_val[temp_idstring,general_index[temp_idstring,i]],general_val[temp_idstring,general_index[temp_idstring,i-1]]))
		     syn_u_variable[j] = 1
		 temp_idstring = "j" j
		 if (i>1 && !equal(general_val[temp_idstring,general_index[temp_idstring,i]],general_val[temp_idstring,general_index[temp_idstring,i-1]]))
		     syn_j_variable[j] = 1
	     }
     }
     # Probe for variable parameters in sweep section
     print "[info|syn] Probing for variable parameters in sweep section..."
     for (i=1;i<=sweep_iterations;i++){
	 if (i>1 && !equal(sweep_a_val[i],sweep_a_val[i-1]))
	     syn_a_variable = 1
	 if (i>1 && !equal(sweep_b_val[i],sweep_b_val[i-1]))
	     syn_b_variable = 1
	 if (i>1 && !equal(sweep_c_val[i],sweep_c_val[i-1]))
	     syn_c_variable = 1
	 if (i>1 && !equal(sweep_alpha_val[i],sweep_alpha_val[i-1]))
	     syn_alpha_variable = 1
	 if (i>1 && !equal(sweep_beta_val[i],sweep_beta_val[i-1]))
	     syn_beta_variable = 1
	 if (i>1 && !equal(sweep_gamma_val[i],sweep_gamma_val[i-1]))
	     syn_gamma_variable = 1
	 if (i>1 && !equal(sweep_molv[i],sweep_molv[i-1]))
	     syn_v_variable = 1
	 if (i>1 && !equal(sweep_ca_val[i],sweep_ca_val[i-1]))
	     syn_ca_variable = 1
	 if (i>1 && !equal(sweep_cb_val[i],sweep_cb_val[i-1]))
	     syn_cb_variable = 1
	 if (i>1 && !equal(sweep_ba_val[i],sweep_ba_val[i-1]))
	     syn_ba_variable = 1
     }
     # Calculate times
     print "[info|syn] Calculating times..."
     for (i=1;i<=general_iterations;i++){
	 syn_time[i] = init_time[i] + prescf_time[i] + scf_time[i] + prho_time[i] + dos_time[i] +\
	     band_time[i] + kdos_time[i] + rx_time[i] + aim_time[i] + critic_time[i]
     }
     # Print info
     print "[info|syn] Printing synopsis..."
     print "General information" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     print "title   :",general_title > syn_output
     print "root    :",global_root > syn_output
     print "pwd     :",global_pwd > syn_output
     print "machine :",global_machine > syn_output
     print "date    :",date() > syn_output
     print "" > syn_output
     print "Sections run and time information" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     if (general_run)
	 print "general section run, time (s) = " general_totaltime > syn_output
     if (init_run)
	 print "initialization section run, time (s) = " init_totaltime > syn_output
     if (prescf_run)
	 print "prescf section run, time (s) = " prescf_totaltime > syn_output
     if (scf_run)
	 print "scf section run, time (s) = " scf_totaltime > syn_output
     if (so_run)
	 print "spinorbit section run, time (s) = " so_totaltime > syn_output
     if (elastic_run)
	 print "elastic section run, time (s) = " elastic_totaltime > syn_output
     if (free_run)
	 print "free section run, time (s) = " free_totaltime > syn_output
     if (prho_run)
	 print "printrho section run, time (s) = " prho_totaltime > syn_output
     if (dos_run)
	 print "dosplot section run, time (s) = " dos_totaltime > syn_output
     if (rx_run)
	 print "rxplot section run, time (s) = " rx_totaltime > syn_output
     if (band_run)
	 print "bandplot section run, time (s) = " band_totaltime > syn_output
     if (kdos_run)
	 print "kdos section run, time (s) = " kdos_totaltime > syn_output
     if (aim_run)
	 print "aim section run, time (s) = " aim_totaltime > syn_output
     if (critic_run)
	 print "critic section run, time (s) = " critic_totaltime > syn_output
     if (sweep_run)
	 print "sweep section run, time (s) = " sweep_totaltime > syn_output
     if (gibbs_run)
	 print "gibbs section run, time (s) = " gibbs_totaltime > syn_output
     print "total run time (s) = " general_totaltime + init_totaltime + prescf_totaltime + scf_totaltime + so_totaltime + \
	 elastic_totaltime + free_totaltime + prho_totaltime + dos_totaltime + rx_totaltime + band_totaltime + \
	 kdos_totaltime + aim_totaltime + critic_totaltime + sweep_totaltime > syn_output
     print "" > syn_output
     print "Structural information" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     printf "%s %-s\n"  ,"Mol. formula :",global_molformula > syn_output
     printf "%s %-.6f\n","Mol. mass    :",global_molmass > syn_output
     printf "%s %-.8f\n","a / bohr     :",global_a > syn_output
     printf "%s %-.8f\n","b / bohr     :",global_b > syn_output
     printf "%s %-.8f\n","c / bohr     :",global_c > syn_output
     printf "%s %-.8f\n","alpha / deg  :",global_alpha > syn_output
     printf "%s %-.8f\n","beta / deg   :",global_beta > syn_output
     printf "%s %-.8f\n","gamma / deg  :",global_gamma > syn_output
     printf "%s %-.8f\n","c/a          :",global_ca > syn_output
     printf "%s %-.8f\n","c/b          :",global_cb > syn_output
     printf "%s %-.8f\n","b/a          :",global_ba > syn_output
     printf "%s %-.8f\n","volume/bohr^3:",global_v > syn_output
     printf "%s %-.8f\n","Mol. volume  :",global_molv > syn_output
     printf "%s %-s\n"  ,"space group  :",global_spg > syn_output
     printf "%s %-s\n"  ,"lattice      :",global_lattice > syn_output
     printf "%s %-s\n"  ,"system       :",global_system > syn_output
     printf "%s %-s\n"  ,"inversion?   :",global_complex?"no":"yes" > syn_output
     if (general_ciffile)
	 print "structure loaded from .cif file :",general_ciffile > syn_output
     if (general_structfile)
	 print "structure loaded from .struct file :",general_structfile > syn_output
     print "nonequivalent atom list in .struct (and position of a representative atom):" > syn_output
     for (i=1;i<=global_nneq;i++){
	 print "  atom " i " is " global_atom[i] " mult= " global_mult[i] " x= "global_nneq_x[i,1] " y= "global_nneq_y[i,1] " z= "global_nneq_z[i,1] " sym= "global_lsym[i] > syn_output
     }
     print "" > syn_output
     print "Additional information" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     if (init_run){
	 print "Number of electrons in unit cell : " init_totale > syn_output
	 print "Valence electrons in unit cell   : " init_totaleval > syn_output
	 print "Core electrons in unit cell      : " init_totalecore > syn_output
	 for (i in init_noe){
	     print "Core | val | total e- for atom   : " "[" i "] " init_noecore[i] " | " init_noeval[i] " | " init_noe[i] > syn_output
	     print "Core | val el. conf. for atom    : " "[" i "] " init_corevalstring[i] > syn_output
	 }
	 for (i=1;i<=global_atomnames;i++){
	     print "Atomic energy (lstart) [" sprintf("%2s",global_atom[global_atomrepr[i]]) "]      : " sprintf("%.7f",init_fratenergy[global_atom[global_atomrepr[i]]]) > syn_output
	 }
	 print "Total in vacuo energy (lstart)   : " sprintf("%.7f",init_frtotalenergy) > syn_output
     }
     if (free_run){
	 for (i=1;i<=global_atomnames;i++){
	     print "Atomic energy (free) [" sprintf("%2s",global_atom[global_atomrepr[i]]) "]        : " sprintf("%.7f",free_fratenergy[global_atomname[i]]) > syn_output
	 }
	 print "Total in vacuo energy (free)     : " sprintf("%.7f",free_frtotalenergy) > syn_output
     }
     print "Core leaking for non-equivalent atoms : " > syn_output
     printf " Id  " > syn_output
     for (i=1;i<=global_nneq;i++)
	 printf "     %2s    ", global_atom[i] > syn_output
     printf "\n" > syn_output
     for (i=1;i<=general_iterations;i++){
	 printf "%5d",i > syn_output
	 for (j=1;j<=global_nneq;j++)
	     printf " %10.3e",init_coreleak[i,j] > syn_output
	 printf "\n" > syn_output
     }
     print "" > syn_output
     print "Calculation fixed parameters" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     printf "%s %-s\n","spinpolarized               :",global_spinpolarized > syn_output
     printf "%s %-s\n","relativistic first density  :",general_relativistic > syn_output
     for (i=1;i<=global_nneq;i++){
	 temp_idstring = "npt" i
	 if (!syn_npt_variable[i])
	     printf "%s %-i\n", "general, npt (atom " i ")       :",general_val[temp_idstring,general_index[temp_idstring,1]] > syn_output
     }
     for (i=1;i<=global_nneq;i++){
	 temp_idstring = "rmt" i
	 if (!syn_rmt_variable[i])
	     printf "%s %-.5f\n", "general, rmt (atom " i ")       :",general_val[temp_idstring,general_index[temp_idstring,1]] > syn_output
     }
     for (i=1;i<=global_nneq;i++){
	 temp_idstring = "r0" i
	 if (!syn_r0_variable[i])
	     printf "%s %-.8f\n", "general, r0  (atom " i ")       :",general_val[temp_idstring,general_index[temp_idstring,1]] > syn_output
     }
     if (!syn_rkmax_variable)
	 printf "%s %-.5f\n","general, rkmax              :",general_val["rkmax",general_index["rkmax",1]] > syn_output
     if (!syn_lmax_variable)
	 printf "%s %-i\n","general, lmax               :",general_val["lmax",general_index["lmax",1]] > syn_output
     if (!syn_lnsmax_variable)
	 printf "%s %-i\n","general, lnsmax             :",general_val["lnsmax",general_index["lnsmax",1]] > syn_output
     if (!syn_gmax_variable)
	 printf "%s %-.3f\n","general, gmax               :",general_val["gmax",general_index["gmax",1]] > syn_output
     if (!syn_mix_variable)
	 printf "%s %-.5f\n","general, mix                :",general_val["mix",general_index["mix",1]] > syn_output
     if (!syn_kpts_variable)
	 printf "%s %-i\n","general, kpts               :",general_val["kpts",general_index["kpts",1]] > syn_output
     printf "%s %-s\n"    ,"initialization, potential   :", init_potential > syn_output
     printf "%s %-.3f\n"  ,"initialization, ecoreval /ry:", init_ecoreval > syn_output
     printf "%s %.2f\n"   ,"initialization, IFFT        :", init_ifft > syn_output
     printf "%s %-.8f\n"  ,"initialization, emin / ry   :", init_energymin  > syn_output
     printf "%s %-.8f\n"  ,"initialization, emax / ry   :", init_energymax  > syn_output
     if (global_ldau){
	 printf "%-28s: %-s\n"    ,"scf, LDA+U type", global_ldautype > syn_output
	 for (i=1;i<=global_ldaus;i++)
	     printf "%-28s: %i / %i \n"    ,"LDA+U appl. in atom / l",global_ldau_atom[i],global_ldau_l[i] > syn_output
     }
     printf "%s %-s\n"    ,"scf, commands used          :", scf_commandstring > syn_output
     print "" > syn_output
     # Determine if mini was run
     syn_mini=""
     for (i=1;i<=general_iterations;i++){
	 if (global_mini[i]){
	     syn_mini = "yes"
	     break
	 }
     }
     if (general_iterations > 1){
	 print "Calculation variable parameters" > syn_output
	 print "---------------------------------------------------------------------" > syn_output
	 print "number of structures :",general_iterations > syn_output
	 temp_string = ""
	 for (i=1;i<=global_nneq;i++){
	     if (syn_npt_variable[i]){
		 temp_format = "%6s"
		 temp_string = temp_string sprintf(temp_format,"npt " i)
	     }
	 }
	 for (i=1;i<=global_nneq;i++){
	     if (syn_rmt_variable[i]){
		 temp_format = "%6s"
		 temp_string = temp_string sprintf(temp_format,"rmt " i)
	     }
	 }
	 for (i=1;i<=global_nneq;i++){
	     if (syn_r0_variable[i]){
		 temp_format = "%10s"
		 temp_string = temp_string sprintf(temp_format,"r0 " i)
	     }
	 }
	 if (syn_rkmax_variable){
	     temp_format = "%6s"
	     temp_string = temp_string sprintf(temp_format,"rkmax")
	 }
	 if (syn_lmax_variable){
	     temp_format = "%6s"
	     temp_string = temp_string sprintf(temp_format,"lmax")
	 }
	 if (syn_lnsmax_variable){
	     temp_format = "%7s"
	     temp_string = temp_string sprintf(temp_format,"lnsmax")
	 }
	 if (syn_gmax_variable){
	     temp_format = "%6s"
	     temp_string = temp_string sprintf(temp_format,"gmax")
	 }
	 if (syn_mix_variable){
	     temp_format = "%6s"
	     temp_string = temp_string sprintf(temp_format,"mix")
	 }
	 if (syn_kpts_variable){
	     temp_format = "%7s"
	     temp_string = temp_string sprintf(temp_format,"kpts")
	 }
	 if (global_ldau){
	     for (i=1;i<=global_ldaus;i++){
		 if (syn_u_variable[i]){
		     temp_format = "%6s"
		     temp_string = temp_string sprintf(temp_format,"U " i)
		 }
	     }
	     for (i=1;i<=global_ldaus;i++){
		 if (syn_j_variable[i]){
		     temp_format = "%6s"
		     temp_string = temp_string sprintf(temp_format,"J " i)
		 }
	     }
	 }
	 if (scf_run){
	     temp_format = "%6s"
	     temp_string = temp_string sprintf(temp_format,"basis")
	     temp_format = "%4s"
	     temp_string = temp_string sprintf(temp_format,"it.")
	     temp_format = "%8s"
	     temp_string = temp_string sprintf(temp_format,"warning")
	     temp_format = "%15s"
	     if (syn_mini){
		 temp_format = "%15s"
		 temp_string = temp_string sprintf(temp_format,"e_(unrlxd)*/ry")
	     }
	     temp_format = "%15s"
	     temp_string = temp_string sprintf(temp_format,"energy*/ ry")
	     temp_format = "%15s"
	     temp_string = temp_string sprintf(temp_format,"efermi / ry")
 	     if (dos_run){
		 temp_format = "%15s"
		 temp_string = temp_string sprintf(temp_format,"DOS(ef)/ry-1")
	     }
	     if (global_spinpolarized == "yes"){
		 temp_format = "%10s"
		 temp_string = temp_string sprintf(temp_format,"mmtot")
	     }

	 }
	 if (so_run){
	     temp_format = "%15s"
	     temp_string = temp_string sprintf(temp_format,"E*(SO)/ ry")
	     if (global_spinpolarized == "yes"){
		 temp_format = "%10s"
		 temp_string = temp_string sprintf(temp_format,"MMtot(SO)")
	     }
	 }
	 temp_format = "%13s"
	 temp_string = temp_string sprintf(temp_format,"time /s")
	 if (critic_run){
	     temp_format = "%10s"
	     temp_string = temp_string sprintf(temp_format,"planarity")
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"morsesum")
	     temp_format = "%30s"
	     temp_string = temp_string sprintf(temp_format,"topology")
	 }
	 print "num  " temp_string > syn_output
	 for (i=1;i<=general_iterations;i++){
	     printf "%-5i ",i > syn_output
	     for (j=1;j<=global_nneq;j++){
		 temp_idstring = "npt" j
		 if (syn_npt_variable[j])
		     printf "%-5i ",general_val[temp_idstring,general_index[temp_idstring,i]] > syn_output
	     }
	     for (j=1;j<=global_nneq;j++){
		 temp_idstring = "rmt" j
		 if (syn_rmt_variable[j])
		     printf "%5.2f ",general_val[temp_idstring,general_index[temp_idstring,i]] > syn_output
	     }
	     for (j=1;j<=global_nneq;j++){
		 temp_idstring = "r0" j
		 if (syn_r0_variable[j])
		     printf "%9.7f ",general_val[temp_idstring,general_index[temp_idstring,i]] > syn_output
	     }
	     if (syn_rkmax_variable){
		 printf "%5.2f ",general_val["rkmax",general_index["rkmax",i]] > syn_output
	     }
	     if (syn_lmax_variable){
		 printf "%5i ",general_val["lmax",general_index["lmax",i]] > syn_output
	     }
	     if (syn_lnsmax_variable){
		 printf "%6i ",general_val["lnsmax",general_index["lnsmax",i]] > syn_output
	     }
	     if (syn_gmax_variable){
		 printf "%5.2f ",general_val["gmax",general_index["gmax",i]] > syn_output
	     }
	     if (syn_mix_variable){
		 printf "%5.3f ",general_val["mix",general_index["mix",i]] > syn_output
	     }
	     if (syn_kpts_variable){
		 printf "%6i ",general_val["kpts",general_index["kpts",i]] > syn_output
	     }
	     if (global_ldau){
		 for (j=1;j<=global_ldaus;j++){
		     temp_idstring = "u" j
		     if (syn_u_variable[j])
			 printf "%5.2f ",general_val[temp_idstring,general_index[temp_idstring,i]] > syn_output
		 }
		 for (j=1;j<=global_ldaus;j++){
		     temp_idstring = "j" j
		     if (syn_j_variable[j])
			 printf "%5.2f ",general_val[temp_idstring,general_index[temp_idstring,i]] > syn_output
		 }
	     }
	     if (scf_run){
		 if (scf_done[i]){
		     if (scf_basissize[i] != "n/a")
			 printf "%5i ",scf_basissize[i] > syn_output
		     else
			 printf "%5s ",scf_basissize[i] > syn_output
		     if (scf_noiter[i] != "n/a")
			 printf "%3i ",scf_noiter[i] > syn_output
		     else
			 printf "%3s ",scf_noiter[i] > syn_output
		     if (scf_warns[i]){
			 temp_string = "("
			 for (j=1;j<=scf_warns[i];j++){
			     temp_string = temp_string scf_warn[i,j]
			     syn_scfwarnaccum[scf_warn[i,j]] = 1
			 }
			 temp_string = temp_string ")"
			 printf "%7s ",temp_string > syn_output
		     }
		     else
			 printf "%7s ","--" > syn_output
		     if (syn_mini)
			 printf "%17.10f ",scf_premini_molenergy[i] > syn_output
		     if (scf_molenergy[i] != "n/a")
			 printf "%17.10f ",scf_molenergy[i] > syn_output
		     else
			 printf "%14s ",scf_molenergy[i] > syn_output
		     if (scf_efermi[i] != "n/a")
			 printf "%14.5f ",scf_efermi[i] > syn_output
		     else
			 printf "%14s ",scf_efermi[i] > syn_output
		     if (dos_run)
			 if (dos_nef[i])
			     printf "%14.5f ",dos_nef[i] > syn_output
			 else
			     printf "%14s ","" > syn_output
		     if (global_spinpolarized == "yes")
			 if (scf_mmtot[i] != "n/a")
			     printf "%9.6f ",scf_mmtot[i] > syn_output
			 else
			     printf "%9s ",scf_mmtot[i] > syn_output
		 }
		 else
		     printf "%39s ", "--- not done ---" > syn_output
	     }
	     if (so_run){
		 if (so_done[i]){
		     if (so_run){
			 temp_format = "%15s"
			 temp_string = temp_string sprintf(temp_format,"E*(SO)/ ry")
			 temp_format = "%10s"
			 temp_string = temp_string sprintf(temp_format,"MMtot(SO)")
		     }
		     if (so_molenergy[i] != "n/a")
			 printf "%17.10f ",so_molenergy[i] > syn_output
		     else
			 printf "%14s ",so_molenergy[i] > syn_output
		     if (global_spinpolarized == "yes") 
			 if (so_mmtot[i] != "n/a")
			     printf "%9.6f ",so_mmtot[i] > syn_output
			 else
			     printf "%9s ",so_mmtot[i] > syn_output
		 }
		 else
		     printf "%24s ", "--- not done ---" > syn_output
	     }
	     printf "%12i ",syn_time[i] > syn_output
	     if (critic_run){
		 if (critic_done[i]){
		     if (critic_planarity[i] != "n/a")
			 printf "%9.6f ",critic_planarity[i] > syn_output
		     else
			 printf "%9s ",critic_planarity[i] > syn_output
		     if (critic_morsesum[i] != "n/a")
			 printf "%8i ",critic_morsesum[i] > syn_output
		     else
			 printf "%8s ",critic_morsesum[i] > syn_output
		     printf "%29s ",critic_topology[i] > syn_output
		 }
		 else
		     printf "%48s ","--- not done ---" > syn_output
	     }
	     printf "\n" > syn_output
	 }
     }
     else{
	 print "" > syn_output
	 print "Only one structure, no variable parameters" > syn_output
	 if (scf_run && scf_done[1]){
	     if (syn_mini)
		 print "Energy*/ry (before mini) = " scf_premini_molenergy[1] > syn_output
	     print "Energy*/ry  = " scf_molenergy[1] > syn_output
	     print "E fermi /ry = " scf_efermi[1] > syn_output
	     if (global_spinpolarized == "yes")
		 print "Mag. moment = " scf_mmtot[1] > syn_output
	     if (scf_warns[1]){
		 temp_string = "("
		 for (j=1;j<=scf_warns[1];j++){
		     temp_string = temp_string scf_warn[1,j]
		     syn_scfwarnaccum[scf_warn[1,j]] = 1
		 }
		 temp_string = temp_string ")"
		 print "Warnings : ",temp_string > syn_output
	     }
	 }
	 else
	     print "No scf data available..." > syn_output
	 if (dos_run && dos_done[1])
	     print "DOS at Ef = " dos_nef[1] > syn_output
	 if (critic_run && critic_done[1]){
	     print "Planarity   = " critic_planarity[1] > syn_output
	     print "Morse sum   = " critic_morsesum[1] > syn_output
	     print "Topology    = " critic_topology[1] > syn_output
	 }
	 else
	     print "No critic data available" > syn_output
	 print "" > syn_output
     }
     if (defined(scf_warns)){
	 print "" > syn_output
	 for (i in syn_scfwarnaccum){
	     if (i == const_warn_unknown)
		 print "(" i ") Unknown warning in .scf file." > syn_output
	     if (i == const_warn_notconv)
		 print "(" i ") SCF process did not converge due to unknown reasons." > syn_output
	     if (i == const_warn_maxiter)
		 print "(" i ") SCF precess did not converge: maximum number of iterations reached." > syn_output
	     if (i == const_warn_efermi)
		 print "(" i ") Fermi energy is close to .in1 energymax." > syn_output
	     if (i == const_warn_ghost)
		 print "(" i ") Ghost bands." > syn_output
	     if (i == const_warn_badclmini)
		 print "(" i ") Bad initial clmsum or LM list." > syn_output
	 }
     }
     if (sweep_run){
	 print "" > syn_output
	 print "Structural grid (sweep) results" > syn_output
	 print "---------------------------------------------------------------------" > syn_output
	 print "" > syn_output
	 print "Fixed parameters --" > syn_output
	 if (!syn_a_variable)
	     print "a / bohr      :",sweep_a_val[1] > syn_output
	 if (!syn_b_variable)
	     print "b / bohr      :",sweep_b_val[1] > syn_output
	 if (!syn_c_variable)
	     print "c / bohr      :",sweep_c_val[1] > syn_output
	 if (!syn_alpha_variable)
	     print "alpha / deg   :",sweep_alpha_val[1] > syn_output
	 if (!syn_beta_variable)
	     print "beta / deg    :",sweep_beta_val[1] > syn_output
	 if (!syn_gamma_variable)
	     print "gamma / deg   :",sweep_gamma_val[1] > syn_output
	 if (!syn_v_variable)
	     print "v / bohr^3    :",sweep_molv[1] > syn_output
	 if (!syn_ca_variable)
	     print "c / a         :",sweep_ca_val[1] > syn_output
	 if (!syn_cb_variable)
	     print "c / b         :",sweep_cb_val[1] > syn_output
	 if (!syn_ba_variable)
	     print "b / a         :",sweep_ba_val[1] > syn_output
	 print "" > syn_output
	 print "Variable parameters --" > syn_output
	 print "number of structures :",sweep_iterations > syn_output
	 temp_string = ""
	 if (syn_a_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"a / bohr")
	 }
	 if (syn_b_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"b / bohr")
	 }
	 if (syn_c_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"c / bohr")
	 }
	 if (syn_alpha_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"alpha/deg")
	 }
	 if (syn_beta_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"beta/deg")
	 }
	 if (syn_gamma_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"gamma/deg")
	 }
	 if (syn_v_variable){
	     temp_format = "%13s"
	     temp_string = temp_string sprintf(temp_format,"v/bohr^3")
	 }
	 if (syn_ca_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"c / a")
	 }
	 if (syn_cb_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"c / b")
	 }
	 if (syn_ba_variable){
	     temp_format = "%9s"
	     temp_string = temp_string sprintf(temp_format,"b / a")
	 }
	 temp_format = "%4s"
	 temp_string = temp_string sprintf(temp_format,"it.")
	 temp_format = "%8s"
	 temp_string = temp_string sprintf(temp_format,"warning")
	 temp_format = "%15s"
	 temp_string = temp_string sprintf(temp_format,"energy / ry")
	 temp_format = "%15s"
	 temp_string = temp_string sprintf(temp_format,"efermi / ry")
	 temp_format = "%10s"
	 temp_string = temp_string sprintf(temp_format,"time /s")
	 temp_format = "%10s"
	 temp_string = temp_string sprintf(temp_format,"planarity")
	 temp_format = "%9s"
	 temp_string = temp_string sprintf(temp_format,"morsesum")
	 temp_format = "%30s"
	 temp_string = temp_string sprintf(temp_format,"topology")
	 print temp_string > syn_output
	 for (i=1;i<=sweep_iterations;i++){
	     if (syn_a_variable){
		 printf "%8.5f ",sweep_a_val[i] > syn_output
	     }
	     if (syn_b_variable){
		 printf "%8.5f ",sweep_b_val[i] > syn_output
	     }
	     if (syn_c_variable){
		 printf "%8.5f ",sweep_c_val[i] > syn_output
	     }
	     if (syn_alpha_variable){
		 printf "%8.5f ",sweep_alpha_val[i] > syn_output
	     }
	     if (syn_beta_variable){
		 printf "%8.5f ",sweep_beta_val[i] > syn_output
	     }
	     if (syn_gamma_variable){
		 printf "%8.5f ",sweep_gamma_val[i] > syn_output
	     }
	     if (syn_v_variable){
		 printf "%12.4f ",sweep_molv[i] > syn_output
	     }
	     if (syn_ca_variable){
		 printf "%8.5f ",sweep_ca_val[i] > syn_output
	     }
	     if (syn_cb_variable){
		 printf "%8.5f ",sweep_cb_val[i] > syn_output
	     }
	     if (syn_ba_variable){
		 printf "%8.5f ",sweep_ba_val[i] > syn_output
	     }
	     if (sweep_done[i]){
		 printf "%3i ",sweep_noiter[i] > syn_output
		 if (sweep_warns[i]){
		     temp_string = "("
		     for (j=1;j<=sweep_warns[i];j++){
			 temp_string = temp_string sweep_warn[i,j]
			 syn_sweepwarnaccum[sweep_warn[i,j]] = 1
		     }
		     temp_string = temp_string ")"
		     printf "%7s ",temp_string > syn_output
		 }
		 else
		     printf "%7s ","--" > syn_output
		 if (sweep_molenergy[i])
		     printf "%17.10f ",sweep_molenergy[i] > syn_output
		 else
		     printf "%14s ","n/a" > syn_output
		 if (sweep_efermi[i])
		     printf "%14.9f ",sweep_efermi[i] > syn_output
		 else
		     printf "%14s ","n/a" > syn_output
		 printf "%9i ",sweep_time[i] > syn_output
		 if (sweep_planarity[i])
		     printf "%9.7f ",sweep_planarity[i] > syn_output
		 else
		     printf "%9s ","n/a" > syn_output
		 if (sweep_morsesum[i] != "n/a")
		     printf "%8i ",sweep_morsesum[i] > syn_output
		 else
		     printf "%8s ","n/a" > syn_output
		 if (sweep_topology[i])
		     printf "%29s ",sweep_topology[i] > syn_output
		 else
		     printf "%29s ","n/a" > syn_output
	     }
	     else{
		 printf "%78-s ", "              --- not done ---" > syn_output
	     }
	     printf "\n" > syn_output
	 }
	 if (defined(sweep_warns)){
	     print "" > syn_output
	     for (i in syn_sweepwarnaccum){
		 if (i == const_warn_unknown)
		     print "(" i ") Unknown warning in .scf file." > syn_output
		 if (i == const_warn_notconv)
		     print "(" i ") SCF process did not converge due to unknown reasons." > syn_output
		 if (i == const_warn_maxiter)
		     print "(" i ") SCF precess did not converge: maximum number of iterations reached." > syn_output
		 if (i == const_warn_efermi)
		     print "(" i ") Fermi energy is close to .in1 energymax." > syn_output
		 if (i == const_warn_badclmini)
		     print "(" i ") Bad initial clmsum or LM list." > syn_output
	     }
	 }
     }
     print "" > syn_output
     if (gibbs_run){
	 print "Gibbs section results" > syn_output
	 print "---------------------------------------------------------------------" > syn_output
	 print "Check " global_root "-gibbs/" global_root ".outputgibbs " > syn_output
     }
     print "" > syn_output
     print "Output, index, plot and gnuplot files" > syn_output
     print "---------------------------------------------------------------------" > syn_output
     print "* .out files" > syn_output
     for (i=1;i<=global_file_out_n;i++){
	 print " - " global_file_out[i] > syn_output
     }
     print "* .index files" > syn_output
     for (i=1;i<=global_file_index_n;i++){
	 print " - " global_file_index[i] > syn_output
     }
     print "* .ps files" > syn_output
     for (i=1;i<=global_file_ps_n;i++){
	 print " - " global_file_ps[i] > syn_output
     }
     print "* .gnuplot files" > syn_output
     for (i=1;i<=global_file_gnuplot_n;i++){
	 print " - " global_file_gnuplot[i] > syn_output
     }
     print "" > syn_output
     if (elastic_run){
	 print "Elastic constants calculation" > syn_output
	 print "---------------------------------------------------------------------" > syn_output
	 if (!elastic_goodenergy && !global_var["elastic_forcefit"]){
	     print " -- Some of the energies required for the fit are missing. -- " >  syn_output
	     print " -- Check all synopsis.out in elastic directory.           -- " >  syn_output
	 }
	 else if (!elastic_goodfit){
	     print " -- One or more fits failed                           -- " > syn_output
	     print " -- Check .log and .err in elastic directory.         -- " > syn_output
	     print " -- You may want to use your own gnuplot script files -- " > syn_output
	 }
	 else{
	     if (elastic_system == "cubic"){
		 printf "c11 (GPa) = %.10f\n",elastic_constant["c11"] > syn_output
		 printf "c12 (GPa) = %.10f\n",elastic_constant["c12"] > syn_output
		 printf "c44 (GPa) = %.10f\n",elastic_constant["c44"] > syn_output
		 print "" > syn_output
		 print " c11 > abs(c12)    ? " elastic_condition[1] > syn_output
		 print " c11 + 2 * c12 > 0 ? " elastic_condition[2] > syn_output
		 print " c44 > 0           ? " elastic_condition[3] > syn_output
		 print "" > syn_output
		 for (i=1;i<=3;i++)
		     print "Res. variance ("const_elastic_defname["cubic",i]") = " elastic_rms[i] > syn_output
		 print "" > syn_output
		 print " Fit coefficients" > syn_output
		 print " Deformation x0 c0 c1 c2 c3 c4 c5 c6 c7 c8 " > syn_output
		 for (i=1;i<=3;i++)
		     printf "%s | %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f \n",const_elastic_defname["cubic",i],elastic_coeff[i,"x0"],elastic_coeff[i,"c0"], \
			 elastic_coeff[i,"c1"],elastic_coeff[i,"c2"],elastic_coeff[i,"c3"],elastic_coeff[i,"c4"], \
			 elastic_coeff[i,"c5"],elastic_coeff[i,"c6"],elastic_coeff[i,"c7"],elastic_coeff[i,"c8"]  > syn_output
	     }
	     else if (elastic_system == "hexagonal") {
		 printf "c11 (GPa) = %.10f\n",elastic_constant["c11"] > syn_output
		 printf "c12 (GPa) = %.10f\n",elastic_constant["c12"] > syn_output
		 printf "c13 (GPa) = %.10f\n",elastic_constant["c13"] > syn_output
		 printf "c33 (GPa) = %.10f\n",elastic_constant["c33"] > syn_output
		 printf "c44 (GPa) = %.10f\n",elastic_constant["c44"] > syn_output
		 print "" > syn_output
		 print " c11 > abs(c12)                ? " elastic_condition[1] > syn_output
		 print " (c11 + c12) * c33 > 2 * c13^2 ? " elastic_condition[2] > syn_output
		 print " c44 > 0                       ? " elastic_condition[3] > syn_output
		 print "" > syn_output
		 for (i=1;i<=5;i++)
		     print "Res. variance ("const_elastic_defname["hexagonal",i]") = " elastic_rms[i] > syn_output
		 print "" > syn_output
		 print " Fit coefficients (Deformation x0 c0 c1 c2 c3 c4 c5 c6 c7 c8 )" > syn_output
		 for (i=1;i<=5;i++)
		     printf "%s | %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f \n",const_elastic_defname["hexagonal",i],elastic_coeff[i,"x0"],elastic_coeff[i,"c0"], \
			 elastic_coeff[i,"c1"],elastic_coeff[i,"c2"],elastic_coeff[i,"c3"],elastic_coeff[i,"c4"], \
			 elastic_coeff[i,"c5"],elastic_coeff[i,"c6"],elastic_coeff[i,"c7"],elastic_coeff[i,"c8"]  > syn_output
	     }
	     else if (elastic_system == "tetragonal1") {
		 printf "c11 (GPa) = %.10f\n",elastic_constant["c11"] > syn_output
		 printf "c12 (GPa) = %.10f\n",elastic_constant["c12"] > syn_output
		 printf "c13 (GPa) = %.10f\n",elastic_constant["c13"] > syn_output
		 printf "c33 (GPa) = %.10f\n",elastic_constant["c33"] > syn_output
		 printf "c44 (GPa) = %.10f\n",elastic_constant["c44"] > syn_output
		 printf "c66 (GPa) = %.10f\n",elastic_constant["c66"] > syn_output
		 print "" > syn_output
		 elastic_condition[1] = (elastic_constant["c11"] > abs(elastic_constant["c12"]))?"yes":"no"
		 elastic_condition[2] = ((elastic_constant["c11"]+elastic_constant["c12"])*elastic_constant["c33"] > \
					 2*elastic_constant["c13"]^2)?"yes":"no"
		 elastic_condition[3] = (elastic_constant["c44"] > 0)?"yes":"no"
		 elastic_condition[4] = (elastic_constant["c66"] > 0)?"yes":"no"
		 print " c11 > abs(c12)                ? " elastic_condition[1] > syn_output
		 print " (c11+c12)*c33 > 2*c13^2       ? " elastic_condition[2] > syn_output
		 print " c44 > 0                       ? " elastic_condition[3] > syn_output
		 print " c66 > 0                       ? " elastic_condition[4] > syn_output
		 print "" > syn_output
		 for (i=1;i<=5;i++)
		     print "Res. variance ("const_elastic_defname["tetragonal1",i]") = " elastic_rms[i] > syn_output
		 print "" > syn_output
		 print " Fit coefficients (Deformation x0 c0 c1 c2 c3 c4 c5 c6 c7 c8 )" > syn_output
		 for (i=1;i<=const_elastic_defs["tetragonal1"];i++)
		     printf "%s | %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f \n",const_elastic_defname["tetragonal1",i],elastic_coeff[i,"x0"],elastic_coeff[i,"c0"], \
			 elastic_coeff[i,"c1"],elastic_coeff[i,"c2"],elastic_coeff[i,"c3"],elastic_coeff[i,"c4"], \
			 elastic_coeff[i,"c5"],elastic_coeff[i,"c6"],elastic_coeff[i,"c7"],elastic_coeff[i,"c8"]  > syn_output
	     }
	 }
	 print "" > syn_output
     }
     if (syn_exhaustive_general_n){
	 print "Exhaustive information for general structures" > syn_output
	 print "---------------------------------------------------------------------" > syn_output
	 printf "%s %-.10f\n","metric matrix (1,1) :", global_metric[1,1] > syn_output
	 printf "%s %-.10f\n","metric matrix (1,2) :", global_metric[1,2] > syn_output
	 printf "%s %-.10f\n","metric matrix (1,3) :", global_metric[1,3] > syn_output
	 printf "%s %-.10f\n","metric matrix (2,2) :", global_metric[2,2] > syn_output
	 printf "%s %-.10f\n","metric matrix (2,3) :", global_metric[2,3] > syn_output
	 printf "%s %-.10f\n","metric matrix (3,3) :", global_metric[3,3] > syn_output
	 for (i=1;i<=global_nneq;i++){
	     printf "%s %-i %s \n", "complete basis specification for atom",i,":" > syn_output
	     printf "  %-.8f %-4i %-4i\n",init_orbital_globe[i],init_orbitals[i],init_orbital_globapw[i] > syn_output
	     for (j=1;j<=init_orbitals[i];j++){
		 printf "  %-2i%-10.5f%-10.5f%4s%2i\n",init_orbital_l[i,j],init_orbital_energy[i,j],init_orbital_var[i,j],init_orbital_cont[i,j],init_orbital_apw[i,j] > syn_output
	     }
	 }
	 print "" > syn_output
	 print "additional information :" > syn_output
	 printf "  %-4s %-7s %-6s %-6s %-6s %-6s %-3s %-8s %-8s %-8s \n","num","sp. fll","gmin","rkm(r)","pws","k(ibz)","los","esmcval","bndemin","bndemax" > syn_output
	 for (i=1;i<=syn_exhaustive_general_n;i++){
	     j = syn_exhaustive_general[i]
	     printf "  %-4i %-7.5f %-6.3f %-6.3f %-6i %-6i %-3i %-8.5f %-8.5f %-8.5f \n",j,general_spacefill[j],prescf_gmin[j],scf_rkmaxreal[j],prescf_pws[j],prescf_ibzkpts[j],scf_los[j],scf_esemicoreval[j],scf_bandemin[j],scf_bandemax[j] > syn_output
	 }
	 print "" > syn_output
	 print "convergence details (DIRB angle) : " > syn_output
	 temp_string = sprintf("  %-4s ","ite")
	 for (i=1;i<=syn_exhaustive_general_n;i++){
	     j = syn_exhaustive_general[i]
	     temp_string = temp_string sprintf("%-5i ",j)
	 }
	 print temp_string > syn_output
	 for (i=1;;i++){
	     temp_string = "  "
	     for (j=1;j<=syn_exhaustive_general_n;j++){
		 k = syn_exhaustive_general[j]
		 if (scf_dirb[k,i] "")
		     temp_string = temp_string sprintf("%-5.1f ",scf_dirb[k,i])
		 else
		     temp_string = temp_string "      "
	     }
	     if (temp_string ~ /^ *$/)
		 break
	     else
		 printf "%-4i %s\n", i, temp_string > syn_output
	 }
     }
     close(syn_output)
     # Generate checkpoint
     print "[info|syn] Writing checkpoints..."
     global_savecheck(global_root "-check/global.check")
     syn_savecheck(global_root "-check/syn.check")
     print "[info|syn] Synopsis section ended successfully..."
     printf "\n"
     next
 }

# Errorproof input
{
    print "[error|global] command not recognized in .wien:"
    print "[error|global] " $0
    exit 1
}

# (xfunx) Functions -----------------------------------------

# clean -- clean root directory
function clean(local_num){
    local_name = general_filename[local_num]
    gsub(".struct","",local_name)
    local_prepath = "cd " local_name " ; "
    mysystem(local_prepath "rm -f *.def > /dev/null 2>&1")
    mysystem(local_prepath "rm -f *.broyd* > /dev/null 2>&1")
    mysystem(local_prepath "rm -f fort.*")
    mysystem(local_prepath "rm -f -- :* > /dev/null 2>&1")
}
# mysystem -- execute an OS order, echoing the command and pretty printing the output
function mysystem(local3_order){
    if (const_global_verbose == "yes")
	print "[exec] " local3_order 
    system(local3_order)
}
# global_extractcif -- extract global info from *.cif
function global_extractcif(local_name,local_overwrite){
    ### Use cif2struct to get lattice and nneq positions
    mysystem(const_cif2structexe " " local_name " > errfile 2>&1")
    if (checkerror("errfile","blank","")){
	mysystem("mv -f errfile " global_root ".cif2struct.err")
	print "[error|global] in cif2struct"
	print "[error|global] Check cif2struct is correctly compiled."
	print "[error|global] Check .cif format is adequate."
	exit 1
    }
    mysystem("rm -f errfile")
    gsub(/\.cif( |\t)*$/,".struct",local_name)
    global_extractstruct(local_name,local_overwrite)
    mysystem("rm -f " local_name)
}
# global_extractstruct -- extract global info from .struct
function global_extractstruct(local2_name,local2_overwrite){
    mysystem(const_lapwextractstructexe " " local2_name " > tempfile_2local")
    getline < "tempfile_2local"
    if (!global_lattice || local2_overwrite)
	getline global_lattice < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_nneq || local2_overwrite)
	getline global_nneq < "tempfile_2local"
    else
	getline < "tempfile_2local"
    getline < "tempfile_2local"
    if (!global_a || local2_overwrite)
	getline global_a < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_b || local2_overwrite)
	getline global_b < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_c || local2_overwrite)
	getline global_c < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_alpha || local2_overwrite)
	getline global_alpha < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_beta || local2_overwrite)
	getline global_beta < "tempfile_2local"
    else
	getline < "tempfile_2local"
    if (!global_gamma || local2_overwrite)
	getline global_gamma < "tempfile_2local"
    else
	getline < "tempfile_2local"
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	if (!global_label[local2_i] || local2_overwrite)
	    getline global_label[local2_i]    < "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_nneq_x[local2_i,1] || local2_overwrite)
	    getline global_nneq_x[local2_i,1]	< "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_nneq_y[local2_i,1] || local2_overwrite)
	    getline global_nneq_y[local2_i,1]	< "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_nneq_z[local2_i,1] || local2_overwrite)
	    getline global_nneq_z[local2_i,1]	< "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_mult[local2_i] || local2_overwrite)
	    getline global_mult[local2_i]	< "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_isplit[local2_i] || local2_overwrite)
	    getline global_isplit[local2_i]   < "tempfile_2local"
	else
	    getline < "tempfile_2local"
	for (local2_j=2;local2_j<=global_mult[local2_i];local2_j++){
	    if (!global_nneq_x[local2_i,local2_j] || local2_overwrite)
		getline global_nneq_x[local2_i,local2_j] < "tempfile_2local"
	    else
		getline < "tempfile_2local"
	    if (!global_nneq_y[local2_i,local2_j] || local2_overwrite)
		getline global_nneq_y[local2_i,local2_j] < "tempfile_2local"
	    else
		getline < "tempfile_2local"
	    if (!global_nneq_z[local2_i,local2_j] || local2_overwrite)
		getline global_nneq_z[local2_i,local2_j] < "tempfile_2local"
	    else
		getline < "tempfile_2local"
	}
	if (!global_atomfullnm[local2_i] || local2_overwrite)
	    getline global_atomfullnm[local2_i] < "tempfile_2local"
	else
	    getline < "tempfile_2local"
	if (!global_atom[local2_i] || local2_overwrite)
	    getline global_atom[local2_i] < "tempfile_2local"
	else
	    getline < "tempfile_2local"
	getline < "tempfile_2local"
	getline < "tempfile_2local"
	getline < "tempfile_2local"
    }
    close("tempfile_2local")
    mysystem("rm -f tempfile_2local")
    global_system = getsystem(global_a,global_b,global_c,global_alpha,global_beta,global_gamma)
    global_v = volume(global_a,global_b,global_c,global_alpha,global_beta,global_gamma)
    global_cosalpha = cos(global_alpha*const_pi/180.0)
    global_cosbeta = cos(global_beta*const_pi/180.0)
    global_cosgamma = cos(global_gamma*const_pi/180.0)

    global_metric[1,1] = global_a * global_a
    global_metric[1,2] = global_a * global_b * global_cosgamma
    global_metric[1,3] = global_a * global_c * global_cosbeta
    global_metric[2,2] = global_b * global_b
    global_metric[2,3] = global_b * global_c * global_cosalpha
    global_metric[3,3] = global_c * global_c

    global_metric[2,1] = global_metric[1,2]
    global_metric[3,1] = global_metric[1,3]
    global_metric[3,2] = global_metric[2,3]

    global_ca = global_c/global_a
    global_cb = global_c/global_b
    global_ba = global_b/global_a
    global_gcdmult = global_mult[1]
    for (local2_i=2;local2_i<=global_nneq;local2_i++){
	global_gcdmult = gcd(global_gcdmult,global_mult[local2_i])
    }
    global_molformula = ""
    global_molmass = 0
    delete global_numberatoms
    delete global_atomname
    global_atomnames = 0
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	global_molatoms[local2_i] = global_mult[local2_i] / global_gcdmult
	global_molformula = global_molformula global_atom[local2_i] global_molatoms[local2_i]
	global_molmass += global_molatoms[local2_i]*const_atomicmass[global_atom[local2_i]]
	global_numberatoms[global_atom[local2_i]] += global_mult[local2_i]
	if (!isin(tolower(global_atom[local2_i]),global_atomname)){
	    global_atomnames++
	    global_atomname[global_atomnames] = tolower(global_atom[local2_i])
	    global_atomrepr[global_atomnames] = local2_i
	}
    }
    global_molv = global_v / global_gcdmult
    if (global_lattice == "P" || global_lattice == "S")
	global_molv = global_molv / 1
    else if (global_lattice == "F")
	global_molv = global_molv / 4
    else if (global_lattice == "B")
	global_molv = global_molv / 2
    else if (global_lattice == "CXY")
	global_molv = global_molv / 2
    else if (global_lattice == "CYZ")
	global_molv = global_molv / 2
    else if (global_lattice == "CXZ")
	global_molv = global_molv / 2
    else if (global_lattice == "R")
	global_molv = global_molv / 1
    else if (global_lattice == "H")
	global_molv = global_molv / 1
    local2_command = const_lapwgetcomplexexe " " local2_name
    local2_command | getline global_complex
    close(local2_command)
}
# general_extractstruct -- extract general info from .struct
function general_extractstruct(local_name,local_overwrite){
    mysystem(const_lapwextractstructexe " " local_name " > tempfile_local")
    if (!general_title || local_overwrite)
	getline general_title < "tempfile_local"
    else
	getline < "tempfile_local"
    ## remove blanks
    general_title = rm_keyword("",general_title)
    getline < "tempfile_local"
    getline < "tempfile_local"
    if (!general_relativistic || local_overwrite)
	getline general_relativistic < "tempfile_local"
    else
	getline < "tempfile_local"
    getline < "tempfile_local"
    getline < "tempfile_local"
    getline < "tempfile_local"
    getline < "tempfile_local"
    getline < "tempfile_local"
    getline < "tempfile_local"
    for (local_i=1;local_i<=global_nneq;local_i++){
	getline < "tempfile_local"
	getline < "tempfile_local"
	getline < "tempfile_local"
	getline < "tempfile_local"
	getline < "tempfile_local"
	getline < "tempfile_local"
	for (local_j=2;local_j<=global_mult[local_i];local_j++){
	    getline < "tempfile_local"
	    getline < "tempfile_local"
	    getline < "tempfile_local"
	}
	getline < "tempfile_local"
	getline < "tempfile_local"
	# npt
	getline local_temp < "tempfile_local"
	for (local_j=1;local_j<=general_alsos;local_j++)
	    if (!general_npt[local_i,local_j] || local_overwrite)
		general_npt[local_i,local_j] = local_temp
	# r0
	getline local_temp < "tempfile_local"
	for (local_j=1;local_j<=general_alsos;local_j++)
	    if (!general_r0[local_i,local_j] || local_overwrite)
		general_r0[local_i,local_j] = local_temp
	# rmt
	getline local_temp < "tempfile_local"
	for (local_j=1;local_j<=general_alsos;local_j++)
	    if (!general_rmt[local_i,local_j] || local_overwrite)
		general_rmt[local_i,local_j] = local_temp
    }
    close("tempfile_local")
    mysystem("rm -f tempfile_local")
}
# global_savecheck -- save global variables state
function global_savecheck(local2_name){
    print global_version > local2_name
    print global_lattice > local2_name
    print global_system > local2_name
    print global_spg > local2_name
    printf "%.10f\n",global_a > local2_name
    printf "%.10f\n",global_b > local2_name
    printf "%.10f\n",global_c > local2_name
    printf "%.10f\n",global_alpha > local2_name
    printf "%.10f\n",global_beta > local2_name
    printf "%.10f\n",global_gamma > local2_name
    print global_complex > local2_name
    print global_spinpolarized > local2_name
    print global_gcdmult > local2_name
    print global_molformula > local2_name
    printf "%.10f\n",global_molmass > local2_name
    printf "%.10f\n",global_v > local2_name
    printf "%.10f\n",global_cosalpha > local2_name
    printf "%.10f\n",global_cosbeta > local2_name
    printf "%.10f\n",global_cosgamma > local2_name
    printf "%.10f\n",global_metric[1,1] > local2_name
    printf "%.10f\n",global_metric[1,2] > local2_name
    printf "%.10f\n",global_metric[1,3] > local2_name
    printf "%.10f\n",global_metric[2,2] > local2_name
    printf "%.10f\n",global_metric[2,3] > local2_name
    printf "%.10f\n",global_metric[3,3] > local2_name
    printf "%.10f\n",global_ca > local2_name
    printf "%.10f\n",global_cb > local2_name
    printf "%.10f\n",global_ba > local2_name
    printf "%.10f\n",global_molv > local2_name
    print global_nneq > local2_name
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	print global_label[local2_i] > local2_name
	print global_atom[local2_i] > local2_name
	print global_lsym[local2_i] > local2_name
	print global_atomfullnm[local2_i] > local2_name
	print global_numberatoms[global_atom[local2_i]] > local2_name
	print global_isplit[local2_i] > local2_name
	print global_molatoms[local2_i] > local2_name
	print global_mult[local2_i] > local2_name
	for (local2_j=1;local2_j<=global_mult[local2_i];local2_j++){
	    printf "%.10f\n",global_nneq_x[local2_i,local2_j] > local2_name
	    printf "%.10f\n",global_nneq_y[local2_i,local2_j] > local2_name
	    printf "%.10f\n",global_nneq_z[local2_i,local2_j] > local2_name
	}
    }
    print global_atomnames > local2_name
    for (local2_i=1;local2_i<=global_atomnames;local2_i++){
	print global_atomname[local2_i] > local2_name
	print global_atomrepr[local2_i] > local2_name
    }
    print general_iterations > local2_name
    print global_file_out_n > local2_name
    for (local2_i=1;local2_i<=global_file_out_n;local2_i++)
	print global_file_out[local2_i] > local2_name
    print global_file_index_n > local2_name
    for (local2_i=1;local2_i<=global_file_index_n;local2_i++)
	print global_file_index[local2_i] > local2_name
    print global_file_ps_n > local2_name
    for (local2_i=1;local2_i<=global_file_ps_n;local2_i++)
	print global_file_ps[local2_i] > local2_name
    print global_file_gnuplot_n > local2_name
    for (local2_i=1;local2_i<=global_file_gnuplot_n;local2_i++)
	print global_file_gnuplot[local2_i] > local2_name
    print global_ldau > local2_name
    print global_ldautype > local2_name
    print global_ldaus > local2_name
    for (local2_i=1;local2_i<=global_ldaus;local2_i++){
	print global_ldau_atom[local2_i] > local2_name
	print global_ldau_l[local2_i] > local2_name
    } 
    for (local2_i=1;local2_i<=general_interations;local2_i++){
	print global_mini[local2_i] > local2_name
    } 
    close(local2_name)
}
# global_loadcheck -- load global variables state
function global_loadcheck(local2_name){
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline global_lattice < local2_name
    getline global_system < local2_name
    getline global_spg < local2_name
    getline global_a < local2_name
    getline global_b < local2_name
    getline global_c < local2_name
    getline global_alpha < local2_name
    getline global_beta < local2_name
    getline global_gamma < local2_name
    getline global_complex < local2_name
    getline global_spinpolarized < local2_name
    getline global_gcdmult < local2_name
    getline global_molformula < local2_name
    getline global_molmass < local2_name
    getline global_v < local2_name
    getline global_cosalpha < local2_name
    getline global_cosbeta < local2_name
    getline global_cosgamma < local2_name
    getline global_metric[1,1] < local2_name
    getline global_metric[1,2] < local2_name
    getline global_metric[1,3] < local2_name
    getline global_metric[2,2] < local2_name
    getline global_metric[2,3] < local2_name
    getline global_metric[3,3] < local2_name
    global_metric[2,1] = global_metric[1,2]
    global_metric[3,1] = global_metric[1,3]
    global_metric[3,2] = global_metric[2,3]
    getline global_ca < local2_name
    getline global_cb < local2_name
    getline global_ba < local2_name
    getline global_molv < local2_name
    getline global_nneq < local2_name
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	getline global_label[local2_i] < local2_name
	getline global_atom[local2_i] < local2_name
	getline global_lsym[local2_i] < local2_name
	getline global_atomfullnm[local2_i] < local2_name
	getline global_numberatoms[global_atom[local2_i]] < local2_name
	getline global_isplit[local2_i] < local2_name
	getline global_molatoms[local2_i] < local2_name
	getline global_mult[local2_i] < local2_name
	for (local2_j=1;local2_j<=global_mult[local2_i];local2_j++){
	    getline global_nneq_x[local2_i,local2_j] < local2_name
	    getline global_nneq_y[local2_i,local2_j] < local2_name
	    getline global_nneq_z[local2_i,local2_j] < local2_name
	}
    }
    getline global_atomnames < local2_name
    for (local2_i=1;local2_i<=global_atomnames;local2_i++){
	getline global_atomname[local2_i] < local2_name
	getline global_atomrepr[local2_i] < local2_name
    }
    getline local2_tmp < local2_name
    getline global_file_out_n < local2_name
    for (local2_i=1;local2_i<=global_file_out_n;local2_i++)
	getline global_file_out[local2_i] < local2_name
    getline global_file_index_n < local2_name
    for (local2_i=1;local2_i<=global_file_index_n;local2_i++)
	getline global_file_index[local2_i] < local2_name
    getline global_file_ps_n < local2_name
    for (local2_i=1;local2_i<=global_file_ps_n;local2_i++)
	getline global_file_ps[local2_i] < local2_name
    getline global_file_gnuplot_n < local2_name
    for (local2_i=1;local2_i<=global_file_gnuplot_n;local2_i++)
	getline global_file_gnuplot[local2_i] < local2_name
    getline global_ldau < local2_name
    getline global_ldautype < local2_name
    getline global_ldaus < local2_name
    for (local2_i=1;local2_i<=global_ldaus;local2_i++){
	getline global_ldau_atom[local2_i] < local2_name
	getline global_ldau_l[local2_i] < local2_name
    } 
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline global_mini[local2_i] < local2_name
    } 
    close(local2_name)
}
function general_savecheck(local2_name){
    print global_version > local2_name
    print general_title > local2_name
    print general_relativistic > local2_name
    print general_totaltime > local2_name
    print general_pad > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print general_filename[local2_i] > local2_name
	print global_nneq > local2_name
	for (local2_j=1;local2_j<=global_nneq;local2_j++){
	    local2_idstring = "npt" local2_j
	    print general_n[local2_idstring] > local2_name
	    local2_idstring = "rmt" local2_j
	    print general_n[local2_idstring] > local2_name
	    local2_idstring = "r0" local2_j
	    print general_n[local2_idstring] > local2_name
	}
	print general_n["rkmax"] > local2_name
	print general_n["lmax"] > local2_name
	print general_n["lnsmax"] > local2_name
	print general_n["gmax"] > local2_name
	print general_n["mix"] > local2_name
	print general_n["kpts"] > local2_name
	print global_ldaus > local2_name
	for (local2_j=1;local2_j<=global_ldaus;local2_j++){
	    local2_idstring = "u" local2_j
	    print general_n[local2_idstring] > local2_name
	    local2_idstring = "j" local2_j
	    print general_n[local2_idstring] > local2_name
	}
	print global_nneq > local2_name
	for (local2_j=1;local2_j<=global_nneq;local2_j++){
	    local2_idstring = "npt" local2_j
	    print general_val[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	    local2_idstring = "rmt" local2_j
	    printf "%.10f\n", general_val[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	    print general_flag[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	    local2_idstring = "r0" local2_j
	    printf "%.10f\n", general_val[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	}
	printf "%.10f\n", general_val["rkmax",general_index["rkmax",local2_i]] > local2_name
	print general_val["lmax",general_index["lmax",local2_i]] > local2_name
	print general_val["lnsmax",general_index["lnsmax",local2_i]] > local2_name
	printf "%.10f\n", general_val["gmax",general_index["gmax",local2_i]] > local2_name
	printf "%.10f\n", general_val["mix",general_index["mix",local2_i]] > local2_name
	print general_val["kpts",general_index["kpts",local2_i]] > local2_name
	print global_ldaus > local2_name
	for (local2_j=1;local2_j<=global_ldaus;local2_j++){
	    local2_idstring = "u" local2_j
	    print general_val[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	    local2_idstring = "j" local2_j
	    print general_val[local2_idstring,general_index[local2_idstring,local2_i]] > local2_name
	}
	printf "%.10f\n",general_spacefill[local2_i] > local2_name
	print general_done[local2_i] > local2_name
    }
    close(local2_name)
}
function general_loadcheck(local2_name){
    general_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline general_title < local2_name
    ## remove blanks
    general_title = rm_keyword("",general_title)
    getline general_relativistic < local2_name
    getline general_totaltime < local2_name
    getline general_pad < local2_name
    getline general_iterations < local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	getline general_filename[local2_i] < local2_name
	getline local2_tmp < local2_name
	for (local2_j=1;local2_j<=local2_tmp;local2_j++){
	    local2_idstring = "npt" local2_j
	    getline general_n[local2_idstring] < local2_name
	    general_index[local2_idstring,local2_i] = local2_i
	    local2_idstring = "rmt" local2_j
	    getline general_n[local2_idstring] < local2_name
	    general_index[local2_idstring,local2_i] = local2_i
	    local2_idstring = "r0" local2_j
	    getline general_n[local2_idstring] < local2_name
	    general_index[local2_idstring,local2_i] = local2_i
	}
	getline general_n["rkmax"] < local2_name
	getline general_n["lmax"] < local2_name
	getline general_n["lnsmax"] < local2_name
	getline general_n["gmax"] < local2_name
	getline general_n["mix"] < local2_name
	getline general_n["kpts"] < local2_name
	general_index["r0",local2_i] = local2_i
	general_index["rkmax",local2_i] = local2_i
	general_index["lmax",local2_i] = local2_i
	general_index["lnsmax",local2_i] = local2_i
	general_index["gmax",local2_i] = local2_i
	general_index["mix",local2_i] = local2_i
	general_index["kpts",local2_i] = local2_i
	getline local2_tmp < local2_name
	for (local2_j=1;local2_j<=local2_tmp;local2_j++){
	    local2_idstring = "u" local2_j
	    getline general_n[local2_idstring] < local2_name
	    general_index[local2_idstring,local2_i] = local2_i
	    local2_idstring = "j" local2_j
	    getline general_n[local2_idstring] < local2_name
	    general_index[local2_idstring,local2_i] = local2_i
	}
	getline local2_tmp < local2_name
	for (local2_j=1;local2_j<=local2_tmp;local2_j++){
	    local2_idstring = "npt" local2_j
	    getline general_val[local2_idstring,local2_i] < local2_name
	    local2_idstring = "rmt" local2_j
	    getline general_val[local2_idstring,local2_i] < local2_name
	    getline general_flag[local2_idstring,local2_i] < local2_name
	    local2_idstring = "r0" local2_j
	    getline general_val[local2_idstring,local2_i] < local2_name
	}
	getline general_val["rkmax",local2_i] < local2_name
	getline general_val["lmax",local2_i] < local2_name
	getline general_val["lnsmax",local2_i] < local2_name
	getline general_val["gmax",local2_i] < local2_name
	getline general_val["mix",local2_i] < local2_name
	getline general_val["kpts",local2_i] < local2_name
	getline local2_tmp < local2_name
	for (local2_j=1;local2_j<=local2_tmp;local2_j++){
	    local2_idstring = "u" local2_j
	    getline general_val[local2_idstring,local2_i] < local2_name
	    local2_idstring = "j" local2_j
	    getline general_val[local2_idstring,local2_i] < local2_name
	}
	getline general_spacefill[local2_i] < local2_name
	getline general_done[local2_i] < local2_name
    }
    close(local2_name)
}
function init_savecheck(local2_name){
    print global_version > local2_name
    print init_potential > local2_name
    printf "%.10f\n", init_ecoreval > local2_name
    printf "%.2f\n", init_ifft > local2_name
    printf "%.10f\n", init_energymin > local2_name
    printf "%.10f\n", init_energymax > local2_name
    print init_nnfactor > local2_name
    print init_totaltime > local2_name
    printf "%.10f\n",init_frtotalenergy > local2_name
    print init_fermi > local2_name
    printf "%.10f\n",init_fermival > local2_name
    print init_totale > local2_name
    print init_totalecore > local2_name
    print init_totaleval > local2_name
    print global_nneq > local2_name
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	print init_lms[local2_i] > local2_name
	for (local2_j=1;local2_j<=init_lms[local2_i];local2_j++){
	    print init_lm_l[local2_i,local2_j] > local2_name
	    print init_lm_m[local2_i,local2_j] > local2_name
	}
	printf "%.10f\n", init_fratenergy[global_atom[local2_i]] > local2_name
	printf "%.10f\n", init_orbital_globe[local2_i] > local2_name
	print init_orbital_globapw[local2_i] > local2_name
	print init_orbitals[local2_i] > local2_name
	for (local2_j=1;local2_j<=init_orbitals[local2_i];local2_j++){
	    print init_orbital_l[local2_i,local2_j] > local2_name
	    printf "%.10f\n", init_orbital_energy[local2_i,local2_j] > local2_name
	    printf "%.10f\n", init_orbital_var[local2_i,local2_j] > local2_name
	    print init_orbital_cont[local2_i,local2_j] > local2_name
	    print init_orbital_apw[local2_i,local2_j] > local2_name
	}
	print init_noe[global_atom[local2_i]] > local2_name
	print init_noecore[global_atom[local2_i]] > local2_name
	print init_noeval[global_atom[local2_i]] > local2_name
	print init_corevalstring[global_atom[local2_i]] > local2_name
    }
    printf "%.10f\n", init_eminin2 > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print init_time[local2_i] > local2_name
	print init_done[local2_i] > local2_name
	print global_nneq > local2_name
	for (local2_j=1;local2_j<=global_nneq;local2_j++)
	    print init_coreleak[local2_i,local2_j] > local2_name
    }
    close(local2_name)
}
function init_loadcheck(local2_name){
    init_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline init_potential < local2_name
    getline init_ecoreval < local2_name
    getline init_ifft < local2_name
    getline init_energymin < local2_name
    getline init_energymax < local2_name
    getline init_nnfactor < local2_name
    getline init_totaltime < local2_name
    getline init_frtotalenergy < local2_name
    getline init_fermi < local2_name
    getline init_fermival < local2_name
    getline init_totale < local2_name
    getline init_totalecore < local2_name
    getline init_totaleval < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline init_lms[local2_i] < local2_name
	for (local2_j=1;local2_j<=init_lms[local2_i];local2_j++){
	    getline init_lm_l[local2_i,local2_j] < local2_name
	    getline init_lm_m[local2_i,local2_j] < local2_name
	}
	getline init_fratenergy[global_atom[local2_i]] < local2_name
	getline init_orbital_globe[local2_i] < local2_name
	getline init_orbital_globapw[local2_i] < local2_name
	getline init_orbitals[local2_i] < local2_name
	for (local2_j=1;local2_j<=init_orbitals[local2_i];local2_j++){
	    getline init_orbital_l[local2_i,local2_j] < local2_name
	    getline init_orbital_energy[local2_i,local2_j] < local2_name
	    getline init_orbital_var[local2_i,local2_j] < local2_name
	    getline init_orbital_cont[local2_i,local2_j] < local2_name
	    getline init_orbital_apw[local2_i,local2_j] < local2_name
	}
	getline init_noe[global_atom[local2_i]] < local2_name
	getline init_noecore[global_atom[local2_i]] < local2_name
	getline init_noeval[global_atom[local2_i]] < local2_name
	getline init_corevalstring[global_atom[local2_i]] < local2_name
    }
    getline init_eminin2 < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline init_time[local2_i] < local2_name
	getline init_done[local2_i] < local2_name
	getline local2_tmp2 < local2_name
	for (local2_j=1;local2_j<=local2_tmp2;local2_j++)
	    getline init_coreleak[local2_i,local2_j] < local2_name
    }
    close(local2_name)
}
function prescf_savecheck(local2_name){
    print global_version > local2_name
    print prescf_kgenoutput > local2_name
    print prescf_kgenshift > local2_name
    print prescf_nice > local2_name
    print prescf_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print prescf_ldau_not[local2_i] > local2_name
	print prescf_ibzkpts[local2_i] > local2_name
	print prescf_gmin[local2_i] > local2_name
	print prescf_pws[local2_i] > local2_name
	print prescf_time[local2_i] > local2_name
	print prescf_done[local2_i] > local2_name
    }
    close(local2_name)
}
function prescf_loadcheck(local2_name){
    prescf_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline prescf_kgenoutput < local2_name
    getline prescf_kgenshift < local2_name
    getline prescf_nice < local2_name
    getline prescf_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline prescf_ldau_not[local2_i] < local2_name
	getline prescf_ibzkpts[local2_i] < local2_name
	getline prescf_gmin[local2_i] < local2_name
	getline prescf_pws[local2_i] < local2_name
	getline prescf_time[local2_i] < local2_name
	getline prescf_done[local2_i] < local2_name
    }
    close(local2_name)
}
function scf_savecheck(local2_name){
    print global_version > local2_name
    print scf_miter > local2_name
    printf "%.10f\n", scf_ec > local2_name
    printf "%.10f\n", scf_cc > local2_name
    printf "%.10f\n", scf_fc > local2_name
    print scf_nice > local2_name
    print scf_nosummary > local2_name
    print scf_totaltime > local2_name
    print scf_itdiag > local2_name
    print scf_in1new > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	printf "%.10f\n", scf_bandemin[local2_i] > local2_name
	printf "%.10f\n", scf_bandemax[local2_i] > local2_name
	printf "%.10f\n", scf_efermi[local2_i] > local2_name
	printf "%.10f\n", scf_energy[local2_i] > local2_name
	printf "%.10f\n", scf_molenergy[local2_i] > local2_name
	printf "%.10f\n", scf_esemicoreval[local2_i] > local2_name
	print scf_dirbs[local2_i] > local2_name
	for (local2_j=1;local2_j<=scf_dirbs[local2_i];local2_j++)
	    printf "%.10f\n", scf_dirb[local2_i,local2_j] > local2_name
	printf "%.10f\n", scf_rkmaxreal[local2_i] > local2_name
	printf "%.10f\n", scf_mmtot[local2_i] > local2_name
	print scf_time[local2_i] > local2_name
	print scf_noiter[local2_i] > local2_name
	print scf_basissize[local2_i] > local2_name
	print scf_los[local2_i] > local2_name
	print scf_warns[local2_i] > local2_name
	for (local2_j=1;local2_j<=scf_warns[local2_i];local2_j++){
	    print scf_warn[local2_i,local2_j] > local2_name
	}
	print scf_done[local2_i] > local2_name
	printf "%.10f\n", scf_premini_molenergy[local2_i] > local2_name
    }
    close(local2_name)
}
function scf_loadcheck(local2_name){
    scf_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline scf_miter < local2_name
    getline scf_ec < local2_name
    getline scf_cc < local2_name
    getline scf_fc < local2_name
    getline scf_nice < local2_name
    getline scf_nosummary < local2_name
    getline scf_totaltime < local2_name
    getline scf_itdiag < local2_name
    getline scf_in1new < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline scf_bandemin[local2_i] < local2_name
	getline scf_bandemax[local2_i] < local2_name
	getline scf_efermi[local2_i] < local2_name
	getline scf_energy[local2_i] < local2_name
	getline scf_molenergy[local2_i] < local2_name
	getline scf_esemicoreval[local2_i] < local2_name
	getline scf_dirbs[local2_i] < local2_name
	for (local2_j=1;local2_j<=scf_dirbs[local2_i];local2_j++)
	    getline scf_dirb[local2_i,local2_j] < local2_name
	getline scf_rkmaxreal[local2_i] < local2_name
	getline scf_mmtot[local2_i] < local2_name
	getline scf_time[local2_i] < local2_name
	getline scf_noiter[local2_i] < local2_name
	getline scf_basissize[local2_i] < local2_name
	getline scf_los[local2_i] < local2_name
	getline scf_warns[local2_i] < local2_name
	for (local2_j=1;local2_j<=scf_warns[local2_i];local2_j++){
	    getline scf_warn[local2_i,local2_j] < local2_name
	}
	getline scf_done[local2_i] < local2_name
	getline scf_premini_molenergy[local2_i] < local2_name
    }
    close(local2_name)
}
function so_savecheck(local2_name){
    print global_version > local2_name
    print so_totaltime > local2_name
    print so_miter > local2_name
    printf "%.10f\n", so_ec > local2_name
    printf "%.10f\n", so_cc > local2_name
    printf "%.10f\n", so_fc > local2_name
    print so_nice > local2_name
    print so_itdiag > local2_name
    print so_in1new > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	printf "%.10f\n", so_bandemin[local2_i] > local2_name
	printf "%.10f\n", so_bandemax[local2_i] > local2_name
	printf "%.10f\n", so_efermi[local2_i] > local2_name
	printf "%.10f\n", so_energy[local2_i] > local2_name
	printf "%.10f\n", so_molenergy[local2_i] > local2_name
	printf "%.10f\n", so_mmtot[local2_i] > local2_name
	print so_time[local2_i] > local2_name
	print so_noiter[local2_i] > local2_name
	print so_done[local2_i] > local2_name
    }
    close(local2_name)
}
function so_loadcheck(local2_name){
    so_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline so_totaltime < local2_name
    getline so_miter < local2_name
    getline so_ec < local2_name
    getline so_cc < local2_name
    getline so_fc < local2_name
    getline so_nice < local2_name
    getline so_itdiag < local2_name
    getline so_in1new < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline so_bandemin[local2_i] < local2_name
	getline so_bandemax[local2_i] < local2_name
	getline so_efermi[local2_i] < local2_name
	getline so_energy[local2_i] < local2_name
	getline so_molenergy[local2_i] < local2_name
	getline so_mmtot[local2_i] < local2_name
	getline so_time[local2_i] < local2_name
	getline so_noiter[local2_i] < local2_name
	getline so_done[local2_i] < local2_name
    }
    close(local2_name)
}
function elastic_savecheck(local2_name){
    print global_version > local2_name
    print elastic_totaltime > local2_name
    print elastic_tetragonal > local2_name
    print elastic_points > local2_name
    printf "%.10f\n",elastic_maxlength > local2_name
    printf "%.10f\n",elastic_maxangle > local2_name
    print elastic_polyorder > local2_name
    print elastic_fixmin > local2_name
    print elastic_term1 > local2_name
    print elastic_pad > local2_name
    print elastic_goodenergy > local2_name
    print elastic_goodfit > local2_name
    printf "%.10f\n", elastic_constant["c11"] > local2_name
    printf "%.10f\n", elastic_constant["c12"] > local2_name
    printf "%.10f\n", elastic_constant["c13"] > local2_name
    printf "%.10f\n", elastic_constant["c33"] > local2_name
    printf "%.10f\n", elastic_constant["c44"] > local2_name
    print elastic_condition[1] > local2_name
    print elastic_condition[2] > local2_name
    print elastic_condition[3] > local2_name
    for (local2_i=1;local2_i<=const_elastic_defs[global_system];local2_i++){
	print elastic_deftime[local2_i] > local2_name
	printf "%.10f\n",elastic_d2e[local2_i] > local2_name
	for (local2_j=1;local2_j<=elastic_points;local2_j++){
	    print elastic_time[local2_i] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"a"] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"b"] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"c"] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"alpha"] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"beta"] > local2_name
	    printf "%.10f\n",elastic_cell[local2_i,local2_j,"gamma"] > local2_name
	    printf "%.10f\n",elastic_energy[local2_i,local2_j] > local2_name
	}
    }
    close(local2_name)
}
function elastic_loadcheck(local2_name){
    elastic_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline elastic_totaltime < local2_name
    getline elastic_tetragonal < local2_name
    getline elastic_points < local2_name
    getline elastic_maxlength < local2_name
    getline elastic_maxangle < local2_name
    getline elastic_polyorder < local2_name
    getline elastic_fixmin < local2_name
    getline elastic_term1 < local2_name
    getline elastic_pad < local2_name
    getline elastic_goodenergy < local2_name
    getline elastic_goodfit < local2_name
    getline elastic_constant["c11"] < local2_name
    getline elastic_constant["c12"] < local2_name
    getline elastic_constant["c13"] < local2_name
    getline elastic_constant["c33"] < local2_name
    getline elastic_constant["c44"] < local2_name
    getline elastic_condition[1] < local2_name
    getline elastic_condition[2] < local2_name
    getline elastic_condition[3] < local2_name
    for (local2_i=1;local2_i<=const_elastic_defs[global_system];local2_i++){
	getline elastic_deftime[local2_i] < local2_name
	getline elastic_d2e[local2_i] < local2_name
	for (local2_j=1;local2_j<=elastic_points;local2_j++){
	    getline elastic_time[local2_i] < local2_name
	    getline elastic_cell[local2_i,local2_j,"a"] < local2_name
	    getline elastic_cell[local2_i,local2_j,"b"] < local2_name
	    getline elastic_cell[local2_i,local2_j,"c"] < local2_name
	    getline elastic_cell[local2_i,local2_j,"alpha"] < local2_name
	    getline elastic_cell[local2_i,local2_j,"beta"] < local2_name
	    getline elastic_cell[local2_i,local2_j,"gamma"] < local2_name
	    getline elastic_energy[local2_i,local2_j] < local2_name
	}
    }
    close(local2_name)
}
function free_savecheck(local2_name){
    print global_version > local2_name
    print free_totaltime > local2_name
    print free_frtotalenergy > local2_name
    print global_atomnames > local2_name
    for (local2_i=1;local2_i<=global_atomnames;local2_i++){
	print free_fratenergy[global_atomname[local2_i]] > local2_name
	print free_done[global_atomname[local2_i]] > local2_name
	print free_time[global_atomname[local2_i]] > local2_name
    }
    close(local2_name)
}
function free_loadcheck(local2_name){
    free_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline free_totaltime < local2_name
    getline free_frtotalenergy < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline free_fratenergy[global_atomname[local2_i]] < local2_name
	getline free_done[global_atomname[local2_i]] < local2_name
	getline free_time[global_atomname[local2_i]] < local2_name
    }
    close(local2_name)
}
function prho_savecheck(local2_name){
    print global_version > local2_name
    print prho_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print prho_time[local2_i] > local2_name
	print prho_done[local2_i] > local2_name
    }
    close(local2_name)
}
function prho_loadcheck(local2_name){
    prho_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline prho_totaltime < local2_name
    getline general_iterations < local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	getline prho_time[local2_i] < local2_name
	getline prho_done[local2_i] < local2_name
    }
    close(local2_name)
}
function dos_savecheck(local2_name){
    print global_version > local2_name
    print dos_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print dos_time[local2_i] > local2_name
	print dos_done[local2_i] > local2_name
	printf "%.10f\n", dos_nef[local2_i] > local2_name
    }
    close(local2_name)
}
function dos_loadcheck(local2_name){
    dos_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline dos_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline dos_time[local2_i] < local2_name
	getline dos_done[local2_i] < local2_name
	getline dos_nef[local2_i] < local2_name
    }
    close(local2_name)
}
function rx_savecheck(local2_name){
    print global_version > local2_name
    print rx_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print rx_time[local2_i] > local2_name
	print rx_done[local2_i] > local2_name
    }
    close(local2_name)
}
function rx_loadcheck(local2_name){
    rx_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline rx_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline rx_time[local2_i] < local2_name
	getline rx_done[local2_i] < local2_name
    }
    close(local2_name)
}
function band_savecheck(local2_name){
    print global_version > local2_name
    print band_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print band_time[local2_i] > local2_name
	print band_done[local2_i] > local2_name
    }
    close(local2_name)
}
function band_loadcheck(local2_name){
    band_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline band_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline band_time[local2_i] < local2_name
	getline band_done[local2_i] < local2_name
    }
    close(local2_name)
}
function kdos_savecheck(local2_name){
    print global_version > local2_name
    print kdos_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print kdos_time[local2_i] > local2_name
	print kdos_done[local2_i] > local2_name
    }
    close(local2_name)
}
function kdos_loadcheck(local2_name){
    kdos_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline kdos_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline kdos_time[local2_i] < local2_name
	getline kdos_done[local2_i] < local2_name
    }
    close(local2_name)
}
function aim_savecheck(local2_name){
    print global_version > local2_name
    print aim_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print aim_time[local2_i] > local2_name
	print aim_done[local2_i] > local2_name
    }
    close(local2_name)
}
function aim_loadcheck(local2_name){
    aim_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline aim_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline aim_time[local2_i] < local2_name
	getline aim_done[local2_i] < local2_name
    }
    close(local2_name)
}
function critic_savecheck(local2_name){
    print global_version > local2_name
    print critic_totaltime > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	printf "%.10f\n", critic_planarity[local2_i] > local2_name
	print critic_morsesum[local2_i] > local2_name
	print critic_topology[local2_i] > local2_name
	print critic_time[local2_i] > local2_name
	print critic_done[local2_i] > local2_name
    }
    close(local2_name)
}
function critic_loadcheck(local2_name){
    critic_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline critic_totaltime < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline critic_planarity[local2_i] < local2_name
	getline critic_morsesum[local2_i] < local2_name
	getline critic_topology[local2_i] < local2_name
	getline critic_time[local2_i] < local2_name
	getline critic_done[local2_i] < local2_name
    }
    close(local2_name)
}
function sweep_savecheck(local2_name){
    print global_version > local2_name
    print sweep_ref > local2_name
    print sweep_potential > local2_name
    printf "%.10f\n", sweep_ecoreval > local2_name
    printf "%.10f\n", sweep_ifft > local2_name
    printf "%.10f\n", sweep_energymin > local2_name
    printf "%.10f\n", sweep_energymax > local2_name
    print sweep_itdiag > local2_name
    print sweep_nice > local2_name
    print sweep_miter > local2_name
    printf "%.10f\n", sweep_cc > local2_name
    printf "%.10f\n", sweep_ec > local2_name
    printf "%.10f\n", sweep_fc > local2_name
    print global_nneq > local2_name
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	print sweep_npt[local2_i] > local2_name
	printf "%.10f\n", sweep_rmt[local2_i] > local2_name
	printf "%.10f\n", sweep_r0[local2_i] > local2_name
    }
    printf "%.10f\n", sweep_rkmax > local2_name
    print sweep_lmax > local2_name
    print sweep_lnsmax > local2_name
    printf "%.10f\n", sweep_gmax > local2_name
    printf "%.10f\n", sweep_mix > local2_name
    print sweep_kpts > local2_name
    print sweep_ldau > local2_name
    print sweep_ldautype > local2_name
    print sweep_ldaus > local2_name
    for (local2_i=1;local2_i<=sweep_ldaus;local2_i++){
	print sweep_ldau_atom[k] > local2_name 
	print sweep_ldau_l[k] > local2_name 
	printf "%.10f\n",sweep_ldau_defu[k] > local2_name
	printf "%.10f\n",sweep_ldau_defj[k] > local2_name
    }
    print sweep_pad > local2_name
    print sweep_renormmode > local2_name
    print sweep_totaltime > local2_name
    print sweep_nosummary > local2_name
    print sweep_fermi > local2_name
    printf "%.10f\n",sweep_fermival > local2_name
    print global_nneq > local2_name
    for (local2_i=1;local2_i<=global_nneq;local2_i++){
	print sweep_orbitals[local2_i] > local2_name
	printf "%.10f\n", sweep_orbital_globe[local2_i]  > local2_name
	print sweep_orbital_globapw[local2_i] > local2_name
	for (local2_j=1;local2_j<=sweep_orbitals[local2_i];local2_j++){
	    print sweep_orbital_l[local2_i,local2_j] > local2_name
	    printf "%.10f\n", sweep_orbital_energy[local2_i,local2_j] > local2_name
	    printf "%.10f\n", sweep_orbital_var[local2_i,local2_j] > local2_name
	    print sweep_orbital_cont[local2_i,local2_j] > local2_name
	    print sweep_orbital_apw[local2_i,local2_j] > local2_name
	}
	print sweep_lms[local2_i] > local2_name
	for (local2_j=1;local2_j<=sweep_lms[local2_i];local2_j++){
	    print sweep_lm_l[local2_i,local2_j] > local2_name
	    print sweep_lm_m[local2_i,local2_j] > local2_name
	}
    }
    print sweep_iterations > local2_name
    for (local2_i=1;local2_i<=sweep_iterations;local2_i++){
	print sweep_filename[local2_i] > local2_name
	printf "%.10f\n", sweep_a_val[local2_i] > local2_name
	printf "%.10f\n", sweep_b_val[local2_i] > local2_name
	printf "%.10f\n", sweep_c_val[local2_i] > local2_name
	printf "%.10f\n", sweep_alpha_val[local2_i] > local2_name
	printf "%.10f\n", sweep_beta_val[local2_i] > local2_name
	printf "%.10f\n", sweep_gamma_val[local2_i] > local2_name
	printf "%.10f\n", sweep_v_val[local2_i] > local2_name
	printf "%.10f\n", sweep_molv[local2_i] > local2_name
	printf "%.10f\n", sweep_ca_val[local2_i] > local2_name
	printf "%.10f\n", sweep_cb_val[local2_i] > local2_name
	printf "%.10f\n", sweep_ba_val[local2_i] > local2_name
	print sweep_time[local2_i] > local2_name
	printf "%.10f\n", sweep_energy[local2_i] > local2_name
	printf "%.10f\n", sweep_molenergy[local2_i] > local2_name
	printf "%.10f\n", sweep_efermi[local2_i] > local2_name
	printf "%.10f\n", sweep_noiter[local2_i] > local2_name
	printf "%.10f\n", sweep_planarity[local2_i] > local2_name
	print sweep_topology[local2_i] > local2_name
        print sweep_morsesum[local2_i] > local2_name
	print sweep_warns[local2_i] > local2_name
	for (local2_j=1;local2_j<=sweep_warns[local2_i];local2_j++){
	    print sweep_warn[local2_i,local2_j] > local2_name
	}
        print sweep_done[local2_i] > local2_name
    }
    close(local2_name)
}
function sweep_loadcheck(local2_name){
    sweep_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline sweep_ref < local2_name
    getline sweep_potential < local2_name
    getline sweep_ecoreval < local2_name
    getline sweep_ifft < local2_name
    getline sweep_energymin < local2_name
    getline sweep_energymax < local2_name
    getline sweep_itdiag < local2_name
    getline sweep_nice < local2_name
    getline sweep_miter < local2_name
    getline sweep_cc < local2_name
    getline sweep_ec < local2_name
    getline sweep_fc < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline sweep_npt[local2_i] < local2_name
	getline sweep_rmt[local2_i] < local2_name
	getline sweep_r0[local2_i] < local2_name
    }
    getline sweep_rkmax < local2_name
    getline sweep_lmax < local2_name
    getline sweep_lnsmax < local2_name
    getline sweep_gmax < local2_name
    getline sweep_mix < local2_name
    getline sweep_kpts < local2_name
    getline sweep_ldau < local2_name
    getline sweep_ldautype < local2_name
    getline sweep_ldaus < local2_name
    for (local2_i=1;local2_i<=sweep_ldaus;local2_i++){
	getline sweep_ldau_atom[k] < local2_name 
	getline sweep_ldau_l[k] < local2_name 
	getline sweep_ldau_defu[k] < local2_name
	getline sweep_ldau_defj[k] < local2_name
    }
    getline sweep_pad < local2_name
    getline sweep_renormmode < local2_name
    getline sweep_totaltime < local2_name
    getline sweep_nosummary < local2_name
    getline sweep_fermi < local2_name
    getline sweep_fermival < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline sweep_orbitals[local2_i] < local2_name
	getline sweep_orbital_globe[local2_i]  < local2_name
	getline sweep_orbital_globapw[local2_i] < local2_name
	for (local2_j=1;local2_j<=sweep_orbitals[local2_i];local2_j++){
	    getline sweep_orbital_l[local2_i,local2_j] < local2_name
	    getline sweep_orbital_energy[local2_i,local2_j] < local2_name
	    getline sweep_orbital_var[local2_i,local2_j] < local2_name
	    getline sweep_orbital_cont[local2_i,local2_j] < local2_name
	    getline sweep_orbital_apw[local2_i,local2_j] < local2_name
	}
	getline sweep_lms[local2_i] < local2_name
	for (local2_j=1;local2_j<=sweep_lms[local2_i];local2_j++){
	    getline sweep_lm_l[local2_i,local2_j] < local2_name
	    getline sweep_lm_m[local2_i,local2_j] < local2_name
	}
    }
    getline sweep_iterations < local2_name
    for (local2_i=1;local2_i<=sweep_iterations;local2_i++){
	getline sweep_filename[local2_i] < local2_name
	getline sweep_a_val[local2_i] < local2_name
	getline sweep_b_val[local2_i] < local2_name
	getline sweep_c_val[local2_i] < local2_name
	getline sweep_alpha_val[local2_i] < local2_name
	getline sweep_beta_val[local2_i] < local2_name
	getline sweep_gamma_val[local2_i] < local2_name
	getline sweep_v_val[local2_i] < local2_name
	getline sweep_molv[local2_i] < local2_name
	getline sweep_ca_val[local2_i] < local2_name
	getline sweep_cb_val[local2_i] < local2_name
	getline sweep_ba_val[local2_i] < local2_name
	getline sweep_time[local2_i] < local2_name
	getline sweep_energy[local2_i] < local2_name
	getline sweep_molenergy[local2_i] < local2_name
	getline sweep_efermi[local2_i] < local2_name
	getline sweep_noiter[local2_i] < local2_name
	getline sweep_planarity[local2_i] < local2_name
	getline sweep_topology[local2_i] < local2_name
	getline sweep_morsesum[local2_i] < local2_name
	getline sweep_warns[local2_i] < local2_name
	for (local2_j=1;local2_j<=sweep_warns[local2_i];local2_j++){
	    getline sweep_warn[local2_i,local2_j] < local2_name
	}
        getline sweep_done[local2_i] < local2_name
    }
    close(local2_name)
}
function gibbs_savecheck(local2_name){
    print global_version > local2_name
    print gibbs_totaltime > local2_name
    close(local2_name)
}
function gibbs_loadcheck(local2_name){
    gibbs_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline gibbs_totaltime < local2_name
    close(local2_name)
}
function syn_savecheck(local2_name){
    print global_version > local2_name
    print syn_output > local2_name
    print general_iterations > local2_name
    for (local2_i=1;local2_i<=general_iterations;local2_i++){
	print syn_time[local2_i] > local2_name
    }
    close(local2_name)
}
function syn_loadcheck(local2_name){
    syn_run = 1
    getline local2_tmp < local2_name
    if (local2_tmp != global_version){
	print "[global|error] This runwien.awk version is incompatible with this check files."
	print "[global|error] runwien.awk version : " global_version
	print "[global|error] check version : " local2_tmp
	exit 1
    }
    getline syn_output < local2_name
    getline local2_tmp < local2_name
    for (local2_i=1;local2_i<=local2_tmp;local2_i++){
	getline syn_time[local2_i] < local2_name
    }
    close(local2_name)
}
# global_reread -- reread all the values of variables from the files ,
# ignoring their present values. Take general_iterations,
# sweep_iterations and *_run as guide to what to read.
function global_reread(){
    # reread global and general file names
    general_indexfile = global_root ".index"
    if (checkexists(general_indexfile)){
	if (!isin(general_indexfile,global_file_index)){
	    global_file_index_n++
	    global_file_index[global_file_index_n] = general_indexfile
	}
    }
    # reread global information from first struct file
    general_pad = int(0.4343*log(general_iterations))+1
    # reread general info from each structure
    general_n["rkmax"] = general_iterations
    general_n["lmax"]  = general_iterations
    general_n["lnsmax"] = general_iterations
    general_n["gmax"]  = general_iterations
    general_n["mix"]  = general_iterations
    general_n["kpts"]  = general_iterations
    for (local_i=1;local_i<=global_nneq;local_i++){
	local_idstring = "npt" local_i
	general_n[local_idstring] = general_iterations
	local_idstring = "rmt" local_i
	general_n[local_idstring] = general_iterations
	local_idstring = "r0" local_i
	general_n[local_idstring] = general_iterations
    }
    delete init_coreleak
    for (local_i=1;local_i<=general_iterations;local_i++){
	# general info
	local_root = global_root sprintf("%0*d",general_pad,local_i)
	if (checkexists(local_root "/" local_root ".struct")){
	    # mark general as done
	    general_done[local_i] = 1
	    general_index["rkmax",local_i] = local_i
	    general_index["lmax",local_i]  = local_i
	    general_index["lnsmax",local_i] = local_i
	    general_index["gmax",local_i]  = local_i
	    general_index["mix",local_i]  = local_i
	    general_index["kpts",local_i]  = local_i
	    for (local_j=1;local_j<=global_nneq;local_j++){
		local_idstring = "npt" local_j
		general_index[local_idstring,local_i] = local_i
		local_idstring = "rmt" local_j
		general_index[local_idstring,local_i] = local_i
		local_idstring = "r0" local_j
		general_index[local_idstring,local_i] = local_i
	    }
	    for (local_j=1;local_j<=global_nneq;local_j++){
		local_idstring = "rmt" local_j
		general_flag[local_idstring,local_i] = "normal"
	    }
	    if (checkexists(local_root "/" local_root ".in1"(global_complex?"c":""))){
		local_string = const_lapwgetrkmaxexe " " local_root "/" local_root ".in1"(global_complex?"c":"")
		local_string | getline general_val["rkmax",local_i]
		close(local_string)
		local_string = const_lapwgetlmaxexe " " local_root "/" local_root ".in1"(global_complex?"c":"")
		local_string | getline general_val["lmax",local_i]
		close(local_string)
		local_string = const_lapwgetlnsmaxexe " " local_root "/" local_root ".in1"(global_complex?"c":"")
		local_string | getline general_val["lnsmax",local_i]
		close(local_string)
	    }
	    if (checkexists(local_root "/" local_root ".in2"(global_complex?"c":""))){
		local_string = const_lapwgetgmaxexe " " local_root "/" local_root ".in2"(global_complex?"c":"")
		local_string | getline general_val["gmax",local_i]
		close(local_string)
	    }
	    if (checkexists(local_root "/" local_root ".inm")){
		local_string = const_lapwgetmixexe " " local_root "/" local_root ".inm"
		local_string | getline general_val["mix",local_i]
		close(local_string)
	    }
	    if (checkexists(local_root "/" local_root ".klist")){
		local_string = const_lapwgetkptsexe " " local_root "/" local_root ".klist"
		local_string | getline general_val["kpts",local_i]
		close(local_string)
	    }
	    # general info, from struct
	    general_filename[local_i] = local_root ".struct"
	    general_spacefill[local_i] = 0
	    mysystem(const_lapwanalyzeglobalexe " " local_root " > local_tempfile 2>&1")
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    getline  < "local_tempfile"
	    for (local_j=1;local_j<=global_nneq;local_j++){
		getline  < "local_tempfile"
		getline  < "local_tempfile"
		getline  < "local_tempfile"
		getline  < "local_tempfile"
		getline  < "local_tempfile"
		getline  < "local_tempfile"
		for (local_k=2;local_k<=global_mult[local_j];local_k++){
		    getline  < "local_tempfile"
		    getline  < "local_tempfile"
		    getline  < "local_tempfile"
		}
		getline < "local_tempfile"
		local_idstring = "npt" local_j
		getline general_val[local_idstring,local_i] < "local_tempfile"
		local_idstring = "r0" local_j
		getline general_val[local_idstring,local_i] < "local_tempfile"
		local_idstring = "rmt" local_j
		getline general_val[local_idstring,local_i] < "local_tempfile"
		general_spacefill[local_i] += 4.0/3.0*const_pi*(general_val[local_idstring,local_i])^3*global_mult[local_j]
		getline < "local_tempfile"
	    }
	    general_spacefill[local_i] /= global_v
	    close("local_tempfile")
	    mysystem("rm -f local_tempfile")
	    # init info
	    if (checkexists(local_root "/" local_root ".in1"(global_complex?"c":""))){
		init_done[local_i] = 1
		local_string = const_lapwgeteminin1exe " " local_root "/" local_root ".in1"(global_complex?"c":"")
		local_string | getline init_energymin
		close(local_string)
		local_string = const_lapwgetemaxin1exe " " local_root "/" local_root ".in1"(global_complex?"c":"")
		local_string | getline init_energymax
		close(local_string)
		local_string = const_lapwgetorbsin1exe " " local_root "/" local_root ".in1"(global_complex?"c":"")" > tempfile"
		mysystem(local_string)
		close(local_string)
		getline local_tmp < "tempfile"
		for (local_j=1;local_j<=local_tmp;local_j++){
		    getline init_orbital_globe[local_j] < "tempfile"
		    getline init_orbital_globapw[local_j] < "tempfile"
		    getline init_orbitals[local_j] < "tempfile"
		    for (local_k=1;local_k<=init_orbitals[local_j];local_k++){
			getline init_orbital_l[local_j,local_k]  < "tempfile"
			getline init_orbital_energy[local_j,local_k] < "tempfile"
			getline init_orbital_var[local_j,local_k]  < "tempfile"
			getline init_orbital_cont[local_j,local_k] < "tempfile"
			getline init_orbital_apw[local_j,local_k]  < "tempfile"
		    }
		}
		close("tempfile")
		mysystem("rm -f tempfile")
	    }
	    if (checkexists(local_root "/" local_root ".in2"(global_complex?"c":""))){
		init_done[local_i] = 1
		local_string = const_lapwgeteminin2exe " " local_root "/" local_root ".in2"(global_complex?"c":"")
		local_string | getline init_eminin2
		close(local_string)
		local_string = const_lapwgetlmsin2exe " " local_root "/" local_root ".in2"(global_complex?"c":"")" " global_nneq " > tempfile"
		mysystem(local_string)
		close(local_string)
		for (local_j=1;local_j<=global_nneq;local_j++){
		    getline init_lms[local_j] < "tempfile"
		    for (local_k=1;local_k<=init_lms[local_j];local_k++){
			getline init_lm_l[local_j,local_k] < "tempfile"
			getline init_lm_m[local_j,local_k] < "tempfile"
		    }
		}
		close("tempfile")
		mysystem("rm -f tempfile")
	    }
	    init_frtotalenergy = 0
	    for(local_j=1;local_j<=global_nneq;local_j++){
		if (checkexists(local_root "/" local_root ".outputst")){
		    local_string = const_lapwgetefreeatomexe " " local_root "/" local_root ".outputst " global_atom[local_j]
		    local_string | getline init_fratenergy[global_atom[local_j]]
		    close(local_string)
		    init_frtotalenergy += global_molatoms[local_j] * init_fratenergy[global_atom[local_j]]
		}
		else{
		    init_frtotalenergy = 0
		    break
		}
	    }
	    delete init_noe
	    delete init_noecore
	    delete init_noeval
	    init_totalecore = 0
	    init_totaleval = 0
	    for(local_j=1;local_j<=global_nneq;local_j++){
		mysystem(const_lapwgetnoeexe " " local_root "/" local_root ".outputst " init_ecoreval " " global_atom[local_j] " > local_tempfile 2>&1")
		getline init_noecore[global_atom[local_j]] < "local_tempfile"
		getline init_noeval[global_atom[local_j]] < "local_tempfile"
		init_noe[global_atom[local_j]] = init_noecore[global_atom[local_j]] + init_noeval[global_atom[local_j]]
		init_totalecore += init_noecore[global_atom[local_j]] * global_mult[local_j]
		init_totaleval += init_noeval[global_atom[local_j]] * global_mult[local_j]
		close("local_tempfile")
		mysystem("rm -f local_tempfile")
	    }
	    init_totale = init_totalecore + init_totaleval
	    delete init_corevalstring
	    for(local_j=1;local_j<=global_nneq;local_j++){
		local_string = const_lapwgetcorevalexe " " local_root "/" local_root ".outputst " init_ecoreval " " global_atom[local_j]
		local_string | getline init_corevalstring[global_atom[local_j]]
		close(local_string)
	    }
	    for(local_j=1;local_j<=global_nneq;local_j++){
		local_string = const_lapwgetleakingexe " " local_root "/" local_root ".outputst " local_j
		local_string | getline init_coreleak[local_i,local_j]
		close(local_string)
	    }
	}
	if (prescf_run){
	    local_string = const_lapwgetibzkptsexe " " local_root "/" local_root ".outputkgen"
	    local_string | getline prescf_ibzkpts[local_i]
	    close(local_string)
	    local_string = const_lapwgetgminexe " " local_root "/" local_root ".outputd"
	    local_string | getline prescf_gmin[local_i]
	    close(local_string)
	    local_string = const_lapwgetpwsexe " " local_root "/" local_root ".outputd"
	    local_string | getline prescf_pws[local_i]
	    close(local_string)
	    prescf_savecheck(global_root "-check/prescf.check")
	}
	if (scf_run){
	    # output files
	    if (checkexists(const_scfsumout)){
		if (!isin(const_scfsumout,global_file_out)){
		    global_file_out_n++
		    global_file_out[global_file_out_n] = const_scfsumout
		}
	    }
	    # scf conv criteria not loaded
	    # itdiag, etc. not loaded
	    # nosummary, nice, etc. not loaded
	    if (checkexists(local_root "/" local_root ".scf") || checkexists(local_root "/" local_root ".scf.noso")){
		if (checkexists(local_root "/" local_root ".scf.noso"))
		    temp_file = local_root "/" local_root ".scf.noso"
		else
		    temp_file = local_root "/" local_root ".scf"
		# scf has been done
		general_done[local_i] = 1
		init_done[local_i] = 1
		prescf_done[local_i] = 1
		scf_done[local_i] = 1
		# reread values
		local_string = const_lapwgetbandeminexe " " temp_file
		local_string | getline scf_bandemin[local_i]
		close(local_string)
		local_string = const_lapwgetbandemaxexe " " temp_file
		local_string | getline scf_bandemax[local_i]
		close(local_string)
		local_string = const_lapwgetefermiexe " " temp_file
		local_string | getline scf_efermi[local_i]
		close(local_string)
		local_string = const_lapwgetetotalexe " " temp_file
		local_string | getline scf_energy[local_i]
		close(local_string)
		scf_molenergy[local_i] = sprintf("%.10f",scf_energy[local_i] / global_gcdmult)
		local_string = const_lapwgetesemicorevalexe " " temp_file
		local_string | getline scf_esemicoreval[local_i]
		close(local_string)
		local_string = const_lapwgetdirbexe " " temp_file
		for (local_j=1;local_string | getline scf_dirb[local_i,local_j];local_j++)
		    ;
		close(local_string)
		scf_dirbs[local_i] = local_j-1
		local_string = const_lapwgetrkmaxrealexe " " temp_file
		local_string | getline scf_rkmaxreal[local_i]
		close(local_string)
		if (global_spinpolarized == "yes"){
		    local_string = const_lapwgetmmtotexe " " temp_file
		    local_string | getline scf_mmtot[local_i]
		    close(local_string)
		}
		local_string = const_lapwgetiterationsexe " " temp_file
		local_string | getline scf_noiter[local_i]
		close(local_string)
		mysystem(const_lapwgetpwbasisexe " " temp_file " > local_tempfile 2>&1")
		getline scf_basissize[local_i] < "local_tempfile"
		getline scf_los[local_i] < "local_tempfile"
		close("local_tempfile")
		mysystem("rm -f local_tempfile")
		scf_warns[local_i] = 0
		if (scf_noiter[local_i]+0 >= scf_miter+0){
		    scf_warns[local_i]++
		    scf_warn[local_i,scf_warns[local_i]] = const_warn_maxiter
		}
		else{
		    mysystem(const_lapwcheckdayfileexe " " local_root "/" local_root ".dayfile > local_tempfile")
		    for (;getline local_string < "local_tempfile";){
			scf_warns[local_i]++
			scf_warn[local_i,scf_warns[local_i]] = local_string
		    }
		    close("local_tempfile")
		    mysystem("rm -rf local_tempfile")
		}
		## scf
		if (abs(scf_efermi[local_i] - init_energymax) < 0.1){
		    scf_warns[local_i]++
		    scf_warn[local_i,scf_warns[local_i]] = const_warn_efermi
		}
		mysystem(const_lapwcheckscfexe " " temp_file " > local_tempfile")
		for (;getline local_string < "local_tempfile";){
		    scf_warns[local_i]++
		    scf_warn[local_i,scf_warns[local_i]] = local_string
		}
		close("local_tempfile")
		mysystem("rm -rf local_tempfile")
	    }
	    # determine if mini has been run
	    if (checkexists(local_root "/" local_root ".scf_mini")){
		global_mini[local_i] = "yes"
		if (checkexists(local_root "/" local_root "_1.scf")){
		    local_string = const_lapwgetetotalexe " " local_root "/" local_root "_1.scf"
		    local_string | getline scf_premini_molenergy[local_i]
		    close(local_string)
		    scf_premini_molenergy[local_i] = sprintf("%.10f",scf_premini_molenergy[local_i] / global_gcdmult)
		}
	    }
	    scf_savecheck(global_root "-check/scf.check")
	}
	if (prho_run){
	    # ps and gnuplot files
	    local_tmp = "ls " global_root "*/*.rhoplot.*.ps"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = local_string
		}
	    }
	    close(local_string)
	    # prho is supposed to be run almost inmediately. checks should be consistent
	}
	if (dos_run){
	    ## Write down ps and gnuplot files
	    local_tmp = "ls " global_root "*/*.dosplot.*.ps"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = local_string
		}
	    }
	    close(local_string)
	    local_tmp = "ls " global_root "*/*.dosplot.*.gnuplot"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_gnuplot)){
		    global_file_gnuplot_n++
		    global_file_gnuplot[global_file_gnuplot_n] = local_string
		}
	    }
	    close(local_string)
	    # dos is supposed to be run almost inmediately. checks should be consistent
	}
	if (rx_run){
	    ## Write down ps and gnuplot files
	    local_tmp = "ls " global_root "*/*.specplot.ps"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = local_string
		}
	    }
	    close(local_string)
	    local_tmp = "ls " global_root "*/*.rxplot.gnuplot"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_gnuplot)){
		    global_file_gnuplot_n++
		    global_file_gnuplot[global_file_gnuplot_n] = local_string
		}
	    }
	    close(local_string)
	    # rx is supposed to be run almost inmediately. checks should be consistent
	}
	if (band_run){
	    ## Write down ps files
	    local_tmp = "ls " global_root "*/*.spaghetti*.ps"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = local_string
		}
	    }
	    close(local_string)
	    # band is supposed to be run almost inmediately. checks should be consistent
	}
	if (kdos_run){
	    ## Write down ps files
	    local_tmp = "ls " global_root "*/*.dosband.*.eps"
	    for (;local_tmp | getline local_string;){
		if (!isin(local_string,global_file_ps)){
		    global_file_ps_n++
		    global_file_ps[global_file_ps_n] = local_string
		}
	    }
	}
	if (aim_run){
	    # aim is supposed to be run almost inmediately. checks should be consistent
	}
	if (critic_run){
	    # critic output files
	    if (checkexists(const_criticsumout)){
		if (!isin(const_criticsumout,global_file_out)){
		    global_file_out_n++
		    global_file_out[global_file_out_n] = const_criticsumout
		}
	    }
	    # critic -> only read results
	    if (checkexists(local_root "/" local_root ".outputcritic")){
		# critic has been done
		critic_done[local_i] = 1
		# reread values
		local_string = "lapw_extractcritic.awk topology " local_root "/" local_root ".outputcritic"
		local_string | getline critic_topology[local_i]
		close(local_string)
		local_string = "lapw_extractcritic.awk planarity " local_root "/" local_root ".outputcritic"
		local_string | getline critic_planarity[local_i]
		close(local_string)
		local_string = "lapw_extractcritic.awk morsesum " local_root "/" local_root ".outputcritic"
		local_string | getline critic_morsesum[local_i]
		close(local_string)
	    }
	    else{
		critic_topology[local_i] = "n/a"
		critic_planarity[local_i] = "n/a"
		critic_morsesum[local_i] = "n/a"
	    }
	    critic_savecheck(global_root "-check/critic.check")
	}
    }
    if (elastic_run){
	# Crystal system classification
	elastic_system = global_system
	if (global_system == "tetragonal")
	    elastic_system = "tetragonal" elastic_tetragonal
	## reread deformations and energies
	elastic_pad = int(0.4343*log(elastic_points))+1
	elastic_goodenergy = 1
	elastic_lstepab = 2 * global_a * elastic_maxlength / (elastic_points - 1)
	elastic_lstepc = 2 * global_c * elastic_maxlength / (elastic_points - 1)
	elastic_astep = 2 * elastic_maxangle  / (elastic_points - 1)
	for (local_i=1;local_i<=const_elastic_defs[elastic_system];local_i++){
	    for (local_j=1;local_j<=elastic_points;local_j++){
		## calculate deformations
		if ((local_j - (elastic_points + 1) / 2) == 0){
		    elastic_cell[local_i,local_j,"a"] = global_a + const_elastic_def[elastic_system,local_i,"a"] * 0.001
		    elastic_cell[local_i,local_j,"b"] = global_b + const_elastic_def[elastic_system,local_i,"b"] * 0.001
		    elastic_cell[local_i,local_j,"c"] = global_c + const_elastic_def[elastic_system,local_i,"c"] * 0.001
		    elastic_cell[local_i,local_j,"alpha"] = global_alpha + const_elastic_def[elastic_system,local_i,"alpha"] * 0.005
		    elastic_cell[local_i,local_j,"beta"]  = global_beta  + const_elastic_def[elastic_system,local_i,"beta"]  * 0.005
		    elastic_cell[local_i,local_j,"gamma"] = global_gamma + const_elastic_def[elastic_system,local_i,"gamma"] * 0.005
		}
		else{
		    elastic_cell[local_i,local_j,"a"] = global_a + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"a"] * elastic_lstepab
		    elastic_cell[local_i,local_j,"b"] = global_b + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"b"] * elastic_lstepab
		    elastic_cell[local_i,local_j,"c"] = global_c + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"c"] * elastic_lstepc
		    elastic_cell[local_i,local_j,"alpha"] = global_alpha + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"alpha"] * elastic_astep
		    elastic_cell[local_i,local_j,"beta"] = global_beta + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"beta"] * elastic_astep
		    elastic_cell[local_i,local_j,"gamma"] = global_gamma + (local_j - (elastic_points+1) / 2) * const_elastic_def[elastic_system,local_i,"gamma"] * elastic_astep
		}
		local_filename = global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,local_i] "/" global_root sprintf("%0*d",elastic_pad,local_j) "/" global_root sprintf("%0*d",elastic_pad,local_j) "1/" global_root sprintf("%0*d",elastic_pad,local_j) "1.scf"
		if (checkexists(local_filename)){
		    local_string = const_lapwgetetotalexe " " local_filename
		    local_string | getline elastic_energy[local_i,local_j]
		    close(local_string)
		    elastic_energy[local_i,local_j] /= global_gcdmult
		}
		else
		    elastic_energy[local_i,local_j] = ""
		if (!elastic_energy[local_i,local_j])
		    elastic_goodenergy = ""
	    }
	}
	## update .out file list
	for (local_i=1;local_i<=const_elastic_defs[elastic_system];local_i++){
	    for (local_j=1;local_j<=elastic_points;local_j++){
		if (checkexists(global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,local_i] "/" global_root sprintf("%0*d",elastic_pad,local_j) "/synopsis.out" )){
		    if (!isin(global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,local_i] "/" global_root sprintf("%0*d",elastic_pad,local_j) "/synopsis.out" ,global_file_out)){
			global_file_out_n++
			global_file_out[global_file_out_n] = global_root "-elastic/" global_root "-" const_elastic_defname[elastic_system,local_i] "/" global_root sprintf("%0*d",elastic_pad,local_j) "/synopsis.out"
		    }
		}
	    }
	}
	elastic_fitall()
	## Add summary to .out list
	if (!isin(elastic_sumout,global_file_out)){
	    global_file_out_n++
	    global_file_out[global_file_out_n] = elastic_sumout
	}
	elastic_savecheck(global_root "-check/elastic.check")
    }
    if (free_run){
	for (local_i=1;local_i<=global_atomnames;local_i++){
	    free_atomname = tolower(global_atomname[local_i])
	    if (checkexists(global_root "-free-" free_atomname "/" global_root "-free-" free_atomname "1/" global_root "-free-" free_atomname "1.scf")){
		local_string = const_lapwgetetotalexe " " global_root "-free-" free_atomname "/" global_root "-free-" free_atomname "1/" global_root "-free-" free_atomname "1.scf"
		local_string | getline free_fratenergy[free_atomname]
		close(local_string)
	    }
	}
	free_frtotalenergy = 0
	for (local_i=1;local_i<=global_nneq;local_i++){
	    free_frtotalenergy += global_molatoms[local_i] * free_fratenergy[tolower(global_atom[local_i])]
	    if (!free_fratenergy[tolower(global_atom[local_i])]){
		free_frtotalenergy = ""
		break
	    }
	}
	free_savecheck(global_root "-check/free.check")
    }
    if (sweep_run){
	sweep_root = global_root "-sweep"
	# sweep output files
	if (checkexists(const_sweepsumout)){
	    if (!isin(const_sweepsumout,global_file_out)){
		global_file_out_n++
		global_file_out[global_file_out_n] = const_sweepsumout
	    }
	}
	sweep_indexfile = sweep_root ".index"
	if (checkexists(sweep_root "/" sweep_indexfile)){
	    if (!isin(sweep_root "/" sweep_indexfile,global_file_index)){
		global_file_index_n++
		global_file_index[global_file_index_n] = sweep_root "/" sweep_indexfile
	    }
	}
	# Write down sweep synopsis.out files
	local_tmp = "ls " sweep_root "/*/synopsis.out"
	for (;local_tmp | getline local_string;){
	    if (!isin(local_string,global_file_out)){
		global_file_out_n++
		global_file_out[global_file_out_n] = local_string
	    }
	}
	close(local_string)
	# info from sweep -> only results
	sweep_pad = int(0.4343*log(sweep_iterations))+1
	for (local_i=1;local_i<=sweep_iterations;local_i++){
	    local_curname = sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "1/" sweep_root sprintf("%0*d",sweep_pad,local_i) "1"
	    # sweep output files
	    if (checkexists(sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/synopsis.out")){
		local_string = "grep 'total run time' " sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/synopsis.out | cut -f2 -d'='"
		local_string | getline sweep_time[local_i]
		close(local_string)
		sweep_time[local_i] += 0
	    }
	    if (checkexists(sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/" const_sweeprunout)){
		if (!isin(sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/" const_sweeprunout,global_file_out)){
		    global_file_out_n++
		    global_file_out[global_file_out_n] = sweep_root "/" sweep_root sprintf("%0*d",sweep_pad,local_i) "/" const_sweeprunout
		}
	    }
	    if (checkexists(local_curname ".scf")){
		sweep_done[local_i] = 1
		local_string = const_lapwgetetotalexe " " local_curname ".scf"
		local_string | getline sweep_energy[local_i]
		close(local_string)
		local_string = const_lapwgetefermiexe " " local_curname ".scf"
		local_string | getline sweep_efermi[local_i]
		close(local_string)
		local_string = const_lapwgetiterationsexe " " local_curname ".scf"
		local_string | getline sweep_noiter[local_i]
		close(local_string)
		sweep_molenergy[local_i] = sprintf("%.10f",sweep_energy[local_i] / global_gcdmult)
		sweep_warns[local_i] = 0
		if (sweep_noiter[local_i]+0 >= sweep_miter+0){
		    sweep_warns[local_i]++
		    sweep_warn[i,sweep_warns[local_i]] = const_warn_maxiter
		}
		else{
		    mysystem(const_lapwcheckdayfileexe " " local_curname ".dayfile > local_tempfile")
		    for (;getline local_string < "local_tempfile";){
			sweep_warns[local_i]++
			sweep_warn[i,sweep_warns[local_i]] = local_string
		    }
		    close("local_tempfile")
		    mysystem("rm -rf local_tempfile")
		}
		if (abs(sweep_efermi[local_i] - sweep_energymax) < 0.1){
		    sweep_warns[local_i]++
		    sweep_warn[i,sweep_warns[local_i]] = const_warn_efermi
		}
		mysystem(const_lapwcheckscfexe " " local_curname ".scf > local_tempfile")
		for (;getline local_string < "local_tempfile";){
		    sweep_warns[local_i]++
		    sweep_warn[i,sweep_warns[local_i]] = local_string
		}
		close("local_tempfile")
		mysystem("rm -rf local_tempfile")
	    }
	    else{
		sweep_energy[local_i] = "n/a"
		sweep_molenergy[local_i] = "n/a"
		sweep_efermi[local_i] = "n/a"
		sweep_noiter[local_i] = "n/a"
	    }
	    if (checkexists(local_curname ".outputcritic")){
		local_string = "lapw_extractcritic.awk planarity " local_curname ".outputcritic"
		local_string | getline sweep_planarity[local_i]
		close(local_string)
		local_string = "lapw_extractcritic.awk topology " local_curname ".outputcritic"
		local_string | getline sweep_topology[local_i]
		close(local_string)
		local_string = "lapw_extractcritic.awk morsesum " local_curname ".outputcritic"
		local_string | getline sweep_morsesum[local_i]
		close(local_string)
	    }
	    else{
		sweep_planarity[local_i] = "n/a"
		sweep_morsesum[local_i] = "n/a"
		sweep_topology[local_i] = "n/a"
	    }
	}
	sweep_savecheck(global_root "-check/sweep.check")
    }
    if (gibbs_run){
	# gibbs is supposed to be run almost inmediately. checks should be consistent
    }
    if (syn_run){
	if (syn_output){
	    if (checkexists(syn_output)){
		if (!isin(syn_output,global_file_out)){
		    global_file_out_n++
		    global_file_out[global_file_out_n] = syn_output
		}
	    }
	}
	else{
	    if (checkexists(const_synoutput)){
		if (!isin(const_synoutput,global_file_out)){
		    global_file_out_n++
		    global_file_out[global_file_out_n] = const_synoutput
		}
		syn_output = const_synoutput
	    }
	}
	# syn is supposed to be run almost inmediately. checks should be consistent
    }
    global_savecheck(global_root "-check/global.check")
    general_savecheck(global_root "-check/general.check")
    init_savecheck(global_root "-check/init.check")
}
# equal -- equate two real numbers
function equal(local_a,local_b){
    return (abs(local_a-local_b)<1.0e-10)?1:0
}
# abs -- absolute value
function abs(local2_x){
    return local2_x>0?local2_x:-local2_x
}
# max -- maximum of x and y
function max(local2_x,local2_y){
    return (local2_x>local2_y?local2_x:local2_y)
}
# min -- minimum of x and y
function min(local2_x,local2_y){
    return (local2_x<local2_y?local2_x:local2_y)
}
# gcd -- greatest common divisor
function gcd(local3_a,local3_b){
    local3_mod0 = local3_a
    local3_mod1 = local3_b
    for (;local3_mod1 != 0;){
	local3_value = local3_mod0 % local3_mod1
	local3_mod0 = local3_mod1
	local3_mod1 = local3_value
    }
    return local3_mod0
}
# volume -- cell unit volume
function volume(local3_a,local3_b,local3_c,local3_alpha,local3_beta,local3_gamma){
    return local3_a*local3_b*local3_c*sqrt(1+2*cos(local3_alpha*const_pi/180)*cos(local3_beta*const_pi/180)*cos(local3_gamma*const_pi/180)-cos(local3_alpha*const_pi/180)^2-cos(local3_beta*const_pi/180)^2-cos(local3_gamma*const_pi/180)^2)
}
# distance -- distance between two points in crystallographic coordinates
function distance(local_x0,local_y0,local_z0,local_x1,local_y1,local_z1){
    local_x = local_x1 - local_x0
    local_y = local_y1 - local_y0
    local_z = local_z1 - local_z0

    return sqrt(local_x*local_x*global_metric[1,1]+	\
		local_y*local_y*global_metric[2,2]+	\
		local_z*local_z*global_metric[3,3]+	\
		2*local_x*local_y*global_metric[1,2]+	\
		2*local_x*local_z*global_metric[1,3]+	\
		2*local_y*local_z*global_metric[2,3])
}
# rm_keyword -- remove keyword and trailing and final blanks and tabs
function rm_keyword(local_keyw,local_reg){
    sub(local_keyw,"",local_reg)
    sub(/^( |\t)*/,"",local_reg)
    sub(/( |\t)*$/,"",local_reg)
    return local_reg
}
# list_parser -- receive a comma-separated list of elements. Each
# element can be either a /-separated list of one,two or three
# elements, with or without % or the keyword auto. Set the value of
# global_niter (number of elements in the list), global_ini/end/incr
# for the limits in each element and global_flag indicating the type of
# element
function list_parser(local_reg){
    delete global_ini
    delete global_end
    delete global_incr
    delete global_flag
    delete global_num
    global_niter = split(local_reg,global_ini,",")
    for (local_i=1;local_i<=global_niter;local_i++){
	if (global_ini[local_i] ~ /auto/){
	    global_flag[local_i] = "auto"
	    continue
	}
	if (global_ini[local_i] ~ /all/){
	    global_flag[local_i] = "all"
	    continue
	}
	if (global_ini[local_i] ~ /none/){
	    global_flag[local_i] = "none"
	    continue
	}
	if (global_ini[local_i] ~ /old/){
	    global_flag[local_i] = "old"
	    continue
	}
	if (global_ini[local_i] ~ /new/){
	    global_flag[local_i] = "new"
	    continue
	}
	if (global_ini[local_i] ~ /%/){
	    gsub("%","",global_ini[local_i])
	    global_flag[local_i] = "%"
	}
	else{
	    global_flag[local_i] = "normal"
	}
	split(global_ini[local_i],local_arr,"/")
	global_ini[local_i] = local_arr[1]
	global_end[local_i] = local_arr[1]
	global_incr[local_i] = 1
	if (local_arr[2])
	    global_end[local_i] = local_arr[2]
	if (local_arr[3])
	    global_incr[local_i] = local_arr[3];
	delete local_arr
	if (global_flag[local_i] == "normal" || global_flag[local_i] == "%"){
	    global_num[local_i] = int((global_end[local_i]-global_ini[local_i])/global_incr[local_i]+0.005)+1
	    if (global_num[local_i] <= 0){
		print "[global|error] Parsing of list : " local_reg
		print "[global|error] returned an infinite loop."
		exit 1
	    }
	}
	else
	    global_num[local_i] = 0
    }
}
# isin -- returns true if first argument is an element of the second argument array
function isin(local3_name,local3_arr){
    for (local3_i in local3_arr)
	if (local3_name == local3_arr[local3_i])
	    return 1
    return ""
}
# checkerror(name,keyw,value) -- Check a given filename (name) for
# errors. If keyw is blank, it is an
# error if the filename has any text. If keyw is "checkword", checks
# for word value in the filename.
function checkerror(local2_name,local2_keyw,local2_value){
    local2_err = 0
    if (local2_keyw == "blank"){
	getline local2_err < local2_name
	close(local2_name)
    }
    if (local2_keyw == "checkword"){
	for(;getline local2_line < local2_name;)
	    if (local2_line ~ local2_value)
		local2_err = 1
	close(local2_name)
    }
    if (local2_err)
	return 1
    else
	return 0
}
# checkexe(name) -- checks for the availability of an executable file
function checkexe(local_name){
    split(local_name,local_arr)
    local_name = local_arr[1]
    local_val = ""
    local_string = "which " local_name
    local_string | getline local_val
    close(local_string)
    return (local_val != "")
}
# checkexists(name) -- checks for the existence of filename name
function checkexists(local2_name){
    local2_err = 0
    local2_reg = const_lapwexistsexe " " local2_name
    local2_reg | getline local2_err
    close(local2_reg)
    return local2_err+0
}
# checkexists(path,name) -- checks for the existence of the vector
# file name.vector. If SCRATCH is an absolute path, it is the path
# chosen. If it is relative, it refers to path.
function checkvector(local_path,local_name){
    local_scr = ENVIRON["SCRATCH"]
    if (local_scr == "") 
	local_scr = "./"
    if (local_scr !~ /\/$/)
	local_scr = local_scr "/"

    local_string = "cd " local_path " ; " const_lapwexistsexe " " local_scr local_name ".vector"
    local_string | getline local_err
    close(local_string)
    return local_err+0
}
# checkempty(name) -- checks if the file is empty
function checkempty(local_name){
    local_string = "du " local_name " | awk '{print $1}'"
    local_string | getline local_err
    if (local_err+0 == 0)
	return 1
    else
	return ""
}
# date -- get system date
function date(){
    "date" | getline global_date
    close("date")
    return global_date
}
# getsystem -- determine system from unit cell parameters
function getsystem(local2_a,local2_b,local2_c,local2_alpha,local2_beta,local2_gamma){
    if (equal(local2_alpha,local2_beta) && equal(local2_beta,local2_gamma) &&\
	equal(local2_alpha,90.0)){
	if (equal(local2_a,local2_b) && equal(local2_b,local2_c)){
	    return "cubic"
	}
	else if (equal(local2_a,local2_b) || equal(local2_b,local2_c) || \
	    equal(local2_c,local2_a)){
	    return "tetragonal"
	}
	else{
	    return "orthorhombic"
	}
    }
    else if (equal(local2_alpha,local2_beta) && equal(local2_beta,local2_gamma) && \
	     equal(local2_a,local2_b) && equal(local2_b,local2_c)){
	return "rhombohedric"
    }
    else if ((equal(local2_alpha,90.0) && equal(local2_beta,90.0)) || (equal(local2_beta,90.0) && equal(local2_gamma,90.0)) || (equal(local2_alpha,90.0) && equal(local2_gamma,90.0))){
	if ((equal(local2_alpha,120.0) || equal(local2_beta,120.0) || equal(local2_gamma,120.0)) &&\
	    (equal(local2_a,local2_b) || equal(local2_b,local2_c) || equal(local2_a,local2_c))){
	    return "hexagonal"
	}
	else{
	    return "monoclinic"
	}
    }
    else{
	return "triclinic"
    }
}
# elastic_sumout, elastic_energy, elastic_points, elastic_cell,
# elastic_goodenergy, elastic_forcefit
# elastic_d2e, elastic_constant, elastic_condition
function elastic_fitall() {
    if (elastic_system == "cubic"){
	## Print interpretive comments
	elastic_sumout = global_root "-elastic/" const_elasticsumout
	print "# Energy vs. deformation plots for a cubic system" > elastic_sumout
	print "# ----------------------------------------------------" > elastic_sumout
	print "#" > elastic_sumout
	print "# In this summary, the lagrangian finite strain tensor is used." > elastic_sumout
	print "# Deformation    Deformed cell parameters            Finite lagrangian strain tensor      Elastic constants expression" > elastic_sumout
	print "#                                                         (Voigt notation)		                                              " > elastic_sumout
	print "#   111000    (a+eps) (a+eps) (a+eps) 90 90 90         (eps1 eps1 eps1 0 0 0)               c11 + 2*c12 = 1 / (3*V) * (d^2E/d(eps1)^2) " > elastic_sumout
	print "#   001000        a  a (a+eps) 90 90 120                 (0 0 eps1 0 0 0)                   c11 = 1 / V * (d^2E/d(eps1)^2) " > elastic_sumout
	print "#   000111     a  a  a  (90-phi) (90-phi) (90-phi)     (0 0 0 eps3 eps3 eps3)               c44 = 1 / (3*V) * (d^2E/d(eps3)^2)" > elastic_sumout
	print "#" > elastic_sumout
	print "#   where:" > elastic_sumout
	print "#   eps1 = ((a+eps)^2 - a^2) / (2*a^2) " > elastic_sumout
	print "#   eps3 = sin(phi)" > elastic_sumout
	print "#" > elastic_sumout
	print "# Please, note that internal strain (caused by the relaxation of atomic coordinates inside the unit cell) " > elastic_sumout 
	print "# unless a minimization (mini) is carried out." > elastic_sumout
	print "#" > elastic_sumout

	## Print energy vs. deformation curves, gnuplot adequate format
	print "# Deformation 111000" > elastic_sumout
	print "#   eps1    Energy* / Ry " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[1,i])
		printf "%.10f %.10f\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / (2 * global_a^2) , elastic_energy[1,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / (2 * global_a^2) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 001000" > elastic_sumout
	print "#   eps1    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[2,i])
		printf "%.10f %.10f\n", (elastic_cell[2,i,"c"]^2 - global_c^2) / (2 * global_c^2), elastic_energy[2,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[2,i,"c"]^2 - global_c^2) / (2 * global_c^2) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 000111" > elastic_sumout
	print "#   eps3    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[3,i])
		printf "%.10f %.10f\n", sin((90-elastic_cell[3,i,"alpha"])*const_pi/180), elastic_energy[3,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", sin((90-elastic_cell[3,i,"alpha"])*const_pi/180) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout

	close(elastic_sumout)

	# Fit energy curves
	if (elastic_goodenergy || global_var["elastic_forcefit"]){
	    elastic_goodfit = 1
	    for (i=1;i<=const_elastic_defs[elastic_system];i++){
		# Build the fitting script
		elastic_build_fitscript(i,0)
		# Run the fitting script
		elastic_run_fitscript(i)
		# Check derivatives
		if (!(elastic_d2e[i]+0))
		    elastic_goodfit = ""
	    }
	    if (elastic_goodfit){
		## Calculate elastic constants
		elastic_constant["c11"] = elastic_d2e[2] / global_molv
		elastic_constant["c44"] = elastic_d2e[3] / (3 * global_molv)
		elastic_constant["c12"] = (elastic_d2e[1] / 6 - elastic_d2e[2] / 2) / global_molv
		## Transform to GPa
		for (i in elastic_constant)
		    elastic_constant[i] *= const_rybohr3togpa
		## Check stability conditions for cubic systems
		elastic_condition[1] = (elastic_constant["c11"] > abs(elastic_constant["c12"]))?"yes":"no"
		elastic_condition[2] = (elastic_constant["c11"]+2*elastic_constant["c12"] > 0)?"yes":"no"
		elastic_condition[3] = (elastic_constant["c44"] > 0)?"yes":"no"
	    }
	    else{
		print "[warn|elastic] Some elastic fit has failed. Check .gnuplot, .log and .err."
		print "[warn|elastic] I can not calculate elastic constants."
	    }
	}
	else{
	    print "[warn|elastic] Elastic energies are not completely known."
	    print "[warn|elastic] Skipping fit..."
	}
    }
    else if (elastic_system == "hexagonal") {
	## Print interpretive comments
	elastic_sumout = global_root "-elastic/" const_elasticsumout
	print "# Energy vs. deformation plots for an hexagonal system" > elastic_sumout
	print "# ----------------------------------------------------" > elastic_sumout
	print "#" > elastic_sumout
	print "# In this summary, the lagrangian finite strain tensor is used." > elastic_sumout
	print "# Deformation    Deformed cell parameters            Finite lagrangian strain tensor                     Elastic constants expression" > elastic_sumout
	print "#                                                         (Voigt notation)		              " > elastic_sumout
	print "#   110000    (a+eps) (a+eps) c 90 90 120                (eps1/2 eps1/2 0 0 0 0)                   1/4*(c11 + c12) = 1/(2*V) * (d^2E / d(eps1)^2)" > elastic_sumout
	print "#   001000        a  a (c+eps) 90 90 120                 (0 0 eps2/2 0 0 0)                        1/8*c33 = 1/(2*V) * (d^2E / d(eps2)^2)" > elastic_sumout
	print "#   111000    (a+eps) (a+eps) (c+eps*c/a) 90 90 120      (eps1/2 eps1/2 eps2/2 0 0 0)              1/4*(c11 + c12) + 1/8*c33 + 1/2*c13 = 1/(2*V) * (d^2E/d(eps1)^2)" > elastic_sumout
	print "#   000110        a  a  c  (90-phi) (90-phi) 120         (0 0 0 eps4 eps4/sqrt(3) 0)               2*c44 = 1/(2*V) * (d^2E/d(eps4)^2)" > elastic_sumout
	print "#   000001        a  a  c  90  90  (120-phi)       (1/3+2/3*eps3 0 0 0 0 2/sqrt(3)*eps3+1/sqrt(3)) -1/3*c12 + 5/9*c11 = 1/(2*V) * (d^2E/d(eps3)^2)" > elastic_sumout
	print "#" > elastic_sumout
	print "#   where:" > elastic_sumout
	print "#   eps1 = ((a+eps)^2 - a^2) / a^2 " > elastic_sumout
	print "#   eps2 = ((c+eps)^2 - c^2) / c^2 " > elastic_sumout
	print "#   eps3 = cos(120-phi)" > elastic_sumout
	print "#   eps4 = sin(phi)" > elastic_sumout
	print "#" > elastic_sumout
	print "# Please, note that internal strain (caused by the relaxation of atomic coordinates inside the unit cell) " > elastic_sumout 
	print "# unless a minimization (mini) is carried out." > elastic_sumout
	print "#" > elastic_sumout

	## Print energy vs. deformation curves, gnuplot adequate format
	print "# Deformation 111000" > elastic_sumout
	print "#   eps1    Energy* / Ry " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[1,i]) 
		printf "%.10f %.10f\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / global_a^2, elastic_energy[1,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / global_a^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 110000" > elastic_sumout
	print "#   eps2    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[2,i])
		printf "%.10f %.10f\n", (elastic_cell[2,i,"a"]^2 - global_a^2) / global_a^2, elastic_energy[2,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[2,i,"a"]^2 - global_a^2) / global_a^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 001000" > elastic_sumout
	print "#   eps1    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[3,i])
		printf "%.10f %.10f\n", (elastic_cell[3,i,"c"]^2 - global_c^2) / global_c^2, elastic_energy[3,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[3,i,"c"]^2 - global_c^2) / global_c^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 000110" > elastic_sumout
	print "#   eps4    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[4,i])
		printf "%.10f %.10f\n", sin((90-elastic_cell[4,i,"alpha"])*const_pi/180), elastic_energy[4,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", sin((90-elastic_cell[4,i,"alpha"])*const_pi/180) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 000001" > elastic_sumout
	print "#   eps3    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[5,i])
		printf "%.10f %.10f\n", cos(elastic_cell[5,i,"gamma"]*const_pi/180), elastic_energy[5,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", cos(elastic_cell[5,i,"gamma"]*const_pi/180) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout

	close(elastic_sumout)

	if (elastic_goodenergy || global_var["elastic_forcefit"]){
	    elastic_goodfit = 1
	    for (i=1;i<=const_elastic_defs[elastic_system];i++){
		# Build the fitting script
		if (i == 5)
		    elastic_build_fitscript(i,-0.5)
		else
		    elastic_build_fitscript(i,0)
		# Run the fitting script
		elastic_run_fitscript(i)
		# Check derivatives
		if (!(elastic_d2e[i]+0))
		    elastic_goodfit = ""
	    }
	    if (elastic_goodfit){
		## Calculate elastic constants
		elastic_constant["c33"] = 4 / global_molv * elastic_d2e[3]
		elastic_constant["c44"] = elastic_d2e[4] / (4 * global_molv)
		elastic_constant["c13"] = (elastic_d2e[1] - elastic_d2e[2] - elastic_d2e[3]) / global_molv
		elastic_constant["c11"] = (3 / 4 * elastic_d2e[2] + 9 / 16 * elastic_d2e[5]) / global_molv
		elastic_constant["c12"] = (5 / 4 * elastic_d2e[2] - 9 / 16 * elastic_d2e[5]) / global_molv
		## Transform to GPa
		for (i in elastic_constant)
		    elastic_constant[i] *= const_rybohr3togpa
		## Check stability conditions for hexagonal systems
		elastic_condition[1] = (elastic_constant["c11"] > abs(elastic_constant["c12"]))?"yes":"no"
		elastic_condition[2] = ((elastic_constant["c11"]+elastic_constant["c12"])*\
					elastic_constant["c33"] > 2*elastic_constant["c13"]^2)?"yes":"no"
		elastic_condition[3] = (elastic_constant["c44"] > 0)?"yes":"no"
	    }
	    else{
		print "[warn|elastic] Some elastic fit has failed. Check .gnuplot, .log and .err."
		print "[warn|elastic] I can not calculate elastic constants."
	    }
	}
	else{
	    print "[warn|elastic] Elastic energies are not completely known."
	    print "[warn|elastic] Skipping fit..."
	}
    } 
    else if (elastic_system == "tetragonal1") { 
	## Print interpretive comments
	elastic_sumout = global_root "-elastic/" const_elasticsumout
	print "# Energy vs. deformation plots for a tetragonal (high symmetry point group) system" > elastic_sumout
	print "# --------------------------------------------------------------------------------" > elastic_sumout
	print "#" > elastic_sumout
	print "# In this summary, the lagrangian finite strain tensor is used." > elastic_sumout
	print "# Deformation    Deformed cell parameters       Finite lagrangian strain tensor   Elastic constants expression" > elastic_sumout
	print "#                                                      (Voigt notation)		              " > elastic_sumout
	print "#   111000 (a+eps) (a+eps) (c+eps*c/a) 90 90 90  (eps1/2 eps1/2 eps2/2 0 0 0)  1/4*(c11+c12) + 1/8*c33 + 1/2*c13 = 1/(2*V)*(d^2E/d(eps1)^2)" > elastic_sumout
	print "#   110000 (a+eps) (a+eps) c 90 90 90            (eps1/2 eps1/2 0 0 0 0)       1/4*(c11 + c12) = 1/(2*V) * (d^2E / d(eps1)^2)" > elastic_sumout
	print "#   001000   a  a (c+eps) 90 90 90               (0 0 eps2/2 0 0 0)            1/8*c33 = 1/(2*V) * (d^2E / d(eps2)^2)" > elastic_sumout
	print "#   010000   a (a+eps) c 90 90 90                (0 eps1/2 0 0 0 0)            1/8*c11 = 1/(2*V) * (d^2E / d(eps1)^2)" > elastic_sumout
	print "#   000010   a  a  c  90 (90-phi) 90             (0 0 0 0 sin(phi) 0)          c44 = 1/(2*V) * (d^2E/d(sin(phi))^2)" > elastic_sumout
	print "#   000001   a  a  c  90  90  (90-phi)           (0 0 0 0 0 sin(phi))          c66 = 1/(2*V) * (d^2E/d(sin(phi))^2)" > elastic_sumout
	print "#" > elastic_sumout
	print "#   where:" > elastic_sumout
	print "#   eps1 = ((a+eps)^2 - a^2) / a^2 " > elastic_sumout
	print "#   eps2 = ((c+eps)^2 - c^2) / c^2 " > elastic_sumout
	print "#" > elastic_sumout
	print "# Please, note that internal strain (caused by the relaxation of atomic coordinates inside the unit cell) " > elastic_sumout 
	print "# unless a minimization (mini) is carried out." > elastic_sumout
	print "#" > elastic_sumout
	## Print energy vs. deformation curves, gnuplot adequate format
	print "# Deformation 111000" > elastic_sumout
	print "#   eps1    Energy* / Ry " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[1,i])
		printf "%.10f %.10f\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / global_a^2, elastic_energy[1,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[1,i,"a"]^2 - global_a^2) / global_a^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 110000" > elastic_sumout
	print "#   eps2    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[2,i])
		printf "%.10f %.10f\n", (elastic_cell[2,i,"a"]^2 - global_a^2) / global_a^2, elastic_energy[2,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[2,i,"a"]^2 - global_a^2) / global_a^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 001000" > elastic_sumout
	print "#   eps1    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[3,i])
		printf "%.10f %.10f\n", (elastic_cell[3,i,"c"]^2 - global_c^2) / global_c^2, elastic_energy[3,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[3,i,"c"]^2 - global_c^2) / global_c^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 010000" > elastic_sumout
	print "#   eps1    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[4,i])
		printf "%.10f %.10f\n", (elastic_cell[4,i,"b"]^2 - global_a^2) / global_a^2, elastic_energy[4,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", (elastic_cell[4,i,"b"]^2 - global_a^2) / global_a^2 > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 000010" > elastic_sumout
	print "#   sin(phi)    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[5,i])
		printf "%.10f %.10f\n", sin((90-elastic_cell[5,i,"beta"])*const_pi/180), elastic_energy[5,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", sin((90-elastic_cell[5,i,"beta"])*const_pi/180) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout
	print "# Deformation 000001" > elastic_sumout
	print "#   sin(phi)    Energy* / Ry  " > elastic_sumout
	for (i=1;i<=elastic_points;i++){
	    if (elastic_energy[6,i])
		printf "%.10f %.10f\n", sin((90-elastic_cell[6,i,"gamma"])*const_pi/180), elastic_energy[6,i] > elastic_sumout
	    else
		printf "# %.10f n/a\n", sin((90-elastic_cell[6,i,"gamma"])*const_pi/180) > elastic_sumout
	}
	print "" > elastic_sumout
	print "" > elastic_sumout

	close(elastic_sumout)
	
	if (elastic_goodenergy || global_var["elastic_forcefit"]){
	    elastic_goodfit = 1
	    for (i=1;i<=const_elastic_defs[elastic_system];i++){
		# Build the fitting script
		elastic_build_fitscript(i,0)
		# Run the fitting script
		elastic_run_fitscript(i)
		# Check derivatives
		if (!(elastic_d2e[i]+0))
		    elastic_goodfit = ""
	    }
	    if (elastic_goodfit){
		## Calculate elastic constants
		elastic_constant["c11"] = 8 * (elastic_d2e[4] / (2*global_molv))
		elastic_constant["c12"] = 4 * (elastic_d2e[2] / (2*global_molv)) - 8 * (elastic_d2e[4] / (2*global_molv))
		elastic_constant["c13"] = 2 * (elastic_d2e[1] - elastic_d2e[2] - elastic_d2e[3]) / (2*global_molv)
		elastic_constant["c33"] = 8 * (elastic_d2e[3] / (2*global_molv))
		elastic_constant["c44"] = (elastic_d2e[5] / (2*global_molv))
		elastic_constant["c66"] = (elastic_d2e[6] / (2*global_molv))
		## Transform to GPa
		for (i in elastic_constant)
		    elastic_constant[i] *= const_rybohr3togpa
		## Check stability conditions for high symmetry tetragonal systems
		elastic_condition[1] = (elastic_constant["c11"] > abs(elastic_constant["c12"]))?"yes":"no"
		elastic_condition[2] = ((elastic_constant["c11"]+elastic_constant["c12"])*elastic_constant["c33"] > \
					2*elastic_constant["c13"]^2)?"yes":"no"
		elastic_condition[3] = (elastic_constant["c44"] > 0)?"yes":"no"
		elastic_condition[4] = (elastic_constant["c66"] > 0)?"yes":"no"
	    }
	    else{
		print "[warn|elastic] Some elastic fit has failed. Check .gnuplot, .log and .err."
		print "[warn|elastic] I can not calculate elastic constants."
	    }
	}
	else{
	    print "[warn|elastic] Elastic energies are not completely known. Skipping fit."
	    print "[warn|elastic] Reload when the energies are correctly calculated..."
	}
    }
}
# elastic_build_fitscript(deformation number, x for fixed minimum)
# Builds the script corresponding to local_def. This function is tightly bound
# to the elastic section and uses many of its variables. Its purpose is
# unloading the code repetition from the main body of the elastic section.
function elastic_build_fitscript(local2_def,local2_zero){
    local2_defname = const_elastic_defname[elastic_system,local2_def]
    local2_filename = global_root "-elastic/fit" local2_defname ".gnuplot"
    local2_prepath = "cd " global_root "-elastic ;"
    print "set terminal postscript eps enhanced color 'Helvetica' 20" > local2_filename
    print "set output 'fit" local2_defname ".eps'" > local2_filename
    if (elastic_term1 == "yes")
	print const_elastic_f[elastic_polyorder] > local2_filename
    else
	print const_elastic_f_1[elastic_polyorder] > local2_filename
    print const_elastic_g[elastic_polyorder] > local2_filename
    print "c0 = " elastic_energy[local2_def,int((elastic_points+1)/2)] > local2_filename
    print "c1 = -0.000005" > local2_filename
    print "c2 = 1.0" > local2_filename
    if (elastic_polyorder > 2){
	print "c3 = -2.0" > local2_filename
	print "c4 = 3.0" > local2_filename
    }
    if (elastic_polyorder > 4){
	print "c5 = 4.0" > local2_filename
	print "c6 = -1.0" > local2_filename
    }
    if (elastic_polyorder > 6){
	print "c7 = 1.0" > local2_filename
	print "c8 = -1.0" > local2_filename
    }
    if (elastic_fixmin == "yes")
	print "x0 = " const_elastic_zero[elastic_system,local2_def] > local2_filename
    else
	print "x0 = " (elastic_cell[1,int((elastic_points+1)/2),"a"]^2 - global_a^2) / global_a^2 > local2_filename
    temp_string = "via c0,c2"
    if (elastic_polyorder > 2)
	temp_string = temp_string ",c3,c4"
    if (elastic_polyorder > 4)
	temp_string = temp_string ",c5,c6"
    if (elastic_polyorder > 6)
	temp_string = temp_string ",c7,c8"
    if (elastic_fixmin == "no")
	temp_string = temp_string ",x0"
    if (elastic_term1 == "yes")
	temp_string = temp_string ",c1"
    print "fit f(x) '" const_elasticsumout "' index " (local2_def-1) " " temp_string > local2_filename
    print "print \"second_derivative: \",g("local2_zero")" > local2_filename
    print "print \"coefficient_c0: \",c0" > local2_filename
    print "print \"coefficient_c2: \",c2" > local2_filename
    if (elastic_polyorder > 2){
	print "print \"coefficient_c3: \",c3" > local2_filename
	print "print \"coefficient_c4: \",c4" > local2_filename
    }
    if (elastic_polyorder > 4){
	print "print \"coefficient_c5: \",c5" > local2_filename
	print "print \"coefficient_c6: \",c6" > local2_filename
    }
    if (elastic_polyorder > 6){
	print "print \"coefficient_c7: \",c7" > local2_filename
	print "print \"coefficient_c8: \",c8" > local2_filename
    }
    if (elastic_fixmin == "no")
	print "print \"coefficient_x0: \",x0" > local2_filename
    if (elastic_term1 == "yes")
	print "print \"coefficient_c1: \",c1" > local2_filename
    print "plot f(x), '" const_elasticsumout "' index " (local2_def-1) " w points" > local2_filename
    close(local2_filename)
}
# elastic_run_fitscript(deformation number)
# Runs the script corresponding to local_def. This function is tightly bound
# to the elastic section and uses many of its variables. Its purpose is
# unloading the code repetition from the main body of the elastic section.
function elastic_run_fitscript(local2_def){
    local2_prepath = "cd " global_root "-elastic ;"
    local2_defname = const_elastic_defname[elastic_system,local2_def]
    mysystem(local2_prepath const_gnuplotexe " fit" local2_defname ".gnuplot > ../errfile 2>&1")
    ## Check for errors in the fit
    if (checkerror("errfile","checkword","Singular matrix in Invert_RtR"))
	elastic_goodfit = ""
    ## Run fit script for 000110
    local2_string = "cat errfile | grep second_derivative | cut -d ' ' -f 2"
    local2_string | getline elastic_d2e[local2_def]
    close(local2_string)
    local2_string = const_lapwgetrmsexe " errfile "
    local2_string | getline elastic_rms[local2_def]
    close(local2_string)
    local2_string = "cat errfile | grep coefficient_c0 | cut -d ' ' -f 2"
    local2_string | getline elastic_coeff[local2_def,"c0"]
    close(local2_string)
    local2_string = "cat errfile | grep coefficient_c2 | cut -d ' ' -f 2"
    local2_string | getline elastic_coeff[local2_def,"c2"]
    close(local2_string)
    if (elastic_polyorder > 2){
	local2_string = "cat errfile | grep coefficient_c3 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c3"]
	close(local2_string)
	local2_string = "cat errfile | grep coefficient_c4 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c4"]
	close(local2_string)
    }
    if (elastic_polyorder > 4){
	local2_string = "cat errfile | grep coefficient_c5 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c5"]
	close(local2_string)
	local2_string = "cat errfile | grep coefficient_c6 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c6"]
	close(local2_string)
    }
    if (elastic_polyorder > 6){
	local2_string = "cat errfile | grep coefficient_c7 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c7"]
	close(local2_string)
	local2_string = "cat errfile | grep coefficient_c8 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c8"]
	close(local2_string)
    }
    local2_string = "cat errfile | grep coefficient_x0 | cut -d ' ' -f 2"
    local2_string | getline elastic_coeff[local2_def,"x0"]
    close(local2_string)
    if (elastic_term1 == "yes"){
	local2_string = "cat errfile | grep coefficient_c1 | cut -d ' ' -f 2"
	local2_string | getline elastic_coeff[local2_def,"c1"]
	close(local2_string)
    }
    mysystem("mv -f errfile " global_root "-elastic/fit" local2_defname ".err")
    mysystem("mv -f " global_root"-elastic/fit.log " global_root "-elastic/fit" local2_defname ".log")
}
# defined -- checks if an array is defined.
function defined(local_a){
    for (local_i in local_a){
	return 1
    }
    return 0
}
# define_constants -- defines: arrays relating atomic symbol to atomic
# number, space group labels and numbers. Obscures source if defined in BEGIN.
function define_constants(){
    const_atomicname[  0] = "Bq";   const_atomicnumber["Bq"] =   0;
    const_atomicnumber["Gh"] =   0;
    const_atomicnumber["Xx"] =   0;
    const_atomicname[  1] = "H" ;   const_atomicnumber["H" ] =   1;
    const_atomicname[  2] = "He";   const_atomicnumber["He"] =   2;
    const_atomicname[  3] = "Li";   const_atomicnumber["Li"] =   3;
    const_atomicname[  4] = "Be";   const_atomicnumber["Be"] =   4;
    const_atomicname[  5] = "B" ;   const_atomicnumber["B" ] =   5;
    const_atomicname[  6] = "C" ;   const_atomicnumber["C" ] =   6;
    const_atomicname[  7] = "N" ;   const_atomicnumber["N" ] =   7;
    const_atomicname[  8] = "O" ;   const_atomicnumber["O" ] =   8;
    const_atomicname[  9] = "F" ;   const_atomicnumber["F" ] =   9;
    const_atomicname[ 10] = "Ne";   const_atomicnumber["Ne"] =  10;
    const_atomicname[ 11] = "Na";   const_atomicnumber["Na"] =  11;
    const_atomicname[ 12] = "Mg";   const_atomicnumber["Mg"] =  12;
    const_atomicname[ 13] = "Al";   const_atomicnumber["Al"] =  13;
    const_atomicname[ 14] = "Si";   const_atomicnumber["Si"] =  14;
    const_atomicname[ 15] = "P" ;   const_atomicnumber["P" ] =  15;
    const_atomicname[ 16] = "S" ;   const_atomicnumber["S" ] =  16;
    const_atomicname[ 17] = "Cl";   const_atomicnumber["Cl"] =  17;
    const_atomicname[ 18] = "Ar";   const_atomicnumber["Ar"] =  18;
    const_atomicname[ 19] = "K" ;   const_atomicnumber["K" ] =  19;
    const_atomicname[ 20] = "Ca";   const_atomicnumber["Ca"] =  20;
    const_atomicname[ 21] = "Sc";   const_atomicnumber["Sc"] =  21;
    const_atomicname[ 22] = "Ti";   const_atomicnumber["Ti"] =  22;
    const_atomicname[ 23] = "V" ;   const_atomicnumber["V" ] =  23;
    const_atomicname[ 24] = "Cr";   const_atomicnumber["Cr"] =  24;
    const_atomicname[ 25] = "Mn";   const_atomicnumber["Mn"] =  25;
    const_atomicname[ 26] = "Fe";   const_atomicnumber["Fe"] =  26;
    const_atomicname[ 27] = "Co";   const_atomicnumber["Co"] =  27;
    const_atomicname[ 28] = "Ni";   const_atomicnumber["Ni"] =  28;
    const_atomicname[ 29] = "Cu";   const_atomicnumber["Cu"] =  29;
    const_atomicname[ 30] = "Zn";   const_atomicnumber["Zn"] =  30;
    const_atomicname[ 31] = "Ga";   const_atomicnumber["Ga"] =  31;
    const_atomicname[ 32] = "Ge";   const_atomicnumber["Ge"] =  32;
    const_atomicname[ 33] = "As";   const_atomicnumber["As"] =  33;
    const_atomicname[ 34] = "Se";   const_atomicnumber["Se"] =  34;
    const_atomicname[ 35] = "Br";   const_atomicnumber["Br"] =  35;
    const_atomicname[ 36] = "Kr";   const_atomicnumber["Kr"] =  36;
    const_atomicname[ 37] = "Rb";   const_atomicnumber["Rb"] =  37;
    const_atomicname[ 38] = "Sr";   const_atomicnumber["Sr"] =  38;
    const_atomicname[ 39] = "Y" ;   const_atomicnumber["Y" ] =  39;
    const_atomicname[ 40] = "Zr";   const_atomicnumber["Zr"] =  40;
    const_atomicname[ 41] = "Nb";   const_atomicnumber["Nb"] =  41;
    const_atomicname[ 42] = "Mo";   const_atomicnumber["Mo"] =  42;
    const_atomicname[ 43] = "Tc";   const_atomicnumber["Tc"] =  43;
    const_atomicname[ 44] = "Ru";   const_atomicnumber["Ru"] =  44;
    const_atomicname[ 45] = "Rh";   const_atomicnumber["Rh"] =  45;
    const_atomicname[ 46] = "Pd";   const_atomicnumber["Pd"] =  46;
    const_atomicname[ 47] = "Ag";   const_atomicnumber["Ag"] =  47;
    const_atomicname[ 48] = "Cd";   const_atomicnumber["Cd"] =  48;
    const_atomicname[ 49] = "In";   const_atomicnumber["In"] =  49;
    const_atomicname[ 50] = "Sn";   const_atomicnumber["Sn"] =  50;
    const_atomicname[ 51] = "Sb";   const_atomicnumber["Sb"] =  51;
    const_atomicname[ 52] = "Te";   const_atomicnumber["Te"] =  52;
    const_atomicname[ 53] = "I" ;   const_atomicnumber["I" ] =  53;
    const_atomicname[ 54] = "Xe";   const_atomicnumber["Xe"] =  54;
    const_atomicname[ 55] = "Cs";   const_atomicnumber["Cs"] =  55;
    const_atomicname[ 56] = "Ba";   const_atomicnumber["Ba"] =  56;
    const_atomicname[ 57] = "La";   const_atomicnumber["La"] =  57;
    const_atomicname[ 58] = "Ce";   const_atomicnumber["Ce"] =  58;
    const_atomicname[ 59] = "Pr";   const_atomicnumber["Pr"] =  59;
    const_atomicname[ 60] = "Nd";   const_atomicnumber["Nd"] =  60;
    const_atomicname[ 61] = "Pm";   const_atomicnumber["Pm"] =  61;
    const_atomicname[ 62] = "Sm";   const_atomicnumber["Sm"] =  62;
    const_atomicname[ 63] = "Eu";   const_atomicnumber["Eu"] =  63;
    const_atomicname[ 64] = "Gd";   const_atomicnumber["Gd"] =  64;
    const_atomicname[ 65] = "Tb";   const_atomicnumber["Tb"] =  65;
    const_atomicname[ 66] = "Dy";   const_atomicnumber["Dy"] =  66;
    const_atomicname[ 67] = "Ho";   const_atomicnumber["Ho"] =  67;
    const_atomicname[ 68] = "Er";   const_atomicnumber["Er"] =  68;
    const_atomicname[ 69] = "Tm";   const_atomicnumber["Tm"] =  69;
    const_atomicname[ 70] = "Yb";   const_atomicnumber["Yb"] =  70;
    const_atomicname[ 71] = "Lu";   const_atomicnumber["Lu"] =  71;
    const_atomicname[ 72] = "Hf";   const_atomicnumber["Hf"] =  72;
    const_atomicname[ 73] = "Ta";   const_atomicnumber["Ta"] =  73;
    const_atomicname[ 74] = "W" ;   const_atomicnumber["W" ] =  74;
    const_atomicname[ 75] = "Re";   const_atomicnumber["Re"] =  75;
    const_atomicname[ 76] = "Os";   const_atomicnumber["Os"] =  76;
    const_atomicname[ 77] = "Ir";   const_atomicnumber["Ir"] =  77;
    const_atomicname[ 78] = "Pt";   const_atomicnumber["Pt"] =  78;
    const_atomicname[ 79] = "Au";   const_atomicnumber["Au"] =  79;
    const_atomicname[ 80] = "Hg";   const_atomicnumber["Hg"] =  80;
    const_atomicname[ 81] = "Tl";   const_atomicnumber["Tl"] =  81;
    const_atomicname[ 82] = "Pb";   const_atomicnumber["Pb"] =  82;
    const_atomicname[ 83] = "Bi";   const_atomicnumber["Bi"] =  83;
    const_atomicname[ 84] = "Po";   const_atomicnumber["Po"] =  84;
    const_atomicname[ 85] = "At";   const_atomicnumber["At"] =  85;
    const_atomicname[ 86] = "Rn";   const_atomicnumber["Rn"] =  86;
    const_atomicname[ 87] = "Fr";   const_atomicnumber["Fr"] =  87;
    const_atomicname[ 88] = "Ra";   const_atomicnumber["Ra"] =  88;
    const_atomicname[ 89] = "Ac";   const_atomicnumber["Ac"] =  89;
    const_atomicname[ 90] = "Th";   const_atomicnumber["Th"] =  90;
    const_atomicname[ 91] = "Pa";   const_atomicnumber["Pa"] =  91;
    const_atomicname[ 92] = "U" ;   const_atomicnumber["U" ] =  92;
    const_atomicname[ 93] = "Np";   const_atomicnumber["Np"] =  93;
    const_atomicname[ 94] = "Pu";   const_atomicnumber["Pu"] =  94;
    const_atomicname[ 95] = "Am";   const_atomicnumber["Am"] =  95;
    const_atomicname[ 96] = "Cm";   const_atomicnumber["Cm"] =  96;
    const_atomicname[ 97] = "Bk";   const_atomicnumber["Bk"] =  97;
    const_atomicname[ 98] = "Cf";   const_atomicnumber["Cf"] =  98;
    const_atomicname[ 99] = "Es";   const_atomicnumber["Es"] =  99;
    const_atomicname[100] = "Fm";   const_atomicnumber["Fm"] = 100;
    const_atomicname[101] = "Md";   const_atomicnumber["Md"] = 101;
    const_atomicname[102] = "No";   const_atomicnumber["No"] = 102;
    const_atomicname[103] = "Lr";   const_atomicnumber["Lr"] = 103;

    const_atomicmass["H"] = 1.00794
    const_atomicmass["He"] = 4.002602
    const_atomicmass["Li"] = 6.941
    const_atomicmass["Be"] = 9.012182
    const_atomicmass["B"] = 10.811
    const_atomicmass["C"] = 12.0107
    const_atomicmass["N"] = 14.0067
    const_atomicmass["O"] = 15.9994
    const_atomicmass["F"] = 18.9984032
    const_atomicmass["Ne"] = 20.1797
    const_atomicmass["Na"] = 22.989770
    const_atomicmass["Mg"] = 24.3050
    const_atomicmass["Al"] = 26.981538
    const_atomicmass["Si"] = 28.0855
    const_atomicmass["P"] = 30.973761
    const_atomicmass["S"] = 32.065
    const_atomicmass["Cl"] = 35.453
    const_atomicmass["Ar"] = 39.948
    const_atomicmass["K"] = 39.0983
    const_atomicmass["Ca"] = 40.078
    const_atomicmass["Sc"] = 44.955910
    const_atomicmass["Ti"] = 47.867
    const_atomicmass["V"] = 50.9415
    const_atomicmass["Cr"] = 51.9961
    const_atomicmass["Mn"] = 54.938049
    const_atomicmass["Fe"] = 55.845
    const_atomicmass["Co"] = 58.933200
    const_atomicmass["Ni"] = 58.6934
    const_atomicmass["Cu"] = 63.546
    const_atomicmass["Zn"] = 65.409
    const_atomicmass["Ga"] = 69.723
    const_atomicmass["Ge"] = 72.64
    const_atomicmass["As"] = 74.92160
    const_atomicmass["Se"] = 78.96
    const_atomicmass["Br"] = 79.904
    const_atomicmass["Kr"] = 83.798
    const_atomicmass["Rb"] = 85.4678
    const_atomicmass["Sr"] = 87.62
    const_atomicmass["Y"] = 88.90585
    const_atomicmass["Zr"] = 91.224
    const_atomicmass["Nb"] = 92.90638
    const_atomicmass["Mo"] = 95.94
    const_atomicmass["Tc"] = 97
    const_atomicmass["Ru"] = 101.07
    const_atomicmass["Rh"] = 102.90550
    const_atomicmass["Pd"] = 106.42
    const_atomicmass["Ag"] = 107.8682
    const_atomicmass["Cd"] = 112.411
    const_atomicmass["In"] = 114.818
    const_atomicmass["Sn"] = 118.710
    const_atomicmass["Sb"] = 121.760
    const_atomicmass["Te"] = 127.60
    const_atomicmass["I"] = 126.90447
    const_atomicmass["Xe"] = 131.293
    const_atomicmass["Cs"] = 132.90545
    const_atomicmass["Ba"] = 137.327
    const_atomicmass["La"] = 138.9055
    const_atomicmass["Ce"] = 140.116
    const_atomicmass["Pr"] = 140.90765
    const_atomicmass["Nd"] = 144.24
    const_atomicmass["Pm"] = 145
    const_atomicmass["Sm"] = 150.36
    const_atomicmass["Eu"] = 151.964
    const_atomicmass["Gd"] = 157.25
    const_atomicmass["Tb"] = 158.92534
    const_atomicmass["Dy"] = 162.500
    const_atomicmass["Ho"] = 164.93032
    const_atomicmass["Er"] = 167.259
    const_atomicmass["Tm"] = 168.93421
    const_atomicmass["Yb"] = 173.04
    const_atomicmass["Lu"] = 174.967
    const_atomicmass["Hf"] = 178.49
    const_atomicmass["Ta"] = 180.9479
    const_atomicmass["W"] = 183.84
    const_atomicmass["Re"] = 186.207
    const_atomicmass["Os"] = 190.23
    const_atomicmass["Ir"] = 192.217
    const_atomicmass["Pt"] = 195.078
    const_atomicmass["Au"] = 196.96655
    const_atomicmass["Hg"] = 200.59
    const_atomicmass["Tl"] = 204.3833
    const_atomicmass["Pb"] = 207.2
    const_atomicmass["Bi"] = 208.98038
    const_atomicmass["Po"] = 209
    const_atomicmass["At"] = 210
    const_atomicmass["Rn"] = 222
    const_atomicmass["Fr"] = 223
    const_atomicmass["Ra"] = 226
    const_atomicmass["Ac"] = 227
    const_atomicmass["Th"] = 232.04
    const_atomicmass["Pa"] = 231
    const_atomicmass["U"] = 238.03
    const_atomicmass["Np"] = 237
    const_atomicmass["Pu"] = 244
    const_atomicmass["Am"] = 243
    const_atomicmass["Cm"] = 247
    const_atomicmass["Bk"] = 247
    const_atomicmass["Cf"] = 251
    const_atomicmass["Es"] = 254
    const_atomicmass["Fm"] = 257
    const_atomicmass["Md"] = 258
    const_atomicmass["No"] = 255
    const_atomicmass["Lr"] = 260

    const_spglat1["p1"]      = const_spglat2["p1"]              = "P"
    const_spglat1["p-1"]     = const_spglat2["-p1"]             = "P"
    const_spglat1["p2"]      = const_spglat2["p2x"]             = "P"
    const_spglat1["p2"]      = const_spglat2["p2y"]             = "P"
    const_spglat1["p2"]      = const_spglat2["p2z"]             = "P"
    const_spglat1["p21"]     = const_spglat2["p2xa"]            = "P"
    const_spglat1["p21"]     = const_spglat2["p2yb"]            = "P"
    const_spglat1["p21"]     = const_spglat2["p2zc"]            = "P"
    const_spglat1["c2"]      = const_spglat2["c2x"]             = "CXY"
    const_spglat1["a2"]      = const_spglat2["a2y"]             = "CYZ"
    const_spglat1["b2"]      = const_spglat2["b2z"]             = "CXZ"
    const_spglat1["b2"]      = const_spglat2["b2x"]             = "CXZ"
    const_spglat1["c2"]      = const_spglat2["c2y"]             = "CXY"
    const_spglat1["a2"]      = const_spglat2["a2z"]             = "CYZ"
    const_spglat1["pm"]      = const_spglat2["p-2x"]            = "P"
    const_spglat1["pm"]      = const_spglat2["p-2y"]            = "P"
    const_spglat1["pm"]      = const_spglat2["p-2z"]            = "P"
    const_spglat1["pc"]      = const_spglat2["p-2xc"]           = "P"
    const_spglat1["pa"]      = const_spglat2["p-2ya"]           = "P"
    const_spglat1["pb"]      = const_spglat2["p-2zb"]           = "P"
    const_spglat1["pb"]      = const_spglat2["p-2xb"]           = "P"
    const_spglat1["pc"]      = const_spglat2["p-2yc"]           = "P"
    const_spglat1["pa"]      = const_spglat2["p-2za"]           = "P"
    const_spglat1["pn"]      = const_spglat2["p-2xbc"]          = "P"
    const_spglat1["pn"]      = const_spglat2["p-2yac"]          = "P"
    const_spglat1["pn"]      = const_spglat2["p-2zab"]          = "P"
    const_spglat1["cm"]      = const_spglat2["c-2x"]            = "CXY"
    const_spglat1["am"]      = const_spglat2["a-2y"]            = "CYZ"
    const_spglat1["bm"]      = const_spglat2["b-2z"]            = "CXZ"
    const_spglat1["bm"]      = const_spglat2["b-2x"]            = "CXZ"
    const_spglat1["cm"]      = const_spglat2["c-2y"]            = "CXY"
    const_spglat1["am"]      = const_spglat2["a-2z"]            = "CYZ"
    const_spglat1["cc"]      = const_spglat2["c-2xc"]           = "CXY"
    const_spglat1["aa"]      = const_spglat2["a-2ya"]           = "CYZ"
    const_spglat1["bb"]      = const_spglat2["b-2zb"]           = "CXZ"
    const_spglat1["bb"]      = const_spglat2["b-2xb"]           = "CXZ"
    const_spglat1["cc"]      = const_spglat2["c-2yc"]           = "CXY"
    const_spglat1["aa"]      = const_spglat2["a-2za"]           = "CYZ"
    const_spglat1["p2/m"]    = const_spglat2["-p2x"]            = "P"
    const_spglat1["p2/m"]    = const_spglat2["-p2y"]            = "P"
    const_spglat1["p2/m"]    = const_spglat2["-p2z"]            = "P"
    const_spglat1["p21/m"]   = const_spglat2["-p2xa"]           = "P"
    const_spglat1["p21/m"]   = const_spglat2["-p2yb"]           = "P"
    const_spglat1["p21/m"]   = const_spglat2["-p2zc"]           = "P"
    const_spglat1["c2/m"]    = const_spglat2["-c2x"]            = "CXY"
    const_spglat1["a2/m"]    = const_spglat2["-a2y"]            = "CYZ"
    const_spglat1["b2/m"]    = const_spglat2["-b2z"]            = "CXZ"
    const_spglat1["b2/m"]    = const_spglat2["-b2x"]            = "CXZ"
    const_spglat1["c2/m"]    = const_spglat2["-c2y"]            = "CXY"
    const_spglat1["a2/m"]    = const_spglat2["-a2z"]            = "CYZ"
    const_spglat1["p2/c"]    = const_spglat2["-p2xc"]           = "P"
    const_spglat1["p2/a"]    = const_spglat2["-p2ya"]           = "P"
    const_spglat1["p2/b"]    = const_spglat2["-p2zb"]           = "P"
    const_spglat1["p2/b"]    = const_spglat2["-p2xb"]           = "P"
    const_spglat1["p2/c"]    = const_spglat2["-p2yc"]           = "P"
    const_spglat1["p2/a"]    = const_spglat2["-p2za"]           = "P"
    const_spglat1["p2/n"]    = const_spglat2["-p2xbc"]          = "P"
    const_spglat1["p2/n"]    = const_spglat2["-p2yac"]          = "P"
    const_spglat1["p2/n"]    = const_spglat2["-p2zab"]          = "P"
    const_spglat1["p21/c"]   = const_spglat2["-p2xca"]          = "P"
    const_spglat1["p21/a"]   = const_spglat2["-p2yab"]          = "P"
    const_spglat1["p21/b"]   = const_spglat2["-p2zbc"]          = "P"
    const_spglat1["p21/b"]   = const_spglat2["-p2xba"]          = "P"
    const_spglat1["p21/c"]   = const_spglat2["-p2ycb"]          = "P"
    const_spglat1["p21/a"]   = const_spglat2["-p2zac"]          = "P"
    const_spglat1["p21/n"]   = const_spglat2["-p2xabc"]         = "P"
    const_spglat1["p21/n"]   = const_spglat2["-p2yabc"]         = "P"
    const_spglat1["p21/n"]   = const_spglat2["-p2zabc"]         = "P"
    const_spglat1["c2/c"]    = const_spglat2["-c2xc"]           = "CXY"
    const_spglat1["a2/a"]    = const_spglat2["-a2ya"]           = "CYZ"
    const_spglat1["b2/b"]    = const_spglat2["-b2zb"]           = "CXZ"
    const_spglat1["b2/b"]    = const_spglat2["-b2xb"]           = "CXZ"
    const_spglat1["c2/c"]    = const_spglat2["-c2yc"]           = "CXY"
    const_spglat1["a2/a"]    = const_spglat2["-a2za"]           = "CYZ"
    const_spglat1["p222"]    = const_spglat2["p2z;2x"]          = "P"
    const_spglat1["p2221"]   = const_spglat2["p2zc;2x"]         = "P"
    const_spglat1["p2122"]   = const_spglat2["p2xa;2y"]         = "P"
    const_spglat1["p2212"]   = const_spglat2["p2yb;2z"]         = "P"
    const_spglat1["p21212"]  = const_spglat2["p2z;2xab"]        = "P"
    const_spglat1["p22121"]  = const_spglat2["p2x;2ybc"]        = "P"
    const_spglat1["p21221"]  = const_spglat2["p2y;2zca"]        = "P"
    const_spglat1["p212121"] = const_spglat2["p2zac;2xab"]      = "P"
    const_spglat1["c2221"]   = const_spglat2["c2zc;2x"]         = "CXY"
    const_spglat1["a2122"]   = const_spglat2["a2xa;2y"]         = "CYZ"
    const_spglat1["b2212"]   = const_spglat2["b2yb;2z"]         = "CXZ"
    const_spglat1["c222"]    = const_spglat2["c2z;2x"]          = "CXY"
    const_spglat1["a222"]    = const_spglat2["a2x;2y"]          = "CYZ"
    const_spglat1["b222"]    = const_spglat2["b2y;2z"]          = "CXZ"
    const_spglat1["f222"]    = const_spglat2["f2z;2x"]          = "F"
    const_spglat1["i222"]    = const_spglat2["i2z;2x"]          = "B"
    const_spglat1["i212121"] = const_spglat2["i2zac;2xab"]      = "B"
    const_spglat1["pmm2"]    = const_spglat2["p2z;-2x"]         = "P"
    const_spglat1["p2mm"]    = const_spglat2["p2x;-2y"]         = "P"
    const_spglat1["pm2m"]    = const_spglat2["p2y;-2z"]         = "P"
    const_spglat1["pmc21"]   = const_spglat2["p2zc;-2x"]        = "P"
    const_spglat1["p21ma"]   = const_spglat2["p2xa;-2y"]        = "P"
    const_spglat1["pb21m"]   = const_spglat2["p2yb;-2z"]        = "P"
    const_spglat1["pcm21"]   = const_spglat2["p2zc;-2y"]        = "P"
    const_spglat1["p21am"]   = const_spglat2["p2xa;-2z"]        = "P"
    const_spglat1["pm21b"]   = const_spglat2["p2yb;-2x"]        = "P"
    const_spglat1["pcc2"]    = const_spglat2["p2z;-2xc"]        = "P"
    const_spglat1["p2aa"]    = const_spglat2["p2x;-2ya"]        = "P"
    const_spglat1["pb2b"]    = const_spglat2["p2y;-2zb"]        = "P"
    const_spglat1["pma2"]    = const_spglat2["p2z;-2xa"]        = "P"
    const_spglat1["p2mb"]    = const_spglat2["p2x;-2yb"]        = "P"
    const_spglat1["pc2m"]    = const_spglat2["p2y;-2zc"]        = "P"
    const_spglat1["pbm2"]    = const_spglat2["p2z;-2yb"]        = "P"
    const_spglat1["p2cm"]    = const_spglat2["p2x;-2zc"]        = "P"
    const_spglat1["pm2a"]    = const_spglat2["p2y;-2xa"]        = "P"
    const_spglat1["pca21"]   = const_spglat2["p2zc;-2xac"]      = "P"
    const_spglat1["p21ab"]   = const_spglat2["p2xa;-2yba"]      = "P"
    const_spglat1["pc21b"]   = const_spglat2["p2yb;-2zcb"]      = "P"
    const_spglat1["pbc21"]   = const_spglat2["p2zc;-2ybc"]      = "P"
    const_spglat1["p21ca"]   = const_spglat2["p2xa;-2zca"]      = "P"
    const_spglat1["pb21a"]   = const_spglat2["p2yb;-2xab"]      = "P"
    const_spglat1["pnc2"]    = const_spglat2["p2z;-2xbc"]       = "P"
    const_spglat1["p2na"]    = const_spglat2["p2x;-2yca"]       = "P"
    const_spglat1["pb2n"]    = const_spglat2["p2y;-2zab"]       = "P"
    const_spglat1["pcn2"]    = const_spglat2["p2z;-2yac"]       = "P"
    const_spglat1["p2an"]    = const_spglat2["p2x;-2zba"]       = "P"
    const_spglat1["pn2b"]    = const_spglat2["p2y;-2xcb"]       = "P"
    const_spglat1["pmn21"]   = const_spglat2["p2zac;-2x"]       = "P"
    const_spglat1["p21mn"]   = const_spglat2["p2xba;-2y"]       = "P"
    const_spglat1["pn21m"]   = const_spglat2["p2ycb;-2z"]       = "P"
    const_spglat1["pnm21"]   = const_spglat2["p2zbc;-2y"]       = "P"
    const_spglat1["p21nm"]   = const_spglat2["p2xca;-2z"]       = "P"
    const_spglat1["pm21n"]   = const_spglat2["p2yab;-2x"]       = "P"
    const_spglat1["pba2"]    = const_spglat2["p2z;-2xab"]       = "P"
    const_spglat1["p2cb"]    = const_spglat2["p2x;-2ybc"]       = "P"
    const_spglat1["pc2a"]    = const_spglat2["p2y;-2zca"]       = "P"
    const_spglat1["pna21"]   = const_spglat2["p2zc;-2xn"]       = "P"
    const_spglat1["p21nb"]   = const_spglat2["p2xa;-2yn"]       = "P"
    const_spglat1["pc21n"]   = const_spglat2["p2yb;-2zn"]       = "P"
    const_spglat1["pbn21"]   = const_spglat2["p2zc;-2yn"]       = "P"
    const_spglat1["p21cn"]   = const_spglat2["p2xa;-2zn"]       = "P"
    const_spglat1["pn21a"]   = const_spglat2["p2yb;-2xn"]       = "P"
    const_spglat1["pnn2"]    = const_spglat2["p2z;-2xn"]        = "P"
    const_spglat1["p2nn"]    = const_spglat2["p2x;-2yn"]        = "P"
    const_spglat1["pn2n"]    = const_spglat2["p2y;-2zn"]        = "P"
    const_spglat1["cmm2"]    = const_spglat2["c2z;-2x"]         = "CXY"
    const_spglat1["a2mm"]    = const_spglat2["a2x;-2y"]         = "CYZ"
    const_spglat1["bm2m"]    = const_spglat2["b2y;-2z"]         = "CXZ"
    const_spglat1["cmc21"]   = const_spglat2["c2zc;-2x"]        = "CXY"
    const_spglat1["a21ma"]   = const_spglat2["a2xa;-2y"]        = "CYZ"
    const_spglat1["bb21m"]   = const_spglat2["b2yb;-2z"]        = "CXZ"
    const_spglat1["ccm21"]   = const_spglat2["c2zc;-2y"]        = "CXY"
    const_spglat1["a21am"]   = const_spglat2["a2xa;-2z"]        = "CYZ"
    const_spglat1["bm21b"]   = const_spglat2["b2yb;-2x"]        = "CXZ"
    const_spglat1["ccc2"]    = const_spglat2["c2z;-2xc"]        = "CXY"
    const_spglat1["a2aa"]    = const_spglat2["a2x;-2ya"]        = "CYZ"
    const_spglat1["bb2b"]    = const_spglat2["b2y;-2zb"]        = "CXZ"
    const_spglat1["amm2"]    = const_spglat2["a2z;-2x"]         = "CYZ"
    const_spglat1["b2mm"]    = const_spglat2["b2x;-2y"]         = "CXZ"
    const_spglat1["cm2m"]    = const_spglat2["c2y;-2z"]         = "CXY"
    const_spglat1["abm2"]    = const_spglat2["a2z;-2xb"]        = "CYZ"
    const_spglat1["b2cm"]    = const_spglat2["b2x;-2yc"]        = "CXZ"
    const_spglat1["cm2a"]    = const_spglat2["c2y;-2za"]        = "CXY"
    const_spglat1["bma2"]    = const_spglat2["b2z;-2ya"]        = "CXZ"
    const_spglat1["c2mb"]    = const_spglat2["c2x;-2zb"]        = "CXY"
    const_spglat1["ac2m"]    = const_spglat2["a2y;-2xc"]        = "CYZ"
    const_spglat1["ama2"]    = const_spglat2["a2z;-2xa"]        = "CYZ"
    const_spglat1["b2mb"]    = const_spglat2["b2x;-2yb"]        = "CXZ"
    const_spglat1["cc2m"]    = const_spglat2["c2y;-2zc"]        = "CXY"
    const_spglat1["bbm2"]    = const_spglat2["b2z;-2yb"]        = "CXZ"
    const_spglat1["c2cm"]    = const_spglat2["c2x;-2zc"]        = "CXY"
    const_spglat1["am2a"]    = const_spglat2["a2y;-2xa"]        = "CYZ"
    const_spglat1["aba2"]    = const_spglat2["a2z;-2xab"]       = "CYZ"
    const_spglat1["b2cb"]    = const_spglat2["b2x;-2ybc"]       = "CXZ"
    const_spglat1["cc2a"]    = const_spglat2["c2y;-2zca"]       = "CXY"
    const_spglat1["bba2"]    = const_spglat2["b2z;-2yba"]       = "CXZ"
    const_spglat1["c2cb"]    = const_spglat2["c2x;-2zcb"]       = "CXY"
    const_spglat1["ac2a"]    = const_spglat2["a2y;-2xac"]       = "CYZ"
    const_spglat1["fmm2"]    = const_spglat2["f2z;-2x"]         = "F"
    const_spglat1["f2mm"]    = const_spglat2["f2x;-2y"]         = "F"
    const_spglat1["fm2m"]    = const_spglat2["f2y;-2z"]         = "F"
    const_spglat1["fdd2"]    = const_spglat2["f2z;-2xd"]        = "F"
    const_spglat1["f2dd"]    = const_spglat2["f2x;-2yd"]        = "F"
    const_spglat1["fd2d"]    = const_spglat2["f2y;-2zd"]        = "F"
    const_spglat1["imm2"]    = const_spglat2["i2z;-2x"]         = "B"
    const_spglat1["i2mm"]    = const_spglat2["i2x;-2y"]         = "B"
    const_spglat1["im2m"]    = const_spglat2["i2y;-2z"]         = "B"
    const_spglat1["iba2"]    = const_spglat2["i2z;-2xab"]       = "B"
    const_spglat1["i2cb"]    = const_spglat2["i2x;-2ybc"]       = "B"
    const_spglat1["ic2a"]    = const_spglat2["i2y;-2zca"]       = "B"
    const_spglat1["ima2"]    = const_spglat2["i2z;-2xa"]        = "B"
    const_spglat1["i2mb"]    = const_spglat2["i2x;-2yb"]        = "B"
    const_spglat1["ic2m"]    = const_spglat2["i2y;-2zc"]        = "B"
    const_spglat1["ibm2"]    = const_spglat2["i2z;-2yb"]        = "B"
    const_spglat1["i2cm"]    = const_spglat2["i2x;-2zc"]        = "B"
    const_spglat1["im2a"]    = const_spglat2["i2y;-2xa"]        = "B"
    const_spglat1["pmmm"]    = const_spglat2["-p-2z;-2x"]       = "P"
    const_spglat1["pnnn"]    = const_spglat2["-p-2zab;-2xbc"]   = "P"
    const_spglat1["pccm"]    = const_spglat2["-p-2z;-2xc"]      = "P"
    const_spglat1["pmaa"]    = const_spglat2["-p-2x;-2ya"]      = "P"
    const_spglat1["pbmb"]    = const_spglat2["-p-2y;-2zb"]      = "P"
    const_spglat1["pban"]    = const_spglat2["-p-2zab;-2xb"]    = "P"
    const_spglat1["pncb"]    = const_spglat2["-p-2xbc;-2yc"]    = "P"
    const_spglat1["pcna"]    = const_spglat2["-p-2yca;-2za"]    = "P"
    const_spglat1["pmma"]    = const_spglat2["-p-2za;-2xa"]     = "P"
    const_spglat1["pbmm"]    = const_spglat2["-p-2xb;-2yb"]     = "P"
    const_spglat1["pmcm"]    = const_spglat2["-p-2yc;-2zc"]     = "P"
    const_spglat1["pmam"]    = const_spglat2["-p-2ya;-2xa"]     = "P"
    const_spglat1["pmmb"]    = const_spglat2["-p-2zb;-2yb"]     = "P"
    const_spglat1["pcmm"]    = const_spglat2["-p-2xc;-2zc"]     = "P"
    const_spglat1["pnna"]    = const_spglat2["-p-2za;-2xbc"]    = "P"
    const_spglat1["pbnn"]    = const_spglat2["-p-2xb;-2yca"]    = "P"
    const_spglat1["pncn"]    = const_spglat2["-p-2yc;-2zab"]    = "P"
    const_spglat1["pnan"]    = const_spglat2["-p-2ya;-2xbc"]    = "P"
    const_spglat1["pnnb"]    = const_spglat2["-p-2zb;-2yca"]    = "P"
    const_spglat1["pcnn"]    = const_spglat2["-p-2xc;-2zab"]    = "P"
    const_spglat1["pmna"]    = const_spglat2["-p-2zac;-2x"]     = "P"
    const_spglat1["pbmn"]    = const_spglat2["-p-2xba;-2y"]     = "P"
    const_spglat1["pncm"]    = const_spglat2["-p-2ycb;-2z"]     = "P"
    const_spglat1["pman"]    = const_spglat2["-p-2yab;-2x"]     = "P"
    const_spglat1["pnmb"]    = const_spglat2["-p-2zbc;-2y"]     = "P"
    const_spglat1["pcnm"]    = const_spglat2["-p-2xca;-2z"]     = "P"
    const_spglat1["pcca"]    = const_spglat2["-p-2za;-2xac"]    = "P"
    const_spglat1["pbaa"]    = const_spglat2["-p-2xb;-2yba"]    = "P"
    const_spglat1["pbcb"]    = const_spglat2["-p-2yc;-2zcb"]    = "P"
    const_spglat1["pbab"]    = const_spglat2["-p-2ya;-2xab"]    = "P"
    const_spglat1["pccb"]    = const_spglat2["-p-2zb;-2ybc"]    = "P"
    const_spglat1["pcaa"]    = const_spglat2["-p-2xc;-2zca"]    = "P"
    const_spglat1["pbam"]    = const_spglat2["-p-2z;-2xab"]     = "P"
    const_spglat1["pmcb"]    = const_spglat2["-p-2x;-2ybc"]     = "P"
    const_spglat1["pcma"]    = const_spglat2["-p-2y;-2zca"]     = "P"
    const_spglat1["pccn"]    = const_spglat2["-p-2zab;-2xac"]   = "P"
    const_spglat1["pnaa"]    = const_spglat2["-p-2xbc;-2yba"]   = "P"
    const_spglat1["pbnb"]    = const_spglat2["-p-2yca;-2zcb"]   = "P"
    const_spglat1["pbcm"]    = const_spglat2["-p-2zc;-2xb"]     = "P"
    const_spglat1["pmca"]    = const_spglat2["-p-2xa;-2yc"]     = "P"
    const_spglat1["pbma"]    = const_spglat2["-p-2yb;-2za"]     = "P"
    const_spglat1["pcmb"]    = const_spglat2["-p-2yb;-2xc"]     = "P"
    const_spglat1["pcam"]    = const_spglat2["-p-2zc;-2ya"]     = "P"
    const_spglat1["pmab"]    = const_spglat2["-p-2xa;-2zb"]     = "P"
    const_spglat1["pnnm"]    = const_spglat2["-p-2z;-2xn"]      = "P"
    const_spglat1["pmnn"]    = const_spglat2["-p-2x;-2yn"]      = "P"
    const_spglat1["pnmn"]    = const_spglat2["-p-2y;-2zn"]      = "P"
    const_spglat1["pmmn"]    = const_spglat2["-p-2zab;-2xa"]    = "P"
    const_spglat1["pnmm"]    = const_spglat2["-p-2xbc;-2yb"]    = "P"
    const_spglat1["pmnm"]    = const_spglat2["-p-2yca;-2zc"]    = "P"
    const_spglat1["pbcn"]    = const_spglat2["-p-2zn;-2xab"]    = "P"
    const_spglat1["pnca"]    = const_spglat2["-p-2xn;-2ybc"]    = "P"
    const_spglat1["pbna"]    = const_spglat2["-p-2yn;-2zca"]    = "P"
    const_spglat1["pcnb"]    = const_spglat2["-p-2yn;-2xac"]    = "P"
    const_spglat1["pcan"]    = const_spglat2["-p-2zn;-2yba"]    = "P"
    const_spglat1["pnab"]    = const_spglat2["-p-2xn;-2zcb"]    = "P"
    const_spglat1["pbca"]    = const_spglat2["-p-2zac;-2xab"]   = "P"
    const_spglat1["pcab"]    = const_spglat2["-p-2yab;-2xac"]   = "P"
    const_spglat1["pnma"]    = const_spglat2["-p-2zac;-2xn"]    = "P"
    const_spglat1["pbnm"]    = const_spglat2["-p-2xba;-2yn"]    = "P"
    const_spglat1["pmcn"]    = const_spglat2["-p-2ycb;-2zn"]    = "P"
    const_spglat1["pnam"]    = const_spglat2["-p-2yab;-2xn"]    = "P"
    const_spglat1["pmnb"]    = const_spglat2["-p-2zbc;-2yn"]    = "P"
    const_spglat1["pcmn"]    = const_spglat2["-p-2xca;-2zn"]    = "P"
    const_spglat1["cmcm"]    = const_spglat2["-c-2zc;-2x"]      = "CXY"
    const_spglat1["amma"]    = const_spglat2["-a-2xa;-2y"]      = "CYZ"
    const_spglat1["bbmm"]    = const_spglat2["-b-2yb;-2z"]      = "CXZ"
    const_spglat1["bmmb"]    = const_spglat2["-b-2yb;-2x"]      = "CXZ"
    const_spglat1["ccmm"]    = const_spglat2["-c-2zc;-2y"]      = "CXY"
    const_spglat1["amam"]    = const_spglat2["-a-2xa;-2z"]      = "CYZ"
    const_spglat1["cmca"]    = const_spglat2["-c-2zac;-2x"]     = "CXY"
    const_spglat1["abma"]    = const_spglat2["-a-2xba;-2y"]     = "CYZ"
    const_spglat1["bbcm"]    = const_spglat2["-b-2ycb;-2z"]     = "CXZ"
    const_spglat1["bmab"]    = const_spglat2["-b-2yab;-2x"]     = "CXZ"
    const_spglat1["ccmb"]    = const_spglat2["-c-2zbc;-2y"]     = "CXY"
    const_spglat1["acam"]    = const_spglat2["-a-2xca;-2z"]     = "CYZ"
    const_spglat1["cmmm"]    = const_spglat2["-c-2z;-2x"]       = "CXY"
    const_spglat1["ammm"]    = const_spglat2["-a-2x;-2y"]       = "CYZ"
    const_spglat1["bmmm"]    = const_spglat2["-b-2y;-2z"]       = "CXZ"
    const_spglat1["cccm"]    = const_spglat2["-c-2z;-2xc"]      = "CXY"
    const_spglat1["amaa"]    = const_spglat2["-a-2x;-2ya"]      = "CYZ"
    const_spglat1["bbmb"]    = const_spglat2["-b-2y;-2zb"]      = "CXZ"
    const_spglat1["cmma"]    = const_spglat2["-c-2za;-2x"]      = "CXY"
    const_spglat1["abmm"]    = const_spglat2["-a-2xb;-2y"]      = "CYZ"
    const_spglat1["bmcm"]    = const_spglat2["-b-2yc;-2z"]      = "CXZ"
    const_spglat1["bmam"]    = const_spglat2["-b-2ya;-2x"]      = "CXZ"
    const_spglat1["cmmb"]    = const_spglat2["-c-2zb;-2y"]      = "CXY"
    const_spglat1["acmm"]    = const_spglat2["-a-2xc;-2z"]      = "CYZ"
    const_spglat1["ccca"]    = const_spglat2["-c-2za;-2xac"]    = "CXY"
    const_spglat1["abaa"]    = const_spglat2["-a-2xb;-2yba"]    = "CYZ"
    const_spglat1["bbcb"]    = const_spglat2["-b-2yc;-2zcb"]    = "CXZ"
    const_spglat1["bbab"]    = const_spglat2["-b-2ya;-2xab"]    = "CXZ"
    const_spglat1["cccb"]    = const_spglat2["-c-2zb;-2ybc"]    = "CXY"
    const_spglat1["acaa"]    = const_spglat2["-a-2xc;-2zca"]    = "CYZ"
    const_spglat1["fmmm"]    = const_spglat2["-f-2z;-2x"]       = "F"
    const_spglat1["fddd"]    = const_spglat2["-f-2zuv;-2xvw"]   = "F"
    const_spglat1["immm"]    = const_spglat2["-i-2z;-2x"]       = "B"
    const_spglat1["ibam"]    = const_spglat2["-i-2z;-2xab"]     = "B"
    const_spglat1["imcb"]    = const_spglat2["-i-2x;-2ybc"]     = "B"
    const_spglat1["icma"]    = const_spglat2["-i-2y;-2zca"]     = "B"
    const_spglat1["ibca"]    = const_spglat2["-i-2zac;-2xab"]   = "B"
    const_spglat1["icab"]    = const_spglat2["-i-2yab;-2xac"]   = "B"
    const_spglat1["imma"]    = const_spglat2["-i-2zac;-2x"]     = "B"
    const_spglat1["ibmm"]    = const_spglat2["-i-2xba;-2y"]     = "B"
    const_spglat1["imcm"]    = const_spglat2["-i-2ycb;-2z"]     = "B"
    const_spglat1["imam"]    = const_spglat2["-i-2yab;-2x"]     = "B"
    const_spglat1["immb"]    = const_spglat2["-i-2zbc;-2y"]     = "B"
    const_spglat1["icmm"]    = const_spglat2["-i-2xca;-2z"]     = "B"
    const_spglat1["p4"]      = const_spglat2["p4"]              = "P"
    const_spglat1["p41"]     = const_spglat2["p41"]             = "P"
    const_spglat1["p42"]     = const_spglat2["p4c"]             = "P"
    const_spglat1["p43"]     = const_spglat2["p43"]             = "P"
    const_spglat1["i4"]      = const_spglat2["i4"]              = "B"
    const_spglat1["i41"]     = const_spglat2["i41b"]            = "B"
    const_spglat1["p-4"]     = const_spglat2["p-4"]             = "P"
    const_spglat1["i-4"]     = const_spglat2["i-4"]             = "B"
    const_spglat1["p4/m"]    = const_spglat2["-p4"]             = "P"
    const_spglat1["p42/m"]   = const_spglat2["-p4c"]            = "P"
    const_spglat1["p4/n"]    = const_spglat2["-p4a"]            = "P"
    const_spglat1["p42/n"]   = const_spglat2["-p4bc"]           = "P"
    const_spglat1["i4/m"]    = const_spglat2["-i4"]             = "B"
    const_spglat1["i41/a"]   = const_spglat2["-i4ad"]           = "B"
    const_spglat1["p422"]    = const_spglat2["p4;2"]            = "P"
    const_spglat1["p4212"]   = const_spglat2["p4ab;2ab"]        = "P"
    const_spglat1["p4122"]   = const_spglat2["p41;2c"]          = "P"
    const_spglat1["p41212"]  = const_spglat2["p43n;2nw"]        = "P"
    const_spglat1["p4222"]   = const_spglat2["p4c;2"]           = "P"
    const_spglat1["p42212"]  = const_spglat2["p4n;2n"]          = "P"
    const_spglat1["p4322"]   = const_spglat2["p43;2c"]          = "P"
    const_spglat1["p43212"]  = const_spglat2["p41n;2abw"]       = "P"
    const_spglat1["i422"]    = const_spglat2["i4;2"]            = "B"
    const_spglat1["i4122"]   = const_spglat2["i41b;2bw"]        = "B"
    const_spglat1["p4mm"]    = const_spglat2["p4;-2"]           = "P"
    const_spglat1["p4bm"]    = const_spglat2["p4;-2ab"]         = "P"
    const_spglat1["p42cm"]   = const_spglat2["p4c;-2c"]         = "P"
    const_spglat1["p42nm"]   = const_spglat2["p4n;-2n"]         = "P"
    const_spglat1["p4cc"]    = const_spglat2["p4;-2c"]          = "P"
    const_spglat1["p4nc"]    = const_spglat2["p4;-2n"]          = "P"
    const_spglat1["p42mc"]   = const_spglat2["p4c;-2"]          = "P"
    const_spglat1["p42bc"]   = const_spglat2["p4c;-2ab"]        = "P"
    const_spglat1["i4mm"]    = const_spglat2["i4;-2"]           = "B"
    const_spglat1["i4cm"]    = const_spglat2["i4;-2ab"]         = "B"
    const_spglat1["i41md"]   = const_spglat2["i41b;-2"]         = "B"
    const_spglat1["i41cd"]   = const_spglat2["i41b;-2c"]        = "B"
    const_spglat1["p-42m"]   = const_spglat2["p-4;2"]           = "P"
    const_spglat1["p-42c"]   = const_spglat2["p-4;2c"]          = "P"
    const_spglat1["p-421m"]  = const_spglat2["p-4;2ab"]         = "P"
    const_spglat1["p-421c"]  = const_spglat2["p-4;2n"]          = "P"
    const_spglat1["p-4m2"]   = const_spglat2["p-4;-2"]          = "P"
    const_spglat1["p-4c2"]   = const_spglat2["p-4;-2c"]         = "P"
    const_spglat1["p-4b2"]   = const_spglat2["p-4;-2ab"]        = "P"
    const_spglat1["p-4n2"]   = const_spglat2["p-4;-2n"]         = "P"
    const_spglat1["i-4m2"]   = const_spglat2["i-4;-2"]          = "B"
    const_spglat1["i-4c2"]   = const_spglat2["i-4;-2c"]         = "B"
    const_spglat1["i-42m"]   = const_spglat2["i-4;2"]           = "B"
    const_spglat1["i-42d"]   = const_spglat2["i-4;2bw"]         = "B"
    const_spglat1["p4/mmm"]  = const_spglat2["-p4;-2"]          = "P"
    const_spglat1["p4/mcc"]  = const_spglat2["-p4;-2c"]         = "P"
    const_spglat1["p4/nbm"]  = const_spglat2["-p4a;-2b"]        = "P"
    const_spglat1["p4/nnc"]  = const_spglat2["-p4a;-2bc"]       = "P"
    const_spglat1["p4/mbm"]  = const_spglat2["-p4;-2ab"]        = "P"
    const_spglat1["p4/mnc"]  = const_spglat2["-p4;-2n"]         = "P"
    const_spglat1["p4/nmm"]  = const_spglat2["-p4a;-2a"]        = "P"
    const_spglat1["p4/ncc"]  = const_spglat2["-p4a;-2ac"]       = "P"
    const_spglat1["p42/mmc"] = const_spglat2["-p4c;-2"]         = "P"
    const_spglat1["p42/mcm"] = const_spglat2["-p4c;-2c"]        = "P"
    const_spglat1["p42/nbc"] = const_spglat2["-p4ac;-2b"]       = "P"
    const_spglat1["p42/nnm"] = const_spglat2["-p4ac;-2bc"]      = "P"
    const_spglat1["p42/mbc"] = const_spglat2["-p4c;-2ab"]       = "P"
    const_spglat1["p42/mnm"] = const_spglat2["-p4n;-2n"]        = "P"
    const_spglat1["p42/nmc"] = const_spglat2["-p4ac;-2a"]       = "P"
    const_spglat1["p42/ncm"] = const_spglat2["-p4ac;-2ac"]      = "P"
    const_spglat1["i4/mmm"]  = const_spglat2["-i4;-2"]          = "B"
    const_spglat1["i4/mcm"]  = const_spglat2["-i4;-2c"]         = "B"
    const_spglat1["i41/amd"] = const_spglat2["-i4bd;-2"]        = "B"
    const_spglat1["i41/acd"] = const_spglat2["-i4bd;-2c"]       = "B"
    const_spglat1["p3"]      = const_spglat2["p3"]              = "H"
    const_spglat1["p31"]     = const_spglat2["p31"]             = "H"
    const_spglat1["p32"]     = const_spglat2["p32"]             = "H"
    const_spglat1["r3"]      = const_spglat2["r3"]              = "R"
    const_spglat1["p-3"]     = const_spglat2["-p3"]             = "H"
    const_spglat1["r-3"]     = const_spglat2["-r3"]             = "R"
    const_spglat1["p312"]    = const_spglat2["p3;2"]            = "H"
    const_spglat1["p321"]    = const_spglat2["p3;2\""]          = "H"
    const_spglat1["p3112"]   = const_spglat2["p31;2#0,0,1/3"]   = "H"
    const_spglat1["p3121"]   = const_spglat2["p31;2\""]         = "H"
    const_spglat1["p3212"]   = const_spglat2["p32;2#0,0,1/6"]   = "H"
    const_spglat1["p3221"]   = const_spglat2["p32;2\""]         = "H"
    const_spglat1["r32"]     = const_spglat2["r3;2\""]          = "R"
    const_spglat1["p3m1"]    = const_spglat2["p3;-2\""]         = "H"
    const_spglat1["p31m"]    = const_spglat2["p3;-2"]           = "H"
    const_spglat1["p3c1"]    = const_spglat2["p3;-2\"c"]        = "H"
    const_spglat1["p31c"]    = const_spglat2["p3;-2c"]          = "H"
    const_spglat1["r3m"]     = const_spglat2["r3;-2\""]         = "R"
    const_spglat1["r3c"]     = const_spglat2["r3;-2\"c"]        = "R"
    const_spglat1["p-31m"]   = const_spglat2["-p3;-2"]          = "H"
    const_spglat1["p-31c"]   = const_spglat2["-p3;-2c"]         = "H"
    const_spglat1["p-3m1"]   = const_spglat2["-p3;-2\""]        = "H"
    const_spglat1["p-3c1"]   = const_spglat2["-p3;-2\"c"]       = "H"
    const_spglat1["r-3m"]    = const_spglat2["-r3;-2\""]        = "R"
    const_spglat1["r-3c"]    = const_spglat2["-r3;-2\"c"]       = "R"
    const_spglat1["p6"]      = const_spglat2["p6"]              = "H"
    const_spglat1["p61"]     = const_spglat2["p61"]             = "H"
    const_spglat1["p65"]     = const_spglat2["p65"]             = "H"
    const_spglat1["p62"]     = const_spglat2["p62"]             = "H"
    const_spglat1["p64"]     = const_spglat2["p64"]             = "H"
    const_spglat1["p63"]     = const_spglat2["p6c"]             = "H"
    const_spglat1["p-6"]     = const_spglat2["p-6"]             = "H"
    const_spglat1["p6/m"]    = const_spglat2["-p6"]             = "H"
    const_spglat1["p63/m"]   = const_spglat2["-p6c"]            = "H"
    const_spglat1["p622"]    = const_spglat2["p6;2"]            = "H"
    const_spglat1["p6122"]   = const_spglat2["p61;2#0,0,-1/12"] = "H"
    const_spglat1["p6522"]   = const_spglat2["p65;2#0,0,1/12"]  = "H"
    const_spglat1["p6222"]   = const_spglat2["p62;2#0,0,1/3"]   = "H"
    const_spglat1["p6422"]   = const_spglat2["p64;2#0,0,1/6"]   = "H"
    const_spglat1["p6322"]   = const_spglat2["p6c;2#0,0,1/4"]   = "H"
    const_spglat1["p6mm"]    = const_spglat2["p6;-2"]           = "H"
    const_spglat1["p6cc"]    = const_spglat2["p6;-2c"]          = "H"
    const_spglat1["p63cm"]   = const_spglat2["p6c;-2"]          = "H"
    const_spglat1["p63mc"]   = const_spglat2["p6c;-2c"]         = "H"
    const_spglat1["p-6m2"]   = const_spglat2["p-6;2"]           = "H"
    const_spglat1["p-6c2"]   = const_spglat2["p-6c;2"]          = "H"
    const_spglat1["p-62m"]   = const_spglat2["p-6;-2"]          = "H"
    const_spglat1["p-62c"]   = const_spglat2["p-6c;-2c"]        = "H"
    const_spglat1["p6/mmm"]  = const_spglat2["-p6;-2"]          = "H"
    const_spglat1["p6/mcc"]  = const_spglat2["-p6;-2c"]         = "H"
    const_spglat1["p63/mcm"] = const_spglat2["-p6c;-2"]         = "H"
    const_spglat1["p63/mmc"] = const_spglat2["-p6c;-2c"]        = "H"
    const_spglat1["p23"]     = const_spglat2["p2;2;3"]          = "P"
    const_spglat1["f23"]     = const_spglat2["f2;2;3"]          = "F"
    const_spglat1["i23"]     = const_spglat2["i2;2;3"]          = "B"
    const_spglat1["p213"]    = const_spglat2["p2ac;2ab;3"]      = "P"
    const_spglat1["i213"]    = const_spglat2["i2ac;2ab;3"]      = "B"
    const_spglat1["pm-3"]    = const_spglat2["-p2;2;3"]         = "P"
    const_spglat1["pn-3"]    = const_spglat2["-p2ab;2bc;3"]     = "P"
    const_spglat1["fm-3"]    = const_spglat2["-f2;2;3"]         = "F"
    const_spglat1["fd-3"]    = const_spglat2["-f2uv;2vw;3"]     = "F"
    const_spglat1["im-3"]    = const_spglat2["-i2;2;3"]         = "B"
    const_spglat1["pa-3"]    = const_spglat2["-p2ac;2ab;3"]     = "P"
    const_spglat1["ia-3"]    = const_spglat2["-i2ac;2ab;3"]     = "B"
    const_spglat1["p432"]    = const_spglat2["p4;2;3"]          = "P"
    const_spglat1["p4232"]   = const_spglat2["p4n;2;3"]         = "P"
    const_spglat1["f432"]    = const_spglat2["f4;2;3"]          = "F"
    const_spglat1["f4132"]   = const_spglat2["f4d;2;3"]         = "F"
    const_spglat1["i432"]    = const_spglat2["i4;2;3"]          = "B"
    const_spglat1["p4332"]   = const_spglat2["p4bdn;2ab;3"]     = "P"
    const_spglat1["p4132"]   = const_spglat2["p4bd;2ab;3"]      = "P"
    const_spglat1["i4132"]   = const_spglat2["i4bd;2ab;3"]      = "B"
    const_spglat1["p-43m"]   = const_spglat2["p-4;2;3"]         = "P"
    const_spglat1["f-43m"]   = const_spglat2["f-4;2;3"]         = "F"
    const_spglat1["i-43m"]   = const_spglat2["i-4;2;3"]         = "B"
    const_spglat1["p-43n"]   = const_spglat2["p-4n;2;3"]        = "P"
    const_spglat1["f-43c"]   = const_spglat2["f-4c;2;3"]        = "F"
    const_spglat1["i-43d"]   = const_spglat2["i-4bd;2ab;3"]     = "B"
    const_spglat1["pm-3m"]   = const_spglat2["-p4;2;3"]         = "P"
    const_spglat1["pn-3n"]   = const_spglat2["-p4a;2bc;3"]      = "P"
    const_spglat1["pm-3n"]   = const_spglat2["-p4n;2;3"]        = "P"
    const_spglat1["pn-3m"]   = const_spglat2["-p4bc;2bc;3"]     = "P"
    const_spglat1["fm-3m"]   = const_spglat2["-f4;2;3"]         = "F"
    const_spglat1["fm-3c"]   = const_spglat2["-f4n;2;3"]        = "F"
    const_spglat1["fd-3m"]   = const_spglat2["-f4vw;2vw;3"]     = "F"
    const_spglat1["fd-3c"]   = const_spglat2["-f4ud;2vw;3"]     = "F"
    const_spglat1["im-3m"]   = const_spglat2["-i4;2;3"]         = "B"
    const_spglat1["ia-3d"]   = const_spglat2["-i4bd;2ab;3"]     = "B"

    const_lmlist["1"]    = "0 0  1 0  1 1 -1 1  2 2  2 1  2 0 -2 1 -2 2  3 3  3 2  3 1  3 0 -3 1 -3 2 -3 3  4 4  4 3  4 2  4 1  4 0 -4 1 -4 2 -4 3 -4 4  "\
                           "5 5  5 4  5 3  5 2  5 1  5 0 -5 1 -5 2 -5 3 -5 4 -5 5  6 6  6 5  6 4  6 3  6 2  6 1  6 0 -6 1 -6 2 -6 3 -6 4 -6 5 -6 6 "\
                           "7 7  7 6  7 5  7 4  7 3  7 2  7 1  7 0 -7 1 -7 2 -7 3 -7 4 -7 5 -7 6 -7 7 "\
                           "8 8  8 7  8 6  8 5  8 4  8 3  8 2  8 1  8 0 -8 1 -8 2 -8 3 -8 4 -8 5 -8 6 -8 7 -8 8 "\
                           "9 9  9 8  9 7  9 6  9 5  9 4  9 3  9 2  9 1  9 0 -9 1 -9 2 -9 3 -9 4 -9 5 -9 6 -9 7 -9 8 -9 9 "\
                           "10 10 10 9 10 8 10 7 10 6 10 5 10 4 10 3 10 2 10 1 10 0 -10 1 -10 2 -10 3 -10 4 -10 5 -10 6 -10 7 -10 8 -10 9 -10 10"
    const_lmlist["-1"]   = "0 0 -2 2 -2 1  2 0  2 1  2 2 -4 4 -4 3 -4 2 -4 1  4 0  4 1  4 2  4 3  4 4 -6 6 -6 5 -6 4 -6 3 -6 2 -6 1  6 0  6 1  6 2  6 3  "\
                           "6 4  6 5  6 6 -8 8 -8 7 -8 6 -8 5 -8 4 -8 3 -8 2 -8 1  8 0  8 1  8 2  8 3  8 4  8 5  8 6  8 7  8 8  "\
                           "10 10 10 9 10 8 10 7 10 6 10 5 10 4 10 3 10 2 10 1 10 0 -10 1 -10 2 -10 3 -10 4 -10 5 -10 6 -10 7 -10 8 -10 9 -10 10"
    const_lmlist["2"]    = "0 0  1 0  2 0  2 2 -2 2  3 0  3 2 -3 2  4 0  4 2 -4 2  4 4 -4 4  5 0  5 2 -5 2  5 4 -5 4  6 0  6 2 -6 2  6 4 -6 4  6 6 -6 6  "\
                           "8 0  8 2 -8 2  8 4 -8 4  8 6 -8 6  8 8 -8 8 10 0  10 2 -10 2  10 4 -10 4  10 6 -10 6  10 8 -10 8  10 10 -10 10"
    const_lmlist["m"]    = " 0 0  1 1 -1 1  2 0  2 2 -2 2  3 1 -3 1  3 3 -3 3  4 0  4 2 -4 2  4 4 -4 4  5 1 -5 1  5 3 -5 3  5 5 -5 5  6 0  6 2 -6 2  6 4 "\
	                   "-6 4  6 6 -6 6 7 1 -7 1 7 3 -7 3 7 5 -7 5 7 7 -7 7 8 0 8 2 -8 2 8 4 -8 4 8 6 -8 6 8 8 -8 8 9 1 -9 1 9 3 -9 3 9 5 -9 5 9 7    "\
	                    "-9 7  9 9  -9 9  10 0 10 2 -10 2 10 4 -10 4 10 6 -10 6 10 8 -10 8 10 10 -10 10"
    const_lmlist["2/m"]  = "0 0 -2 2  2 0  2 2 -4 4 -4 2  4 0  4 2  4 4 -6 6 -6 4 -6 2  6 0  6 2  6 4  6 6 -8 8 -8 6 -8 4 -8 2  8 0  8 2  8 4  8 6  8 8  "\
                           "-10 10 -10 8 -10 6 -10 4 -10 2 10 0 10 2 10 4 10 6 10 8 10 10"
    const_lmlist["222"]  = "0 0  2 0  2 2  3 0 -3 2  4 0  4 2  4 4  5 0 -5 2 -5 4  6 0  6 2  6 4  6 6  7 0 -7 2 -7 4 -7 6  8 0  8 2  8 4  8 6  8 8  "\
                           "9 0 -9 2 -9 4 -9 6 -9 8 10 0 10 2 10 4 10 6 10 8 10 10"
    const_lmlist["mm2"]  = "0 0  1 0  2 0  2 2  3 0  3 2  4 0  4 2  4 4  5 0  5 2  5 4  6 0  6 2  6 4  6 6  7 0  7 2  7 4  7 6  8 0  8 2  8 4  8 6  8 8  "\
                           "9 0  9 2  9 4  9 6  9 8 10 0 10 2 10 4 10 6 10 8 10 10"
    const_lmlist["mmm"]  = "0 0  2 0  2 2  4 0  4 2  4 4  6 0  6 2  6 4  6 6  8 0  8 2  8 4  8 6  8 8 10 0 10 2 10 4 10 6 10 8 10 10"
    const_lmlist["4"]    = "0 0  1 0  2 0  3 0  4 0 -4 4  4 4  5 0 -5 4  5 4  6 0 -6 4  6 4  7 0 -7 4  7 4  8 0 -8 4  8 4 -8 8  8 8  "\
                           "9 0 -9 4  9 4 -9 8  9 8 10 0 10 -4 10 4 10 -8 10 8"
    const_lmlist["-4"]   = "0 0  2 0  3 2 -3 2  4 0 -4 4  4 4  5 2 -5 2  6 0 -6 4  6 4  7 2 -7 2  7 6 -7 6  8 0 -8 4  8 4 -8 8  8 8  "\
                           "9 2 -9 2  9 6 -9 6 10 0 -10 4 10 4 -10 8 10 8"
    const_lmlist["4/m"]  = "0 0  2 0  4 0 -4 4  4 4  6 0 -6 4  6 4  8 0 -8 4  8 4 -8 8  8 8 10 0 -10 4 10 4 -10 8 10 8"
    const_lmlist["422"]  = "0 0  1 0  2 0  3 0  4 0  4 4  5 0 -5 4  5 4  6 0  6 4  7 0 -7 4  7 4  8 0  8 4  8 8  9 0 -9 4 -9 8"\
                           "10 0 10 4 10 8"
    const_lmlist["4mm"]  = "0 0  1 0  2 0  3 0  4 0  4 4  5 0  5 4  6 0  6 4  7 0  7 4  8 0  8 4  8 8  9 0  9 4  9 8 10 0 10 4 10 8"
    const_lmlist["-42m"] = "0 0  2 0 -3 2  4 0  4 4 -5 2  6 0  6 4 -7 2 -7 6  8 0  8 4  8 8 -9 2 -9 6 10 0 10 4 10 8"
    const_lmlist["-4m2"] = "0 0  2 0 -3 2  4 0  4 4 -5 2  6 0  6 4 -7 2 -7 6  8 0  8 4  8 8 -9 2 -9 6 10 0 10 4 10 8"
    const_lmlist["4/mmm"]= "0 0  2 0  4 0  4 4  6 0  6 4  8 0  8 4  8 8 10 0 10 4 10 8"
    const_lmlist["3"]    = "0 0  1 0  2 0  3 0  3 3 -3 3  4 0  4 3 -4 3  5 0  5 3 -5 3  6 0  6 3 -6 3  6 6 -6 6  7 0  7 3 -7 3  7 6 -7 6  8 0  8 3 -8 3  "\
                           "8 6 -8 6  9 0  9 3 -9 3  9 6 -9 6  9 9 -9 9 10 0 10 3 -10 3 10 6 -10 6 10 9 -10 9"
    const_lmlist["-3"]   = "0 0  2 0  4 0 -4 3  4 3  6 0 -6 3  6 3 -6 6  6 6  8 0 -8 3  8 3 -8 6  8 6 10 0 -10 3 10 3 -10 6 10 6 -10 9 10 9"
    const_lmlist["312"]  = "0 0  1 0  2 0  3 0 -3 3  4 0  4 3  5 0 -5 3  6 0  6 3  6 6  7 0 -7 3 -7 6  8 0  8 3  8 6  9 0 -9 3 -9 6 -9 9 "\
                           "10 0 10 3 10 6 10 9"
    const_lmlist["321"]  = "0 0  1 0  2 0  3 0 -3 3  4 0  4 3  5 0 -5 3  6 0  6 3  6 6  7 0 -7 3 -7 6  8 0  8 3  8 6  9 0 -9 3 -9 6 -9 9 "\
                           "10 0 10 3 10 6 10 9"
    const_lmlist["31m"]  = "0 0  1 0  2 0  3 0  3 3  4 0  4 3  5 0  5 3  6 0  6 3  6 6  7 0  7 3  7 6  8 0  8 3  8 6  9 0  9 3  9 6  9 9  "\
                           "10 0 10 3 10 6 10 9"
    const_lmlist["3m1"]  = "0 0  1 0  2 0  3 0  3 3  4 0  4 3  5 0  5 3  6 0  6 3  6 6  7 0  7 3  7 6  8 0  8 3  8 6  9 0  9 3  9 6  9 9  "\
                           "10 0 10 3 10 6 10 9"
    const_lmlist["-31m"] = "0 0  2 0  4 0  4 3  6 0  6 3  6 6  8 0  8 3  8 6 10 0 10 3 10 6 10 9"
    const_lmlist["-3m1"] = "0 0  2 0  4 0  4 3  6 0  6 3  6 6  8 0  8 3  8 6 10 0 10 3 10 6 10 9"
    const_lmlist["6"]    = "0 0  1 0  2 0  3 0  4 0  5 0  6 0 -6 6  6 6  7 0 -7 6  7 6  8 0 -8 6  8 6  9 0 -9 6  9 6 10 0 -10 6 10 6"
    const_lmlist["-6"]   = "0 0  2 0  3 3 -3 3  4 0  5 3 -5 3  6 0  6 6  7 3 -7 3  8 0  8 6  9 0  9 3 -9 3  9 9 -9 9 10 0 10 6"
    const_lmlist["6/m"]  = "0 0  2 0  4 0  6 0 -6 6  6 6  8 0 -8 6  8 6 10 0 -10 6 10 6" 
    const_lmlist["622"]  = "0 0  1 0  2 0  3 0  4 0  5 0  6 0  6 6  7 0 -7 6  8 0  8 6  9 0 -9 6 10 0 10 6"
    const_lmlist["6mm"]  = "0 0  1 0  2 0  3 0  4 0  5 0  6 0  6 6  7 0  7 6  8 0  8 6  9 0  9 6 10 0 10 6"
    const_lmlist["-6m2"] = "0 0  2 0  3 3  4 0  5 3  6 0  6 6  7 3  8 0  8 6  9 3  9 9  10 0  10 6"
    const_lmlist["-62m"] = "0 0  2 0  3 3  4 0  5 3  6 0  6 6  7 3  8 0  8 6  9 3  9 9  10 0  10 6"
    const_lmlist["6/mmm"]= "0 0  2 0  4 0  6 0  6 6  8 0  8 8 10 0 10 8"
    const_lmlist["23"]   = "0 0  4 0  4 4  6 0  6 4 -3 2  6 2  6 6 -7 2 -7 6  8 0  8 4  8 8 -9 2 -9 6 -9 4 -9 8 10 0 10 4 10 8 10 2 10 6 10 10"
    const_lmlist["m-3"]  = "0 0  4 0  4 4  6 0  6 4  6 2  6 6  8 0  8 4  8 8 10 0 10 4 10 8 10 2 10 6 10 10"
    const_lmlist["432"]  = "0 0  4 0  4 4  6 0  6 4  8 0  8 4  8 8 -9 4 -9 8 10 0 10 4 10 8"
    const_lmlist["-43m"] = "0 0  4 0  4 4  6 0  6 4 -3 2 -7 2 -7 6  8 0  8 4  8 8 -9 2 -9 6 10 0 10 4 10 8"
    const_lmlist["m-3m"] = "0 0  4 0  4 4  6 0  6 4  8 0  8 4  8 8  10 0  10 4  10 8"
}
