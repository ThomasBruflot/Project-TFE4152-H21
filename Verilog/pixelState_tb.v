`timescale 1 ns / 1 ps

module PIXEL_STATE_TB ();

    logic clock, reset;
    logic erase;
	logic expose;
	logic convert;
	logic [row-1:0] read;

    parameter int col=4,row=4;

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end  

    PIXEL_STATE dout(clock, reset, erase, expose, convert, read);

    initial begin
        $dumpfile("pixelState_tb.vcd");
        $dumpvars();
		reset = 1; #20;
		reset = 0; #15000;
        reset = 1; #20;
        reset = 0; #1000;
        
        $finish;
    end
endmodule
