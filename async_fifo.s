module async_fifo #(
    parameter int DATA_W = 8,
    parameter int ADDR_W = 4
)(
    input  logic              wclk,
    input  logic              wrst_n,
    input  logic              w_en,
    input  logic [DATA_W-1:0] wdata,
    output logic              full,

    input  logic              rclk,
    input  logic              rrst_n,
    input  logic              r_en,
    output logic [DATA_W-1:0] rdata,
    output logic              empty
);

    localparam int DEPTH = 1 << ADDR_W;

    logic [DATA_W-1:0] mem [0:DEPTH-1];

    logic [ADDR_W:0] wbin, wgray;
    logic [ADDR_W:0] rbin, rgray;

    logic [ADDR_W:0] rgray_w1, rgray_w2;
    logic [ADDR_W:0] wgray_r1, wgray_r2;

    logic [ADDR_W:0] wbin_next, wgray_next;
    logic [ADDR_W:0] rbin_next, rgray_next;

    assign wbin_next  = wbin + ((w_en && !full) ? 1'b1 : 1'b0);
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;

    assign rbin_next  = rbin + ((r_en && !empty) ? 1'b1 : 1'b0);
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;

    assign empty = (rgray == wgray_r2);

    // For ADDR_W+1 Gray pointer bits, full occurs when the next
    // write pointer equals the synchronized read pointer with
    // the two MSBs inverted.
    assign full = (wgray_next ==
                   {~rgray_w2[ADDR_W:ADDR_W-1],
                     rgray_w2[ADDR_W-2:0]});

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rgray_w1 <= '0;
            rgray_w2 <= '0;
        end else begin
            rgray_w1 <= rgray;
            rgray_w2 <= rgray_w1;
        end
    end

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wgray_r1 <= '0;
            wgray_r2 <= '0;
        end else begin
            wgray_r1 <= wgray;
            wgray_r2 <= wgray_r1;
        end
    end

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= '0;
            wgray <= '0;
        end else if (w_en && !full) begin
            mem[wbin[ADDR_W-1:0]] <= wdata;
            wbin  <= wbin_next;
            wgray <= wgray_next;
        end
    end

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin  <= '0;
            rgray <= '0;
            rdata <= '0;
        end else if (r_en && !empty) begin
            rdata <= mem[rbin[ADDR_W-1:0]];
            rbin  <= rbin_next;
            rgray <= rgray_next;
        end
    end

endmodule
