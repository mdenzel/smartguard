#!/bin/bash

#
#  @title:    Smart-Guard: phase 1 and 2
#  @authors:  Michael Denzel <research@michael-denzel.de>, Alessandro Bruni
#  @date:     2015-06-08
#  @license:  GNU General Public License 2.0 or later
#
#  Shellscript to generate and run ProVerif proofs for Smart-Guard phase 1 and 2
#


#global variables
prefix=./proofs-
files="smart-guard-phase12.gen,-DTRUSTEDOUTPUT smart-guard-phase12.gen,-DTRUSTEDOUTPUT,-DKEYLOGGER smart-guard-phase12.gen, smart-guard-phase12.gen,-DKEYLOGGER"

function generate(){
	input="./"$1
	folder=$2
	IFS=' ';
	flags=($3)

	echo "generating ProVerif proofs: \"$folder\""
    mkdir -p $folder
    #	1. none compromised
    cpp ${flags[@]} < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/1_none_compromised.pv
    #----------------------------------------
    #	2. kb compromised
    cpp ${flags[@]} -DKB_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/2_kb_compromised.pv
    #	3. sc compromised
    cpp ${flags[@]} -DSC_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/3_sc_compromised.pv
    #	4. pc compromised
    cpp ${flags[@]} -DPC_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/4_pc_compromised.pv
    #----------------------------------------
    #	5. sc pc compromised
    cpp ${flags[@]} -DSC_COMPR -DPC_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/5_sc_pc_compromised.pv
    #	6. kb pc compromised
    cpp ${flags[@]} -DKB_COMPR -DPC_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/6_kb_pc_compromised.pv
    #	7. sc kb compromised
    cpp ${flags[@]} -DSC_COMPR -DKB_COMPR< $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/7_sc_kb_compromised.pv
    #----------------------------------------
    #	8. all compromised
    cpp ${flags[@]} -DKB_COMPR -DSC_COMPR -DPC_COMPR < $input 2>/dev/null | sed '/^#/ d' | cat -s > $folder/8_kb_sc_pc_compromised.pv
}

for f in $files; do
	IFS=',';
	ops=($f) #make array
	name=${ops[0]} #get first entry
	ops="${ops[@]:1}" #remove first entry
	folder=$prefix$name`echo "$ops" | tr -d ' '`

	#generate files
	generate $name $folder $ops
done
