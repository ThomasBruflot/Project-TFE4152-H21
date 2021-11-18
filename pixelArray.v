module PIXEL_ARRAY(VBN1, RAMP, RESET, ERASE, EXPOSE, READ, DATA);
    input                 VBN1; // each buss can share the same bias and ramp
    input                 RAMP;
    input                RESET; // reset, erase and expose is common for all the pixels
    input                ERASE;
    input               EXPOSE;
    input [row-1:0]           READ; // each row needs its own read
    inout [row-1:0][7:0]      DATA; // we need 4 8-bit busses out of the system
    
    parameter [row*col*4-1:0] dv_pixel = 0; 
    parameter int col=4,row=4;
    
    generate
        genvar i;
        for (i=0; i<row; i=i+1) begin
            genvar j;
            for (j=0; j<col; j=j+1)begin
                PIXEL_SENSOR #(.dv_pixel_int(dv_pixel[(i*col*4+j*4+3):(i*col*4+j*4)])) ps(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[i], DATA[j]);
            end
        end
    endgenerate

endmodule 