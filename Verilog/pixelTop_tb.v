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
   always #clk_period clk=~clk; // we make the clock 

   //------------------------------------------------------------
   // Pixel
   //------------------------------------------------------------
   /*
   parameter [row*col*4-1:0] dv_pixel = {4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd4, 4'd3, 4'd2,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd6, 4'd5, 4'd4, 4'd3,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd7, 4'd6, 4'd5, 4'd4,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd8, 4'd7, 4'd6, 4'd5,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd9, 4'd8, 4'd7, 4'd6,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd1, 4'd9, 4'd8, 4'd7,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd2, 4'd1, 4'd9, 4'd8,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd3, 4'd2, 4'd1, 4'd9,
                                         4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1};
   */
   parameter [row*col*4-1:0] dv_pixel = {4'd1,4'd2, 4'd3,4'd4,   // we give the pixels different voltage values
                                         4'd5,4'd6, 4'd7,4'd8,
                                         4'd9,4'd10,4'd1,4'd2,   
                                         4'd3,4'd4, 4'd5,4'd6};
   parameter int col=4,row=4; // here we set the number of pixels per row and per column for the whole system

   //Analog signals
   logic         anaBias1;
   logic          anaRamp;
   logic         anaReset;

   //Tie off the unused lines
   assign anaReset = 1; // is always high

   //Digital
   logic                       erase;
   logic                      expose;
   logic [row-1:0]              read; // one read per row
   tri[col-1:0][7:0]         pixData; // one data variable per column
   logic                     convert;

   // We split up the output data for easier reading 
   logic [7:0] pixelDataOut_0,  pixelDataOut_1, pixelDataOut_2, pixelDataOut_3;
   

   //Instanciate the pixel and set dv_pixel and number of pixels for the whole system 
   PIXEL_TOP #(.dv_pixel(dv_pixel), .col(col), .row(row)) pt1(clk, reset, erase, expose, convert, read, anaBias1, anaReset, anaRamp, pixData);

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[col-1:0][7:0] data; // one data bus per column 


   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp = convert ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1 = expose ? clk : 0;
   

   // each pixData is set to be data for each pixel in the row, while not reading. While reading it is set to a high impedance state
   generate
      genvar i;
      for (i = 0; i<col; i = i + 1)begin
         assign pixData[i] = read? 8'bZ: data[i]; 
      end
   endgenerate

   // pixelDataOut is plit into 4 variables for easier reading 
   assign pixelDataOut_0 = pixelDataOut[0];
   assign pixelDataOut_1 = pixelDataOut[1];
   assign pixelDataOut_2 = pixelDataOut[2];
   assign pixelDataOut_3 = pixelDataOut[3];

   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus. Assert convert_stop to return control to main state machine.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         data = 0;
      end
      if(convert) begin
         for (int i=0;i<col;i=i+1) begin
            data[i] += 1; // data counts upward while converting, pixData is then set to this value so that each pixel takes in a digital ramp 
         end
      end
      else begin
         data = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [col-1:0][7:0] pixelDataOut; // one for each column 
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut = 0;
      end
      else begin
         if(read) begin
            for (int i=0;i<col;i=i+1)begin
               pixelDataOut[i] <= pixData[i]; // After convet is done each pixel on the row has latched a value that they output through pixData, pixelDataOut is here set to this value  
            end
         end
         else begin
            pixelDataOut = 0;
         end
      end
   end
   
   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial begin
      $dumpfile("pixelTop_tb.vcd"); // we dump the result into a vcd file that GTKwave can read
      $dumpvars(0,pixelTop_tb);
      
      reset=1; #clk_period; // we reset, wait a while and reset again 
      reset=0; #test_reset;  // test_reset = clk_period*3700
      reset=1; #clk_period;  
      reset=0;

      #sim_end
         $stop;
   end

endmodule // test
