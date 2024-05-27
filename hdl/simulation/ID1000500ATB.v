`timescale 1ns/1ns

module ID1000500ATB();

            //----------------------------------------------------------
            //.......MANDATORY TB PARAMETERS............................
            //----------------------------------------------------------
localparam	CYCLE		    = 'd20, // Define the clock work cycle in ns (user)
            DATAWIDTH    = 'd32, // AIP BITWIDTH
            MAX_SIZE_MEM = 'd6,  // MAX MEMORY SIZE AMONG ALL AIP MEMORIES (Defined by the user)
            //------------------------------------------------------------
            //..................CONFIG VALUES.............................
            //------------------------------------------------------------           
            STATUS   = 5'd30,//Mandatory config
            IP_ID    = 5'd31,//Mandatory config
            MemX	 = 5'd0, // Config values defined in the CSV file
            AddrX	 = 5'd1,
			MdataY	 = 5'd2,
			AdataY	 = 5'd3,
            MemZ	 = 5'd4,
            AdrrZ	 = 5'd5,
            size    = 5'd6,
            Addrsize    = 5'd7,
            //------------------------------------------------------------
            //..................PARAMETERS DEFINED BY THE USER............
            //------------------------------------------------------------
            SIZE_MEMX    = 'd10,
			SIZE_MEMY	 = 'd5,
			SIZE_MEMZ	 = 'd15,	
			SIZE_CONFIG	 = 10'hAA,
            INT_BIT_DONE = 'd0; //Bit corresponding to the Int Done flag.
            


//AIP Interface signals
reg			 readAIP;
reg			 writeAIP;
reg			 startAIP;
reg	[ 4:0] configAIP;
reg	[DATAWIDTH-1:0] dataInAIP;

wire		    intAIP;
wire	[DATAWIDTH-1:0] dataOutAIP;

reg   clk, rst_a, en_s;

//Clock source procedural block
always #(CYCLE/2) clk = !clk;


//DUT instance
ID1000500A_convolution
DUT
(
    .clk		(clk),
    .rst_a		(rst_a),
    .en_s		(en_s),
    .data_in	(dataInAIP),      //different data in information types
    .data_out	(dataOutAIP),     //different data out information types
    .write		(writeAIP),       //Used for protocol to write different information types
    .read		(readAIP),        //Used for protocol to read different information types
    .start		(startAIP),       //Used to start the IP core
    .conf_dbus	(configAIP),      //Used for protocol to determine different actions types
    .int_req	(intAIP)          //Interruption request
);

//Testbench stimulus
initial
   begin
      $display($time, " << Start Simulation >>");
      
      aipReset();  
      convolution_task();
      
      $display($time, " << End Simulation >>");
      $stop;      
   end

task convolution_task;
   //variables   
   //Auxiliar variables
   reg [DATAWIDTH-1:0] tb_data;

   reg [DATAWIDTH-1:0] dataSet0 [SIZE_MEMX-1:0];
   reg [(DATAWIDTH*SIZE_MEMX)-1:0] dataSet_packed0;
   
   reg [DATAWIDTH-1:0] dataSet1 [SIZE_MEMY-1:0];
   reg [(DATAWIDTH*SIZE_MEMY)-1:0] dataSet_packed1;

   reg [DATAWIDTH-1:0] result [SIZE_MEMZ-1:0];
   reg [(DATAWIDTH*SIZE_MEMZ)-1:0] result_packed;
   
   integer i;
   begin
        // READ IP_ID
        getID(tb_data);
        $display ("%7T Read ID %h", $time, tb_data);
        
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);
        
        //(INTERRUPTIONS) 
        //FOR ENABLING INTERRUPTIONS
        enableINT(INT_BIT_DONE);
        

        // DATA X GENERATION
		dataSet0[0] = 8'h01;
		dataSet0[1] = 8'h02;
		dataSet0[2] = 8'h03;
		dataSet0[3] = 8'h04;
		dataSet0[4] = 8'h03;
		dataSet0[5] = 8'h07;
		dataSet0[6] = 8'h06;
		dataSet0[7] = 8'h0A;
		dataSet0[8] = 8'h05;
		dataSet0[9] = 8'h08;
		   
        
        //****CONVERTION TO A SINGLE ARRAY
        for (i = 0; i < (SIZE_MEMX) ; i=i+1) begin 
            dataSet_packed0[DATAWIDTH*i+:DATAWIDTH] = dataSet0[i]; 
        end

		// DATA X GENERATION
		dataSet1[0] = 8'h03;
		dataSet1[1] = 8'h03;
		dataSet1[2] = 8'h05;
		dataSet1[3] = 8'h06;
		dataSet1[4] = 8'h07;   
        
        //****CONVERTION TO A SINGLE ARRAY
        for (i = 0; i < (SIZE_MEMY) ; i=i+1) begin 
            dataSet_packed1[DATAWIDTH*i+:DATAWIDTH] = dataSet1[i]; 
        end             
        
        writeMem(MemX, dataSet_packed0, SIZE_MEMX,0);
		writeMem(MemY, dataSet_packed1, SIZE_MEMY,0);
        
        //CONVOLUTION CONFIGURATION
        tb_data[9:0] = SIZE_CONFIG;
        
        writeConfReg(Csize,tb_data,1,0);

        // START PROCESS
        $display("%7T Sending start", $time);
        start();

        /*// (WITHOUT INTERRUPTIONS) 
        //WAIT FOR DONE FLAG WITHOUT INTERRUPTS ENABLED
        tb_data = 0;
        while (!tb_data[0]) begin//checking bit DONE
            getStatus(tb_data);
            $display("%7T Status - %08x", $time, tb_data);
            #(CYCLE*10);
        end 
        //(WITHOUT INTERRUPTIONS)*/
        
        // (INTERRUPTIONS) 
        // WAIT FOR DONE FLAG WITH INTERRUPTIONS ENABLED     
        while (intAIP) begin//checking intAIP signal
            #(CYCLE*10);
        end
        // (INTERRUPTIONS)  
        
        $display("%7T Done flag detected!", $time);
        
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);
        
        //CLEAR INT DONE FLAG
        clearINT(INT_BIT_DONE);
        
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);     


        // READ MEM OUT
        readMem(MdataZ, result_packed, SIZE_MEMZ, 0);
        //*****CONVERTION TO A 2D ARRAY
        for (i = 0; i < (SIZE_MEMZ) ; i=i+1) begin 
            result[i]= result_packed[DATAWIDTH*i+:DATAWIDTH]; 
        end
        
        $display ("\t\tI \t\tI \t\tResult");
        for (i = 0; i < SIZE_MEMZ; i=i+1) begin
            //read_interface(MDATAOUT, tb_data);
            $display ("Read data %2d \t%8h \t%8h \t%8h", i, dataSet0[i], dataSet1[i], result[i]);
        end
        
        // DISABLE INTERRUPTIONS
        disableINT(INT_BIT_DONE);

        #(CYCLE*15);
   
   end

endtask

//*******************************************************************
//*********************AIP TASKS DEFINITION**************************
//*******************************************************************

task aipReset;
   begin
      clk		= 1'b1;
      en_s		= 1'b1;
      readAIP	= 1'b0;
      writeAIP	= 1'b0;
      startAIP	= 1'b0;
      configAIP= 5'd0;
      dataInAIP= 32'd0;
      
      rst_a		= 1'b0;	// reset is active
      #3 rst_a	= 1'b1;	// at time #n release reset
      #37;
   end
endtask


task getID;
   output [DATAWIDTH-1:0] read_ID;
      
      begin
         single_read(IP_ID,read_ID);
      end
endtask

task getStatus;
   output [DATAWIDTH-1:0] read_status;
      
      begin
         single_read(STATUS,read_status);
      end
endtask

task writeMem;
        input [                         4:0] config_value;
        input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;

      integer i;
        begin        
            //SET POINTER
            single_write(config_value+1, offset);
            
            //WRITE MEMORY
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin
               dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
               writeAIP = 1'b1;
               #(CYCLE);
            end
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask

task writeConfReg;
        input [                         4:0] config_value;
        input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;
        
        integer i;
        begin        
            //SET POINTER
            single_write(config_value+1, offset);
            
            //WRITE MEMORY
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin
               dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
               writeAIP = 1'b1;
               #(CYCLE);
            end
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask



task readMem;
        input [                         4:0] config_value;   
        output[(DATAWIDTH*MAX_SIZE_MEM)-1:0] read_data;     
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;        
        
        integer i;
        begin
            //SET POINTER
            single_write(config_value+1, offset);
        
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin               
               readAIP = 1'b1;
               #(CYCLE);
               read_data[(i*DATAWIDTH)+:DATAWIDTH]=dataOutAIP;
            end
            readAIP = 1'b0;
            #(CYCLE);
        end
endtask

task enableINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] mask;
       
  begin

       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       mask[idxInt] = 1'b1; //enabling INT bit

       single_write(STATUS, {8'd0,mask,16'd0});//write status reg
  end
endtask

task disableINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] mask;
  begin
   
       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       mask[idxInt] = 1'b0; //disabling INT bit

       single_write(STATUS, {8'd0,mask,16'd0});//write status reg
  end
endtask

task clearINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] clear_value;
       reg [7:0] mask;
    
  begin
    
       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       clear_value = 7'd1 <<  idxInt;

       single_write(STATUS, {8'd0,mask,8'd0,clear_value});//write status reg
  end
endtask

task start;
  begin
      startAIP = 1'b1;
      #(CYCLE);
      startAIP = 1'b0;
      #(CYCLE);
  end
endtask

task single_write;
        input [          4:0] config_value;
        input [DATAWIDTH-1:0] write_data;
        begin
            configAIP = config_value;
            dataInAIP = write_data;
            #(CYCLE)
            writeAIP = 1'b1;
            #(CYCLE)
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask

task single_read;
  input  [          4:0] config_value;
  output [DATAWIDTH-1:0] read_data;
  begin
      configAIP = config_value;
      #(CYCLE);
      readAIP = 1'b1;
      #(CYCLE);
      read_data = dataOutAIP;
      readAIP = 1'b0;
      #(CYCLE);
  end
endtask

endmodule
