#!/bin/bash

#
#  @title:    ProVerif proofs for Smart-Guard
#  @authors:  Michael Denzel <md.research@mailbox.org>, Alessandro Bruni
#  @date:     2016-05-23
#  @license:  GNU General Public License 2.0 or later
#
#  Shellscript to generate and run ProVerif proofs for Smart-Guard
#

### CONFIG ###
# (please alter this section as needed)
#additional proofs
WIHTOUT_TRUSTED_OUTPUT=0 #set to 1 to show the proofs for phase 1 and 2 without trusted output (they will only be partly secure!)
KEYLOGGER=1              #set to 1 to show proofs with an active keylogger
#proof generation
ONLY_GENERATE=0          #set to 1 to only generate proofs without executing them
FORCE_GENERATION=0       #set to 1 to enforce proof generation each time (not needed for ONLY_GENERATE)
CLEANUP=0                #set to 1 to enforce cleaning up the generated files after running (ignored for ONLY_GENERATE)
##############

#check that proverif and cpp (c-pre-processor) are installed
type proverif >/dev/null 2>&1 || { echo >&2 "Could not locate ProVerif. Aborting..." && exit -1; }
type cpp >/dev/null 2>&1 || { echo >&2 "Could not locate C-pre-processor (needed for proof generation). Aborting..." && exit -1; }

# ------------ Generate proofs -----------------

#check if generation is enforced or not all proofs exist
if [ $FORCE_GENERATION -eq 1 ] || [ $ONLY_GENERATE -eq 1 ] ||
       [ ! -d ./phase_1_2/proofs-smart-guard-phase12.gen ] ||
       [ ! -d ./phase_1_2/proofs-smart-guard-phase12.gen-DKEYLOGGER ] ||
       [ ! -d ./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT ] ||
       [ ! -d ./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT-DKEYLOGGER ] ||
       [ ! -d ./phase_3/proofs-smart-guard-phase3.gen ] ||
       [ ! -d ./phase_3/proofs-smart-guard-phase3.gen-DKEYLOGGER ]
then
    #generate proofs for phase 1 and 2
    cd ./phase_1_2
    ./generate.sh
    #generate proofs for phase 3
    cd ../phase_3
    ./generate.sh
    #go back to main directory
    cd ..
    
    #exit if only generation was requested
    if [ $ONLY_GENERATE -eq 1 ]; then
        exit 0
    fi
fi

# ------------ PHASE 1 and 2 -----------------
cd ./phase_1_2

#without trusted output
if [ $WIHTOUT_TRUSTED_OUTPUT -eq 1 ]; then
    #without keylogger
    printf "\n--- PHASE 1 and 2 ---\n"
    sh ./run.sh ./proofs-smart-guard-phase12.gen

    #keylogger
    if [ $KEYLOGGER -eq 1 ]; then
        printf "\n--- PHASE 1 and 2 (keylogger) ---\n"
        sh ./run.sh ./proofs-smart-guard-phase12.gen-DKEYLOGGER
    fi
    printf "\n\n======================================\n\n"
fi

#without keylogger
printf "\n--- PHASE 1 and 2 (trusted output) ---\n"
sh ./run.sh ./proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT

#keylogger
if [ $KEYLOGGER -eq 1 ]; then
    printf "\n--- PHASE 1 and 2 (trusted output, keylogger) ---\n"
    sh ./run.sh ./proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT-DKEYLOGGER
fi
printf "\n\n======================================\n\n"

#go back to main directory
cd ..

# ------------ PHASE 3 -----------------
cd ./phase_3

#without keylogger
printf "\n--- PHASE 3 ---\n"
sh ./run.sh ./proofs-smart-guard-phase3.gen

#keylogger
if [ $KEYLOGGER -eq 1 ]; then
    printf "\n--- PHASE 3 (keylogger) ---\n"
    sh ./run.sh ./proofs-smart-guard-phase3.gen-DKEYLOGGER
fi

#go back to main directory
cd ..

# ------------ CLEANUP -----------------

if [ $CLEANUP -eq 1 ]; then
    printf "\nClean up: "
    rm -r ./phase_1_2/proofs-smart-guard-phase12.gen \
       ./phase_1_2/proofs-smart-guard-phase12.gen-DKEYLOGGER \
       ./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT \
       ./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT-DKEYLOGGER \
       ./phase_3/proofs-smart-guard-phase3.gen \
       ./phase_3/proofs-smart-guard-phase3.gen-DKEYLOGGER
    if [ $? -eq 0 ]; then
        echo "success"
    else
        echo "failed"
    fi
fi
