`timescale 1 ns / 1 ps

module PIXEL_TOP (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ, VBN1, ANARESET, RAMP, DATA);
    input logic              RESET;
    input logic              CLOCK;
    input logic               VBN1;
    input logic           ANARESET;
    input logic               RAMP;
    inout logic             EXPOSE;
    inout logic            CONVERT;
    inout logic [row-1:0]         READ; // each row needs its own read
    inout logic              ERASE;
    inout [col-1:0][7:0]          DATA; / we need one 8-bit bus for each column

    parameter int col=4,row=4; // this will be overwritten in pixelTop_tb
    parameter [row*col*4-1:0] dv_pixel = 0; // this will be overwritten in pixelTop_tb

    // We instansiate a PIXEL_ARRAY and a PIXEL_STATE module so that PIXEL_STATE can contsol the states of each pixel in PIXEL_ARRAY
    PIXEL_ARRAY #(.dv_pixel(dv_pixel), .col(col), .row(row)) pa1 (VBN1, RAMP, ANARESET, ERASE, EXPOSE, READ, DATA);
    PIXEL_STATE #(.col(col), .row(row)) ps1 (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ);

endmodule
