///==------------------------------------------------------------------==///
/// Conv kernel: partial sum buffer
///==------------------------------------------------------------------==///
module PSUM_BUFF #(
    parameter data_width = 25,
    parameter addr_width = 8,
    parameter depth      = 61
) (
    input clk,
    input rst_n,
    input p_valid_data,
    input p_write_zero,
    input p_init,
    input odd_cnt,
    input signed [data_width-1:0] pe0_data,
    input signed [data_width-1:0] pe1_data,
    input signed [data_width-1:0] pe2_data,
    input signed [data_width-1:0] pe3_data,
    output [data_width-1:0] fifo_out,
    output valid_fifo_out
);
    // wire [data_width-1:0] fifo_head;
    // reg  [data_width-1:0] fifo_head_reg;
    reg  [data_width-1:0] fifo_in0;
    reg  [data_width-1:0] fifo_in1;

    wire signed [data_width-1:0] adder_out;
    wire empty0, full0;
    wire empty1, full1;

    reg fifo_rd_en0;
    reg fifo_wr_en0;
    reg fifo_rd_en1;
    reg fifo_wr_en1;
    /// delayed odd_cnt
    reg d_odd_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            d_odd_cnt <= 0;
        else 
            d_odd_cnt <= odd_cnt;
    end

    /// Shifter register, there are four pipeline stages
    reg [3-1:0] p_valid;
    reg [3-1:0] p_write_zero_reg;

    reg [data_width-1:0] fifo_out_i;
    reg [data_width-1:0] fifo_out_a;
    wire [data_width-1:0] fifo_out_i0;
    wire [data_width-1:0] fifo_out_i1;

    always @(*) begin
        if (!rst_n) begin
            fifo_out_i = 0;
            fifo_out_a = 0;
        end else if (~d_odd_cnt) begin
            fifo_out_i = fifo_out_i1;
            fifo_out_a = fifo_out_i0;
        end else begin
            fifo_out_i = fifo_out_i0;
            fifo_out_a = fifo_out_i1;
        end
    end

    /// Whether the output of current fifo output is valid
    assign valid_fifo_out = p_write_zero_reg;

    /// Relu Operation
    assign fifo_out = fifo_out_i[data_width-1] ? 0 : fifo_out_i;

    /// Fifo read and write
    /// When to write fifo
    /// Data that will be written to fifo
    wire write_zero;
    assign write_zero = p_write_zero || p_write_zero_reg;
    always @(*) begin
        if (!rst_n) begin
            fifo_rd_en0 = 0;
            fifo_wr_en0 = 0;
            fifo_rd_en1 = 0;
            fifo_wr_en1 = 0;
            fifo_in0 = 0;
            fifo_in1 = 0;
        end else if (p_init) begin
            fifo_rd_en0 = 0;
            fifo_wr_en0 = 1;
            fifo_rd_en1 = 0;
            fifo_wr_en1 = 1;
            fifo_in0 = 0;
            fifo_in1 = 0;
        end else if (write_zero & d_odd_cnt) begin
            fifo_rd_en0 = p_write_zero;
            fifo_wr_en0 = p_write_zero_reg;
            fifo_rd_en1 = p_valid[0];
            fifo_wr_en1 = p_valid[2];
            fifo_in0 = 0;
            fifo_in1 = adder_out;
        end else if (write_zero & ~d_odd_cnt) begin
            fifo_rd_en1 = p_write_zero;
            fifo_wr_en1 = p_write_zero_reg;
            fifo_rd_en0 = p_valid[0];
            fifo_wr_en0 = p_valid[2];
            fifo_in1 = 0;
            fifo_in0 = adder_out;
        end else if (~d_odd_cnt & ~write_zero) begin
            fifo_rd_en1 = 0;
            fifo_wr_en1 = 0;
            fifo_rd_en0 = p_valid[0];
            fifo_wr_en0 = p_valid[2];
            fifo_in1 = 0;
            fifo_in0 = adder_out;
        end else if (d_odd_cnt & ~write_zero) begin
            fifo_rd_en0 = 0;
            fifo_wr_en0 = 0;
            fifo_rd_en1 = p_valid[0];
            fifo_wr_en1 = p_valid[2];
            fifo_in0 = 0;
            fifo_in1 = adder_out;
        end else begin
            fifo_rd_en0 = 0;
            fifo_wr_en0 = 0;
            fifo_rd_en1 = 0;
            fifo_wr_en1 = 0;
            fifo_in0 = 0;
            fifo_in1 = 0;
        end
    end
    /// Whether the current input is valid data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            p_valid <= 3'b0;
        else 
            p_valid <= {p_valid[1:0], p_valid_data};
    end
    /// Whether the current write zero is valid data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            p_write_zero_reg <= 1'b0;
        else 
            p_write_zero_reg <= p_write_zero;
    end
    /// Adder tree
    PSUM_ADD #(.data_width(data_width)) adder_tree (
        .clk(clk),
        .rst_n(rst_n),
        .pe0_data(pe0_data),
        .pe1_data(pe1_data),
        .pe2_data(pe2_data),
        .pe3_data(pe3_data),
        .fifo_data(fifo_out_a),
        .out(adder_out)
    );
    /// Synchronous fifo
    SYNCH_FIFO #(
        .data_width(data_width),
        .addr_width(addr_width),
        .depth(depth)
    ) synch_fifo0 (
        .clk(clk),
        .rd_en(fifo_rd_en0),
        .wr_en(fifo_wr_en0),
        .rst_n(rst_n),
        .empty(empty0),
        .full(full0),
        .data_out(fifo_out_i0),
        .data_in(fifo_in0)
    );

    /// Synchronous fifo
    SYNCH_FIFO #(
        .data_width(data_width),
        .addr_width(addr_width),
        .depth(depth)
    ) synch_fifo1 (
        .clk(clk),
        .rd_en(fifo_rd_en1),
        .wr_en(fifo_wr_en1),
        .rst_n(rst_n),
        .empty(empty1),
        .full(full1),
        .data_out(fifo_out_i1),
        .data_in(fifo_in1)
    );

endmodule