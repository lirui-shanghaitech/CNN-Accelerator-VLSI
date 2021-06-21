///==------------------------------------------------------------------==///
/// Conv kernel: writeback controller
///==------------------------------------------------------------------==///
module WRITE_BACK #(
    parameter data_width = 25,
    parameter depth = 61
) (
    input  clk,
    input  rst_n,
    input  start_init,
    input  p_filter_end,
    input  [data_width-1:0] row0,
    input  row0_valid,
    input  [data_width-1:0] row1,
    input  row1_valid,
    input  [data_width-1:0] row2,
    input  row2_valid,
    input  [data_width-1:0] row3,
    input  row3_valid,
    input  [data_width-1:0] row4,
    input  row4_valid,
    output p_write_zero0,
    output p_write_zero1,
    output p_write_zero2,
    output p_write_zero3,
    output p_write_zero4,
    output p_init,
    output [data_width-1:0] out_port0,
    output [data_width-1:0] out_port1,
    output port0_valid,
    output port1_valid,
    output start_conv
);
    /// machine state encode
    localparam IDLE         = 4'b0000;
    localparam INIT_BUFF    = 4'b0001;
    localparam START_CONV   = 4'b0010;
    localparam WAIT_ADD     = 4'b0011;
    localparam ROW_0_1      = 4'b0100;
    localparam CLEAR_0_1    = 4'b0101;
    localparam ROW_2_3      = 4'b0110;
    localparam CLEAR_2_3    = 4'b0111;
    localparam ROW_5        = 4'b1000;
    localparam CLEAR_START_CONV = 4'b1001;
    localparam CLEAR_CNT    = 4'b1010;
    // localparam DONE         = 4'b1001;
    /// machine state
    reg [3:0] st_next;
    reg [3:0] st_cur;
    reg [7:0] cnt;
    /// State transfer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            st_cur <= IDLE;
        else 
            st_cur <= st_next;
    end
    /// Next state logic
    always @(*) begin
        st_next = st_cur;
        case(st_cur)
            IDLE:
                if (start_init)
                    st_next = INIT_BUFF;
                else
                    st_next = IDLE;
            INIT_BUFF:
                if (cnt == depth-1)
                    st_next = START_CONV;
                else
                    st_next = INIT_BUFF;
            START_CONV:
                if (cnt >= depth+2)
                    st_next = CLEAR_START_CONV;
                else 
                    st_next = START_CONV;
            CLEAR_START_CONV:
                if (p_filter_end)
                    st_next = WAIT_ADD;
                else
                    st_next = CLEAR_START_CONV;
            WAIT_ADD:
                if (cnt == depth-1)
                    st_next = CLEAR_CNT;
                else
                    st_next = WAIT_ADD;
            CLEAR_CNT:
                st_next = ROW_0_1;
            ROW_0_1:
                if (cnt == depth-1)
                    st_next = CLEAR_0_1;
                else
                    st_next = ROW_0_1;
            CLEAR_0_1:
                st_next = ROW_2_3;
            ROW_2_3:
                if (cnt == depth-1)
                    st_next = CLEAR_2_3;
                else
                    st_next = ROW_2_3;
            CLEAR_2_3:
                st_next = ROW_5;
            ROW_5:
                if (cnt == depth-1)
                    st_next = START_CONV;
                else
                    st_next = ROW_5;
            // DONE:
            //     st_next = START_CONV;
            default:
                st_next = IDLE;  
        endcase
    end
    /// Output logic
    reg p_write_zero0_r;
    reg p_write_zero1_r;
    reg p_write_zero2_r;
    reg p_write_zero3_r;
    reg p_write_zero4_r;
    reg p_init_r;
    reg [data_width-1:0] out_port0_r;
    reg [data_width-1:0] out_port1_r;
    reg port0_valid_r;
    reg port1_valid_r;
    reg start_conv_r;
    /// Output start conv signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            start_conv_r <= 0;
        else if (st_cur == START_CONV)
            start_conv_r <= 1;
        else
            start_conv_r <= 0;
    end
    assign start_conv = start_conv_r;
    /// Output zero flag signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_write_zero0_r <= 0;
            p_write_zero1_r <= 0;
        end else if (st_cur == ROW_0_1) begin
            p_write_zero0_r <= 1;  
            p_write_zero1_r <= 1;
        end else begin
            p_write_zero0_r <= 0;
            p_write_zero1_r <= 0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_write_zero2_r <= 0;
            p_write_zero3_r <= 0;
        end else if (st_cur == ROW_2_3) begin
            p_write_zero2_r <= 1;  
            p_write_zero3_r <= 1;
        end else begin
            p_write_zero2_r <= 0;
            p_write_zero3_r <= 0;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_write_zero4_r <= 0;
        end else if (st_cur == ROW_5) begin
            p_write_zero4_r <= 1;  
        end else begin
            p_write_zero4_r <= 0;
        end
    end
    assign p_write_zero0 = p_write_zero0_r;
    assign p_write_zero1 = p_write_zero1_r;
    assign p_write_zero2 = p_write_zero2_r;
    assign p_write_zero3 = p_write_zero3_r;
    assign p_write_zero4 = p_write_zero4_r;   
    /// Init buffer signal, why this signal? since, at the beginning, the buffer is empty, we only need to
    /// push zero to buffer without read from it, this behaviour is difference from p_write_zerox signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            p_init_r <= 0;
        else if (st_cur == INIT_BUFF)
            p_init_r <= 1;
        else
            p_init_r <= 0;
    end
    assign p_init = p_init_r;
    /// Update the cnt
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= 0;
        else if (st_cur == IDLE || st_cur == CLEAR_0_1  || st_cur == CLEAR_START_CONV
            || st_cur == CLEAR_2_3 || st_cur == CLEAR_CNT)
            cnt <= 0;
        else 
            cnt <= cnt + 1;
    end
    /// Final result, a big mux
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_port0_r <= 0;
            out_port1_r <= 0;
            port0_valid_r <= 0;
            port1_valid_r <= 0;
        end else begin
            case({row0_valid, row1_valid, row2_valid, row3_valid, row4_valid})
                5'b11000 : begin
                    out_port0_r <= row0;
                    out_port1_r <= row1;
                    port0_valid_r <= row0_valid;
                    port1_valid_r <= row1_valid;
                end
                5'b00110 : begin
                    out_port0_r <= row2;
                    out_port1_r <= row3;
                    port0_valid_r <= row2_valid;
                    port1_valid_r <= row3_valid;
                end
                5'b00001 : begin
                    out_port0_r <= row4;
                    out_port1_r <= 0;
                    port0_valid_r <= row4_valid;
                    port1_valid_r <= 0;
                end
                default : begin
                    out_port0_r <= 0;
                    out_port1_r <= 0;
                    port0_valid_r <= 0;
                    port1_valid_r <= 0;
                end    
            endcase
        end
    end
    assign out_port0 = out_port0_r;
    assign out_port1 = out_port1_r;
    assign port0_valid = port0_valid_r;
    assign port1_valid = port1_valid_r;
endmodule
