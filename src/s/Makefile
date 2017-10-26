# Copyright 1984-2016 Cisco Systems, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

m = ta6le
archincludes = x86_64.ss


MAKEFLAGS += --no-print-directory

# the following flags control various compiler options.  flags prefixed by an x
# separately control the options used while compiling a cross compiler.

# o determines the optimize level
o = 3

# d is the debug level at which the system should be built
d = 0

# i determines whether inspector-information is generated: f for false, t for true
i = f

# cp0 (xcp0) determines the number of cp0 (source optimizer) iterations run
cp0 = 2
xcp0 = 2

# p (xp) determines whether source profiling is enabled: f for false, t for true.
p = f
xp = f

# bp (xpb) determines whether binary profiling is enabled: f for false, t for true.
bp = f
xbp = f

# loadspd determines whether source-profile data is loaded: f for false, t for true
loadspd = f

# dumpspd determines whether source-profile data is dumped: f for false, t for true
dumpspd = f

# loadbpd determines whether binary-profile data is loaded: f for false, t for true
loadbpd = f

# dumpbpd determines whether binary-profile data is dumped: f for false, t for true
dumpbpd = f

# compile determines the entry point for compilng files
# another useful value for this is compile-with-asm, defined in debug.ss
compile = compile-file

# pdhtml determines whether profile-dump-html is called at the end of a build
pdhtml = f

# gac determines whether cost-center allocation counts are generated: f for false, t for true
gac = f

# gac determines whether cost-center instruction counts are generated: f for false, t for true
gic = f

# pps determines whether pass timings are printed
pps = f

Scheme = ../../out/scheme
export SCHEMEHEAPDIRS=../../out

# Define the libdirs separator character
dirsep = :

ProfileDumpSource = source.pd
ProfileDumpBlock = block.pd
SchemeBoot = ../../out/scheme.boot
Cheader = ../c/scheme.h
Cequates = ../c/equates.h

# The following controls the patch files loaded before compiling, typically used only
# to load a new compiler for cross compilation
patchfile =
patch = patch

# putting cpnanopass.patch early for maximum make --jobs=2 benefit
patchobj = patch.patch cpnanopass.patch cprep.patch cpcheck.patch\
 cp0.patch cpvalid.patch cpletrec.patch\
 reloc.patch\
 compile.patch fasl.patch syntax.patch env.patch\
 read.patch interpret.patch ftype.patch strip.patch\
 ubify.patch

#ordering constraints:
#first: library, prims, mathprims, front, 5_?
#last: back
#newhash before read
#io before read
#event before 4
#ftype after syntax
#layout and record before strnum (first define-record)
#date before 7
#(there may be other constraints as well)

basesrc =\
 library.ss prims.ss mathprims.ss record.ss 5_1.ss 5_2.ss 5_3.ss\
 strnum.ss bytevector.ss 5_4.ss 5_6.ss 5_7.ss\
 event.ss 4.ss front.ss foreign.ss 6.ss print.ss newhash.ss\
 format.ss date.ss 7.ss cafe.ss trace.ss engine.ss\
 interpret.ss cprep.ss cpcheck.ss cp0.ss cpvalid.ss cpletrec.ss inspect.ss\
 enum.ss io.ss read.ss primvars.ss syntax.ss costctr.ss\
 exceptions.ss pretty.ss env.ss\
 fasl.ss reloc.ss pdhtml.ss strip.ss ftype.ss back.ss

baseobj = ${basesrc:%.ss=%.$m}

compilersrc =\
 cpnanopass.ss compile.ss cback.ss

compilerobj = ${compilersrc:%.ss=%.$m}

src = ${basesrc} ${compilersrc}
obj = ${baseobj} ${compilerobj}
asm = $(basesrc:%.ss=%.asm)

macroobj =\
 cmacros.so priminfo.so primvars.so env.so setup.so

allsrc =\
 ${basesrc} ${compilersrc} cmacros.ss ${archincludes} setup.ss debug.ss priminfo.ss primdata.ss layout.ss\
 base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss\
 np-languages.ss

doit: bootstrap

all: bootall ${Cheader} ${Cequates}

# allx runs all up to two times and checks to see if the new boot file is the
# same as the last, i.e., the system is properly bootstrapped.
allx: prettyclean saveboot
	$(MAKE) all
	if $(MAKE) checkboot; then echo fine ; else\
	  $(MAKE) prettyclean saveboot &&\
	  $(MAKE) all &&\
	  $(MAKE) checkboot ;\
	fi
	$(MAKE) restoreboot

# bootstrap runs allx if any sources have changed since the last bootstrap
bootstrap: ${allsrc}
	$(MAKE) allx
	touch bootstrap

# source eagerly creates links to most of the files that might be needed
source: ${allsrc} mkheader.ss script.all

# profiled goes through the involved process of building a profile-optimized boot file
profiled:
	$(MAKE) profileclean
	$(MAKE) all p=t
	$(MAKE) prettyclean
	$(MAKE) io.$m dumpspd=t
	$(MAKE) prettyclean
	$(MAKE) all loadspd=t bp=t SchemeBoot=../../out/xscheme.boot
	$(MAKE) prettyclean
	$(MAKE) io.$m loadspd=t dumpbpd=t Scheme="../../out/scheme -b ../../out/xscheme.boot"
	/bin/rm -f ../../out/xscheme.boot
	$(MAKE) prettyclean
	$(MAKE) all loadspd=t loadbpd=t

# clean removes the products of the targets above
clean: profileclean
	rm -f bootstrap

# the remaining targets are typically not useful except to support those above

.SUFFIXES:
.SUFFIXES: .ss .$m .patch .so .asm

.ss.$m:
	echo '(reset-handler abort)'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$p (compile-profile (quote source)))'\
             '(when #$(bp) (compile-profile (quote block)))'\
             '(when #$(loadspd) (profile-load-data "${ProfileDumpSource}"))'\
             '(when #$(loadbpd) (profile-load-data "${ProfileDumpBlock}"))'\
             '(generate-inspector-information #$i)'\
             '(generate-allocation-counts #${gac})'\
             '(generate-instruction-counts #${gic})'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(collect-trip-bytes (expt 2 24))'\
             '(collect-request-handler (lambda () (collect 0 1)))'\
             '(collect 1 2)'\
             '(time (${compile} "$*.ss" "$*.$m" (quote $m)))'\
             '(when #${pdhtml} (profile-dump-html))'\
             '(when #${dumpspd} (profile-dump-data "${ProfileDumpSource}"))'\
             '(when #${dumpbpd} (profile-dump-data "${ProfileDumpBlock}"))'\
             | ${Scheme} -q ${macroobj} ${patchfile}

.ss.asm:
	echo '(reset-handler abort)'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$p (compile-profile (quote source)))'\
             '(when #$(bp) (compile-profile (quote block)))'\
             '(when #$(loadspd) (profile-load-data "${ProfileDumpSource}"))'\
             '(when #$(loadbpd) (profile-load-data "${ProfileDumpBlock}"))'\
             '(generate-inspector-information #$i)'\
             '(generate-allocation-counts #${gac})'\
             '(generate-instruction-counts #${gic})'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(collect-trip-bytes (expt 2 24))'\
             '(collect-request-handler (lambda () (collect 0 1)))'\
             '(collect 1 2)'\
             '(print-gensym (quote pretty/suffix))'\
             '(compile-with-asm "$*.ss" "$*.$m" (quote $m))'\
             '(when #${pdhtml} (profile-dump-html))'\
             '(when #${dumpspd} (profile-dump-data "${ProfileDumpSource}"))'\
             '(when #${dumpbpd} (profile-dump-data "${ProfileDumpBlock}"))'\
             | ${Scheme} -q ${macroobj} ${patchfile}

.ss.so:
	echo '(reset-handler abort)'\
             '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
	     '(keyboard-interrupt-handler (lambda () (display "interrupted---aborting\n") (reset)))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(generate-inspector-information #$i)'\
             '(subset-mode (quote system))'\
             '(compile-file "$*.ss" "$*.so")'\
             | ${Scheme} -q cmacros.so priminfo.so

.ss.patch:
	echo '(reset-handler abort)'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$(xp) (compile-profile (quote source)))'\
             '(when #$(xbp) (compile-profile (quote block)))'\
             '(generate-inspector-information #$i)'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(collect-trip-bytes (expt 2 24))'\
             '(collect-request-handler (lambda () (collect 0 1)))'\
             '(collect 1 2)'\
             '(time (${compile} "$*.ss" "$*.patch" (quote $m)))'\
             | ${Scheme} -q ${macroobj}

saveboot:
	cp -p -f ${SchemeBoot} ../../out/scb

checkboot:
	@echo '(reset-handler abort)'\
              '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
              '(begin'\
                 '(#%$$fasl-file-equal? "../../out/scb" "../../out/scheme.boot" #t)'\
                 '(printf "bootfile comparison succeeded\n"))'\
             | ${Scheme} -b ../../out/scb -q

xcheckboot: ${macroobj} ${patchfile}
	@echo '(reset-handler abort)'\
              '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
              '(begin'\
                 '(#%$$fasl-file-equal? "../../out/scb" "../../out/scheme.boot" #t)'\
                 '(printf "bootfile comparison succeeded\n"))'\
             | ${Scheme} -q ${macroobj} ${patchfile}

restoreboot:
	-mv -f ../../out/scb ${SchemeBoot}

${SchemeBoot}: ${macroobj} ${patchfile} ${baseobj} ${compilerobj}
	echo '(reset-handler abort)'\
             '(apply #%$$make-boot-file "${SchemeBoot}" (quote $m) (quote ())'\
             '  (map symbol->string (quote (${baseobj} ${compilerobj}))))'\
             | ${Scheme} -q ${macroobj} ${patchfile}

cmacros.so: cmacros.ss machine.ss layout.ss
	echo '(reset-handler abort)'\
             '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
             '(keyboard-interrupt-handler (lambda () (display "interrupted---aborting\n") (reset)))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(generate-inspector-information #$i)'\
             '(subset-mode (quote system))'\
             '(compile-file "$*.ss" "$*.so")'\
             | ${Scheme} -q

priminfo.so: priminfo.ss primdata.ss cmacros.so
	echo '(reset-handler abort)'\
             '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
             '(keyboard-interrupt-handler (lambda () (display "interrupted---aborting\n") (reset)))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(generate-inspector-information #$i)'\
             '(subset-mode (quote system))'\
             '(compile-file "$*.ss" "$*.so")'\
             | ${Scheme} -q cmacros.so

# supply primvars.so as well as cmacros.so
mkheader.so: mkheader.ss cmacros.so primvars.so env.so
	echo '(reset-handler abort)'\
             '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
             '(keyboard-interrupt-handler (lambda () (display "interrupted---aborting\n") (reset)))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(generate-inspector-information #$i)'\
             '(subset-mode (quote system))'\
             '(compile-file "$*.ss" "$*.so")'\
             | ${Scheme} -q cmacros.so priminfo.so primvars.so env.so

nanopass.so: $(shell echo ./nanopass/nanopass/*) ./nanopass/nanopass.ss
	echo '(reset-handler abort)'\
             '(base-exception-handler (lambda (c) (fresh-line) (display-condition c) (newline) (reset)))'\
             '(keyboard-interrupt-handler (lambda () (display "interrupted---aborting\n") (reset)))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(generate-inspector-information #$i)'\
             '(collect-trip-bytes (expt 2 24))'\
             '(collect-request-handler (lambda () (collect 0 1)))'\
             '(collect 1 2)'\
             '(compile-library "./nanopass/nanopass.ss" "nanopass.so")'\
             | ${Scheme} -q --libdirs "./nanopass${dirsep}${dirsep}." --compile-imported-libraries


script.all: Makefile

script.all makescript: 
	echo '(reset-handler abort)'\
             '(for-each load (command-line-arguments))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$p (compile-profile (quote source)))'\
             '(when #$(bp) (compile-profile (quote block)))'\
             '(when #$(loadspd) (profile-load-data "${ProfileDumpSource}"))'\
             '(when #$(loadbpd) (profile-load-data "${ProfileDumpBlock}"))'\
             '(generate-inspector-information #$i)'\
             '(generate-allocation-counts #${gac})'\
             '(generate-instruction-counts #${gic})'\
             '(#%$$enable-pass-timing #${pps})'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(collect-trip-bytes (expt 2 24))'\
             '(collect-request-handler (lambda () (collect 0 1)))'\
             '(time (for-each (lambda (x y)'\
             '                   (collect 1 2)'\
             '                   (${compile} (symbol->string x)'\
             '                                 (symbol->string y)'\
             '                                 (quote $m)))'\
             '                (quote (${src}))'\
             '                (quote (${obj}))))'\
             '(when #${pps} (#%$$print-pass-stats))'\
             '(apply #%$$make-boot-file "${SchemeBoot}" (quote $m) (quote ())'\
             '  (map symbol->string (quote (${baseobj} ${compilerobj}))))'\
             '(when #${pdhtml} (profile-dump-html))'\
             '(when #${dumpspd} (profile-dump-data "${ProfileDumpSource}"))'\
             '(when #${dumpbpd} (profile-dump-data "${ProfileDumpBlock}"))'\
             > script.all

script-static.all:
	echo '(reset-handler abort)'\
             '(for-each load (command-line-arguments))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$p (compile-profile (quote source)))'\
             '(when #$(bp) (compile-profile (quote block)))'\
             '(generate-inspector-information #$i)'\
             '(generate-allocation-counts #${gac})'\
             '(generate-instruction-counts #${gic})'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(compile-with-setup-closure-counts (quote (${closure-opt})) (quote (${src})) (quote (${obj})) (quote $m) #$r)'\
             '(apply #%$$make-boot-file "${SchemeBoot}" (quote $m) (quote ())'\
             '  (map symbol->string (quote (${baseobj} ${compilerobj}))))'\
             '(when #${pdhtml} (profile-dump-html))'\
             > script-static.all

script-dynamic.all:
	echo '(reset-handler abort)'\
             '(for-each load (command-line-arguments))'\
             '(optimize-level $o)'\
             '(debug-level $d)'\
             '(when #$p (compile-profile (quote source)))'\
             '(when #$(bp) (compile-profile (quote block)))'\
             '(generate-inspector-information #$i)'\
             '(generate-allocation-counts #${gac})'\
             '(generate-instruction-counts #${gic})'\
             '(run-cp0 (lambda (cp0 x)'\
             '           (do ([i ${cp0} (fx- i 1)] [x x (cp0 x)])'\
             '               ((fx= i 0) x))))'\
             '(compile-with-closure-counts (quote (${closure-opt})) (quote (${src})) (quote (${obj})) (quote $m) #$r)'\
             '(apply #%$$make-boot-file "${SchemeBoot}" (quote $m) (quote ())'\
             '  (map symbol->string (quote (${baseobj} ${compilerobj}))))'\
             '(when #${pdhtml} (profile-dump-html))'\
             > script-dynamic.all

closure-counts:  ${allsrc} ${patchfile} ${macroobj} nanopass.so base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss script-static.all script-dynamic.all
	${Scheme} -q ${macroobj} ${patchfile} --script script-static.all
	$(MAKE) ${SchemeBoot}
	${Scheme} -q ${macroobj} ${patchfile} --script script-dynamic.all
	$(MAKE) all

bootall: ${allsrc} ${patchfile} ${macroobj} nanopass.so makescript
	${Scheme} -q ${macroobj} ${patchfile} --script script.all

${patch}: ${patchobj}
	rm -f ${patch}
	cat ${patchobj} > ${patch}

${asm} ${obj} mkheader.so: ${macroobj} nanopass.so base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss ${patchfile}
primvars.so setup.so mkheader.so env.so: cmacros.so priminfo.so primref.ss
setup.so: debug.ss

${patchobj}: ${macroobj} nanopass.so base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss env.ss
cpnanopass.$m cpnanopass.patch: nanopass.so np-languages.ss ${archincludes}
5_4.$m: ./unicode/unicode-char-cases.ss ./unicode/unicode-charinfo.ss

${Cheader}: mkheader.so ${macroobj} nanopass.so base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss
	(if [ -r ${Cheader} ]; then mv -f ${Cheader} ${Cheader}.bak; fi)
	echo '(reset-handler abort)'\
             '(mkscheme.h "${Cheader}" (quote $m))' |\
         ${Scheme} -q ${macroobj} mkheader.so
	(if `cmp -s ${Cheader} ${Cheader}.bak`;\
          then mv -f ${Cheader}.bak ${Cheader};\
          else rm -f ${Cheader}.bak; fi)

${Cequates}: mkheader.so ${macroobj} nanopass.so base-lang.ss expand-lang.ss primref.ss types.ss io-types.ss fasl-helpers.ss hashtable-types.ss
	(if [ -r ${Cequates} ]; then mv -f ${Cequates} ${Cequates}.bak; fi)
	echo '(reset-handler abort)'\
             '(mkequates.h "${Cequates}")' |\
         ${Scheme} -q ${macroobj} mkheader.so
	(if `cmp -s ${Cequates} ${Cequates}.bak`;\
          then mv -f ${Cequates}.bak ${Cequates};\
          else rm -f ${Cequates}.bak; fi)

prettyclean:
	rm -f *.$m xpatch ${patch} *.patch *.so *.asm script.all header.tmp *.html
	rm -rf nanopass/*.so

profileclean: prettyclean
	rm -f ${ProfileDumpSource} ${ProfileDumpBlock}

