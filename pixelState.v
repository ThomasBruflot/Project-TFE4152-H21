`timescale 1 ns / 1 ps

module PIXEL_STATE (clock, reset, erase, expose, convert, read);
    input clock, reset;
    output logic erase, expose, convert;
	output logic [row-1:0] read;

	parameter int col=4,row=4;
    parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4; 
    
    logic [2:0] state, next_state;
	logic [row-1:0] read2;
	integer           counter;            //Delay counter in state machine

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
			// pixel nr. 1 
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
					read2 = 1;
					state = IDLE; 
				end
			end
			READ: begin
				if((counter%c_read == 0) && (counter != 0))begin 
					read2 = read2 << 1;
				end
				if(counter == c_read*row) begin // when read is done ps1,2,3 will wait for ps3 to be done reading before next_state is set to erase
					state = IDLE; 
					next_state = ERASE;
				end
			end
			IDLE:
				state <= next_state;
			endcase // case (state)
			if(state == IDLE)
			counter = 0;
			else
			counter = counter + 1;
		end
	end

	// Control the output signals
	always_ff @(negedge clock ) begin
		case(state)
			ERASE: begin
			erase <= 1;
			read <= 0;
			expose <= 0; // expose[0] here and so on..
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
			read <= read2;
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