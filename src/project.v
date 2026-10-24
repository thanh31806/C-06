module tt_um_thanh31806_c06 (
    input  wire [7:0] ui_in,    // Dữ liệu mẫu đầu vào (sample_in)
    output wire [7:0] uo_out,   // Kết quả đếm (result_count[7:0])
    input  wire [7:0] uio_in,   // Ngưỡng so sánh (threshold)
    output wire [7:0] uio_out,  // Bit cao của kết quả + xung window_done
    output wire [7:0] uio_oe,   // Output enable cho uio
    input  wire       ena,      // Enable (thường nối 1)
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (tích cực mức thấp)
);

    // Ánh xạ tín hiệu từ cổng Tiny Tapeout vào logic C06
    wire [7:0] sample_in = ui_in;
    wire [7:0] threshold = uio_in;
    
    // Các tín hiệu nội bộ của C06
    logic       event_now;
    logic       terminal;
    logic [8:0] completed_count;
    logic [8:0] result_count_internal;
    logic       window_done_internal;
    
    // Các thanh ghi trạng thái
    logic [7:0] window_count;
    logic [8:0] event_count;

    always_comb begin
        event_now = (sample_in > threshold);
        terminal  = (window_count == 8'd255);
        completed_count = {1'b0, event_count} + {{8{1'b0}}, event_now};
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            window_count <= 8'd0;
            event_count  <= 9'd0;
            result_count_internal <= 9'd0;
            window_done_internal  <= 1'b0;
        end else begin
            window_done_internal <= 1'b0;
            if (terminal) begin
                result_count_internal <= completed_count;
                window_count <= 8'd0;
                event_count  <= 9'd0;
                window_done_internal  <= 1'b1;
            end else begin
                window_count <= window_count + 8'd1;
                event_count  <= completed_count;
            end
        end
    end

    // --- Ánh xạ tín hiệu ra các cổng Tiny Tapeout ---
    
    // uo_out: 8 bit thấp của kết quả
    assign uo_out = result_count_internal[7:0];
    
    // uio_out: Bit 0 là xung window_done, Bit 1 là bit 8 của kết quả
    assign uio_out[0] = window_done_internal;
    assign uio_out[1] = result_count_internal[8];
    assign uio_out[7:2] = 6'b0; // Các bit còn lại nối 0
    
    // uio_oe: Chỉ định các chân uio là output (1 = output)
    assign uio_oe = 8'b00000011; // Chỉ bit 0 và 1 là output

endmodule
