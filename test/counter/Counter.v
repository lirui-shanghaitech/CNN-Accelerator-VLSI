/*************************************************************
*	Copyright(C) 2021 SHTU_VSP
*	    All right reserved
*
*	FILE NAME:  Counter.v
*	   AUTHOR:  Chaolin
*	     DATE:  2021-05-09 12:24:24
*	  Version:  
*
* ************************************************************
* DESCRIPTION:
*   
*	Module counter is a 4 bits counter count the number when
*	enable is set. The counter register is posedge triger.
* 
* 
* ***********************************************************/

module Counter(
    
    input enable,
    output [3:0] counter_out,
    input clk,
    input rst_n

);

    reg [3:0] cnt_R;

    always @(posedge clk or negedge rst_n)
    begin
	if(!rst_n)
	    cnt_R <= 'd0;
	else if(enable)
	    cnt_R <= cnt_R + 1'b1;
    end

    assign counter_out = cnt_R;


endmodule
