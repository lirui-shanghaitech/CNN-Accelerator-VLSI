///==------------------------------------------------------------------==///
/// testbench of top level conv kernel
///==------------------------------------------------------------------==///
`define CI 0
`define CO 0
`define TI 16
`define TI_FACTOR 64/`TI
`define CFG_CI (`CI+1)*8
`define CFG_CO (`CO+1)*8
`define IFM_LEN `CFG_CI*(`TI+3)*`TI_FACTOR*13*8
`define WGT_LEN 4*4*`CFG_CI*`CFG_CO*13*`TI_FACTOR
`define BUF_DEPTH 61
`define OFM_C `CFG_CO
`define OFM_H `BUF_DEPTH
`define OFM_W `BUF_DEPTH
`define OUT_DATA_WIDTH 25

module tb_conv ();

    reg clk, rst_n, start_conv;
    reg [1:0] cfg_ci;
    reg [1:0] cfg_co;
    wire [63:0] ifm;
    reg  [63:0] ifm_r;
    wire [31:0] weight;
    reg [31:0] wgt_r;
    wire[24:0] ofm_port0;
    wire[24:0] ofm_port1;
    wire ofm_port0_v, ofm_port1_v, ifm_read, wgt_read, end_conv;

    reg [32:0] ifm_cnt;
    reg [32:0] wgt_cnt;

    /// Store weight and ifm
    reg [7:0] ifm_in [0:`IFM_LEN-1];
    reg [7:0] wgt_in [0:`WGT_LEN-1];

    CONV_ACC #(
        .out_data_width(`OUT_DATA_WIDTH),
        .buf_addr_width(5),
        .buf_depth(`TI)
    ) conv_acc (
        .clk(clk),
        .rst_n(rst_n),
        .start_conv(start_conv),
        .cfg_ci(cfg_ci),
        .cfg_co(cfg_co),
        .ifm(ifm),
        .weight(weight),
        .ofm_port0(ofm_port0),
        .ofm_port1(ofm_port1),
        .ofm_port0_v(ofm_port0_v),
        .ofm_port1_v(ofm_port1_v),
        .ifm_read(ifm_read),
        .wgt_read(wgt_read),
        .end_conv(end_conv)
    );

    /// Ifm dispatcher
    initial begin
        $readmemb("./ifm.txt", ifm_in);
    end

    always @(*) begin
        if (!rst_n) begin
            ifm_r = 0;
        end else if (ifm_read) begin
            ifm_r[7:0]   = ifm_in[ifm_cnt+0];
            ifm_r[15:8]  = ifm_in[ifm_cnt+1];
            ifm_r[23:16] = ifm_in[ifm_cnt+2];
            ifm_r[31:24] = ifm_in[ifm_cnt+3];
            ifm_r[39:32] = ifm_in[ifm_cnt+4];
            ifm_r[47:40] = ifm_in[ifm_cnt+5];
            ifm_r[55:48] = ifm_in[ifm_cnt+6];
            ifm_r[63:56] = ifm_in[ifm_cnt+7];
        end else
            ifm_r = 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ifm_cnt <= 0;
        else if (ifm_cnt == `IFM_LEN && !ifm_read)
            ifm_cnt <= 0;
        else if (ifm_read)
            ifm_cnt <= ifm_cnt + 8;
        else
            ifm_cnt <= ifm_cnt;
    end
    assign ifm = ifm_r;

    /// Wgt dispatcher
    initial begin
        $readmemb("./weight.txt", wgt_in);
    end

    always @(*) begin
        if (!rst_n) begin
            wgt_r = 0;
        end else if (wgt_read) begin
            wgt_r[7:0]   = wgt_in[wgt_cnt+0];
            wgt_r[15:8]  = wgt_in[wgt_cnt+1];
            wgt_r[23:16] = wgt_in[wgt_cnt+2];
            wgt_r[31:24] = wgt_in[wgt_cnt+3];
        end else
            wgt_r = 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wgt_cnt <= 0;
        else if (wgt_cnt == `WGT_LEN && !wgt_read)
            wgt_cnt <= 0;
        else if (wgt_read)
            wgt_cnt <= wgt_cnt + 4;
        else
            wgt_cnt <= wgt_cnt;
    end
    assign weight = wgt_r;

    /// Write data to file
    integer fp_w;
    integer oc;
    integer oh;
    integer ow;
    integer th;
    integer thcnt;
    integer tw;
    reg stop_flag;
    
    task read_output;
        input [`OUT_DATA_WIDTH-1:0] port0;
        input [`OUT_DATA_WIDTH-1:0] port1;
        input port0_v;
        input port1_v;
        reg signed [`OUT_DATA_WIDTH-1:0] ofm [0:`OFM_C-1][0:`OFM_H-1][0:`OFM_W-1];
        integer toc;
        integer toh;
        integer tow;


        WRITE: begin 
            toc = 0;
            toh = 0;
            tow = 0;
            if (oc <= `OFM_C-1) begin
                if (port0_v && port1_v) begin
                    ofm[oc][oh][ow+tw*`TI]   = port0;
                    ofm[oc][oh+1][ow+tw*`TI] = port1;
                    ow = ow + 1;
                    if (ow == `TI ) begin
                        ow = 0;
                        oh = oh + 2;
                        thcnt = thcnt + 2;
                    end 
                end else if (port0_v) begin
                    ofm[oc][oh][ow+tw*`TI]   = port0;
                    ow = ow + 1;
                    if (ow == `TI ) begin
                        ow = 0;
                        oh = oh + 1;
                        thcnt = thcnt + 1;
                        if (thcnt == 5) begin
                            thcnt = 0;
                            tw = tw + 1;
                            oh = oh - 5;
                            if (tw == 4) begin
                                tw = 0;
                                oh = oh + 5;
                            end
                        end
                    end 
                    if (oh == 65) begin
                        oh = 0;
                        oc = oc + 1;
                        $display("\033[33m[ConvKernel: ] Computing channel: %d\033[0m", oc);
                    end
                end
                stop_flag = 1'b1;
            end else begin
                if (stop_flag) begin
                    for (toc=0; toc < `OFM_C; toc = toc + 1) begin
                        $fwrite(fp_w, "\n\n");
                        for (toh=0; toh < `OFM_H; toh = toh + 1) begin
                            for (tow=0; tow < `OFM_W; tow = tow + 1) begin
                                $fwrite(fp_w, "%d ", ofm[toc][toh][tow]);
                                if (tow == `OFM_W-1) begin
                                    $fwrite(fp_w, "\n");
                                end
                            end
                        end
                    end
                    $display("\033[32m[ConvKernel: ] Finish writing results to conv_acc_out.txt\033[0m");
                    $fclose(fp_w);
                    $finish;
                end
                stop_flag = 1'b0;
            end 
        end
    endtask

    initial WRITE:begin
        fp_w = $fopen("conv_acc_out.txt");
        ow = 0;
        oc = 0;
        oh = 0;
        th = 0;
        tw = 0;
        thcnt = 0;
        stop_flag = 0;
        forever begin
            @(posedge clk);
            read_output(ofm_port0, ofm_port1, ofm_port0_v, ofm_port1_v);
        end
    end

    // generate clock 
    initial begin 
        clk = 1'b0;
        #5  clk = 1'b1;
        forever #5 clk = ~clk;
    end
    /// reset and other control signal from master side
    initial begin
        rst_n      = 1;
        start_conv = 0;
        cfg_ci = `CI;
        cfg_co = `CO;
        #10 rst_n  = 0;
        #10 rst_n  = 1;

        #10  start_conv = 1;
        #10  start_conv = 0;
        $display("\n\033[32m[ConvKernel: ] Set the clock period to 10ns\033[0m");
        $display("\033[32m[ConvKernel: ] Start to compute conv\033[0m");

    end

endmodule //tb_conv