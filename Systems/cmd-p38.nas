# By G ROBIN  
#cmd-p38.nas
# Copied from F4U-7

#CowlFlap =================


setprop("/position/altitude-agl-ft",0);
setprop("/controls/flight/cowl-flap",0);
setprop("/gear/gear[0]/position-norm",0);



 
cowlflapSurvey = func {
#print("boucle");
	if(getprop("/controls/gear/gear-down")>0){
		if(getprop("gear/gear[0]/wow")>0 and getprop("/controls/flight/cowl-flap")<1){
			setprop("/controls/flight/cowl-flap", 1);
			print("init cowlflap");
		}else{
		settimer(cowlflapSurvey, 0.1);
		}
		}
}



setlistener("/controls/gear/gear-down",cowlflapSurvey,1);


#Flap only if less than 200 knots=======================




flapcmd = func {
	if(getprop("/velocities/airspeed-kt")<200){
		controls.flapsDown(1);
	}

}



#Control des eclairages==============================

setprop("/sim/model/p38/lighting/instrument-lights",0);

Light_Cmd=func{	
		if(getprop("/systems/electrical/outputs/instrument-lights")>27){
			Light_Value=getprop("/sim/model/p38/lighting/instrument-lights");
			setprop("/controls/lighting/instruments-norm",Light_Value);
		}	
}		
setlistener("/sim/model/p38/lighting/instrument-lights",Light_Cmd);


#Alimentation Electrique========Allumé   Coupé===========================================


Aig_AC=0;

setprop("/controls/electric/master-switch",Aig_AC);

Electric_Cmt=func{
	Aig_AC=getprop("/controls/electric/master-switch");
	Aig_AC=1-Aig_AC;
	setprop("/controls/electric/master-switch",Aig_AC);
}

Electric_Cmd=func{
	if(getprop("/controls/electric/master-switch")=="1"){
	setprop("/controls/electric/battery-switch","true");
	setprop("controls/electric/external-power", "true");
	setprop("/controls/engines/engine[0]/master-bat", "true");
	
    	setprop("/controls/switches/master-avionics", "true");	
	}
	elsif(getprop("/controls/electric/master-switch")=="0"){
	setprop("/controls/electric/battery-switch","false");
	setprop("controls/electric/external-power", "false");
	setprop("/controls/engines/engine[0]/master-bat", "false");
	
    	setprop("/controls/switches/master-avionics", "false");
	setprop("/controls/lighting/instruments-norm",0);
	}
}
Electric_Cmd();

setlistener("/controls/electric/master-switch",Electric_Cmd);

#Magneto===============================================================

magvaleur=0;
stepMagnetos = func {
	change = arg[0];
	magvaleur = getprop("/controls/engines/engine[0]/magnetos");
	setprop("/controls/engines/engine[0]/magnetos", magvaleur + change);
	if(getprop("/controls/engines/engine[0]/magnetos")=="1"){
		Electric_Cmt();
	}
}

#Control surcompression et durée d'utilisation=========================================
 #// (In throttle % - actual input is 0 -> 1)
 #// 99 / 100 - Takeoff boost
 #// 96 / 97 / 98 - Rated boost
 #// 0 - 95 - Idle to Rated boost (MinManifoldPressure to MaxManifoldPressure)
 #// In real life, most planes would be fitted with a mechanical 'gate' between
 #// the rated boost and takeoff boost positions.

#TakeOffBoost=0.99;
#RatedBoost=0.96;
#IdleRatedBoostMin=0;
#IdleRatedBoostMax=0.95;

boost_start=0;
delay_st=300;  #5 minutes ?
timer_boost=0;
now_st=0;

Ctl_Throttle=func{
    if(getprop("/controls/engines/engine[0]throttle")>0.981){	
            if(timer_boost==1){	
                    now_st=getprop("sim/time/elapsed-sec");			
                    if (now_st - boost_start > delay_st ) {
                            setprop("/controls/engines/engine[0]throttle", 0.98);
                            setprop("/controls/engines/engine[1]throttle", 0.98);
                            setprop("/controls/flight/cowl-flap", 0);
                            timer_boost=0;
                            #print("now_st",now_st);
                            #print("Fin",timer_boost);
                    }
            }else{
                    timer_boost=1;
                    boost_start=getprop("sim/time/elapsed-sec");
                    print("boost_start");	
                    }
            settimer(Ctl_Throttle,1);
    }else{
    timer_boost=0;
    #print("Fin",timer_boost);
    }
    #print("boucle");
    
}





setlistener("/controls/engines/engine[0]throttle",Ctl_Throttle);



