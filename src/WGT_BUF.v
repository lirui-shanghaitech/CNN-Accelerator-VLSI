module WGT_BUF (clk, rst_n, wgt_input, wgt_read, wgt_buf0, wgt_buf1, wgt_buf2, wgt_buf3);

input clk;
input rst_n;
input signed [7:0] wgt_input;
input wgt_read;
output signed [7:0] wgt_buf0;
output signed [7:0] wgt_buf1;
output signed [7:0] wgt_buf2;
output signed [7:0] wgt_buf3;

reg signed [7:0] wgt_buf [3:0];


integer i;

always @(posedge clk or negedge rst_n) 
    if (~rst_n) 
    begin
        for(i = 0; i < 4; i = i + 1) 
        begin
            wgt_buf[i] <= 0;
        end
    end
    else
    begin
        if(wgt_read)
        begin
            wgt_buf[3] <= wgt_buf[2];
            wgt_buf[2] <= wgt_buf[1];
            wgt_buf[1] <= wgt_buf[0];
            wgt_buf[0] <= wgt_input;
        end
        else
        begin
            wgt_buf[3] <= wgt_buf[3];
            wgt_buf[2] <= wgt_buf[2];
            wgt_buf[1] <= wgt_buf[1];
            wgt_buf[0] <= wgt_buf[0];
        end
    end

    assign wgt_buf0 = wgt_buf[0];
    assign wgt_buf1 = wgt_buf[1];
    assign wgt_buf2 = wgt_buf[2];
    assign wgt_buf3 = wgt_buf[3];

endmodule 