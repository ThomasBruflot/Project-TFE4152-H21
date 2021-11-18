`timescale 1 ns / 1 ps

module PIXEL_STATE_TB ();

    logic clock, reset;
    logic erase;
	logic [3:0] expose;
	logic [3:0] convert;
	logic [3:0] read;

    logic ex_0;
    logic conv_0;
    logic read_0;
    logic ex_1;
    logic conv_1;
    logic read_1;
    logic ex_2;
    logic conv_2;
    logic read_2;
    logic ex_3;
    logic conv_3;
    logic read_3;

    

    initial begin
        clock = 0;
        forever #1 clock = ~clock;
    end  

    
    assign ex_0 =    expose[0];
    assign conv_0 = convert[0];
    assign read_0 =    read[0];
    assign   ex_1 =  expose[1];
    assign conv_1 = convert[1];
    assign read_1 =    read[1];
    assign   ex_2 =  expose[2];
    assign conv_2 = convert[2];
    assign read_2 =    read[2];
    assign   ex_3 =  expose[3];
    assign conv_3 = convert[3];
    assign read_3 =    read[3];
    
	

    PIXEL_STATE dout(clock, reset, erase, expose, convert, read);

    initial begin
        $dumpfile("pixelState_tb.vcd");
        $dumpvars();
		reset = 1; #20;
		reset = 0; #10000;
        reset = 1; #20;
        reset = 0; #1000;
        
        $finish;
    end
endmodule

