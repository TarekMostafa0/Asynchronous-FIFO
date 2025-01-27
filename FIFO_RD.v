module FIFO_RD  #(parameter FIFO_DEPTH = 8,
							P_SIZE = 4) 
(
	input 						R_CLK, R_RST,
	input 						R_INC,
	input	 	[P_SIZE-1:0]	rq2_wptr,
	output reg					EMPTY,
	output 	 	[P_SIZE-2:0]	raddr,
	output reg 	[P_SIZE-1:0]	rptr

);
	wire 			empty;
	wire [P_SIZE-1:0]	r_bnext, r_gnext;
	reg  [P_SIZE-1:0]	rbin;

	assign r_bnext = rbin + (R_INC & !EMPTY);
	assign r_gnext = r_bnext>>1 ^ r_bnext;

	assign empty   = (r_gnext==rq2_wptr);
	assign raddr   = rbin[P_SIZE-2:0];

	always @(posedge R_CLK or negedge R_RST) begin
		if (~R_RST) begin
			rbin <= 0;
			rptr <= 0;
		end
		else begin
			rbin <= r_bnext;
			rptr <= r_gnext;
		end
	end	

	always @(posedge R_CLK or negedge R_RST) begin : proc_EMPTY
		if(~R_RST) begin
			EMPTY <= 1;
		end else begin
			EMPTY <= empty;
		end
	end

endmodule