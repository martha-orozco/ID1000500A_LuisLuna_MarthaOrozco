module conv_processor_mux3to1 #(
		parameter DATA_WIDTH= 8
)(
		input wire [DATA_WIDTH-1:0] in1,
		input wire [DATA_WIDTH-1:0] in2,
		input wire [DATA_WIDTH-1:0] in3,
		input wire  [1:0] sel,
		output reg [DATA_WIDTH-1:0] out
	   
);


always @(*) begin
	case (sel)
		2'b00: out=in1;
		2'b01: out=in2;
		2'b10: out=in3;
		default: out=in1;
	endcase
end

endmodule