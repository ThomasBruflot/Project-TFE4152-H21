module PIXEL_ARRAY(VBN1, RAMP, RESET, ERASE, EXPOSE, READ, DATA);
    input [3:0]           VBN1; 
    input [3:0]           RAMP;
    input                 RESET; 
    input                 ERASE;
    input [3:0]           EXPOSE;
    input [3:0]           READ;
    inout [3:0][7:0]      DATA; 
    
    //split up into columns that share the same buss
    PIXEL_SENSOR ps0  (VBN1[0], RAMP[0], RESET, ERASE, EXPOSE[0], READ[0], DATA[0]);
    PIXEL_SENSOR ps1  (VBN1[0], RAMP[0], RESET, ERASE, EXPOSE[0], READ[0], DATA[1]);
    PIXEL_SENSOR ps2  (VBN1[0], RAMP[0], RESET, ERASE, EXPOSE[0], READ[0], DATA[2]);
    PIXEL_SENSOR ps3  (VBN1[0], RAMP[0], RESET, ERASE, EXPOSE[0], READ[0], DATA[3]);

    PIXEL_SENSOR ps4  (VBN1[1], RAMP[1], RESET, ERASE, EXPOSE[1], READ[1], DATA[0]);
    PIXEL_SENSOR ps5  (VBN1[1], RAMP[1], RESET, ERASE, EXPOSE[1], READ[1], DATA[1]);
    PIXEL_SENSOR ps6  (VBN1[1], RAMP[1], RESET, ERASE, EXPOSE[1], READ[1], DATA[2]);
    PIXEL_SENSOR ps7  (VBN1[1], RAMP[1], RESET, ERASE, EXPOSE[1], READ[1], DATA[3]);

    PIXEL_SENSOR ps8  (VBN1[2], RAMP[2], RESET, ERASE, EXPOSE[2], READ[2], DATA[0]);
    PIXEL_SENSOR ps9  (VBN1[2], RAMP[2], RESET, ERASE, EXPOSE[2], READ[2], DATA[1]);
    PIXEL_SENSOR ps10 (VBN1[2], RAMP[2], RESET, ERASE, EXPOSE[2], READ[2], DATA[2]);
    PIXEL_SENSOR ps11 (VBN1[2], RAMP[2], RESET, ERASE, EXPOSE[2], READ[2], DATA[3]);

    PIXEL_SENSOR ps12 (VBN1[3], RAMP[3], RESET, ERASE, EXPOSE[3], READ[3], DATA[0]);
    PIXEL_SENSOR ps13 (VBN1[3], RAMP[3], RESET, ERASE, EXPOSE[3], READ[3], DATA[1]);
    PIXEL_SENSOR ps14 (VBN1[3], RAMP[3], RESET, ERASE, EXPOSE[3], READ[3], DATA[2]);
    PIXEL_SENSOR ps15 (VBN1[3], RAMP[3], RESET, ERASE, EXPOSE[3], READ[3], DATA[3]);


endmodule 