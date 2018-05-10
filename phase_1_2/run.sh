#!/bin/bash

#
#  @title:    Smart-Guard: phase 1 and 2
#  @authors:  Michael Denzel <md.research@mailbox.org>, Alessandro Bruni
#  @date:     2015-06-03
#  @license:  GNU General Public License 2.0 or later
#
#  Shellscript to generate and run ProVerif proofs for Smart-Guard phase 1 and 2
#

#checks
if [ $# -ne 1 ]; then
    echo "usage: $0 <directory>"
    exit -1
fi
#check if trusted output is enabled for these proofs
if [[ $1 == *"-DTRUSTEDOUTPUT"* ]]; then
    trustedoutput=1
else
    trustedoutput=0
fi

#print in filtered way
function pv_print(){
    #check confidentiality
    substring="RESULT not attacker(_p[0-9]*)*\(m_[0-9]*\[\]\) is true."
    if [[ $1 =~ $substring ]]; then
        printf "   conf.    "
    else
        printf "    NO      "
    fi

    #check strong confidentiality
    substring="RESULT not mess(_p[0-9]*)*\(ch_att\[\],m_[0-9]*\[\]\) is true."
    if [[ $1 =~ $substring ]]; then
        printf "  conf.     "
    else
        printf "   NO       "
    fi

	#check integrity for pc (if NO trusted output is available, otherwise it makes no sense)
    if [ $trustedoutput -eq 0 ]; then
	    substring="RESULT event\(pc_pass\(m_[0-9]*\)\) ==> event\(user_pass\(m_[0-9]*\)\) is true."
        if [[ $1 =~ $substring ]]; then
            printf "int.      "
        else
            printf " NO       "
        fi
    fi

    #check integrity for smart-card
    substring="RESULT event\(sc_pass\(m_[0-9]*\)\) ==> event\(user_pass\(m_[0-9]*\)\) is true."
    if [[ $1 =~ $substring ]]; then
        printf "int.      "
    else
        printf " NO       "

    fi

    #check integrity for keyboard
    substring="RESULT event\(kb_pass\(m_[0-9]*\)\) ==> event\(user_begin\(m_[0-9]*\)\) is true."
    if [[ $1 =~ $substring ]]; then
        printf "int.      "
    else
        printf " NO       "
    fi

    #check for success
    substring="mess(_p[0-9]*)*\(ch_pub\[\],success\[\]\)\. RESULT not mess(_p[0-9]*)*\(ch_pub\[\],success\[\]\) cannot be proved\."
    if [[ $1 =~ $substring ]]; then
        echo "success"
    else
        echo "   NO"
    fi
}


#get files
files=`ls $1/*.pv`

#print header
echo "running folder: $1"
if [ $trustedoutput -eq 0 ]; then
    printf "\n%-24s| %s | %s | %s | %s | %s | %s\n" file "strong conf." "conf." "int. pc" "int. sc" "int. kb" run-through
else
    printf "\n%-24s| %s | %s | %s | %s | %s\n" file "strong conf." "conf." "int. sc" "int. kb" run-through
fi
echo "--------------------------------------------------------------------------------"
#iterte over them
for f in $files; do
    #print file (without path)
    fx=`echo $f | cut -f3 -d"/"`
    printf "%-27s" $fx

    #call proverif
    filter='grep -B 1 "RESULT"'
    res=`proverif $f | sed '/^\s*$/ d' | eval "$filter"`

    #print in a filtered way (as "table")
    res=`echo $res` #kill new lines '\n'
    pv_print "$res"
done
