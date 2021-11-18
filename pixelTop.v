`timescale 1 ns / 1 ps

module PIXEL_TOP (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ, VBN1, ANARESET, RAMP, DATA);
    input logic              RESET;
    input logic              CLOCK;
    input logic               VBN1;
    input logic           ANARESET;
    input logic               RAMP;
    inout logic             EXPOSE;
    inout logic            CONVERT;
    inout logic [row-1:0]         READ;
    inout logic              ERASE;
    inout [row-1:0][7:0]          DATA;

    parameter int col=4,row=4;
    parameter [row*col*4-1:0] dv_pixel = 0;

    PIXEL_ARRAY #(.dv_pixel(dv_pixel), .col(col), .row(row)) pa1 (VBN1, RAMP, ANARESET, ERASE, EXPOSE, READ, DATA);
    PIXEL_STATE #(.col(col), .row(row)) ps1 (CLOCK, RESET, ERASE, EXPOSE, CONVERT, READ);

endmodule