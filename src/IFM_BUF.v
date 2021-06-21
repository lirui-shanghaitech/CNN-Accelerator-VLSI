module IFM_BUF (clk, rst_n, ifm_input, ifm_read, ifm_buf0, ifm_buf1, ifm_buf2, ifm_buf3);

input clk;
input rst_n;
input signed [7:0] ifm_input;
input ifm_read;
output signed [7:0] ifm_buf0;
output signed [7:0] ifm_buf1;
output signed [7:0] ifm_buf2;
output signed [7:0] ifm_buf3;

reg signed [7:0] ifm_buf [3:0];

integer i;

always @(posedge clk or negedge rst_n) 
    if (~rst_n) 
    begin
        for(i = 0; i < 4; i = i + 1) 
        begin
            ifm_buf[i] <= 0;
        end
    end
    else
    begin
        if(ifm_read)
        begin
            ifm_buf[3] <= ifm_buf[2];
            ifm_buf[2] <= ifm_buf[1];
            ifm_buf[1] <= ifm_buf[0];
            ifm_buf[0] <= ifm_input;
        end
        else 
        begin
            ifm_buf[3] <= ifm_buf[3];
            ifm_buf[2] <= ifm_buf[2];
            ifm_buf[1] <= ifm_buf[1];
            ifm_buf[0] <= ifm_buf[0];
        end
    end

assign ifm_buf0 = ifm_buf[0];
assign ifm_buf1 = ifm_buf[1];
assign ifm_buf2 = ifm_buf[2];
assign ifm_buf3 = ifm_buf[3];

endmodule 