`timescale 1ns/1ps

module tb;
    // Tín hiệu kết nối với DUT
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Khởi tạo module (tên phải khớp với top_module trong info.yaml)
    tt_um_thanh31806_c06 dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Tạo xung clock
    always #5 clk = ~clk;

    // Task nạp mẫu
    task apply_cycle(input [7:0] sample, input [7:0] thresh);
        begin
            ui_in = sample;
            uio_in = thresh;
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 0;
        uio_in = 0;
        
        repeat(2) @(posedge clk);
        rst_n = 1;
        #1;

        // CA 1: Sự kiện tại chu kỳ 1, 255, 256
        apply_cycle(8'd101, 8'd100);
        for (int i=2; i<=254; i++) apply_cycle(8'd100, 8'd100);
        apply_cycle(8'd101, 8'd100);
        apply_cycle(8'd101, 8'd100);
        
        if (uo_out !== 8'd3 || uio_out[1] !== 1'b0) begin
            $display("FAIL: CA 1. Ky vong 3, nhan duoc uo_out=%0d, uio_out[1]=%0d", uo_out, uio_out[1]);
        end else begin
            $display("PASS: CA 1 (Ket qua = 3)");
        end
                // Reset mạch trước khi chạy Ca 2
        rst_n = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        #1;

        // CA 2: Tất cả đều vượt ngưỡng (Kết quả 256)
        for (int i=1; i<=256; i++) apply_cycle(8'd101, 8'd100);
        
        if (uo_out !== 8'd0 || uio_out[1] !== 1'b1) begin
            $display("FAIL: CA 2. Ky vong 256, nhan duoc uo_out=%0d, uio_out[1]=%0d", uo_out, uio_out[1]);
        end else begin
            $display("PASS: CA 2 (Ket qua = 256)");
        end

        $display("Testbench finished.");
        $finish;
    end
endmodule
   
