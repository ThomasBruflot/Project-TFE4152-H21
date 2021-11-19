module PIXEL_ARRAY(VBN1, RAMP, RESET, ERASE, EXPOSE, READ, DATA);
    input                 VBN1; // each buss can share the same bias and ramp
    input                 RAMP;
    input                RESET; // reset, erase and expose is common for all the pixels
    input                ERASE;
    input               EXPOSE;
    input [row-1:0]           READ; // each row needs its own read
    inout [col-1:0][7:0]      DATA; // we need one 8-bit bus for each column
    
    parameter [row*col*4-1:0] dv_pixel = 0; // this will be overwritten in pixelTop_tb
    parameter int col=4,row=4; // this will be overwritten in pixelTop_tb
    
    generate // we generate the right number of pixel sensors based on the column with and row width that is set
        genvar i;
        for (i=0; i<row; i=i+1) begin
            genvar j;
            for (j=0; j<col; j=j+1)begin // each row gets its own READ and each column gets its own DATA bus 
                PIXEL_SENSOR #(.dv_pixel_int(dv_pixel[(i*col*4+j*4+3):(i*col*4+j*4)])) ps(VBN1, RAMP, RESET, ERASE, EXPOSE, READ[i], DATA[j]);
            end // this (i*col*4+j*4+3) and this (i*col*4+j*4) equation gives each new pixel sensor the next part of the pv_pixel array (they each get 4 bit)
        end
    endgenerate

endmodule 
