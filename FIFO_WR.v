module FIFO_WR  #(parameter FIFO_DEPTH = 8,
							P_SIZE = 4) 
(
	input 						W_CLK, W_RST,
	input 						W_INC,
	input	 	[P_SIZE-1:0]	wq2_rptr,
	output reg					FULL,
	output 	 	[P_SIZE-2:0]	waddr,
	output reg 	[P_SIZE-1:0]	wptr

);

	wire 			full;
	wire [P_SIZE-1:0]	w_bnext, w_gnext;
	reg  [P_SIZE-1:0]	wbin;

	assign w_bnext = wbin + (W_INC & !FULL);
	assign w_gnext = w_bnext>>1 ^ w_bnext;

	assign full    = (w_gnext[P_SIZE-1]!=wq2_rptr[P_SIZE-1]) && (w_gnext[P_SIZE-2]!=wq2_rptr[P_SIZE-2]) && (w_gnext[P_SIZE-3:0]==wq2_rptr[P_SIZE-3:0]);
	assign waddr   = wbin[P_SIZE-2:0];


	always @(posedge W_CLK or negedge W_RST) begin
		if (~W_RST) begin
			wbin <= 0;
			wptr <= 0;
		end
		else begin
			wbin <= w_bnext;
			wptr <= w_gnext;
		end
	end	

	always @(posedge W_CLK or negedge W_RST) begin : proc_FULL
		if(~W_RST) begin
			FULL <= 0;
		end else begin
			FULL <= full;
		end
	end

endmodule