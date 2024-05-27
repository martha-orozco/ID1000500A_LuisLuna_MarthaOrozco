module conv_processor_register #(
		parameter DATA_WIDTH= 8
)(
		input wire clk,
		input wire rstn,
		input wire clear,
		input wire load,
		input wire [DATA_WIDTH-1:0] data_in,
		output reg [DATA_WIDTH-1:0] data_out	
	   
);

always@(posedge clk, negedge rstn) begin
		if(!rstn)
				  data_out<={DATA_WIDTH{1'b0}};
		else if(clear)
					data_out<={DATA_WIDTH{1'b0}};
		else if(load)
					data_out<=data_in;	
end

endmodule