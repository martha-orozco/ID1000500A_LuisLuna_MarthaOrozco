module conv_processor_FSM (
	input wire clk,
	input wire rstn,
	input wire comp1_in,
	input wire comp2_in,
	input wire comp3_in,
	input wire init_in,
	output reg addrZ_clr_out,
	output reg addrZ_load_out,
	output reg done_out,
	output reg addrY_clr_out,
	output reg addrY_load_out,
	output reg addrX_load_out,
	output reg aux_clr_out,
	output reg aux_load_out,
	output reg sel_addrY_out,
	output reg [1:0] sel_addrX_out,
	output reg readX_out,
	output reg readY_out,
	output reg writeZ_out,
   output reg busy_out	
);

//States
localparam [3:0]  s1=	4'b0000, 
						s2=	4'b0001, 
						s3=	4'b0010, 
						s4=	4'b0011, 
						s5=	4'b0100, 
						s6=	4'b0101, 
						s7=	4'b0110, 
						s8=	4'b0111, 
						s9=	4'b1000, 
						s10=	4'b1001, 
						s11=	4'b1010,
						s12=	4'b1011,
						s13=  4'b1100,
                  s14=  4'b1101;
						
						

reg [3:0] pres;  // actual state
reg [3:0] next;  // next state


//================================================================
// Always Block to update states 
//================================================================
always@(posedge clk, negedge rstn) begin
		if(~rstn) begin
					pres<=s1; // go to state initial		
		end
		else begin
			      pres<= next; // go to the next state	

		end
end

//================================================================
// Always Block to change state 
//================================================================
always@(*) begin

		case (pres) // depending of the state, do the following
					
				s1: begin 
				
					if(init_in)
						next=s2;
					else
						next=s1;
				end	
				
				s2: begin 
				
					if(comp1_in)
						next=s3;
					else
						next=s4;
					
				end
				
				s3: begin 
					  
					if(comp2_in)
						next=s5;
					else
						next=s6;
				end
				
				s4: begin
                 next=s14;
            end
				
				s5: begin	
					next=s7;	
			
				end
				
				s6: begin
					next=s7;
						
				end
				
				s7: begin
					if(comp3_in)
						next=s11;
					else
						next=s8;	
				end
				
				s8: begin
					next=s9;	
				end
				
				s9: begin
					next=s10;	
				end
				
				s10: begin
					
					if(comp1_in)
						next=s3;
					else
						next=s4;		
				end
				
				s11: begin	
					next=s12;
				end
				
				s12: begin	
					next=s13;
				end
				
				s13: begin	
					
					if(comp3_in)
						next=s11;
					else
						next=s8;	
				end
            
            s14: begin
				
					if(~init_in)
						next=s1;
					else
						next=s14;	
				end
		endcase
end

//================================================================
// Always Block to manage outputs in each state
//================================================================


always @ (*) begin
addrZ_clr_out  = 1'b0;
addrZ_load_out = 1'b0;
done_out       = 1'b0;
addrY_clr_out  = 1'b0;
addrY_load_out = 1'b0;
addrX_load_out = 1'b0;
aux_clr_out    = 1'b0;
aux_load_out   = 1'b0;
sel_addrY_out  = 1'b0;
sel_addrX_out  = 2'b01;
readX_out      = 1'b0;
readY_out      = 1'b0;
writeZ_out     = 1'b0;
busy_out       = 1'b0;
		
	   case (pres)
				s1: begin 				
						addrZ_clr_out = 1'b1;
						sel_addrX_out = 2'b01;
				end	
				
				s2: begin 					
				end
				
				s3: begin 
						aux_clr_out = 1'b1;
                  busy_out  = 1'b1;

				end		
				s4: begin
						done_out  = 1'b1;
				end		
				s5: begin					
						addrY_clr_out  = 1'b1;
						addrX_load_out = 1'b1;						
						sel_addrX_out  = 2'b01;
                  busy_out  = 1'b1; 
				end
				s6: begin
				
						addrY_load_out = 1'b1;
						addrX_load_out = 1'b1;						
						sel_addrX_out  = 2'b10;	
                  busy_out  = 1'b1;
				end
						
				
				s7: begin
                 busy_out  = 1'b1;
				end
				
				s8: begin
						writeZ_out = 1'b1;
                  busy_out  = 1'b1;
				end
				
				s9: begin					
						addrZ_load_out = 1'b1;
                  busy_out  = 1'b1;
				end
				
				s10: begin
                 busy_out  = 1'b1;
					
				end
				
				s11: begin	
						readX_out = 1'b1;
						readY_out = 1'b1;	
                  busy_out  = 1'b1;
				end
				
				s12: begin	
						
						addrY_load_out = 1'b1;
						addrX_load_out = 1'b1;						
						sel_addrY_out  = 1'b1;
                  sel_addrX_out=2'b00;
                  busy_out  = 1'b1;
				end
				
				s13: begin				

						aux_load_out = 1'b1;	
                  busy_out  = 1'b1;
				end
            
            s14: begin
				end	
		endcase
end

endmodule