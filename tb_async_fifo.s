module tb_async_fifo;
    localparam int DW=8, AW=3;

    logic wclk=0, rclk=0;
    logic wrst_n=0, rrst_n=0;
    logic w_en, r_en, full, empty;
    logic [DW-1:0] wdata, rdata;

    async_fifo #(.DATA_W(DW), .ADDR_W(AW)) dut(.*);

    always #5 wclk=~wclk;
    always #7 rclk=~rclk;

    integer k;

    initial begin
        w_en=0; r_en=0; wdata=0;
        #20;
        wrst_n=1; rrst_n=1;

        // Write a sequence from the write clock domain.
        for (k=0; k<6; k=k+1) begin
            @(negedge wclk);
            if (!full) begin
                w_en=1;
                wdata=k+8'hA0;
            end
        end
        @(negedge wclk);
        w_en=0;

        // Read from the independent read clock domain.
        repeat(2) @(negedge rclk);
        for (k=0; k<6; k=k+1) begin
            @(negedge rclk);
            if (!empty) r_en=1;
        end
        @(negedge rclk);
        r_en=0;

        #100;
        $display("Asynchronous FIFO CDC test completed.");
        $finish;
    end
endmodule
