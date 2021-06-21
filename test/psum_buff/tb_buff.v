///==------------------------------------------------------------------==///
/// testbench of psum buffer
///==------------------------------------------------------------------==///

`define BUF_DEPTH 8
`define BUF_ADDR_WIDTH 3
`define BUF_DATA_WIDTH 25

module TEST_PSUM_BUFF();
    reg clk;
    reg rst_n, p_valid_data, p_write_zero, p_init;
    reg signed  [`BUF_DATA_WIDTH-1:0] pe0_data;
    reg signed  [`BUF_DATA_WIDTH-1:0] pe1_data;
    reg signed  [`BUF_DATA_WIDTH-1:0] pe2_data;
    reg signed  [`BUF_DATA_WIDTH-1:0] pe3_data;
    wire signed [`BUF_DATA_WIDTH-1:0] fifo_out;
    reg signed  [`BUF_DATA_WIDTH-1:0] temp;
    wire valid_fifo_out;


    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero),
        .p_init(p_init),
        .pe0_data(pe0_data),
        .pe1_data(pe1_data),
        .pe2_data(pe2_data),
        .pe3_data(pe3_data),
        .fifo_out(fifo_out),
        .valid_fifo_out(valid_fifo_out)
    );

    // generate clock 
    initial begin 
        #5  clk = 1'b1;
        forever #5 clk = ~clk;
    end
    /// Write zero task
    task write_zero;
        output signed [`BUF_DATA_WIDTH-1:0] out;
        begin
            p_init = 1;
            @(posedge clk);
            out = fifo_out;
            $display("Current fifo head: ", out);
            #1 p_init = 0;
        end
    endtask

    /// Write zero task
    task write_zero_filter;
        output signed [`BUF_DATA_WIDTH-1:0] out;
        begin
            p_write_zero = 1;
            @(posedge clk);
            out = fifo_out;
            $display("Current fifo head: ", out);
            #1 p_write_zero = 0;
        end
    endtask

    /// push data task
    task push_data;
        input signed [`BUF_DATA_WIDTH-1:0] data0;
        input signed [`BUF_DATA_WIDTH-1:0] data1;
        input signed [`BUF_DATA_WIDTH-1:0] data2;
        input signed [`BUF_DATA_WIDTH-1:0] data3;
        begin
            $display("Push data: ", data0, data1, data2, data3);
            pe0_data = data0;
            pe1_data = data1;
            pe2_data = data2;
            pe3_data = data3;
            p_valid_data = 1;
            @(posedge clk);
            #1 p_valid_data = 0;
        end
    endtask

    integer i;
    integer j;
    initial begin
        rst_n     = 1;
        p_valid_data = 0;
        p_write_zero = 0;
        p_init = 0;
        pe0_data = 0;
        pe1_data = 0;
        pe2_data = 0;
        pe3_data = 0;

        #5 rst_n  = 0;
        #10 rst_n = 1;

        write_zero(temp);
        write_zero(temp);
        write_zero(temp);
        write_zero(temp);
        write_zero(temp);
        write_zero(temp);
        write_zero(temp);
        write_zero(temp);

        push_data(1,1,1,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,2,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,3,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,4,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,5,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,6,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,7,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,8,2,2);
        $display("Current fifo head is: ", fifo_out);

        #30 p_valid_data = 0;

        push_data(1,1,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,2,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,3,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,4,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,5,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,6,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,7,2,2);
        $display("Current fifo head is: ", fifo_out);
        push_data(1,8,2,2);
        $display("Current fifo head is: ", fifo_out);

        #30 p_valid_data = 0;

        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
        write_zero_filter(temp);
    end

endmodule