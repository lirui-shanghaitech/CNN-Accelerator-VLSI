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
    input signed [data_width-1:0] pe0_data,
    input signed [data_width-1:0] pe1_data,
    input signed [data_width-1:0] pe2_data,
    input signed [data_width-1:0] pe3_data,
    output [data_width-1:0] fifo_out,
    output valid_fifo_out
);
    // wire [data_width-1:0] fifo_head;
    // reg  [data_width-1:0] fifo_head_reg;
    reg  [data_width-1:0] fifo_in;
    wire signed [data_width-1:0] adder_out;
    wire empty, full;
    reg fifo_rd_en;
    reg fifo_wr_en;
    /// Shifter register, there are four pipeline stages
    reg [3-1:0] p_valid;
    reg [3-1:0] p_write_zero_reg;

    /// Whether the output of current fifo output is valid
    assign valid_fifo_out = p_write_zero_reg;

    /// Fifo read and write
    /// When to write fifo
    /// Data that will be written to fifo
    always @(*) begin
        if (!rst_n) begin
            fifo_wr_en = 0;
            fifo_rd_en = 0;
            fifo_in = 0;
        end else if (p_init) begin
            fifo_wr_en = 1;
            fifo_rd_en = 0;
            fifo_in = 0;
        end else if (p_write_zero || p_write_zero_reg) begin
            fifo_wr_en = p_write_zero_reg;
            fifo_rd_en = p_write_zero;
            fifo_in = 0;
        end else begin
            fifo_wr_en = p_valid[2];
            fifo_rd_en = p_valid[0];
            fifo_in = adder_out;
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
        .fifo_data(fifo_out),
        .out(adder_out)
    );
    /// Synchronous fifo
    SYNCH_FIFO #(
        .data_width(data_width),
        .addr_width(addr_width),
        .depth(depth)
    ) synch_fifo (
        .clk(clk),
        .rd_en(fifo_rd_en),
        .wr_en(fifo_wr_en),
        .rst_n(rst_n),
        .empty(empty),
        .full(full),
        .data_out(fifo_out),
        .data_in(fifo_in)
    );

endmodule