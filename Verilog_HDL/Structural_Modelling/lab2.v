/*
E/131/058 De silva M.D.R.A.M
E/13/181 Karunaratne S.L.B
*/


module stimulus;

reg clock,load,clear_bar;
reg[3:0] A_addr,B_addr,C_addr;
wire[15:0] A,B;
reg[15:0] C;


integer i,a,b; // 32 bit 

//the clock
initial
	clock = 1'b0;

always
	#5 clock = ~clock;
initial
	#1000 $finish;
// Instantiate the register file

Register_File reg_file(A_addr,B_addr,C_addr,C,load,clear_bar,clock,A,B);
initial
begin
//When load = 1,clear_bar = 0

clear_bar = 0;
load = 1'b1;

#1;

C_addr = 1;
C = 25;
B_addr = 1;
A_addr = 7;
#5 $display("C=%b C_addr= %b Aaddr[%b]= %b  Baddr[%b]= %b",C,C_addr,A_addr,A,B_addr,B);


C = 7;
C_addr = 8;
A_addr = 8;
clear_bar=1;
#10 $display("C=%b C_addr= %b Aaddr[%b]= %b Baddr[%b]= %b",C,C_addr,A_addr,A,B_addr,B);

C_addr=1;
C=25;
#10 $display("C=%b C_addr= %b Aaddr[%b]= %b Baddr[%b]= %b",C,C_addr,A_addr,A,B_addr,B);

clear_bar=0;
#10 $display("C=%b C_addr= %b Aaddr[%b]= %b Baddr[%b]= %b",C,C_addr,A_addr,A,B_addr,B);

end
	
endmodule


module Register_File(A_addr,B_addr,C_addr,C,load,clear_bar,clock,A,B);

input [3:0] C_addr,A_addr,B_addr;
input [15:0] C;
input load,clear_bar,clock;

output reg[15:0] A,B;
reg [15:0] register_file [15:0]; // An array of 16 registers each of 16 bits



integer i; 

// clear all registers
always @(clear_bar) 
begin
	if (clear_bar ==1'b0)
	begin
	
		for(i=0;i<16;i=i+1)
		begin
			register_file [i] = 0;
		end
	 
	end
end



//writing and reading from the register_file
always @(posedge clock)
begin
	
	if(load==1'b1 && clear_bar==1'b1)
	begin
		
		register_file [C_addr] = C; // 16 bits of data written to register_file
	end	
		
	
	A = register_file [A_addr];
		
	
	B = register_file [B_addr];
		
	
	
end

endmodule