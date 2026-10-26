module tt_um_thanh31806_c06 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [7:0] sample_in = ui_in;
    wire [7:0] threshold = uio_in;

    reg [7:0] window_count;
    reg [8:0] event_count;
    reg [8:0] result_count;
    reg       window_done;

    wire event_now = (sample_in > threshold);
    wire window_full = (window_count == 8'd255);

    always_ff @(posedge clk) begin
        if (!rst_n || !ena) begin
            window_count <= 8'd0;
            event_count  <= 9'd0;
            result_count <= 9'd0;
            window_done  <= 1'b0;
        end else begin
            window_done <= 1'b0;

            if (window_full) begin
                event_count <= event_count + {{8{1'b0}}, event_now};
                result_count <= event_count + {{8{1'b0}}, event_now};
                window_count <= 8'd0;
                window_done  <= 1'b1;
            end else begin
                event_count <= event_count + {{8{1'b0}}, event_now};
                window_count <= window_count + 8'd1;
            end
        end
    end

    assign uo_out = result_count[7:0];
    assign uio_out[0] = window_done;
    assign uio_out[1] = result_count[8];
    assign uio_out[7:2] = 6'b0;
    assign uio_oe = 8'b00000011;

endmodule
