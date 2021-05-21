module line_buffer_control_padding
	#(
		parameter input_y = 3,
		parameter input_x = 3
	)
	(
	clk,
	rst,
	sof,
	busy,
	input_valid,
	output_valid,
	is_pad_0,
	is_pad_1,
	is_pad_2,
	is_pad_3,
	is_pad_4,
	is_pad_5,
	is_pad_6,
	is_pad_7,
	is_pad_8,
	//debug
	state,
	input_valid_count,
	x,
	y
);	
	localparam state_rst    = 3'd0;
	localparam state_idle   = 3'd1;
	localparam state_return = 3'd2;
	
	input clk;
	input rst;
	input sof;
	input input_valid;
	output reg busy;
	output reg output_valid;
	output reg [2:0] state;
	output reg is_pad_0, is_pad_1, is_pad_2, is_pad_3, is_pad_4, is_pad_5, is_pad_6, is_pad_7, is_pad_8;
	output reg [15:0] input_valid_count;
	always @ (posedge clk) begin // output_valid control 
		if(rst) begin
			state <= state_rst;
		end else begin
			case(state)
				state_rst:
					begin
						if(sof) begin
							state <= state_idle;
							output_valid <= 1'b0;
							if (input_valid || busy) begin
								input_valid_count <= 1;
							end else begin
								input_valid_count <= 0;
							end
						end
					end
				state_idle:
					begin
						if(input_valid && input_valid_count != input_y + 2 - 1) begin
							input_valid_count <= input_valid_count + 1;
						end else begin
							if(input_valid || busy) begin
								input_valid_count <= input_valid_count + 1;
								output_valid <= 1'b1;
								state <= state_return;
							end
						end		
					end
				state_return:
					begin
						if(input_valid && sof) begin
							output_valid <= 0;
							input_valid_count <= 1;
							state <= state_idle;
						end else if(sof) begin
							input_valid_count <= 0;
							state <= state_idle;
						end else if(input_valid || busy) begin
							output_valid <= 1;
							input_valid_count <= input_valid_count + 1;
						end else if(!input_valid) begin
							output_valid <= 0;
						end
					end
			endcase
		end
	end
	output reg [7:0] x;
	output reg [7:0] y;
	always @ (posedge clk) begin
		if(rst || sof) begin
			busy <= 0;
		end else if(input_valid_count == input_x*input_y - 1 && input_valid) begin
			busy <= 1;
		end else if(x == input_x && y == input_y - 1) begin
			busy <= 0;
		end
	end
	always @ (posedge clk) begin // x, y count
		if(rst) begin
			x <= 0;
			y <= 0;
		end else  begin
			if(sof) begin
				x <= 0;
				y <= 0;
			end else if(input_valid || busy) begin
				if(y != input_y - 1) begin
					y <= y + 1;
				end else begin
					y <= 0;
					if(x != input_x) begin
						x <= x + 1;
					end else begin
						x <= 0;
					end
				end 
			end 
		end
	end
	always @ (posedge clk) begin // padding control
		if(rst) begin
			is_pad_0 <= 0;
			is_pad_1 <= 0;
			is_pad_2 <= 0;
			is_pad_3 <= 0;
			is_pad_4 <= 0;
			is_pad_5 <= 0;
			is_pad_6 <= 0;
			is_pad_7 <= 0;
			is_pad_8 <= 0;
		end else if(x == 1) begin
			if(y == 0) begin
				is_pad_0 <= 1;
				is_pad_1 <= 1;
				is_pad_2 <= 1;
				is_pad_3 <= 1;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 1;
				is_pad_7 <= 0;
				is_pad_8 <= 0;
			end else if(y >= 1 && y < input_y - 1) begin
				is_pad_0 <= 1;
				is_pad_1 <= 1;
				is_pad_2 <= 1;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 0;
				is_pad_7 <= 0;
				is_pad_8 <= 0;
			end else if(y == input_y - 1) begin
				is_pad_0 <= 1;
				is_pad_1 <= 1;
				is_pad_2 <= 1;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 1;
				is_pad_6 <= 0;
				is_pad_7 <= 0;
				is_pad_8 <= 1;
			end
		end else if(x > 1 && x != input_x) begin
			if(y == 0) begin
				is_pad_0 <= 1;
				is_pad_1 <= 0;
				is_pad_2 <= 0;
				is_pad_3 <= 1;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 1;
				is_pad_7 <= 0;
				is_pad_8 <= 0;
			end else if(y == input_y - 1) begin
				is_pad_0 <= 0;
				is_pad_1 <= 0;
				is_pad_2 <= 1;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 1;
				is_pad_6 <= 0;
				is_pad_7 <= 0;
				is_pad_8 <= 1;
			end else begin
				is_pad_0 <= 0;
				is_pad_1 <= 0;
				is_pad_2 <= 0;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 0;
				is_pad_7 <= 0;
				is_pad_8 <= 0;
			end
		end else if(x == input_x) begin
			if(y == 0) begin
				is_pad_0 <= 1;
				is_pad_1 <= 0;
				is_pad_2 <= 0;
				is_pad_3 <= 1;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 1;
				is_pad_7 <= 1;
				is_pad_8 <= 1;
			end else if(y >= 1 && y < input_y - 1) begin
				is_pad_0 <= 0;
				is_pad_1 <= 0;
				is_pad_2 <= 0;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 0;
				is_pad_6 <= 1;
				is_pad_7 <= 1;
				is_pad_8 <= 1;
			end else if(y == input_y - 1) begin
				is_pad_0 <= 0;
				is_pad_1 <= 0;
				is_pad_2 <= 1;
				is_pad_3 <= 0;
				is_pad_4 <= 0;
				is_pad_5 <= 1;
				is_pad_6 <= 1;
				is_pad_7 <= 1;
				is_pad_8 <= 1;
			end
		end
	end
	endmodule