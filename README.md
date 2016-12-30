System Level Model of MEMS Clamped-Clamped Beam in VHDL-AMS generated by ANSYS ROM Tool
=======================================================================================

Reference:
----------
Release 11.0 Documentation for ANSYS: 8.5. Sample Miniature Clamped-Clamped Beam Analysis

Beam parameters:
----------------
 * B_L=100  Beam length
 * B_W=20   Beam width
 * B_T=2    Beam thickness
 * E_G=4    Electrode gap

Material properties <110> Si:
-----------------------------
 * MP,EX,1,169e3
 * MP,NUXY,1,0.066
 * MP,DENS,1,2.329e-15
 * MP,ALPX,1,1e-6

Calculation of voltage displacement functions up to pull-in:
------------------------------------------------------------
  * Linear analysis: 992 volts
  * Nonlinear analysis (stress stiffening is ON): 1270 volts
  * Initial prestress analysis: 1408 volts
    * sigm_b=-100
    * tunif,sigm_b*(1-0.066)/(169e3*1e-6)

There are two element loads: acceleration and a uniform pressure load:
----------------------------
* acel,,,9.81e12                ! acceleration in Z-direction 9.81e6 m/s**2
* sf,all,pres,0.1               ! uniform 100 kPa pressure load

Damping:
--------
dm_1=0 and dm_2=0 in original model (see initial.vhd) !!!
