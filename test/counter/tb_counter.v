/*************************************************************
*	Copyright(C) 2021 SHTU_VSP
*	    All right reserved
*
*	FILE NAME:  tb_counter.v
*	   AUTHOR:  Chaolin
*	     DATE:  2021-05-09 12:28:44
*	  Version:  
*
* ************************************************************
* DESCRIPTION:
* 
*	This is a testbench for module counter.
* 
* ***********************************************************/

module tb_counter();

    reg clk;
    reg rst_n;
    reg enable;
    wire [3:0] counter_tb;

    Counter dut(.enable(enable), .counter_out(counter_tb), .clk(clk), .rst_n(rst_n));



    // generate clock 
    initial begin 
	#5  clk = 1'b1;
	forever #5 clk = ~clk;
    end

    task check_count; 
	begin 
	    @(negedge clk);
	    $display("Checking counter %0d at %0t", counter_tb, $time);
	end
    endtask


    initial begin 
	#1  rst_n = 1'b1;
	enable = 0;
	#22 $display("Begin to reset the counter @%0t", $time);
	rst_n = 1'b0;
	@(posedge clk);
	@(negedge clk);
	$display("Checking the counter after reset @%0t", $time);
	$display("Counter suppose is 0 and we get %0d from dut", counter_tb);
	repeat(5) @(posedge clk);
	#0 rst_n = 1'b1;
	$display("Disable reset @%0t", $time);
	repeat(5) @(posedge clk);
	#0 enable = 1'b1;
	$display("Setting the enable signal @%0t", $time);
	$display("checking the counter for 20 cycle:");
	repeat(20) check_count;
	@(negedge clk);
	#0  enable = 1'b0;
	$display("Disable the enable signal @%0t", $time);
	$display("checking the counter for 10 cycle:");
	repeat(10) check_count;
	#20 $finish;
    end


endmodule
