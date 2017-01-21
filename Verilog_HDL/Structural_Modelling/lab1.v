/*

E/13/181 S.L.B. KARUNARATHNE	
E/13/058 M.D.R.A.M. DE DILVA

*/

module stimulus_4;

	reg[3:0] in;
	wire[3:0] out;
	reg clock;


	initial
		clock = 1'b0;

	always
		#5 clock = ~clock;

	initial
		#45 $finish;

	reg s0,s1,en,l_shift,r_shift;

	SR_4 sr4(out,in,s0,s1,clock,en,l_shift,r_shift);

	//simulation of 4-bit shift register
	initial
	begin
		// set input lines
		in=4'b0100;
		en=1'b1;
		r_shift=1'b0;
		l_shift=1'b0;
		#1 $display("Clock=%b IN= %b\n",clock,in);
		// parallel
		s1 =1'b1 ;s0 =1'b1;
		#5 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n", clock,s1, s0, out);
		// shift right
		s1 =1'b0; s0 =1'b1;
		r_shift=1'b1;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n", clock,s1, s0, out);
		// shift left
		s1 =1'b1; s0 =1'b0;
		l_shift=1'b1;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n",clock, s1, s0, out);
		// hold
		s1 =1'b0; s0 =1'b0;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n",clock, s1, s0, out);
	end
	
endmodule

module stimulus_8;

	reg[7:0] in;
	wire[7:0] out;
	reg clock;


	initial
		clock = 1'b0;

	always
		#5 clock = ~clock;

	initial
		#45 $finish;

	reg s0,s1,en,l_shift,r_shift;

	SR_8 sr8(out,in,s0,s1,clock,en,l_shift,r_shift);

	//simulation of 4-bit shift register
	initial
	begin
		// set input lines
		in=8'b01101100;
		en=1'b1;
		r_shift=1'b0;
		l_shift=1'b0;
		#2 $display("Clock=%b IN= %b\n",clock,in);
		// parallel
		s1 =1'b1 ;s0 =1'b1;
		#5 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n", clock,s1, s0, out);
		// shift right
		s1 =1'b0; s0 =1'b1;
		r_shift=1'b1;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n", clock,s1, s0, out);
		// shift left
		s1 =1'b1; s0 =1'b0;
		l_shift=1'b1;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n",clock, s1, s0, out);
		// hold
		s1 =1'b0; s0 =1'b0;
		#10 $display("Clock=%b S1 = %b, S0 = %b, OUTPUT = %b \n",clock, s1, s0, out);
	end
	
endmodule


module SR_4(out, in, s0, s1,clk,en,l_shift,r_shift);
	
	input [3:0] in;
	input s0,s1,clk,en,l_shift,r_shift;
	output reg [3:0] out;

	always @(posedge clk)
	begin
		if(en==1'b1)
			begin
			if (s1==1'b1 && s0==1'b1)
				out<=in; 
			else if (s1==1'b0 && s0==1'b1)
				//shift right
				out <= {r_shift,out[3:1]}; 
			else if (s1==1'b1 && s0==1'b0)
				//shift_left
				out <= {out[2:0],l_shift}; 


			end
	end
	
endmodule



module SR_8(out, in, s0, s1,clk,en,l_shift,r_shift);

	input [7:0] in;
	input s0,s1,clk,en,l_shift,r_shift;
	output reg [7:0] out;

	wire[3:0] least=in[3:0];
	wire[3:0] most=in[7:4];
	wire[3:0] least1;
	wire[3:0] most1;



	SR_4 left(least1,least,s0,s1,clk,en,l_shift,in[4]);
	SR_4 right(most1,most,s0,s1,clk,en,in[4],r_shift);

	always
		#1 out<={most1,least1};

endmodule
