///==------------------------------------------------------------------==///
/// Conv kernel: synchronous FIFO
///==------------------------------------------------------------------==///
/// Synchronous FIFO
module SYNCH_FIFO #(
    parameter data_width = 25,
    parameter addr_width = 8,
    parameter depth      = 61
) (
    /// Control signal
    input clk,
    input rd_en,
    input wr_en,
    input rst_n,
    /// status signal
    output empty,
    output full,
    /// data signal
    output reg [data_width-1:0] data_out,
    input [data_width-1:0] data_in
);
    reg [addr_width:0] cnt;
    reg [data_width-1:0] fifo_mem [0:depth-1];
    reg [addr_width-1:0] rd_ptr;
    reg [addr_width-1:0] wr_ptr;
    /// Status generation
    assign empty = (cnt == 0);
    assign full  = (cnt == depth);
    /// Updata read pointer && Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr   <= 0;
        else if (rd_en && !empty) begin
            if (rd_ptr == depth-1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr + 1;
        end else 
            rd_ptr <= rd_ptr;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_out <= 0;
        else if (rd_en && !empty)
            data_out <= fifo_mem[rd_ptr];
    end
    /// Update write pointer && write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en  && !full) begin
            if (wr_ptr == depth-1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr + 1;
        end else 
            wr_ptr <= wr_ptr;
    end

    always @(posedge clk) begin
        if (wr_en  & ~full)
            fifo_mem[wr_ptr] = data_in;
    end
    /// Update the counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= 0;
        else begin
            case ({wr_en, rd_en})
                2'b00: cnt <= cnt;
                2'b01: cnt <= !empty ? cnt-1 : cnt;
                2'b10: cnt <= !full  ? cnt+1 : cnt;
                2'b11: cnt <= cnt;
            endcase
        end
    end
endmodule