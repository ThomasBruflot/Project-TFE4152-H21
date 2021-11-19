`timescale 1 ns / 1 ps

module pixelArray_tb; // This test-bench is written for a 4x4 system

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
   parameter real    dv_pixel = 5;  //Set the expected photodiode current (0-1)

   //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   logic              erase;
   logic              expose;
   logic [3:0]          read;
   tri[3:0][7:0]     pixData; //  We need this to be a wire, because we're tristating it

   //Instanciate the pixels
   PIXEL_ARRAY #(.dv_pixel(dv_pixel)) pa1(anaBias1, anaRamp, anaReset, erase,expose, read,pixData);

   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;

   logic               convert;
   logic [2:0]    state,next_state;   //States
   integer             counter;       //Delay counter in state machine

   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 5;

   // Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           read <= 4'b0000;
           expose <= 0;
           convert <= 0;
        end
        EXPOSE: begin
           erase <= 0;
           read <= 4'b0000;
           expose <= 1;
           convert <= 0;
        end
        CONVERT: begin
           erase <= 0;
           read <= 4'b0000;
           expose <= 0;
           convert = 1;
        end
        READ: begin
           erase <= 0;
           read <= 4'b0001; // we only test with the first row reading
           expose <= 0;
           convert <= 0;
        end
        IDLE: begin
           erase <= 0;
           read <= 4'b0000;
           expose <= 0;
           convert <= 0;

        end
      endcase // case (state)
   end // always @ (state)

   // Control the state transitions
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         state = IDLE;
         next_state = ERASE;
         counter  = 0;
         convert  = 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 next_state <= EXPOSE;
                 state <= IDLE;
              end
           end
           EXPOSE: begin
              if(counter == c_expose) begin
                 next_state <= CONVERT;
                 state <= IDLE;
              end
           end
           CONVERT: begin
              if(counter == c_convert) begin
                 next_state <= READ;
                 state <= IDLE;
              end
           end
           READ:
             if(counter == c_read) begin
                state <= IDLE;
                next_state <= ERASE;
             end
           IDLE:
             state <= next_state;
         endcase // case (state)
         if(state == IDLE)
           counter = 0;
         else
           counter = counter + 1;
      end
   end // always @ (posedge clk or posedge reset)

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[3:0][7:0] data;


   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp = convert ? clk : 0;

   // During expoure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1 = expose ? clk : 0;
   

   
   assign pixData[0] = read? 8'bZ: data[0];
   assign pixData[1] = read? 8'bZ: data[1];
   assign pixData[2] = read? 8'bZ: data[2];
   assign pixData[3] = read? 8'bZ: data[3];

   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus. Assert convert_stop to return control to main state machine.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
          data = 4'b0000;
      end
      if(convert) begin
         data[0] +=  1;
         data[1] +=  1;
         data[2] +=  1;
         data[3] +=  1;
      end
      else begin
         data = 4'b0000;
      end
   end // always @ (posedge clk or reset)


   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [3:0][7:0] pixelDataOut;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut = 4'b0000;
      end
      else begin
         if(read) begin
            pixelDataOut[0] <= pixData[0];
            pixelDataOut[1] <= pixData[1];
            pixelDataOut[2] <= pixData[2];
            pixelDataOut[3] <= pixData[3];
         end
         else begin
            pixelDataOut = 4'b0000;
         end
      end
   end
   

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial
     begin
        $dumpfile("pixelArray_tb.vcd"); // we dump the result into a vcd file that GTKwave can read
        $dumpvars(0,pixelArray_tb);

        reset=1; #clk_period; // we reset, wait some time and then reset again 
        reset=0; #test_reset;  
        reset=1; #clk_period;  
        reset=0;

        #sim_end
          $stop;
     end

endmodule 
