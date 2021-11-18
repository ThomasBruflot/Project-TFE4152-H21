`timescale 1 ns / 1 ps

module pixelTop_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk =0;
   logic reset =0;
   parameter integer clk_period = 500;
   parameter integer sim_end = clk_period*2400;
   parameter integer test_reset = clk_period*3700; // 3600 + 100
   always #clk_period clk=~clk;

   //------------------------------------------------------------
   // Pixel
   //------------------------------------------------------------
   parameter real    dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

   //Analog signals
   logic [3:0]   anaBias1;
   logic [3:0]    anaRamp;
   logic         anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   logic                       erase;
   logic [3:0]                expose;
   logic [3:0]                  read;
   tri[3:0][7:0]             pixData;
   logic [3:0]               convert;
   logic [3:0]          convert_stop;
   

   logic [7:0] pixelDataOut_0;
   logic [7:0] pixelDataOut_1;
   logic [7:0] pixelDataOut_2;
   logic [7:0] pixelDataOut_3;
       

   assign pixelDataOut_0 = pixelDataOut[0];
   assign pixelDataOut_1 = pixelDataOut[1];
   assign pixelDataOut_2 = pixelDataOut[2];
   assign pixelDataOut_3 = pixelDataOut[3];
   

   //Instanciate the pixel
   PIXEL_TOP  pt1(clk, reset, erase, expose, convert, read, anaBias1, anaReset, anaRamp, pixData);

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[3:0][7:0] data;


   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp[0] = convert[0] ? clk : 0;
   assign anaRamp[1] = convert[1] ? clk : 0;
   assign anaRamp[2] = convert[2] ? clk : 0;
   assign anaRamp[3] = convert[3] ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1[0] = expose[0] ? clk : 0;
   assign anaBias1[1] = expose[1] ? clk : 0;
   assign anaBias1[2] = expose[2] ? clk : 0;
   assign anaBias1[3] = expose[3] ? clk : 0;
   

   // If we're not reading the pixData, then we should drive the bus
   assign pixData[0] = read? 8'bZ: data[0];
   assign pixData[1] = read? 8'bZ: data[1];
   assign pixData[2] = read? 8'bZ: data[2];
   assign pixData[3] = read? 8'bZ: data[3];

   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus. Assert convert_stop to return control to main state machine.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
          data[0] = 0;
          data[1] = 0;
          data[2] = 0;
          data[3] = 0;
      end
      if(convert) begin
         data[0] +=  1;
         data[1] +=  1;
         data[2] +=  1;
         data[3] +=  1;
      end
      else begin
         data[0] = 0;
         data[1] = 0;
         data[2] = 0;
         data[3] = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [3:0][7:0] pixelDataOut;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut[0] = 0;
         pixelDataOut[1] = 0;
         pixelDataOut[2] = 0;
         pixelDataOut[3] = 0;
      end
      else begin
         if(read) begin
            pixelDataOut[0] <= pixData[0];
            pixelDataOut[1] <= pixData[1];
            pixelDataOut[2] <= pixData[2];
            pixelDataOut[3] <= pixData[3];
         end
         else begin
            pixelDataOut[0] = 0;
            pixelDataOut[1] = 0;
            pixelDataOut[2] = 0;
            pixelDataOut[3] = 0;
         end
      end
   end
   
   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial begin
      $dumpfile("pixelTop_tb.vcd");
      $dumpvars(0,pixelTop_tb);
      
      reset=1; #clk_period;
      reset=0; #test_reset;  
      reset=1; #clk_period;  
      reset=0;

      #sim_end
         $stop;
   end

endmodule // test