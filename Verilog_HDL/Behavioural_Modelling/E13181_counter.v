//Lab 8 : 4-bit Counter implementation in verilog

// Top level stimulus module
module testbed;

	// Declare variables for stimulating input
	reg CLK, CLEAR_BAR;
	wire [3:0] NUM;
	
	initial
		$monitor($time," Count : %d",NUM);
		
	//Instantiate the design block counter	
	//NUM is the 4-bit output from the counter
	//CLK is the clock signal
	//The counter should increment at each falling edge of the clock cycle 
	//CLEAR_BAR is the signal that asynchronously clears the counter. A CLEAR_BAR=0 should clear the counter.
	rippleCounter4 mycounter(NUM,CLK,CLEAR_BAR);	
		
	// reset	
	initial
	begin	
		CLEAR_BAR=1'b0;	
		#5 CLEAR_BAR=1'b1;
		#500 CLEAR_BAR=1'b0;
		#50 CLEAR_BAR=1'b1;
	end		
		
	// Set up the clock to toggle every 10 time units	
	initial
	begin
		
		//generate files needed to plot the waveform
		//you can plot the waveform generated after running the simulator by using gtkwave	
		$dumpfile("wavedata.vcd");
		$dumpvars(0,testbed);	
		CLK = 1'b0;
		forever #10 CLK = ~CLK;
		
		
	end

	// Finish the simulation at time 400
	initial
	begin
		#700 $finish;
	end
	
endmodule


//you code goes here

//SR latch with reset
module SR_latch(Q,S,R,reset);

input S,R,reset;
output Q;

wire w;

//configure the NAND gates
nand (Q,S,w);
nand (w,R,reset,Q);

endmodule

//D latch with reset
module D_latch(Q,D,E,reset);

input D,E,reset;
output Q;

wire [2:0] w;

not (w[0],D);
nand (w[1],D,E);
nand (w[2],w[0],E);

//setup the SR latch
SR_latch s(Q,w[1],w[2],reset);

endmodule

//D flip-flop with reset
module D_flip_flop(Q,D,C,reset);

input D,C,reset;	//C is the clock
output Q;

wire [1:0] w;

not (w[0],C);

//set-up the master and slave
D_latch master(w[1],D,C,reset);
D_latch slave(Q,w[1],w[0],reset);

endmodule


//T flip-flop with reset 
module T_flip_flop(Q,T,C,reset);

input T,C,reset;	//C is the clock
output Q;

wire w;

xor (w,T,Q);

D_flip_flop d(Q,w,C,reset);

endmodule

//ripple up counter with reset
module rippleCounter4(NUM,CLK,CLEAR_BAR);

input CLK,CLEAR_BAR;
output [3:0] NUM;

//set up the array of T flip-flops wih T set to high 
T_flip_flop t1(NUM[0],1'b1,CLK,CLEAR_BAR);
T_flip_flop t2(NUM[1],1'b1,NUM[0],CLEAR_BAR);
T_flip_flop t3(NUM[2],1'b1,NUM[1],CLEAR_BAR);
T_flip_flop t4(NUM[3],1'b1,NUM[2],CLEAR_BAR);

endmodule
