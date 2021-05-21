	module register(
		clk,
		rst,
		load,
		data_in,
		data_out
	);
	//parameter 
	parameter data_width = 8;
	//input
	input clk;
	input rst;
	input load;
	input [data_width - 1:0] data_in;
	//output 
	output [data_width - 1:0] data_out;
	
	reg [data_width - 1:0] my_reg;
	assign data_out = my_reg;
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			my_reg <= 0;
		end else if (load) begin
			my_reg <= data_in;
		end
	end

endmodule