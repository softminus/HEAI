# Hazardous Environment Air Interface

HEAI is an in-progress GSM PHY/MAC intended to function as a subcomponent of a GSM/LTE cell modem, designed to enable development of upper protocol layers with [LANGSEC](http://langsec.org/) principles firmly in mind. Desired characteristics include a strong separation between DSP-related tasks and protocol parsing/state as follows:


## Architecture
* All DSP/SDR functions live in the FPGA, which has an I/Q interface with an RF transceiver and a low-speed serial interface with a host machine.

* All protocol state, message parsing, and message generation/serialisation/"unparsing" is done in an appropriately sandboxed process on the host machine.



## Reasoning
* The host machine does not handle real-time tasks, I/Q samples, nor DSP maths. Because of this, the link between the FPGA and the host can be low bitrate, since it does not have to transport I/Q samples -- just data bits. The host treats the FPGA/RF components as "just another network interface" (albeit one using an abstruse protocol and not TCP/IP/Ethernet) and does not need a powerful, SIMD-capable CPU.

* The FPGA gateware (and code executed on soft cores within the FPGA) does not manage protocol parsing/state. Rather, it concerns itself only with channel coding/decoding, modulation, demodulation, and burst timing.

* Doing all the protocol parsing/state tasks on the host machine means that we can trivially use the memory-safe/strongly-typed programming languages of our choice. Published vulnerabilities for modern cellular modems are reminiscent of 1990s-vintage TCP/IP stack vulnerabilities -- such as [fragmentation reassembly bugs](https://comsecuris.com/blog/posts/theres_life_in_the_old_dog_yet_tearing_new_holes_into_inteliphone_cellular_modems/). I believe [LANGSEC](http://langsec.org/) techniques can help us do much better, and this design decision will make it easier to generate/test/fuzz/verify parsers and state machines for complex languages/protocols.


## Caveats
* There are no plans to do anything with CDMA/WCDMA/UMTS/HSPA, only GSM and LTE.

* No GSM implementation can provide privacy/integrity for the data it transmits, since the encryption scheme that GSM uses is utterly broken. I wouldn't trust LTE too much either. Use some kind of VPN. I hear wireguard's good.

* I haven't started implementing the receiver components yet.

## Warning
The code in this repository is very incomplete. Do not use it for broadcasting RF unless you do appropriate conformance testing, since I haven't yet.
