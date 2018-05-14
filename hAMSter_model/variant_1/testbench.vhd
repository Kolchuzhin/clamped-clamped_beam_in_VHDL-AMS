--*****************************************************************************
--*****************************************************************************
-- Model: testbench for transducer.vhd / ccbeam.vhd in hAMSter
--
-- Clamped-Clamped Beam is driven by a voltage (see key_load): 
--					1. sweep computing the pull-in voltage 
--					2. chirp
--					3. puls
--
-- Author: Vladimir Kolchuzhin, LMGT, TU Chemnitz
-- <vladimir.kolchuzhin@ieee.org>
-- Date: 19.10.2011

-- Library dependencies:
--	VHDL-AMS generated code from ANSYS for hAMSter 
--				initial.vhd
--				s_ams_130.vhd
--				ca12_ams_130.vhd
--				transducer.vhd
-------------------------------------------------------------------------------
-- Reference: Release 11.0 Documentation for ANSYS 
--            8.5. Sample Miniature Clamped-Clamped Beam Analysis 
--
-- Beam parameters
-- B_L=100  Beam length
-- B_W=20   Beam width
-- B_T=2    Beam thickness
-- E_G=4    Electrode gap
--
-- Material properties <110> Si
-- MP,EX,1,169e3
-- MP,NUXY,1,0.066
-- MP,DENS,1,2.329e-15
-- MP,ALPX,1,1e-6
--
-- Calculation of voltage displacement functions up to pull-in:
-- Linear analysis: 992 volts
-- Nonlinear analysis (stress stiffening is ON): 1270 volts
-- Initial prestress analysis: 1408 volts
-- sigm_b=-100
-- tunif,sigm_b*(1-0.066)/(169e3*1e-6)
--
-- There are two element loads: acceleration and a uniform pressure load:
-- acel,,,9.81e12                ! acceleration in Z-direction 9.81e6 m/s**2
-- sf,all,pres,0.1               ! uniform 100 kPa pressure load
--
-- Damping: dm_1=0 and dm_2=0; in original model (see initial.vhd) !!!
--
-- A gap element (COMBIN40) connects to the center of the beam at a master node (node 21). 
-- It has a contact stiffness of 1.E6 N/m and an initial gap of 0.3 µm.
--
-------------------------------------------------------------------------------
-- Euler solver:
-- time=20u; step=10n

-- The computed pull-in voltage is 14xx volts
-------------------------------------------------------------------------------
-- ID: testbench.vhd
-- ver. 0.20 19.11.2011 OK in hAMSter
-- ver. 0.21 14.05.2018
--*****************************************************************************
--*****************************************************************************
use work.electromagnetic_system.all;
use work.all;

library ieee;
use ieee.math_real.all;
                
entity testbench is
end;

architecture behav of testbench is
  terminal struc1_ext,struc2_ext: translational;	--
  terminal lagrange1_ext,lagrange2_ext:translational;	--
  terminal master1_ext,master2_ext:translational;	--
  terminal elec1_ext,elec2_ext: electrical;		--

  -- Modal displacement
  quantity q_ext1 across fm_ext1 through struc1_ext;          -- Modal amplitude 1
  quantity q_ext2 across fm_ext2 through struc2_ext;          -- Modal amplitude 2
  -- Lagrangian multipler                                               
  quantity p_ext1 across r_ext1  through lagrange1_ext;
  quantity p_ext2 across r_ext2  through lagrange2_ext;
  -- Nodal displacement
  quantity u_ext1 across f_ext1  through master1_ext;          -- Nodal amplitude 1
  quantity u_ext2 across f_ext2  through master2_ext;          -- Nodal amplitude 2
  -- Electrical ports
  quantity v_ext1 across i_ext1  through elec1_ext;           -- Conductor 1
  quantity v_ext2 across i_ext2  through elec2_ext;           -- Conductor 2

  constant digital_delay:time:=10.0 ns;        -- digital time step size for matrix update == analog time step

  constant el_load1:real:=0.0;
  constant el_load2:real:=0.0;
  
  constant t_end:real:=20.0e-06;
  constant    dt:real:=10.0E-09;
  constant ac_value:real:=10.0;
  constant dc_value:real:=1420.0;

-- puls
  constant   t1:real:=1.0E-06;
  constant   t2:real:=5.0E-06;
-- chirp
  constant f_begin:real:=  0.10e6;               -- begin of frequency sweep
  constant f_end:real:=    5.00e6;               --   end of frequency sweep


  constant   key_load:integer:=0; -- 0/1/2 == ramp/chirp/puls

begin

-- Loads

if key_load = 0 use -- ramp/sweep
    v_ext1 == dc_value/t_end*now;
end use;

if key_load = 1 use -- chirp
   v_ext1 == dc_value*0.0 + ac_value*sin(2.0*3.14*(f_begin + (f_end-f_begin)/t_end*now) * now);
end use;

if key_load = 2 use -- puls
 if now <= t1-dt use         
	v_ext1 == 0.0;
  end use;
  if now > t1-dt and now <= t1 use
	v_ext1 == 0.0;
  end use;        
  if now > t1 and now <= t2 use
	v_ext1 == dc_value*0.1;
  end use;
  if now > t2 and now <= t2+dt use
	v_ext1 == 0.0;
  end use;
  if now > t2+dt use
	v_ext1 == 0.0;
 end use;
end use;

-- BCs:
--i_ext1==0.0;
v_ext2==0.0;

fm_ext1==0.0;          -- external modal force 1
fm_ext2==0.0;          -- external modal force 2

r_ext1==0.0;           -- must be zero
r_ext2==0.0;           -- must be zero

f_ext1==0.0;           -- external nodal force on master node 1
f_ext2==0.0;           -- external nodal force on master node 2 

--
--                           Lagrangian ports
--
--                              p1        p2
--                r_ext1=0 ->>- o         o -<<- r_ext2=0
--                              |         |
--         modal ports   o------o---------o------o     nodal ports
--                       |                       | 
-- fm_ext1=0 ->>- q1 o---o                       o---o u1 -<<- f_ext1=0
--                       | element1: transducer  |
-- fm_ext2=0 ->>- q2 o---o                       o---o u2 -<<- f_ext2=0
--                       |                       |
--                       o------o---------o------o
--                              |         |
--                              o         o
--                     input: v1_ext    v2_ext=0
--                             
--                           electrical ports  
--
-- ASCII-Schematic of the component: transducer
-------------------------------------------------------------------------------
element1:      
 			    entity transducer(behav)
   	       generic map (digital_delay,el_load1,el_load2)
 	          port map (struc1_ext,struc2_ext,
                        lagrange1_ext,lagrange2_ext,
                        master1_ext,master2_ext,
                        elec1_ext,elec2_ext);
end;
-------------------------------------------------------------------------------
