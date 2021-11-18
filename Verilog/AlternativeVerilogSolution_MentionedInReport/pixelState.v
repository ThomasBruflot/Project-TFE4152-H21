`timescale 1 ns / 1 ps

module PIXEL_STATE (clock, reset, erase, expose, convert, read);
    input clock, reset;
    output logic erase;
	output logic [3:0] expose, convert, read;

    parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4; 
    
    logic [3:0][2:0] state, next_state;
	integer           counter0, counter1, counter2, counter3;       

	parameter integer c_erase = 5;
	parameter integer c_expose = 255;
	parameter integer c_convert = 255;
	parameter integer c_read = 5;

    always_ff @(posedge clock or posedge reset) begin
    	if(reset) begin
        	state = {IDLE, IDLE, IDLE, IDLE}; 
        	next_state = {ERASE, ERASE, ERASE, ERASE}; 
        	counter0 = 0;
			counter1 = 0;
			counter2 = 0;
			counter3 = 0;
        	convert[0] = 0;
			convert[1] = 0;
			convert[2] = 0;
			convert[3] = 0;
    	end
		else begin
			// pixel nr. 1 
			case (state[0])
			ERASE: begin
				if(counter0 == c_erase) begin 
					next_state[0] = EXPOSE; // after counting to 5 ERASE is done, the next state is set to EXPOSE, so next clock gives EXPOSE
					state[0] = IDLE; // counter is set to 0 and next clock gives next state, when state is set to IDLE
				end
			end
			EXPOSE: begin
				if(counter0 == c_expose) begin
					next_state[0] = CONVERT; // after counting to 255 EXPOSE is done, the next state is set to CONVERT, so next clock gives CONVERT
					state[0] = IDLE; // same at before

					next_state[1] = EXPOSE; // now that ps1 is done exposing ps2 can expose on next clock 
					state[1] = IDLE; // the second pixel's state is set to idle
				end
			end
			CONVERT: begin
				if(counter0 == c_convert) begin
					next_state[0] = READ; // same at before
					state[0] = IDLE; // same at before
				end
			end
			READ:
				if(counter0 == c_read) begin // when read is done ps1,2,3 will wait for ps3 to be done reading before next_state is set to erase
				state[0] = IDLE; 
				next_state[0] = IDLE;
				end
			IDLE:
				state[0] <= next_state[0];
			endcase // case (state)
			if(state[0] == IDLE)
			counter0 = 0;
			else
			counter0 = counter0 + 1;

			// pixel nr. 2
			case (state[1])
			ERASE: begin
				if(counter0 == c_erase) begin // all pixels erase at the same time, but only ps1 gets to go to next state after erase is done
					next_state[1] = IDLE; // having IDLE as next state makes the ps idle until next_state is set to EXPOSE, which happens when ps1 is done exposing
					state[1] = IDLE;
				end
			end
			EXPOSE: begin
				if(counter1 == c_expose) begin
					next_state[1] = CONVERT;
					state[1] = IDLE;

					next_state[2] = EXPOSE; 
					state[2] = IDLE;
				end
			end
			CONVERT: begin
				if(counter1 == c_convert) begin
					next_state[1] = READ;
					state[1] = IDLE;
				end
			end
			READ:
				if(counter1 == c_read) begin
				state[1] = IDLE;
				next_state[1] = IDLE;
				end
			IDLE:
				state[1] <= next_state[1];
			endcase 
			if(state[1] == IDLE)
			counter1 = 0;
			else
			counter1 = counter1 + 1;

			
			case (state[2]) 
			ERASE: begin
				if(counter0 == c_erase) begin
					next_state[2] = IDLE;
					state[2] = IDLE;
				end
			end
			EXPOSE: begin
				if(counter2 == c_expose) begin
					next_state[2] = CONVERT;
					state[2] = IDLE;
					next_state[3] = EXPOSE; 
					state[3] = IDLE;
				end
			end
			CONVERT: begin
				if(counter2 == c_convert) begin
					next_state[2] = READ;
					state[2] = IDLE;
				end
			end
			READ:
				if(counter2 == c_read) begin
				state[2] = IDLE;
				next_state[2] = IDLE;
				end
			IDLE:
				state[2] <= next_state[2];
			endcase
			if(state[2] == IDLE)
			counter2 = 0;
			else
			counter2 = counter2 + 1;

			// pixel nr.3
			case (state[3]) 
			ERASE: begin
				if(counter0 == c_erase) begin
					next_state[3] = IDLE;
					state[3] = IDLE;
				end
			end
			EXPOSE: begin
				if(counter3 == c_expose) begin
					next_state[3] = CONVERT;
					state[3] = IDLE;
				end
			end
			CONVERT: begin
				if(counter3 == c_convert) begin
					next_state[3] = READ;
					state[3] = IDLE;
				end
			end
			READ: 
				if(counter3 == c_read) begin 
				state[3] = IDLE;
				next_state = {ERASE, ERASE, ERASE, ERASE};
				end
			IDLE:
				state[3] <= next_state[3];
			endcase \
			if(state[3] == IDLE)
			counter3 = 0;
			else
			counter3 = counter3 + 1;
		end
    end

	// Control the output signals
   always_ff @(negedge clock ) begin
      case(state[0])
			ERASE: begin
			erase <= 1;
			read[0] <= 0; 
			expose[0] <= 0; 
			convert[0] <= 0;
			end
			EXPOSE: begin
			erase <= 0;
			read[0] <= 0;
			expose[0] <= 1;
			convert[0] <= 0;
			end
			CONVERT: begin
			erase <= 0;
			read[0] <= 0;
			expose[0] <= 0;
			convert[0] = 1;
			end
			READ: begin
			erase <= 0;
			read[0] <= 1;
			expose[0] <= 0;
			convert[0] <= 0;
			end
			IDLE: begin
			erase <= 0;
			read[0] <= 0;
			expose[0] <= 0;
			convert[0] <= 0;
			end
	  endcase

		case(state[1])
			ERASE: begin
			erase <= 1;
			read[1] <= 0;
			expose[1] <= 0;
			convert[1] <= 0;
			end
			EXPOSE: begin
			erase <= 0;
			read[1] <= 0;
			expose[1] <= 1;
			convert[1] <= 0;
			end
			CONVERT: begin
			erase <= 0;
			read[1] <= 0;
			expose[1] <= 0;
			convert[1] = 1;
			end
			READ: begin
			erase <= 0;
			read[1] <= 1;
			expose[1] <= 0;
			convert[1] <= 0;
			end
			IDLE: begin
			erase <= 0;
			read[1] <= 0;
			expose[1] <= 0;
			convert[1] <= 0;
			end
		endcase

		case(state[2])
			ERASE: begin
			erase <= 1;
			read[2] <= 0;
			expose[2] <= 0;
			convert[2] <= 0;
			end
			EXPOSE: begin
			erase <= 0;
			read[2] <= 0;
			expose[2] <= 1;
			convert[2] <= 0;
			end
			CONVERT: begin
			erase <= 0;
			read[2] <= 0;
			expose[2] <= 0;
			convert[2] = 1;
			end
			READ: begin
			erase <= 0;
			read[2] <= 1;
			expose[2] <= 0;
			convert[2] <= 0;
			end
			IDLE: begin
			erase <= 0;
			read[2] <= 0;
			expose[2] <= 0;
			convert[2] <= 0;
			end
		endcase

		case(state[3])
			ERASE: begin
			erase <= 1;
			read[3] <= 0;
			expose[3] <= 0;
			convert[3] <= 0;
			end
			EXPOSE: begin
			erase <= 0;
			read[3] <= 0;
			expose[3] <= 1;
			convert[3] <= 0;
			end
			CONVERT: begin
			erase <= 0;
			read[3] <= 0;
			expose[3] <= 0;
			convert[3] = 1;
			end
			READ: begin
			erase <= 0;
			read[3] <= 1;
			expose[3] <= 0;
			convert[3] <= 0;
			end
			IDLE: begin
			erase <= 0;
			read[3] <= 0;
			expose[3] <= 0;
			convert[3] <= 0;
			end
      	endcase // case (state)
   end // always @ (state)
endmodule