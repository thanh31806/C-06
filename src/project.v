module c06_core (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] sample_in,
    input  logic [7:0] threshold,
    output logic [7:0] window_count,
    output logic [8:0] event_count,
    output logic [8:0] result_count,
    output logic       window_done
);

    logic       event_now;
    logic       terminal;
    logic [8:0] completed_count;

    always_comb begin
        event_now = (sample_in > threshold);
        terminal  = (window_count == 8'd255);
        completed_count = {1'b0, event_count} + {{8{1'b0}}, event_now};
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            window_count <= 8'd0;
            event_count  <= 9'd0;
            result_count <= 9'd0;
            window_done  <= 1'b0;
        end else begin
            window_done <= 1'b0;
            if (terminal) begin
                result_count <= completed_count;
                window_count <= 8'd0;
                event_count  <= 9'd0;
                window_done  <= 1'b1;
            end else begin
                window_count <= window_count + 8'd1;
                event_count  <= completed_count;
            end
        end
    end
endmodule
