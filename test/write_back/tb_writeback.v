///==------------------------------------------------------------------==///
/// testbench of write back controller
///==------------------------------------------------------------------==///

`define BUF_DEPTH 8
`define BUF_ADDR_WIDTH 3
`define BUF_DATA_WIDTH 25
`define NUM_BUFF 5
`define OFM_C 1
`define OFM_H 10
`define OFM_W 8

module TEST_PSUM_BUFF();
    /// Connection between the buffer and write back controllers
    wire [`BUF_DATA_WIDTH-1:0] fifo_out[0:`NUM_BUFF-1];
    wire valid_fifo_out[0:`NUM_BUFF-1];
    wire p_write_zero[0:`NUM_BUFF-1];
    wire p_init, start_conv;

    /// Top level output
    wire [`BUF_DATA_WIDTH-1:0] out_port0, out_port1;
    wire port0_valid, port1_valid;

    /// Signals from lin's part
    reg [`BUF_DATA_WIDTH-1:0] pe00_data, pe10_data, pe20_data, pe30_data;
    reg [`BUF_DATA_WIDTH-1:0] pe01_data, pe11_data, pe21_data, pe31_data;
    reg [`BUF_DATA_WIDTH-1:0] pe02_data, pe12_data, pe22_data, pe32_data;
    reg [`BUF_DATA_WIDTH-1:0] pe03_data, pe13_data, pe23_data, pe33_data;
    reg [`BUF_DATA_WIDTH-1:0] pe04_data, pe14_data, pe24_data, pe34_data;
    reg p_filter_end, p_valid_data;

    /// Shared signals or from cpu
    reg clk, rst_n, start_init;

    WRITE_BACK #(
        .data_width(`BUF_DATA_WIDTH),
        .depth(`BUF_DEPTH)
    ) writeback_control (
        .clk(clk),
        .rst_n(rst_n),
        .start_init(start_init),
        .p_filter_end(p_filter_end),
        .row0(fifo_out[0]),
        .row0_valid(valid_fifo_out[0]),
        .row1(fifo_out[1]),
        .row1_valid(valid_fifo_out[1]),
        .row2(fifo_out[2]),
        .row2_valid(valid_fifo_out[2]),
        .row3(fifo_out[3]),
        .row3_valid(valid_fifo_out[3]),
        .row4(fifo_out[4]),
        .row4_valid(valid_fifo_out[4]),
        .p_write_zero0(p_write_zero[0]),
        .p_write_zero1(p_write_zero[1]),
        .p_write_zero2(p_write_zero[2]),
        .p_write_zero3(p_write_zero[3]),
        .p_write_zero4(p_write_zero[4]),
        .p_init(p_init),
        .out_port0(out_port0),
        .out_port1(out_port1),
        .port0_valid(port0_valid),
        .port1_valid(port1_valid),
        .start_conv(start_conv)
    );

    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff0 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[0]),
        .p_init(p_init),
        .pe0_data(pe00_data),
        .pe1_data(pe10_data),
        .pe2_data(pe20_data),
        .pe3_data(pe30_data),
        .fifo_out(fifo_out[0]),
        .valid_fifo_out(valid_fifo_out[0])
    );

    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff1 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[1]),
        .p_init(p_init),
        .pe0_data(pe01_data),
        .pe1_data(pe11_data),
        .pe2_data(pe21_data),
        .pe3_data(pe31_data),
        .fifo_out(fifo_out[1]),
        .valid_fifo_out(valid_fifo_out[1])
    );

    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff2 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[2]),
        .p_init(p_init),
        .pe0_data(pe02_data),
        .pe1_data(pe12_data),
        .pe2_data(pe22_data),
        .pe3_data(pe32_data),
        .fifo_out(fifo_out[2]),
        .valid_fifo_out(valid_fifo_out[2])
    );

    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff3 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[3]),
        .p_init(p_init),
        .pe0_data(pe03_data),
        .pe1_data(pe13_data),
        .pe2_data(pe23_data),
        .pe3_data(pe33_data),
        .fifo_out(fifo_out[3]),
        .valid_fifo_out(valid_fifo_out[3])
    );

    PSUM_BUFF #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) psum_buff4 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[4]),
        .p_init(p_init),
        .pe0_data(pe04_data),
        .pe1_data(pe14_data),
        .pe2_data(pe24_data),
        .pe3_data(pe34_data),
        .fifo_out(fifo_out[4]),
        .valid_fifo_out(valid_fifo_out[4])
    );

    // generate clock 
    initial begin 
        clk = 1'b0;
        #5  clk = 1'b1;
        forever #5 clk = ~clk;
    end

    /// push data task
    task push_data_buff;
        input signed [`BUF_DATA_WIDTH-1:0] data0;
        input signed [`BUF_DATA_WIDTH-1:0] data1;
        input signed [`BUF_DATA_WIDTH-1:0] data2;
        input signed [`BUF_DATA_WIDTH-1:0] data3;
        begin
            // $display("Push data to five buffers: ", data0, data1, data2, data3);
            pe00_data = data0;
            pe10_data = data1;
            pe20_data = data2;
            pe30_data = data3;

            pe01_data = data0;
            pe11_data = data1;
            pe21_data = data2;
            pe31_data = data3;

            pe02_data = data0;
            pe12_data = data1;
            pe22_data = data2;
            pe32_data = data3;

            pe03_data = data0;
            pe13_data = data1;
            pe23_data = data2;
            pe33_data = data3;

            pe04_data = data0;
            pe14_data = data1;
            pe24_data = data2;
            pe34_data = data3;
            p_valid_data = 1;
            @(posedge clk);
            #1 p_valid_data = 0;
        end
    endtask

    /// push data task
    task push_data_last;
        input signed [`BUF_DATA_WIDTH-1:0] data0;
        input signed [`BUF_DATA_WIDTH-1:0] data1;
        input signed [`BUF_DATA_WIDTH-1:0] data2;
        input signed [`BUF_DATA_WIDTH-1:0] data3;
        begin
            // $display("Push data to five buffers: ", data0, data1, data2, data3);
            pe00_data = data0;
            pe10_data = data1;
            pe20_data = data2;
            pe30_data = data3;

            pe01_data = data0;
            pe11_data = data1;
            pe21_data = data2;
            pe31_data = data3;

            pe02_data = data0;
            pe12_data = data1;
            pe22_data = data2;
            pe32_data = data3;

            pe03_data = data0;
            pe13_data = data1;
            pe23_data = data2;
            pe33_data = data3;

            pe04_data = data0;
            pe14_data = data1;
            pe24_data = data2;
            pe34_data = data3;
            p_valid_data = 1;
            p_filter_end = 1;
            @(posedge clk);
            #1 p_valid_data = 0;
            p_filter_end = 0;
        end
    endtask

    
    /// Write data to file
    integer fp_w;
    integer oc;
    integer oh;
    integer ow;
    reg stop_flag;
    
    task read_output;
        input [`BUF_DATA_WIDTH-1:0] port0;
        input [`BUF_DATA_WIDTH-1:0] port1;
        input port0_v;
        input port1_v;
        reg [`BUF_DATA_WIDTH-1:0] ofm [0:`OFM_C-1][0:`OFM_H-1][0:`OFM_W-1];
        integer toc;
        integer toh;
        integer tow;

        WRITE: begin 
            toc = 0;
            toh = 0;
            tow = 0;
            if (oc <= `OFM_C-1) begin
                if (port0_v && port1_v) begin
                    ofm[oc][oh][ow]   = port0;
                    ofm[oc][oh+1][ow] = port1;
                    ow = ow + 1;
                    if (ow == `OFM_W) begin
                        ow = 0;
                        oh = oh + 2;
                    end
                    if (oh == `OFM_H) begin
                        oh = 0;
                        oc = oc + 1;
                    end
                end else if (port0_v) begin
                    ofm[oc][oh][ow]   = port0;
                    ow = ow + 1;
                    if (ow == `OFM_W) begin
                        ow = 0;
                        oh = oh + 1;
                    end
                    if (oh == `OFM_H) begin
                        oh = 0;
                        oc = oc + 1;
                    end
                end
                stop_flag = 1'b1;
            end else begin
                if (stop_flag) begin
                    for (toc=0; toc < `OFM_C; toc = toc + 1) begin
                        for (toh=0; toh < `OFM_H; toh = toh + 1) begin
                            for (tow=0; tow < `OFM_W; tow = tow + 1) begin
                                $fwrite(fp_w, "%d ", ofm[toc][toh][tow]);
                                if (tow == `OFM_W-1) begin
                                    $fwrite(fp_w, "\n");
                                end
                            end
                        end
                    end
                    $display("\n[ConvKernel: ]: Finish writing results to conv_acc_out.txt");
                end
                stop_flag = 1'b0;
            end 
        end
    endtask

    integer i;
    integer j;
    initial begin
        rst_n     = 1;
        p_valid_data = 0;
        p_filter_end = 0;
        start_init = 0;
        {pe00_data, pe10_data, pe20_data, pe30_data} = 100'b0;
        {pe01_data, pe11_data, pe21_data, pe31_data} = 100'b0;
        {pe02_data, pe12_data, pe22_data, pe32_data} = 100'b0;
        {pe03_data, pe13_data, pe23_data, pe33_data} = 100'b0;
        {pe04_data, pe14_data, pe24_data, pe34_data} = 100'b0;
        #10 rst_n  = 0;
        #10 rst_n = 1;

        #10  start_init = 1;
        #10 start_init = 0;

        #100;
        @(posedge clk);
        #1
        push_data_buff(1,1,1,2);
        push_data_buff(1,2,2,2);
        push_data_buff(1,3,2,2);
        push_data_buff(1,4,2,2);
        push_data_buff(1,5,2,2);
        push_data_buff(1,6,2,2);
        push_data_buff(1,7,2,2);
        push_data_buff(1,8,2,2);

        #30 p_valid_data = 0;

        push_data_buff(1,1,1,2);
        push_data_buff(1,2,2,2);
        push_data_buff(1,3,2,2);
        push_data_buff(1,4,2,2);
        push_data_buff(1,5,2,2);
        push_data_buff(1,6,2,2);
        push_data_buff(1,7,2,2);
        push_data_buff(1,8,2,2);

        #30 p_valid_data = 0;

        push_data_last(1,1,1,2);
        push_data_last(1,2,2,2);
        push_data_last(1,3,2,2);
        push_data_last(1,4,2,2);
        push_data_last(1,5,2,2);
        push_data_last(1,6,2,2);
        push_data_last(1,7,2,2);
        push_data_last(1,8,2,2);

        @(posedge clk);
        #300 p_valid_data = 0;

        push_data_buff(1,1,1,2);
        push_data_buff(1,2,2,2);
        push_data_buff(1,3,2,2);
        push_data_buff(1,4,2,2);
        push_data_buff(1,5,2,2);
        push_data_buff(1,6,2,2);
        push_data_buff(1,7,2,2);
        push_data_buff(1,8,2,2);

        #30 p_valid_data = 0;

        push_data_buff(1,1,1,2);
        push_data_buff(1,2,2,2);
        push_data_buff(1,3,2,2);
        push_data_buff(1,4,2,2);
        push_data_buff(1,5,2,2);
        push_data_buff(1,6,2,2);
        push_data_buff(1,7,2,2);
        push_data_buff(1,8,2,2);

        #30 p_valid_data = 0;

        push_data_last(1,1,1,2);
        push_data_last(1,2,2,2);
        push_data_last(1,3,2,2);
        push_data_last(1,4,2,2);
        push_data_last(1,5,2,2);
        push_data_last(1,6,2,2);
        push_data_last(1,7,2,2);
        push_data_last(1,8,2,2);
    end

    initial WRITE:begin
        fp_w = $fopen("conv_acc_out.txt");
        ow = 0;
        oc = 0;
        oh = 0;
        stop_flag = 0;
        forever begin
            @(posedge clk);
            read_output(out_port0, out_port1, port0_valid, port1_valid);
        end
    end

    
endmodule