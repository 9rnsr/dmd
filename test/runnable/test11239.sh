#!/usr/bin/env bash

src=runnable${SEP}extra-files
dir=${RESULTS_DIR}${SEP}runnable
output_file=${dir}/test11239.sh.out

rm ${output_file}

$DMD -m${MODEL} -I${src} -debug -od${dir} -c ${src}${SEP}test11239a.d >>${output_file} || exit 1
$DMD -m${MODEL} -I${src}        -od${dir} -c ${src}${SEP}test11239b.d >>${output_file} || exit 1
$DMD -m${MODEL} -od${dir} -of${dir}${SEP}test11239${EXE} ${dir}${SEP}test11239a${OBJ} ${dir}${SEP}test11239b${OBJ} >>${output_file} || exit 1

${dir}${SEP}test11239${EXE} >>${output_file} || exit 1

rm ${dir}/test11239{{a,b}${OBJ},${EXE}}

echo Success >>${output_file}
