module DF_SYNC #(parameter W = 4) (
	input 				clk, rst_n,
	input 		[W-1:0]	ptr,
	output reg	[W-1:0]	q2_ptr
);

	reg [W-1:0] q1_ptr;

	always @(posedge clk or negedge rst_n) begin : proc_syn
		if(~rst_n) begin
			q2_ptr <= 0;
			q1_ptr <= 0;
		end 
		else begin
			q2_ptr <= q1_ptr;
			q1_ptr <= ptr;
		end
	end

endmodule