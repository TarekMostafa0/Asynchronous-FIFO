module FIFO_MEM #(parameter DATA_WIDTH = 8, 
							FIFO_DEPTH = 8,
							P_SIZE = 4) 
(
	input  					W_CLK, W_RST, wclk_en,
	input  [DATA_WIDTH-1:0]	WR_DATA,
	input  [P_SIZE-2:0]		raddr, waddr,
	output [DATA_WIDTH-1:0]	RD_DATA
);

	reg [FIFO_DEPTH-1:0] i;
	reg [DATA_WIDTH-1:0] MEM [FIFO_DEPTH-1:0];

	always @(posedge W_CLK or negedge W_RST) begin : proc_write
		if (~W_RST) begin
			for (i = 0; i < FIFO_DEPTH; i=i+1) begin
				MEM[i] <= {DATA_WIDTH{1'b0}};
			end
		end
		else if(wclk_en) begin
			MEM[waddr] <= WR_DATA;
		end
	end

	assign	RD_DATA = MEM[raddr];


endmodule