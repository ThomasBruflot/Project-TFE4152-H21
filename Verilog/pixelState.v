`timescale 1 ns / 1 ps

module PIXEL_STATE (clock, reset, erase, expose, convert, read);
    input clock, reset;
    output logic erase, expose, convert;
	output logic [row-1:0] read; // one read signal for each row

	parameter int col=4,row=4; // this will be overwritten in pixelTop_tb
    parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4; 
    
    logic [2:0] state, next_state; // holds the current and next states
	logic [row-1:0] read_tmp; // holds the array which indicates what row is reading
	integer           counter;    // counts the number of clock cycles that have passed

	//State duration in clock cycles
	parameter integer c_erase = 5;
	parameter integer c_expose = 255;
	parameter integer c_convert = 255;
	parameter integer c_read = 5;


	// Control the output signals
	always_ff @(posedge clock or posedge reset) begin
		if(reset) begin
			state = IDLE; // all are set to idle so that next clock gives ERASE for all
			next_state = ERASE; 
			
			counter = 0;
		end
		else begin
			case (state)
			ERASE: begin
				if(counter == c_erase) begin 
					next_state = EXPOSE; // after counting to 5 ERASE is done, the next state is set to EXPOSE, so next clock gives EXPOSE
					state = IDLE; // counter is set to 0 and next clock gives next state, when state is set to IDLE
				end
			end
			EXPOSE: begin
				if(counter == c_expose) begin
					next_state = CONVERT; // after counting to 255 EXPOSE is done, the next state is set to CONVERT, so next clock gives CONVERT
					state = IDLE; // same as before
				end
			end
			CONVERT: begin
				if(counter == c_convert) begin
					next_state = READ;
					read_tmp = 1; // here read_tmp is set e.g. 000001 
					state = IDLE; 
				end
			end
			READ: begin
				if((counter%c_read == 0) && (counter != 0))begin // Every time five clock cycles have pased we left shft the 1 and give the next row permission to read 
					read_tmp = read_tmp << 1; // we left shift
				end
				if(counter == c_read*row) begin // when read is done for all the rows next_state is set to erase for all the pixels 
					state = IDLE; 
					next_state = ERASE;
				end
			end
			IDLE:
				state <= next_state; // once we are in IDLE state is set to next state 
			endcase // case (state)
			if(state == IDLE)
			counter = 0; // the counter is reset in IDLE
			else
			counter = counter + 1; // otherwise we incerment
		end
	end

	// Control the output signals
	always_ff @(negedge clock ) begin // Here we set the output values of the module (that contorl the pixel array) 
		case(state)
			ERASE: begin // the values are set according to what state we are in
			erase <= 1; 
			read <= 0;
			expose <= 0; 
			convert <= 0;
			end
			EXPOSE: begin
			erase <= 0;
			read <= 0;
			expose <= 1;
			convert <= 0;
			end
			CONVERT: begin
			erase <= 0;
			read <= 0;
			expose <= 0;
			convert = 1;
			end
			READ: begin
			erase <= 0;
			read <= read_tmp; // read is here set to an array of the same size as the number of rows, that has a 1 at one of the bits, indicating which row can read
			expose <= 0;
			convert <= 0;
			end
			IDLE: begin
			erase <= 0;
			read <= 0;
			expose <= 0;
			convert <= 0;
			end
		endcase
	end // always @ (state)

endmodule
