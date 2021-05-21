module line_buffer_control_strike
	#(parameter input_y = 6)
	(
	clk,
	rst,
	sof,
	eof,
	input_valid,
	output_valid,
	reset_all_cell,
	//debug
	state,
	y_count
);	
	localparam state_rst = 3'd0;
	localparam state_idle = 3'd1;
	localparam state_return = 3'd2;
	localparam state_wait = 3'd3;
	
	input clk;
	input rst;
	input sof, eof;
	input input_valid;
	output reg output_valid;

	output reg [2:0] state;
	output reg reset_all_cell;
	reg [10:0] input_valid_count;
	output reg [10:0] y_count;
	
	reg [2:0]     return_count;
	reg [7:0]     wait_count;
	reg is_eof;
	always @ (posedge clk) begin
		if(rst) begin
			state <= state_rst;
		end else begin
			case(state)
				state_rst:
					begin
						if(sof) begin
							state <= state_idle;
							output_valid <= 1'b0;
							y_count <= 11'd0;
							wait_count <= 2'b0;
							reset_all_cell <= 1'b0;
							is_eof <= 1'b0;
							return_count <= 0;
							if (input_valid) begin
								input_valid_count <= 11'd1;
							end else begin
								input_valid_count <= 11'd0;
							end
						end
					end
				state_idle:
					begin
						if(input_valid && input_valid_count != input_y*2 + 3 - 1) begin
							input_valid_count <= input_valid_count + 11'd1;
						end else begin
							if(input_valid) begin
								output_valid <= 1'b1;
								y_count <= 11'd1;
								state <= state_return;
							end
						end		
					end
				state_return:
					begin
						if(y_count != (input_y - 1) /2) begin
							if(input_valid) begin
								if(eof) begin
									is_eof <= 1'b1;
									output_valid <= 1'b1;
									y_count <= y_count + 11'd1;
								end else begin
									return_count <= return_count + 1;
									if(return_count == 1) begin
										return_count <= 0;
										output_valid <= 1'b1;
										y_count <= y_count + 11'd1;
									end else begin
										output_valid <= 1'b0;
									end
									//output_valid <= 1'b1;
									//y_count <= y_count + 11'd1;
								end
							end else begin
								output_valid <= 1'b0	;
							end	
						end else begin
							y_count <= 11'd0;
							output_valid <= 1'b0;
							if (is_eof) begin
								if(sof) begin
									is_eof <= 1'b0;
									state <= state_idle;
									input_valid_count <= 11'd1;
								end else begin
									state <= state_rst;
									reset_all_cell <= 1'b1;
								end
							end else begin
								state <= state_wait;
								if(input_valid) begin
									wait_count <= 2'd1;
								end
							end
						end
					end
				state_wait:
					begin
						if(input_valid && wait_count != input_y + 2) begin
							wait_count <= wait_count + 1'd1;
						end else begin
							if(input_valid) begin
								y_count <= 11'd1;
								state <= state_return;
								output_valid <= 1'b1;
							end
						end
					end
			endcase
		end
	end
endmodule