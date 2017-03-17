
# ProVerif Proofs for Smart-Guard

Paper:    Smart-Guard: Defending User Input from Malware  
Authors:  Michael Denzel, Alessandro Bruni, Mark Ryan  
Date:     2016-05-25


## Quick Start

*REMARK: ALL PROOFS REQUIRE PROVERIF v. 1.89!*

Simply run the shellscript in the command-line:

```
	$ sh ./run_all.sh
```

(tested on Fedora 23; ProVerif v.1.89)

Keywords:

```
kb           = keyboard
sc           = smart-card
pc           = the computer of the Smart-Guard user
conf.        = ProVerif file proves confidentiality
strong conf. = ProVerif file proves strong confidentiality
               (=offline attacker could not gain access to the message)
int.         = ProVerif file proves integrity
               (=smart-card begins)
strong int.  = ProVerif file proves strong integrity
               (=smart-card begins and accepts encryption)
success      = proof reaches the end of the protocol
NO           = ProVerif file does not prove the property
```

There is also a self-explanatory CONFIG section in `run_all.sh`.


## Running ProVerif Manually

Since there are 8 proofs for every configuration, we generate the proofs from
the `*.gen` files using the C-pre-processor. The `run_all.sh` script has an option
(ONLY_GENERATE) to generate the proofs without running them.

Afterwards the ProVerif files are in the sub-folder `./phase_*/proofs-*`. They
can be run separately and are named by the compromised devices.

```
kb = compromised Keyboard
sc = compromised Smart-card
pc = compromised PC
```

The folder names indicate which options are enabled:
```
-DTRUSTEDOUTPUT = Trusted Output is present
-DKEYLOGGER     = a hardware keylogger is present
```

So, e.g. the file `./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT/5_sc_pc_compromised.pv`
proofs the case with a compromised smart-card (sc), a compromised PC (pc),
an honest keyboard, trusted output, without keylogger for phase 1 and 2 of Smart-Guard.

To run it, execute the following:

```
	$ proverif ./phase_1_2/proofs-smart-guard-phase12.gen-DTRUSTEDOUTPUT/5_sc_pc_compromised.pv
```

*REMARK:*
success is a (dummy) secret which gets leaked at the end
of the protocol to indicate that it ran through. Thus,
when running manually, ProVerif should return `false` or
the following output:

```
So the attacker may send this message on this channel.
mess(ch_pub[],success[]).
RESULT not mess(ch_pub[],success[]) cannot be proved.
```

## Difference Strong Confidentiality to Confidentiality

We introduced strong confidentiality as additional property of the protocol.

Strong confidentiality means, the offline attacker was not able to
gain access to the message m. This is independent from the online
attacker and is only the pre-condition for part 3 of the protocol.
So, if strong confidentiality is compromised in part 1 or 2 but part 3
manages to secure confidentiality, then confidentiality still holds.

Confidentiality, on the other hand, means that the online attacker
got the message (usually sent by the offline attacker). If
this happens, confidentiality is definitely compromised and cannot
be secured in part 3.

Details can also be found in the paper "Smart-Guard: Defending User Input
from Malware" (Conference on Advanced and Trusted Computing ATC 2016).

## License

All provided files in this repository are under the GNU General Public License 2.0 or later.

