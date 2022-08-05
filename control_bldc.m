function ITSE = control_bldc(k)
global kp ki kd
 dN=0;
 dn=0;
 kp=k(1,1)
 ki=k(1,2)
 kd=k(1,3)

 sim('bldcmotor.slx')
 
 t=simout.time;
 dN=simout.Data;
 dn=dN.^2;
 
 ITSE=trapz(t',dn.*t);
end