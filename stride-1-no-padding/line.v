module line
#(
	parameter input_y = 3,	
	parameter data_width = 32
)
(
	clk,
	rst,
	load,
	data_in,
	data_out_0,
	data_out_1,
	data_out_2,
	data_out
);
	input clk;
	input rst;
	input load;
	input  [data_width - 1:0] data_in;
	output [data_width - 1:0] data_out_0;
	output [data_width - 1:0] data_out_1;
	output [data_width - 1:0] data_out_2;
	output [data_width - 1:0] data_out;
	
	wire [data_width - 1:0] inter_connect [3:input_y];
	assign data_out = inter_connect[input_y];
	assign inter_connect[3] = data_out_2;
	genvar i;
	generate
		if(input_y > 3) begin
			for(i = 0; i <= input_y - 1; i = i + 1) begin : name
				if(i == 0) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_in), .data_out(data_out_0));
				end else if(i == 1) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_out_0), .data_out(data_out_1));
				end else if(i == 2) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_out_1), .data_out(data_out_2));
				end else begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(inter_connect[i]), .data_out(inter_connect[i + 1]));		
				end
			end
		end else if(input_y == 3) begin
			for(i = 0; i <= input_y - 1; i = i + 1) begin : name_2
				if(i == 0) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_in), .data_out(data_out_0));
				end else if(i == 1) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_out_0), .data_out(data_out_1));
				end else if(i == 2) begin
					register #(data_width) my_reg(.clk(clk), .rst(rst), .load(load), .data_in(data_out_1), .data_out(data_out_2));
				end
			end 
		end
	endgenerate


endmodule