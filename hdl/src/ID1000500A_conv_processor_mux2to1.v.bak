module conv_processor_mux2to1 #(
		parameter DATA_WIDTH= 8
)(
		input wire [DATA_WIDTH-1:0] in1,
		input wire [DATA_WIDTH-1:0] in2,
		input wire  sel,
		output wire [DATA_WIDTH-1:0] out
	   
);

assign out=sel?in1:in2;

endmodule