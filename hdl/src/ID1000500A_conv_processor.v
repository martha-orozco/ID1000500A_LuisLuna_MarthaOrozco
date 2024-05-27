/*
Convolution processor based on the requirements of the TAE P1 project.
Author: Vidkar Delgado
Date:   May-2023
*/

module conv_processor (
	input wire clk,
	input wire rstn,

   input wire [7:0] dataX_i,
	input wire [4:0] sizeX_i,
	input wire [7:0] dataY_i,
	input wire [4:0] sizeY_i,
	input wire       start_i,
	
	output wire [4:0] memXaddr_o,
	output wire [4:0] memYaddr_o,
	output wire [5:0] memZaddr_o,
	output wire [15:0] dataZ_o,
	output wire        writeZ_o,
	output wire        busy_o,
	output reg         done_o

);

//signal declaration
localparam DATA_WIDTH=8,
           ADDR_WIDTH=5;

reg comp1_wire;
reg comp2_wire;
reg comp3_wire;
wire addrZ_clr_wire;
wire addrZ_load_wire;
wire done_wire;
wire addrY_clr_wire;
wire addrY_load_wire;
wire addrX_load_wire;
wire aux_clr_wire;
wire aux_load_wire;
wire sel_addrY_wire;
wire [1:0] sel_addrX_wire;
wire readX_wire;
wire readY_wire;
//wire writeZ_wire;

wire [ADDR_WIDTH:0] addrX;
wire [ADDR_WIDTH:0] addrX_next;

wire [ADDR_WIDTH:0] addrY;
wire [ADDR_WIDTH:0] addrY_next;

wire [(2*DATA_WIDTH)-1:0] aux;

wire [(2*DATA_WIDTH)-1:0] mult_temp_wire;


//instance of the FSM

conv_processor_FSM fsm(
	.clk(clk),
	.rstn(rstn),
	.comp1_in(comp1_wire),
	.comp2_in(comp2_wire),
	.comp3_in(comp3_wire),
	.init_in(start_i),
	.addrZ_clr_out(addrZ_clr_wire),
	.addrZ_load_out(addrZ_load_wire),
	.done_out(done_wire),
	.addrY_clr_out(addrY_clr_wire),
	.addrY_load_out(addrY_load_wire),
	.addrX_load_out(addrX_load_wire),
	.aux_clr_out(aux_clr_wire),
	.aux_load_out(aux_load_wire),
	.sel_addrY_out(sel_addrY_wire),
	.sel_addrX_out(sel_addrX_wire),
	.readX_out(),
	.readY_out(),
	.writeZ_out(writeZ_o),
   .busy_out(busy_o)
);

//datapath

//always block for registers

//FF Valid
always@(posedge clk) begin			
      if(done_wire)
            done_o<=1'b1;
      else
            done_o<=1'b0;			
end

//register addrX
conv_processor_register #(
	.DATA_WIDTH(ADDR_WIDTH+1)
) addrX_reg (
				.clk(clk),
            .rstn(rstn),
				.clear(1'b0),
				.load(addrX_load_wire),
				.data_in(addrX_next),
				.data_out(addrX)	
);

//register addrY
conv_processor_register #(
	.DATA_WIDTH(ADDR_WIDTH+1)
) addry_reg (
				.clk(clk),
            .rstn(rstn),
				.clear(addrY_clr_wire),
				.load(addrY_load_wire),
				.data_in(addrY_next),
				.data_out(addrY)	
);

//register addrZ
conv_processor_register #(
	.DATA_WIDTH(ADDR_WIDTH+1)
) addrz_reg (
				.clk(clk),
            .rstn(rstn),
				.clear(addrZ_clr_wire),
				.load(addrZ_load_wire),
				.data_in(memZaddr_o+1'b1),
				.data_out(memZaddr_o)	
);


//register aux
conv_processor_register #(
	.DATA_WIDTH(2*DATA_WIDTH)
) aux_reg (
				.clk(clk),
            .rstn(rstn),
				.clear(aux_clr_wire),
				.load(aux_load_wire),
				.data_in(mult_temp_wire+aux),
				.data_out(aux)
);


//multiplier
assign mult_temp_wire=dataX_i*dataY_i;

//multiplexers

conv_processor_mux2to1 #(
		.DATA_WIDTH(ADDR_WIDTH+1)
) mux1 (
		.in1(addrY + 1'b1),
		.in2(memZaddr_o-sizeX_i+1'b1),
		.sel(sel_addrY_wire),
		.out(addrY_next)	   
);

conv_processor_mux3to1 #(
		.DATA_WIDTH(ADDR_WIDTH+1)
) mux2 (
		.in1(addrX-1'b1),
		.in2(memZaddr_o),
		.in3({1'b0,sizeX_i}-1'b1),
		.sel(sel_addrX_wire),
		.out(addrX_next)  
);


//comparisions

always @(*) begin
	if(memZaddr_o < sizeX_i+sizeY_i-1'b1)
		comp1_wire=1'b1;
	else
		comp1_wire=1'b0;
		
	if(memZaddr_o < sizeX_i)
		comp2_wire=1'b1;
	else
		comp2_wire=1'b0;
		
	if(addrY < sizeY_i && addrX[ADDR_WIDTH] == 1'b0)
		comp3_wire=1'b1;                
	else
		comp3_wire=1'b0;	
end

assign memXaddr_o = addrX[ADDR_WIDTH-1:0];  
assign memYaddr_o = addrY[ADDR_WIDTH-1:0];                                                                                                         
assign  dataZ_o   = aux;                                                               
                                              

endmodule                                            