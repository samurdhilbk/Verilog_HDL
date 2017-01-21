
/*CO224 Project :Processor design
E/13/181
E/13/058
Group No: 4
*/

/*processor : Handles branch and jump instructions and manouver through the indexes of the instructions.
*/
module processor(bne,bne_offset,reg_out_1,reg_out_2);
  
reg clock;

initial
begin
	clock = 1'b0;
	
end	

always
	#5 clock = ~clock; //rise of a positive edge every 10 seconds




//inputs coming from the control module output
input[15:0] reg_out_1;
input[15:0] reg_out_2;
//To keep current instruction
reg [15:0] curr_instr;

reg[15:0] instruction;
reg[15:0] ALU,Memory;

reg writ_en;

reg signed [11:0] offset;

input bne;
input signed [3:0] bne_offset;
reg [3:0] opcode;

reg [15:0] instr [0:100];

reg enable;

reg b;

integer num;

/*INSTRUCTION Structure
R type: rd,rt,rs,opcode (all has 4 bits each)
load/store : offset,rt,rs,opcode (all has 4 biuts each)
branch :offset,rt,rs,opcode
jump : offset(12bits),opcode 

opcode list
 ADD   2
 SUB   6
 AND   0
 OR    1
 SLT   7
 BNE	 14
 LW    8
 SW   10
 JUMP 15 */

initial
begin
/**
r2=0;

here:;
r2=r2+2;
if(r2!=20) goto here;

goto end;
r2=r2+2;
end:;
r2=r2-2;

*/
b=1'b0;
instr[0]=16'b0001000000001010; //str[r0,#1],r0 
instr[1]=16'b0001001000001000; //ldr r2,[r0,#1]
instr[2]=16'b0010001000110010; //r2=r2+r3;(r2=r2+2)
instr[3]=16'b1111001001001110; //Bne r2,r4 offset -1
instr[4]=16'b0000000000101111; //jmp 2
instr[5]=16'b0010001000110010; //r2=r2+r3;(r2=r2+2)
instr[6]=16'b0010001000110110; //r2=r2-r3;(r2=r2-2)

num=7;

end

//Instantiating the control module
control con(clock,instruction,enable,bne,bne_offset,reg_out_1,reg_out_2);


integer curr_index=0;
 
always @(posedge clock) //happens at positive edge of the clock
begin

if(b==1'b1 && bne==1'b1)
begin
 #3;
 if(reg_out_1!=reg_out_2) //condition for bne
 begin
 $display("one=%b two=%b off=%d %0t",reg_out_1,reg_out_2,bne_offset,$time);
 curr_index=curr_index+bne_offset; // to go to the required branch address
 end
 else 
 begin
 $display("one=%b two=%b off=%d %0t",reg_out_1,reg_out_2,bne_offset,$time);
 curr_index=curr_index+1; //no branching,go to the next instruction in line
 end
 b=1'b0;
 
end

else

begin

if(curr_index<num)
begin
	curr_instr=instr[curr_index];
	
	opcode=curr_instr[3:0]; // get the opcode bits of the instruction
	
	$display("instruction %b %0t",curr_instr,$time);
	if(opcode==4'b1110)  //opcode condition for branch
	begin
	  instruction=curr_instr;
	  b=1'b1;
	  enable=1'b1;	
	end
	else if(opcode==4'b1111) //opcode conditoin for jump
	begin
	#4; // time kept to avoid hazards
	  enable=1'b0;
	  offset=curr_instr[15:4]; //retrieve the offset bits
	
	  curr_index=curr_index+offset; //jumps to the required jump location
	end
	else
	  //if opcode isnt jump or branch
	begin
	  instruction=curr_instr;
	  enable=1'b1;
	  //if(opcode>=0 && opcode <8) writ_en=1'b1; 
	  //else writ_en=1'b0;
	  curr_index=curr_index+1;
	end
	

end
else 
  // if all the instructions has been run then enable is set to 0 and process is finished.
begin
enable=1'b0;	
#3 $finish;

end

end
	
end
  
 
endmodule

/* data memory : Used by load/store instructions to either store or retrieve data form the memory.
                 A memory of 32 registers (each having 16 bits)

*/


module data_memory(clock,reg_value,offset,write_val,write,load,A);

input [15:0] reg_value,write_val;
input [3:0] offset;// indidcates by how much relative to somepoint in memory it can go.

input load,clock,write;


reg[3:0] Read_add,Write_add;

output reg[15:0] A; //return the value.(used by load instructions.)
reg [15:0] memory [31:0]; // An array of 32 registers each of 16 bits

reg[5:0] loc;// register to identify the location in memory.

initial
begin

memory[1]=16'b0000000000001101; // test value added to load.
end

//writing and reading from the memory
always @(posedge clock)
begin

	
	
	#4; // time kept to avoid hazards.
	loc=reg_value+offset; // gives the required memory location
	
	
	if(write==1'b1) //condition for store instructoins.write should be enabled.
	begin

	$display("write_val %b loc=%b %0t",write_val,loc,$time);
	memory [loc] = write_val; // 16 bits of data written to memory
	end
	
	if(load==1'b1) //condition for laod instructions.load should be enabled.
	begin

	A = memory [loc];
	$display("load_val %b loc=%b %0t",A,loc,$time);
	end
			
	
end


endmodule


/* Register_File: Have 16 registers each having 16 bits.
                  Used to retrive values as well as write values to the register file.
                  
*/

module Register_File(clock,A_addr,B_addr,C_addr,C_alu,C_mem,write,alu_enable,mem_enable,A,B);

input [3:0] C_addr,A_addr,B_addr; //write adress and input addresses.
input [15:0] C_alu,C_mem;         //values to be wrttien comming from alu and data memory.
input clock,write,alu_enable,mem_enable; // control lines 

reg Write,Alu_enable,Mem_enable;

reg[3:0] write_addr;

output reg[15:0] A,B;
reg [15:0] register_file [15:0]; // An array of 16 registers each of 16 bits

//pre loaded instructions in reg file for use.
initial
begin
register_file[0]=16'b0000000000000000;
register_file[3]=16'b0000000000000010;
register_file[4]=16'b0000000000010100;
end

initial
begin
Write=1'b0;
Alu_enable=1'b0;
end

always @alu_enable
$display("%0t",$time);
//at postive edge register values are saved to some registers for use.
always @(posedge clock)
begin
Write=write;
Alu_enable=alu_enable;
Mem_enable=mem_enable;
write_addr=C_addr;
end


//writing and reading from the register_file
always @(posedge clock)
begin
	
	
	#2;//time kept to avoid hazards.
	
	
	
	
	if(Write==1'b1) //wirte back is enabled.
	
	begin
	
	if(Alu_enable==1'b1) // value written to reg file is coming from ALU
	begin
	$display("alu_out addr=%b %b %0t",write_addr,C_alu,$time);
	register_file [write_addr] = C_alu; 
	end
	
	if(Mem_enable==1'b1)//value written to reg file is coming from Data memory
	begin
	$display("mem_out=%b write_addr=%b %0t",C_mem,write_addr,$time);
	register_file [write_addr] = C_mem;
	end
	
	end
	
	#1; // getting output values for input reg adresses.
	A = register_file [A_addr];
			
	B = register_file [B_addr];
	
	
		
	
	
end

endmodule





/*
control : checks the input instruction and sets neccessary control lines for modules data memory,alu,registerfile and proccessor.
        
*/


module control(clock,instruction,enable,bne,bne_offset,reg_out_1,reg_out_2);

input clock,enable;

input [15:0] instruction;

output reg bne;

output reg [3:0] bne_offset;
output reg [15:0] reg_out_1,reg_out_2;

reg [3:0] Alu_Op;
reg [3:0] Read_Reg1,Read_Reg2,Write_Reg ;

reg [3:0]  offset;
reg [15:0] Write_value;

reg[15:0] reg_value;
wire[15:0] alu_out,mem_out;
wire[15:0] 	A,B;


reg write,load,write_reg;


reg Alu_enable,write_enable,mem_enable;

wire writ_enn;


// instantiating the modules
Register_File reg_file(clock,Read_Reg1,Read_Reg2,Write_Reg,alu_out,mem_out,write_reg,Alu_enable,mem_enable,A,B);
ALU alu(clock,Alu_Op,A,B,Alu_enable,alu_out);
data_memory datamem (clock,B,offset,A,write,load,mem_out);


initial 
begin
bne=1'b0;

end

always @(posedge clock) // at postive edge sets A,B as outputs,which are sent to proecssor inputs.
begin

reg_out_1 = A;
reg_out_2 = B;



#1;

if(enable==1'b1)
begin

//breaks the instruction and put them to neccesary registers.
Alu_Op = instruction[3:0];
Read_Reg2 = instruction[7:4];
Read_Reg1 = instruction[11:8];
Write_Reg = instruction[15:12];
offset = instruction[15:12];
bne_offset = instruction[15:12];
bne=1'b0;
write=1'b0;
load=1'b0;




//op code is a Alu operation
if (Alu_Op>0 && Alu_Op <8)
begin
Alu_enable=1'b1;
write_reg=1'b1;
mem_enable=1'b0;
end
else if (Alu_Op == 8) //load word opcode handling
begin
Alu_enable=1'b0;
load=1'b1;
write=1'b0;
Write_Reg=instruction[11:8];
mem_enable=1'b1;

write_reg=1'b1;
end
else if( Alu_Op == 10 )//store word opcode handling
begin
Alu_enable=1'b0;

write=1'b1;
load=1'b0;
mem_enable=1'b0;
end
else if (Alu_Op==4'b1110)//bne opcode handling
begin
bne=1'b1;
write_reg=1'b0;
write=1'b0;
load=1'b0;
end



end
end

endmodule

/*
ALU : checks the opcode and selects the required operation and executes it and outputs the write value which will be wirtten to the register file.

*/

module ALU(clock,Alu_Op,A,B,Alu_enable,Write_value);


input clock,Alu_enable;
input [15:0] A,B; //register values used for operation.
input [3:0] Alu_Op;

output reg [15:0] Write_value;

parameter ADD      = 4'd2;
parameter SUB      = 4'd6;
parameter AND      = 4'd0;
parameter OR       = 4'd1;
parameter SLT      = 4'd7;



    

always @(posedge clock)
begin


#4;


if(Alu_enable==1'b1)
begin

case (Alu_Op)

ADD:
begin
$display("ADD %b %b %0t",A,B,$time);
Write_value = A+B;
end

SUB:
begin
$display("SUB %b %b %0t",A,B,$time);
Write_value = A-B;
end

AND:
begin
Write_value = A && B;
end


OR:
begin
Write_value = A || B;
end

SLT:
begin
if(B>A)
Write_value = 1;
else
Write_value = 0;
end

endcase

end

end

endmodule
