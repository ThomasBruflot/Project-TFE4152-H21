
plt=python3 ../../py/plot.py


	
pixSens:
	${MAKE} ngspice	 TB=pixelSensor_tb



ngspice:
	ngspice -a ${TB}.cir
	

compRun:
	${MAKE} aim TB=comp
	
pltComp:
	${plt} comp.csv v4 "v(vcmp_out),v(vramp),v(vstore),v(vs),v(vo2)" same
	
	
aim:
	-rm ${TB}.log
	-rm ${TB}.csv
	aimspice ${TB}.cir -o csv 

clean:
	-rm *.csv
	-rm *.log
	-rm *.sim
