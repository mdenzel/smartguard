#!/bin/bash

#
#  @title:    Smart-Guard: phase 2
#  @authors:  Michael Denzel <research@michael-denzel.de>, Alessandro Bruni
#  @date:     2015-06-03
#  @license:  GNU General Public License 2.0 or later
#
#  Shellscript to generate and run ProVerif proofs for Smart-Guard phase 2
#

#print in filtered way
function pv_print(){
    #check confidentiality
    substring="RESULT not mess\(ch_att\[\],m_[0-9]*\[!1 = v_[0-9]*\]\) is true."
    if [[ $1 =~ $substring ]]; then
        echo -en "   conf.         "
    else
        echo -en "    NO           "
    fi

    #check integrity
    substring="RESULT event\(rec_end\(m_[0-9]*\)\) ==> event\(kb_begin\(m_[0-9]*\)\) \|\| event\(sc_begin\(m_[0-9]*\)\) is true."
    if [[ $1 =~ $substring ]]; then
        echo -en "   int.        "
    else
        echo -en "    NO         "
    fi

    #check for success
    substring="mess(ch_pub[],success[]). RESULT not mess(ch_pub[],success[]) cannot be proved."
    if [[ "$1" =~ "$substring" ]]; then
        echo "success"
    else
        echo "   NO"
    fi
}


#get files
files=`ls $1/*.pv`

#print header
echo "running folder: $1"
printf "\n%-24s   %s    %s    %s\n" file confidentiality integrity run-through
echo "--------------------------------------------------------------------------------"
#iterte over them
for f in $files; do
    #print file (without path)
    fx=`echo $f | cut -f3 -d"/"`
    printf "%-25s    " $fx

    #call proverif
    filter='grep -B 1 "RESULT"'
    res=`proverif $f | sed '/^\s*$/ d' | eval "$filter"`

    #print in a filtered way (as "table")
    res=`echo $res` #kill new lines '\n'
    pv_print "$res"
done
