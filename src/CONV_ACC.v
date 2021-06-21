///==------------------------------------------------------------------==///
/// Conv kernel: top level module
///==------------------------------------------------------------------==///

module CONV_ACC #(
    parameter out_data_width = 25,
    parameter buf_addr_width = 5,
    parameter buf_depth      = 16
) (
    input  clk,
    input  rst_n,
    input  start_conv,
    input  [1:0] cfg_ci,
    input  [1:0] cfg_co,
    input  [63:0] ifm,
    input  [31:0] weight,
    output [24:0] ofm_port0,
    output [24:0] ofm_port1,
    output ofm_port0_v,
    output ofm_port1_v,
    output ifm_read,
    output wgt_read,
    output end_conv
);

    /// Assign ifm to each pes
    reg [7:0] rows [0:7];
    always @(*) begin
        rows[0] = ifm[7:0];
        rows[1] = ifm[15:8];
        rows[2] = ifm[23:16];
        rows[3] = ifm[31:24];
        rows[4] = ifm[39:32];
        rows[5] = ifm[47:40];
        rows[6] = ifm[55:48];
        rows[7] = ifm[63:56];
        // {rows[0], rows[1], rows[2], rows[3], rows[4], rows[5], rows[6], rows[7]} = 
        //     {ifm[7:0], ifm[15:8], ifm[23:16], ifm[31:24], ifm[39:32], ifm[47:40], ifm[55:48], ifm[63:56]};
    end
    /// Assign weight to each pes
    reg [7:0] wgts [0:3];
    always @(*) begin
        wgts[0] = weight[7:0];
        wgts[1] = weight[15:8];
        wgts[2] = weight[23:16];
        wgts[3] = weight[31:24];

        // {wgts[0], wgts[1], wgts[2], wgts[3]} = {weight[7:0], weight[15:8], weight[23:16], weight[31:24]};
    end

    ///==-------------------------------------------------------------------------------------==
    /// Connect between PE and PE_FSM
    wire ifm_read_en;
    wire wgt_read_en;
    assign ifm_read = ifm_read_en;
    assign wgt_read = wgt_read_en;
    /// Connection between PEs+PE_FSM and WRITEBACK+BUFF
    wire [out_data_width-1:0] pe00_data, pe10_data, pe20_data, pe30_data;
    wire [out_data_width-1:0] pe01_data, pe11_data, pe21_data, pe31_data;
    wire [out_data_width-1:0] pe02_data, pe12_data, pe22_data, pe32_data;
    wire [out_data_width-1:0] pe03_data, pe13_data, pe23_data, pe33_data;
    wire [out_data_width-1:0] pe04_data, pe14_data, pe24_data, pe34_data;
    wire p_filter_end, p_valid_data, start_again;
    /// PE FSM
    PE_FSM pe_fsm ( .clk(clk), .rst_n(rst_n), .start_conv(start_conv), .start_again(start_again), .cfg_ci(cfg_ci), .cfg_co(cfg_co), 
            .ifm_read(ifm_read_en), .wgt_read(wgt_read_en), .p_valid_output(p_valid_data), 
            .last_chanel_output(p_filter_end), .end_conv(end_conv) );  
    
    /// PE Array
    /// wgt0 row0 pe00 pe01 pe02 pe03 pe04
    /// wgt1 row1 pe10 pe11 pe12 pe13 pe14
    /// wgt2 row2 pe20 pe21 pe22 pe23 pe24
    /// wgt3      pe30 pe31 pe32 pe33 pe34
    ///      row3      row4 row5 row6 row7

    /// First row
    wire [7:0] ifm_buf00, ifm_buf01, ifm_buf02, ifm_buf03;
    wire [7:0] ifm_buf10, ifm_buf11, ifm_buf12, ifm_buf13;
    wire [7:0] ifm_buf20, ifm_buf21, ifm_buf22, ifm_buf23;
    wire [7:0] ifm_buf30, ifm_buf31, ifm_buf32, ifm_buf33;
    wire [7:0] ifm_buf40, ifm_buf41, ifm_buf42, ifm_buf43;
    wire [7:0] ifm_buf50, ifm_buf51, ifm_buf52, ifm_buf53;
    wire [7:0] ifm_buf60, ifm_buf61, ifm_buf62, ifm_buf63;
    wire [7:0] ifm_buf70, ifm_buf71, ifm_buf72, ifm_buf73;

	wire [7:0] wgt_buf00, wgt_buf01, wgt_buf02, wgt_buf03;
	wire [7:0] wgt_buf10, wgt_buf11, wgt_buf12, wgt_buf13;
	wire [7:0] wgt_buf20, wgt_buf21, wgt_buf22, wgt_buf23;
	wire [7:0] wgt_buf30, wgt_buf31, wgt_buf32, wgt_buf33;



	IFM_BUF ifm_buf0( .clk(clk), .rst_n(rst_n), .ifm_input(rows[0]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf00), .ifm_buf1(ifm_buf01), .ifm_buf2(ifm_buf02), .ifm_buf3(ifm_buf03));
	IFM_BUF ifm_buf1( .clk(clk), .rst_n(rst_n), .ifm_input(rows[1]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf10), .ifm_buf1(ifm_buf11), .ifm_buf2(ifm_buf12), .ifm_buf3(ifm_buf13));
	IFM_BUF ifm_buf2( .clk(clk), .rst_n(rst_n), .ifm_input(rows[2]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf20), .ifm_buf1(ifm_buf21), .ifm_buf2(ifm_buf22), .ifm_buf3(ifm_buf23));
	IFM_BUF ifm_buf3( .clk(clk), .rst_n(rst_n), .ifm_input(rows[3]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf30), .ifm_buf1(ifm_buf31), .ifm_buf2(ifm_buf32), .ifm_buf3(ifm_buf33));
	IFM_BUF ifm_buf4( .clk(clk), .rst_n(rst_n), .ifm_input(rows[4]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf40), .ifm_buf1(ifm_buf41), .ifm_buf2(ifm_buf42), .ifm_buf3(ifm_buf43));
	IFM_BUF ifm_buf5( .clk(clk), .rst_n(rst_n), .ifm_input(rows[5]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf50), .ifm_buf1(ifm_buf51), .ifm_buf2(ifm_buf52), .ifm_buf3(ifm_buf53));
	IFM_BUF ifm_buf6( .clk(clk), .rst_n(rst_n), .ifm_input(rows[6]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf60), .ifm_buf1(ifm_buf61), .ifm_buf2(ifm_buf62), .ifm_buf3(ifm_buf63));
	IFM_BUF ifm_buf7( .clk(clk), .rst_n(rst_n), .ifm_input(rows[7]), .ifm_read(ifm_read_en), 
	.ifm_buf0(ifm_buf70), .ifm_buf1(ifm_buf71), .ifm_buf2(ifm_buf72), .ifm_buf3(ifm_buf73));

	WGT_BUF wgt_buf0( .clk(clk), .rst_n(rst_n), .wgt_input(wgts[0]), .wgt_read(wgt_read_en), 
	.wgt_buf0(wgt_buf00), .wgt_buf1(wgt_buf01), .wgt_buf2(wgt_buf02), .wgt_buf3(wgt_buf03));
	WGT_BUF wgt_buf1( .clk(clk), .rst_n(rst_n), .wgt_input(wgts[1]), .wgt_read(wgt_read_en), 
	.wgt_buf0(wgt_buf10), .wgt_buf1(wgt_buf11), .wgt_buf2(wgt_buf12), .wgt_buf3(wgt_buf13));
	WGT_BUF wgt_buf2( .clk(clk), .rst_n(rst_n), .wgt_input(wgts[2]), .wgt_read(wgt_read_en), 
	.wgt_buf0(wgt_buf20), .wgt_buf1(wgt_buf21), .wgt_buf2(wgt_buf22), .wgt_buf3(wgt_buf23));
	WGT_BUF wgt_buf3( .clk(clk), .rst_n(rst_n), .wgt_input(wgts[3]), .wgt_read(wgt_read_en), 
	.wgt_buf0(wgt_buf30), .wgt_buf1(wgt_buf31), .wgt_buf2(wgt_buf32), .wgt_buf3(wgt_buf33));
    
	PE pe00( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf00), .ifm_input1(ifm_buf01), .ifm_input2(ifm_buf02), .ifm_input3(ifm_buf03), 
	.wgt_input0(wgt_buf00), .wgt_input1(wgt_buf01), .wgt_input2(wgt_buf02), .wgt_input3(wgt_buf03), .p_sum(pe00_data) );
	PE pe01( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf10), .ifm_input1(ifm_buf11), .ifm_input2(ifm_buf12), .ifm_input3(ifm_buf13), 
	.wgt_input0(wgt_buf00), .wgt_input1(wgt_buf01), .wgt_input2(wgt_buf02), .wgt_input3(wgt_buf03), .p_sum(pe01_data) );
	PE pe02( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf20), .ifm_input1(ifm_buf21), .ifm_input2(ifm_buf22), .ifm_input3(ifm_buf23), 
	.wgt_input0(wgt_buf00), .wgt_input1(wgt_buf01), .wgt_input2(wgt_buf02), .wgt_input3(wgt_buf03), .p_sum(pe02_data) );
	PE pe03( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf30), .ifm_input1(ifm_buf31), .ifm_input2(ifm_buf32), .ifm_input3(ifm_buf33), 
	.wgt_input0(wgt_buf00), .wgt_input1(wgt_buf01), .wgt_input2(wgt_buf02), .wgt_input3(wgt_buf03), .p_sum(pe03_data) );
	PE pe04( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf40), .ifm_input1(ifm_buf41), .ifm_input2(ifm_buf42), .ifm_input3(ifm_buf43), 
	.wgt_input0(wgt_buf00), .wgt_input1(wgt_buf01), .wgt_input2(wgt_buf02), .wgt_input3(wgt_buf03), .p_sum(pe04_data) );


	PE pe10( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf10), .ifm_input1(ifm_buf11), .ifm_input2(ifm_buf12), .ifm_input3(ifm_buf13), 
	.wgt_input0(wgt_buf10), .wgt_input1(wgt_buf11), .wgt_input2(wgt_buf12), .wgt_input3(wgt_buf13), .p_sum(pe10_data) );
	PE pe11( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf20), .ifm_input1(ifm_buf21), .ifm_input2(ifm_buf22), .ifm_input3(ifm_buf23), 
	.wgt_input0(wgt_buf10), .wgt_input1(wgt_buf11), .wgt_input2(wgt_buf12), .wgt_input3(wgt_buf13), .p_sum(pe11_data) );
	PE pe12( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf30), .ifm_input1(ifm_buf31), .ifm_input2(ifm_buf32), .ifm_input3(ifm_buf33), 
	.wgt_input0(wgt_buf10), .wgt_input1(wgt_buf11), .wgt_input2(wgt_buf12), .wgt_input3(wgt_buf13), .p_sum(pe12_data) );
	PE pe13( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf40), .ifm_input1(ifm_buf41), .ifm_input2(ifm_buf42), .ifm_input3(ifm_buf43), 
	.wgt_input0(wgt_buf10), .wgt_input1(wgt_buf11), .wgt_input2(wgt_buf12), .wgt_input3(wgt_buf13), .p_sum(pe13_data) );
	PE pe14( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf50), .ifm_input1(ifm_buf51), .ifm_input2(ifm_buf52), .ifm_input3(ifm_buf53), 
	.wgt_input0(wgt_buf10), .wgt_input1(wgt_buf11), .wgt_input2(wgt_buf12), .wgt_input3(wgt_buf13), .p_sum(pe14_data) );


	PE pe20( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf20), .ifm_input1(ifm_buf21), .ifm_input2(ifm_buf22), .ifm_input3(ifm_buf23), 
	.wgt_input0(wgt_buf20), .wgt_input1(wgt_buf21), .wgt_input2(wgt_buf22), .wgt_input3(wgt_buf23), .p_sum(pe20_data) );
	PE pe21( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf30), .ifm_input1(ifm_buf31), .ifm_input2(ifm_buf32), .ifm_input3(ifm_buf33), 
	.wgt_input0(wgt_buf20), .wgt_input1(wgt_buf21), .wgt_input2(wgt_buf22), .wgt_input3(wgt_buf23), .p_sum(pe21_data) );
	PE pe22( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf40), .ifm_input1(ifm_buf41), .ifm_input2(ifm_buf42), .ifm_input3(ifm_buf43), 
	.wgt_input0(wgt_buf20), .wgt_input1(wgt_buf21), .wgt_input2(wgt_buf22), .wgt_input3(wgt_buf23), .p_sum(pe22_data) );
	PE pe23( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf50), .ifm_input1(ifm_buf51), .ifm_input2(ifm_buf52), .ifm_input3(ifm_buf53), 
	.wgt_input0(wgt_buf20), .wgt_input1(wgt_buf21), .wgt_input2(wgt_buf22), .wgt_input3(wgt_buf23), .p_sum(pe23_data) );
	PE pe24( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf60), .ifm_input1(ifm_buf61), .ifm_input2(ifm_buf62), .ifm_input3(ifm_buf63), 
	.wgt_input0(wgt_buf20), .wgt_input1(wgt_buf21), .wgt_input2(wgt_buf22), .wgt_input3(wgt_buf23), .p_sum(pe24_data) );


	PE pe30( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf30), .ifm_input1(ifm_buf31), .ifm_input2(ifm_buf32), .ifm_input3(ifm_buf33), 
	.wgt_input0(wgt_buf30), .wgt_input1(wgt_buf31), .wgt_input2(wgt_buf32), .wgt_input3(wgt_buf33), .p_sum(pe30_data) );
	PE pe31( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf40), .ifm_input1(ifm_buf41), .ifm_input2(ifm_buf42), .ifm_input3(ifm_buf43), 
	.wgt_input0(wgt_buf30), .wgt_input1(wgt_buf31), .wgt_input2(wgt_buf32), .wgt_input3(wgt_buf33), .p_sum(pe31_data) );
	PE pe32( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf50), .ifm_input1(ifm_buf51), .ifm_input2(ifm_buf52), .ifm_input3(ifm_buf53), 
	.wgt_input0(wgt_buf30), .wgt_input1(wgt_buf31), .wgt_input2(wgt_buf32), .wgt_input3(wgt_buf33), .p_sum(pe32_data) );
	PE pe33( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf60), .ifm_input1(ifm_buf61), .ifm_input2(ifm_buf62), .ifm_input3(ifm_buf63), 
	.wgt_input0(wgt_buf30), .wgt_input1(wgt_buf31), .wgt_input2(wgt_buf32), .wgt_input3(wgt_buf33), .p_sum(pe33_data) );
	PE pe34( .clk(clk), .rst_n(rst_n), .ifm_input0(ifm_buf70), .ifm_input1(ifm_buf71), .ifm_input2(ifm_buf72), .ifm_input3(ifm_buf73), 
	.wgt_input0(wgt_buf30), .wgt_input1(wgt_buf31), .wgt_input2(wgt_buf32), .wgt_input3(wgt_buf33), .p_sum(pe34_data) );	

    ///==-------------------------------------------------------------------------------------==
    /// Connection between the buffer and write back controllers
    wire [out_data_width-1:0] fifo_out[0:4];
    wire valid_fifo_out[0:4];
    wire p_write_zero[0:4];
    wire p_init;
    wire odd_cnt;

    /// Write back controller
    WRITE_BACK #(
        .data_width(out_data_width),
        .depth(buf_depth)
    ) writeback_control (
        .clk(clk),
        .rst_n(rst_n),
        .start_init(start_conv),
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
        .out_port0(ofm_port0),
        .out_port1(ofm_port1),
        .port0_valid(ofm_port0_v),
        .port1_valid(ofm_port1_v),
        .start_conv(start_again),
        .odd_cnt(odd_cnt)
    );
    
    /// Buffer
    PSUM_BUFF #(
        .data_width(out_data_width),
        .addr_width(buf_addr_width),
        .depth(buf_depth)
    ) psum_buff0 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[0]),
        .p_init(p_init),
        .odd_cnt(odd_cnt),
        .pe0_data(pe00_data),
        .pe1_data(pe10_data),
        .pe2_data(pe20_data),
        .pe3_data(pe30_data),
        .fifo_out(fifo_out[0]),
        .valid_fifo_out(valid_fifo_out[0])
    );

    PSUM_BUFF #(
        .data_width(out_data_width),
        .addr_width(buf_addr_width),
        .depth(buf_depth)
    ) psum_buff1 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[1]),
        .p_init(p_init),
        .odd_cnt(odd_cnt),
        .pe0_data(pe01_data),
        .pe1_data(pe11_data),
        .pe2_data(pe21_data),
        .pe3_data(pe31_data),
        .fifo_out(fifo_out[1]),
        .valid_fifo_out(valid_fifo_out[1])
    );

    PSUM_BUFF #(
        .data_width(out_data_width),
        .addr_width(buf_addr_width),
        .depth(buf_depth)
    ) psum_buff2 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[2]),
        .p_init(p_init),
        .odd_cnt(odd_cnt),
        .pe0_data(pe02_data),
        .pe1_data(pe12_data),
        .pe2_data(pe22_data),
        .pe3_data(pe32_data),
        .fifo_out(fifo_out[2]),
        .valid_fifo_out(valid_fifo_out[2])
    );

    PSUM_BUFF #(
        .data_width(out_data_width),
        .addr_width(buf_addr_width),
        .depth(buf_depth)
    ) psum_buff3 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[3]),
        .p_init(p_init),
        .odd_cnt(odd_cnt),
        .pe0_data(pe03_data),
        .pe1_data(pe13_data),
        .pe2_data(pe23_data),
        .pe3_data(pe33_data),
        .fifo_out(fifo_out[3]),
        .valid_fifo_out(valid_fifo_out[3])
    );

    PSUM_BUFF #(
        .data_width(out_data_width),
        .addr_width(buf_addr_width),
        .depth(buf_depth)
    ) psum_buff4 (
        .clk(clk),
        .rst_n(rst_n),
        .p_valid_data(p_valid_data),
        .p_write_zero(p_write_zero[4]),
        .p_init(p_init),
        .odd_cnt(odd_cnt),
        .pe0_data(pe04_data),
        .pe1_data(pe14_data),
        .pe2_data(pe24_data),
        .pe3_data(pe34_data),
        .fifo_out(fifo_out[4]),
        .valid_fifo_out(valid_fifo_out[4])
    );

endmodule //CONV_ACC