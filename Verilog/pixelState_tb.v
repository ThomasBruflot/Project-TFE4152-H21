`timescale 1 ns / 1 ps

module PIXEL_STATE_TB ();

    logic clock, reset;
    logic erase;
	logic expose;
	logic convert;
	logic [row-1:0] read;

    parameter int col=4,row=4; // we test for a 4x4 system
    parameter real dv_pixel = 5;  //Set the expected photodiode current (0-1)

    initial begin // we make a clock 
        clock = 0;
        forever #10 clock = ~clock;
    end  

    PIXEL_STATE #(.dv_pixel(dv_pixel)) dout(clock, reset, erase, expose, convert, read);

    initial begin
        $dumpfile("pixelState_tb.vcd"); // we dump the result into a vcd file that GTKwave can read
        $dumpvars();
		reset = 1; #20; // we reset, wait a while and then reset again 
		reset = 0; #15000;
        reset = 1; #20;
        reset = 0; #1000;
        
        $finish;
    end
endmodule
