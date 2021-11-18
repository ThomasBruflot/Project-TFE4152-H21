`timescale 1 ns / 1 ps

module PIXEL_TOP (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ, VBN1, ANARESET, RAMP, DATA);
    input logic              RESET;
    input logic              CLOCK;
    input logic [3:0]         VBN1;
    input logic           ANARESET;
    input logic [3:0]         RAMP;
    inout logic [3:0]       EXPOSE;
    inout logic [3:0]      CONVERT;
    inout logic [3:0]         READ;
    inout logic              ERASE;
    inout [3:0][7:0]          DATA;


    PIXEL_ARRAY pa1 (VBN1, RAMP, ANARESET, ERASE, EXPOSE, READ, DATA);
    PIXEL_STATE ps1 (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ);

endmodule