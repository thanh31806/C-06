`timescale 1ns/1ps

module tb;
    // Khai báo tín hiệu
    reg clk;
    reg rst_n;
    reg [7:0] sample_in;
    reg [7:0] threshold;
    wire [7:0] result_count;
    wire window_done;

    // Khởi tạo module cần kiểm tra (phải khớp tên top_module trong info.yaml)
    tt_um_thanh31806_c06 dut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_in(sample_in),
        .threshold(threshold),
        .result_count(result_count),
        .window_done(window_done)
    );

    // Tạo xung clock chu kỳ 10ns
    always #5 clk = ~clk;

    // Task nạp một mẫu dữ liệu
    task apply_cycle(input [7:0] x);
        begin
            sample_in = x;
            @(posedge clk);
            #1;
        end
    endtask

    // Task reset mạch
    task reset_dut;
        begin
            rst_n = 0;
            sample_in = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
            #1;
        end
    endtask

    initial begin
        // Khởi tạo
        clk = 0;
        rst_n = 1;
        sample_in = 0;
        threshold = 8'd100;

        reset_dut();

        // CA KIỂM THỬ 1: Sự kiện tại chu kỳ 1, 255, 256
        apply_cycle(8'd101);
        for (int i=2; i<=254; i++) apply_cycle(8'd100);
        apply_cycle(8'd101);
        apply_cycle(8'd101);
        
        // Kiểm tra kết quả
        if (result_count !== 9'd3) $display("FAIL: CA 1 sai, ky vong 3, nhan duoc %0d", result_count);
        else $display("PASS: CA 1 dung");

        // CA KIỂM THỬ 2: Tất cả đều vượt ngưỡng
        reset_dut();
        for (int i=1; i<=256; i++) apply_cycle(8'd101);
        if (result_count !== 9'd256) $display("FAIL: CA 2 sai, ky vong 256, nhan duoc %0d", result_count);
        else $display("PASS: CA 2 dung");

        $display("Testbench finished.");
        $finish;
    end
endmodule
