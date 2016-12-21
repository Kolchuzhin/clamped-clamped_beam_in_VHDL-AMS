--*****************************************************************************
--*****************************************************************************
-- Model: Clamped-Clamped Beam
--
-- Author: Vladimir Kolchuzhin, LMGT, TU Chemnitz
-- <vladimir.kolchuzhin@ieee.org>
-- Date: 19.10.2011
--
-- VHDL-AMS generated code from ANSYS for hAMSter, uMKSV units
-- structure with initial prestress
-------------------------------------------------------------------------------
-- Reference: Release 11.0 Documentation for ANSYS 
-- 8.5. Sample Miniature Clamped-Clamped Beam Analysis 
--
-- Beam parameters
-- B_L=100  Beam length
-- B_W=20   Beam width
-- B_T=2    Beam thickness
-- E_G=4    Electrode gap
--
-- Material properties <110> Si
-- MP,EX,1,169e3			!
-- MP,NUXY,1,0.066			!
-- MP,DENS,1,2.329e-15		!
-- MP,ALPX,1,1e-6			!

-- number of basis functions = 2; 2 modes: i=1, j=0, k=3
-- 2 conductors => 1 capacitance C12
-- 2 master nodes


-- There are two element loads: acceleration and a uniform pressure load:
-- acel,,,9.81e12                ! acceleration in Z-direction 9.81e6 m/s**2
-- sf,all,pres,0.1               ! uniform 100 kPa pressure load

--
-- Calculation of voltage displacement functions up to pull-in:
-- Linear analysis: 992 volts
-- Nonlinear analysis (stress stiffening is ON): 1270 volts
-- Initial prestress analysis: 1408 volts
-- sigm_b=-100
-- tunif,sigm_b*(1-0.066)/(169e3*1e-6)
--
--
-- Damping: dm_1=0;  dm_2=0; in original model !!!
--
-- A gap element (COMBIN40) connects to the center of the beam at a master node (node 21). 
-- It has a contact stiffness of 1.E6 N/m and an initial gap of 0.3 µm.
--
-- 
-- Modal analysis data:
--   1 0.20869E+07
--   2 0.53712E+07
--   3 0.10294E+08
--   4 0.17055E+08
--   5 0.25888E+08
--   6 0.37093E+08
--   7 0.42665E+08
--   8 0.47883E+08
--   9 0.51057E+08
-------------------------------------------------------------------------------
-- Euler solver:
-- time=20u; step=10n
-- The computed pull-in voltage is 14xx volts
-------------------------------------------------------------------------------
-- ID: ccbeam.vhd
-- ver. 0.21 23.11.2016 ccbeam.vhd based on: initial.vhd, s_ams_130.vhd, ca12_ams_130.vhd,transducer.vhd
--*****************************************************************************
--*****************************************************************************
package Electromagnetic_system IS

    nature electrical is real across real through electrical_ground reference;
    nature translational is real across real through mechanical_ground reference;

end package Electromagnetic_system;

library ieee;
use ieee.math_real.all;

--use work.s_dat_103.all;
--use work.ca12_dat_103.all;
--use work.initial.all;
use work.electromagnetic_system.all;


entity ccbeam is
  generic (delay:time; el_load1, el_load2:real);
  port (terminal struc1,struc2:translational;
        terminal lagrange1,lagrange2:translational;
        terminal master1,master2:translational;
        terminal elec1,elec2:electrical);
end;


architecture behav of ccbeam is
  type ret_type is array(1 to 4) of real;

quantity q1 across fm1 through struc1;
quantity q2 across fm2 through struc2;
quantity p1 across r1 through lagrange1;
quantity p2 across r2 through lagrange2;
quantity u1 across f1 through master1;
quantity u2 across f2 through master2;
quantity v1 across i1 through elec1;
quantity v2 across i2 through elec2;
-------------------------------------------------------------------------------
--package initial is
-- model parameters from FE-simulations
constant mm_1:real:=  0.185207030268E-11;  -- modal mass for mode 1
constant mm_2:real:=  0.194379055271E-11;  -- modal mass for mode 2

constant f_1:real:=  0.20869E+07        ;  -- frequency mode 1  ***
constant f_2:real:=  0.10294E+08        ; -- frequency mode 2  ***
-- eigenvector at master node 1
constant fi1_1:real:=  0.995464482369   ; -- eigenvector mode 1 at master node 1
constant fi1_2:real:= -0.929504617585   ; -- eigenvector mode 2 at master node 1
-- eigenvector at master node 2
constant fi2_1:real:=  0.553419215537   ; -- eigenvector mode 2 at master node 1
constant fi2_2:real:=  0.888589814646   ; -- eigenvector mode 2 at master node 2
-- acceleration in z-direction 9.8e6 m/s**2
constant el1_1:real:=  -24.1171438098   ;  -- element load 1 mode 1
constant el1_2:real:=  -10.6523772382   ;  -- element load 1 mode 2
-- uniform 1 MPa pressure load 
constant el2_1:real:=   52.6096410185   ;  -- element load 2 mode 1
constant el2_2:real:=   23.3814480531   ;  -- element load 2 mode 2

-------
constant Qm_1:real:=   10.0; -- quality factor for mode 1, user defined
constant Qm_2:real:=   10.0; -- quality factor for mode 2, user defined

constant km_1:real:=   mm_1*(2.0*3.14*f_1)**2; -- modal stiffness mode 1
constant km_2:real:=   mm_2*(2.0*3.14*f_2)**2; -- modal stiffness mode 2

constant dm_1:real:=SQRT(mm_1*km_1)/Qm_1; -- modal damping constant for mode 1 --[|--
constant dm_2:real:=SQRT(mm_2*km_2)/Qm_2; -- modal damping constant for mode 2 --[|-- 
-------
--end package initial;
-------------------------------------------------------------------------------
--package s_dat_103 is
-- the strain energy function
constant s_type103:integer:=1;							-- type of fit function: Lagrange polynomial
constant s_inve103:integer:=1;							-- not inverted
signal s_ord103:real_vector(1 to 3):=(6.0, 2.0, 0.0);	-- order of polynomial
signal s_fak103:real_vector(1 to 4):=(0.340259232109,8.27974055976,0.0,2338.043873);
constant s_anz103:integer:=       21;    -- total number of coefficients
signal s_data103:real_vector(1 to 21):=  -- polynomial coefficients
(
  0.246103007688E-01,
 -0.592194289171E-14,
  0.588163120255    ,
  0.206195084844E-13,
  0.310785053702    ,
 -0.150090189401E-13,
  0.218511103401E-03,
  0.561671007347E-16,
 -0.607923437658E-03,
 -0.974081033856E-15,
 -0.397309376326E-01,
  0.253061854361E-14,
 -0.177980113126E-04,
 -0.162208591397E-14,
  0.253678100458E-01,
  0.691613737529E-14,
  0.104640619917E-01,
 -0.245661412821E-13,
  0.344132820990E-04,
  0.180081497945E-13,
  0.700669792426E-07
);
--end;
-------------------------------------------------------------------------------
--package ca12_dat_103 is
--  the capacitance between conductor 1 and 2
constant ca12_type103:integer:=1;
constant ca12_inve103:integer:=2;								-- inverted
signal ca12_ord103:real_vector(1 to 3):=(6.0, 2.0, 0.0);
signal ca12_fak103:real_vector(1 to 4):=(0.340259232109,8.27974055976,0.0,462.927518575);
constant ca12_anz103:integer:=       21;
signal ca12_data103:real_vector(1 to 21):=
(
  0.753283687900    ,
  0.274473414578    ,
 -0.461863149061E-01,
  0.138701246697E-01,
 -0.577173008909E-02,
  0.872396318797E-02,
 -0.551446912259E-02,
  0.497764560409E-02,
  0.375266194850E-02,
 -0.237433276804E-02,
  0.793317695316E-03,
 -0.345447049565E-03,
  0.181030057463E-02,
 -0.135055776377E-02,
 -0.240462928166E-03,
  0.174907882002E-03,
 -0.150577377133E-03,
 -0.372662233549E-04,
  0.721515427319E-04,
  0.276041714666E-03,
 -0.246811712009E-03
);
--end;
-------------------------------------------------------------------------------
function spoly_calc(qx, qy, qz : in real:=0.0; s_type,s_inve : integer :=0;
                    s_ord, s_fak, s_data:real_vector) return ret_type is

    constant Sx:integer:=integer(s_ord(1))+1;
    constant Sy:integer:=integer(s_ord(2))+1;
    constant Sz:integer:=integer(s_ord(3))+1;
    variable fwx:real_vector(1 to Sx):=(others=>0.0);
    variable fwy:real_vector(1 to Sy):=(others=>0.0);
    variable fwz:real_vector(1 to 1):=(others=>0.0);
    variable dfwx:real_vector(1 to Sx):=(others=>0.0);
    variable dfwy:real_vector(1 to Sy):=(others=>0.0);
    variable dfwz:real_vector(1 to 1):=(others=>0.0);
    variable res_val:ret_type:=(others=>0.0);
    variable fwv,dfwvx,dfwvy,dfwvz,fak2:real:=0.0;
    variable Px_s,Py_s,Px,Py,Lx,Ly,Lz,ii:integer:=0;

  begin 
     Lx:=integer(s_ord(1));
     Ly:=integer(s_ord(2));
     Lz:=integer(s_ord(3));
     for i in 1 to Lx+1 loop
       fwx(i):=qx**(i-1)*s_fak(1)**(i-1);
       if i=2 then
         dfwx(i):=s_fak(1)**(i-1);
       end if;
       if i>2 then
         dfwx(i):=real(i-1)*qx**(i-2)*s_fak(1)**(i-1);
       end if;
     end loop;
     for i in 1 to Ly+1 loop
       fwy(i):=qy**(i-1)*s_fak(2)**(i-1);
      if i=2 then
         dfwy(i):=s_fak(2)**(i-1);
       end if;
       if i>2 then
         dfwy(i):=real(i-1)*qy**(i-2)*s_fak(2)**(i-1);
       end if;
     end loop;
     for i in 1 to Lz+1 loop
       fwz(i):=qz**(i-1)*s_fak(3)**(i-1);
      if i=2 then
         dfwz(i):=s_fak(3)**(i-1);
       end if;
       if i>2 then
         dfwz(i):=real(i-1)*qz**(i-2)*s_fak(3)**(i-1);
       end if;
     end loop;
     if s_type=1 then	 -- type Lagrange polynomial
       ii:=1;
       for zi in 0 to Lz loop
         for yi in 0 to Ly loop
           for xi in 0 to Lx loop
             fwv:=fwv+s_data(ii)*fwx(xi+1)*fwy(yi+1)*fwz(zi+1);
             dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwy(yi+1)*fwz(zi+1);
             dfwvy:=dfwvy+s_data(ii)*fwx(xi+1)*dfwy(yi+1)*fwz(zi+1);
             dfwvz:=dfwvz+s_data(ii)*fwx(xi+1)*fwy(yi+1)*dfwz(zi+1);
             ii:=ii+1;
           end loop;
         end loop;
       end loop;
     end if;
     if s_type=2 then
       ii:=1;
       Px_s:=integer(s_ord(1));
       Py_s:=integer(s_ord(2));
       for zi in 0 to Lz loop
         Px:=Px_s-zi;
         Py:=Py_s;
         for yi in 0 to Py loop
           for xi in 0 to Px loop
             fwv:=fwv+s_data(ii)*fwx(xi+1)*fwy(yi+1)*fwz(zi+1);
             dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwy(yi+1)*fwz(zi+1);
             dfwvy:=dfwvy+s_data(ii)*fwx(xi+1)*dfwy(yi+1)*fwz(zi+1);
             dfwvz:=dfwvz+s_data(ii)*fwx(xi+1)*fwy(yi+1)*dfwz(zi+1);
             ii:=ii+1;
           end loop;
           Px:=Px-1;
         end loop;
         Py:=Py-1;
       end loop;
     end if;
    if s_type=3 then
       ii:=1;
       for yi in 0 to Ly loop
         for xi in 0 to Lx loop
           fwv:=fwv+s_data(ii)*fwx(xi+1)*fwy(yi+1);
           dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwy(yi+1);
           dfwvy:=dfwvy+s_data(ii)*fwx(xi+1)*dfwy(yi+1);
           dfwvz:=dfwvz+0.0;
           ii:=ii+1;
         end loop;
       end loop;
      for zi in 1 to Lz loop
         for xi in 0 to Lx loop
           fwv:=fwv+s_data(ii)*fwx(xi+1)*fwz(zi+1);
           dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwz(zi+1);
           dfwvy:=dfwvy+0.0;
           dfwvz:=dfwvz+s_data(ii)*fwx(xi+1)*dfwz(zi+1);
           ii:=ii+1;
         end loop;
       end loop;
       for zi in 1 to Lz loop
         for yi in 1 to Ly loop
           fwv:=fwv+s_data(ii)*fwy(yi+1)*fwz(zi+1);
           dfwvx:=dfwvx+0.0;
           dfwvy:=dfwvy+s_data(ii)*dfwy(yi+1)*fwz(zi+1);
           dfwvz:=dfwvz+s_data(ii)*fwy(yi+1)*dfwz(zi+1);
           ii:=ii+1;
         end loop;
       end loop;
     end if;
     if s_type=4 then
       ii:=1;
       Px:=integer(s_ord(1));
       Py:=integer(s_ord(2));
       for yi in 0 to Py loop
         for xi in 0 to Px loop
           fwv:=fwv+s_data(ii)*fwx(xi+1)*fwy(yi+1);
           dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwy(yi+1);
           dfwvy:=dfwvy+s_data(ii)*fwx(xi+1)*dfwy(yi+1);
           dfwvz:=dfwvz+0.0;
           ii:=ii+1;
         end loop;
         Px:=Px-1;
       end loop;
       Px:=integer(s_ord(1));
       for zi in 1 to Lz loop
         for xi in 0 to Px-1 loop
           fwv:=fwv+s_data(ii)*fwx(xi+1)*fwz(zi+1);
           dfwvx:=dfwvx+s_data(ii)*dfwx(xi+1)*fwz(zi+1);
           dfwvy:=dfwvy+0.0;
           dfwvz:=dfwvz+s_data(ii)*fwx(xi+1)*dfwz(zi+1);
           ii:=ii+1;
         end loop;
         Px:=Px-1;
       end loop;
       for zi in 1 to Lz-1 loop
         for yi in 1 to Py-1 loop
           fwv:=fwv+s_data(ii)*fwy(yi+1)*fwz(zi+1);
           dfwvx:=dfwvx+0.0;
           dfwvy:=dfwvy+s_data(ii)*dfwy(yi+1)*fwz(zi+1);
           dfwvz:=dfwvz+s_data(ii)*fwy(yi+1)*dfwz(zi+1);
           ii:=ii+1;
         end loop;
         Py:=Py-1;
       end loop;
     end if;
     if s_inve=1 then
       fwv:=fwv*s_fak(4);
       dfwvx:=dfwvx*s_fak(4);
       dfwvy:=dfwvy*s_fak(4);
       dfwvz:=dfwvz*s_fak(4);
     else
       fak2:=1.0/s_fak(4);
       dfwvx:=-dfwvx/(fwv**2);
       dfwvy:=-dfwvy/(fwv**2);
       dfwvz:=-dfwvz/(fwv**2);
       fwv:=1.0/fwv;
       fwv:=fwv*fak2;
       dfwvx:=dfwvx*fak2;
       dfwvy:=dfwvy*fak2;
       dfwvz:=dfwvz*fak2;
     end if;
     res_val:=(fwv, dfwvx, dfwvy, dfwvz);
     return res_val;
  end spoly_calc;
-------------------------------------------------------------------------------

signal sene_103:ret_type;
signal ca12_103:ret_type;

begin

p1:process
begin
  sene_103<= spoly_calc(q1,q2,0.0,s_type103,s_inve103,s_ord103,s_fak103,s_data103);
  ca12_103<= spoly_calc(q1,q2,0.0,ca12_type103,ca12_inve103,ca12_ord103,ca12_fak103,ca12_data103);
  wait for delay;
end process;

break on sene_103(2),sene_103(3),sene_103(4),ca12_103(2),ca12_103(3),ca12_103(4);

fm1==mm_1*q1'dot'dot + dm_1*q1'dot +sene_103(2) -ca12_103(2)*(v1-v2)**2/2.0 +fi1_1*p1 +fi2_1*p2 -el1_1*el_load1 -el2_1*el_load2;
fm2==mm_2*q2'dot'dot + dm_2*q2'dot +sene_103(3) -ca12_103(3)*(v1-v2)**2/2.0 +fi1_2*p1 +fi2_2*p2 -el1_2*el_load1 -el2_2*el_load2;
r1==fi1_1*q1+fi1_2*q2-u1;
r2==fi2_1*q1+fi2_2*q2-u2;
f1==-p1;
f2==-p2;
i1==+((v1-v2)*(ca12_103(2)*q1'dot+ca12_103(3)*q2'dot)+(v1'dot-v2'dot)*ca12_103(1));
i2==-((v1-v2)*(ca12_103(2)*q1'dot+ca12_103(3)*q2'dot)+(v1'dot-v2'dot)*ca12_103(1));

end;
-------------------------------------------------------------------------------
