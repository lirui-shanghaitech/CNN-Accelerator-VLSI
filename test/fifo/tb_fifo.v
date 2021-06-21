///==------------------------------------------------------------------==///
/// testbench of synchronous fifo
///==------------------------------------------------------------------==///

`define BUF_DEPTH 8
`define BUF_ADDR_WIDTH 3
`define BUF_DATA_WIDTH 25

module TEST_FIFO ();
    reg  clk, rst_n, wr_en, rd_en;
    reg  [`BUF_DATA_WIDTH-1:0] data_in;
    reg  [`BUF_DATA_WIDTH-1:0] temp;
    wire [`BUF_DATA_WIDTH-1:0] data_out;
    wire empty;
    wire full;

    SYNCH_FIFO #(
        .data_width(`BUF_DATA_WIDTH),
        .addr_width(`BUF_ADDR_WIDTH),
        .depth(`BUF_DEPTH)
    ) synch_fifo (
        .clk(clk),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rst_n(rst_n),
        .empty(empty),
        .full(full),
        .data_out(data_out),
        .data_in(data_in)
    );
    /// Push task
    task push;
        input [`BUF_DATA_WIDTH-1:0] data;
        if (full)
            $display("Opps! Buffer already full, pop then push");
        else begin
            $display("Pushed: ", data);
            data_in = data;
            wr_en   = 1;
            @(posedge clk);
            #1 wr_en = 0;
        end
    endtask

    /// Pop task
    task pop;
        output [`BUF_DATA_WIDTH-1:0] data;
        if (empty)
            $display("Opps! Buffer is empty nothing to pop");
        else begin
            rd_en = 1;
            @(posedge clk);
            #1 rd_en = 0;
            data = data_out;
            $display("Poped: ", data);
        end
    endtask
    /// clock generation
    always #5 clk = ~clk;

    /// Run simulation
    initial begin
        clk       = 0;
        rst_n     = 1;
        rd_en     = 0;
        wr_en     = 0;
        temp      = 0;
        data_in   = 0;
        #5 rst_n  = 0;
        #10 rst_n = 1;

        push(1);
        fork
           push(2);
           pop(temp);
        join            
        push(10);
        push(20);
        push(30);
        push(40);
        push(50);
        push(60);
        push(70);
        push(80);
        push(90);
        push(100);
        push(110);
        push(120);
        push(130);

        pop(temp);
        push(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
		push(140);
        pop(temp);
        push(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        pop(temp);
        push(5);
        pop(temp);
    end

endmodule