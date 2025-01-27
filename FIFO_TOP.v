module FIFO_TOP #(parameter DATA_WIDTH = 8, 
							FIFO_DEPTH = 8,
							P_SIZE = ($clog2(FIFO_DEPTH)+1) ) 
(
	input						W_CLK, W_RST, R_CLK, R_RST,
	input						W_INC, R_INC,			
	input 	[DATA_WIDTH-1:0] 	WR_DATA,
	output 	[DATA_WIDTH-1:0]	RD_DATA,
	output						FULL, EMPTY

);

	wire 				wclk_en;
	wire [P_SIZE-1:0] 		rptr, wptr, wq2_rptr, rq2_wptr;
	wire [P_SIZE-2:0]	waddr, raddr;

	assign wclk_en = !FULL & W_INC;

	FIFO_MEM #(.DATA_WIDTH(DATA_WIDTH), .P_SIZE(P_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) FIFO_MEM_CNTRL(
		.RD_DATA(RD_DATA),
		.W_CLK  (W_CLK),
		.W_RST  (W_RST),
		.WR_DATA(WR_DATA),
		.raddr  (raddr),
		.waddr  (waddr),
		.wclk_en(wclk_en)
	);

	FIFO_WR #(.P_SIZE(P_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) FIFO_WRITE(
		.W_CLK(W_CLK),
		.waddr(waddr),
		.W_RST(W_RST),
		.W_INC(W_INC),
		.FULL (FULL),
		.wq2_rptr (wq2_rptr),
		.wptr (wptr)
	);

	FIFO_RD #(.P_SIZE(P_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) FIFO_READ(
		.raddr(raddr),
		.rq2_wptr(rq2_wptr),
		.rptr (rptr),
		.R_CLK(R_CLK),
		.R_RST(R_RST),
		.R_INC(R_INC),
		.EMPTY(EMPTY)
	); 
	
	DF_SYNC #(.W(P_SIZE)) sync_r2w(
		.clk   (W_CLK),
		.rst_n (W_RST),
		.ptr   (rptr),
		.q2_ptr(wq2_rptr)
	);

	DF_SYNC #(.W(P_SIZE)) sync_w2r(
		.clk   (R_CLK),
		.rst_n (R_RST),
		.ptr   (wptr),
		.q2_ptr(rq2_wptr)
	);

endmodule