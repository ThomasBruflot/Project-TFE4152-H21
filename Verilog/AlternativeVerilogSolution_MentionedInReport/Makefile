
ps:
	iverilog -g2012 -o pixelSensor -c pixelSensor.fl
	vvp -n pixelSensor

ar:
	iverilog -g2012 -o pixelArray -c pixelArray.fl
	vvp -n pixelArray

fsm: 
	iverilog -g2012 -o pixelState -c pixelState.fl
	vvp -n pixelState

pt:
	iverilog -g2012 -o pixelTop -c pixelTop.fl
	vvp -n pixelTop
