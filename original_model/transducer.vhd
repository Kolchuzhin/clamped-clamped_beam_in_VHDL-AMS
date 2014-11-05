package Electromagnetic_system IS

    nature electrical is real across real through electrical_ground reference;
    nature translational is real across real through mechanical_ground reference;

end package Electromagnetic_system;


use work.s_dat_103.all;
use work.ca12_dat_103.all;
use work.initial.all;
use work.electromagnetic_system.all;



entity transducer is
  generic (delay:time; el_load1, el_load2:real);
  port (terminal struc1,struc2:translational;
        terminal lagrange1,lagrange2:translational;
        terminal master1,master2:translational;
        terminal elec1,elec2:electrical);
end;

architecture behav of transducer is
  type ret_type is array(1 to 4) of real;

quantity q1 across fm1 through struc1;
quantity q2 across fm2 through struc2;
quantity p1 across r1 through lagrange1;
quantity p2 across r2 through lagrange2;
quantity u1 across f1 through master1;
quantity u2 across f2 through master2;
quantity v1 across i1 through elec1;
quantity v2 across i2 through elec2;

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
     if s_type=1 then
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
