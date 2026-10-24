odule c06_core_tb;
    logic clk, rst_n;
    logic [7:0] sample_in, threshold;
    logic [7:0] window_count;
    logic [8:0] event_count, result_count;
    logic window_done;
    always #5 clk = ~clk;
    task automatic apply_cycle(input logic [7:0] x);
        begin
            sample_in = x;
            @(posedge clk);
            #1; 
        end
    endtask
    task automatic reset_dut;
        begin
            rst_n = 0;
            sample_in = 0;
            repeat(2) @(posedge clk); 
            rst_n = 1;
            #1;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 1;
        sample_in = 0;
        threshold = 8'd100; // Đặt ngưỡng so sánh là 100
        reset_dut();
        apply_cycle(8'd101); // Chu kỳ 1: Vượt ngưỡng (101 > 100)
        for (int i=2; i<=254; i++) apply_cycle(8'd100); // Chu kỳ 2-254: Không vượt (100 == 100)
        apply_cycle(8'd101); // Chu kỳ 255: Vượt ngưỡng
        apply_cycle(8'd101); // Chu kỳ 256: Vượt ngưỡng (và là chu kỳ kết thúc)
        assert(window_done == 1) else $fatal(1, "Loi: window_done khong bat tai chu ky 256");
        assert(result_count == 9'd3) else $fatal(1, "Loi: Ket qua sai, ky vong 3, nhan duoc %0d", result_count);
        assert(window_count == 0) else $fatal(1, "Loi: window_count khong reset");
        assert(event_count == 0) else $fatal(1, "Loi: event_count khong reset");
        apply_cycle(8'd101); // Mẫu đầu tiên của cửa sổ 2
        assert(window_count == 8'd1) else $fatal(1, "Loi: Cua so 2 khong bat dau dung");
        assert(event_count == 9'd1) else $fatal(1, "Loi: Bo dem su kien cua cua so 2 sai");
        for (int i=2; i<=256; i++) apply_cycle(8'd100); 
        assert(result_count == 9'd1) else $fatal(1, "Loi: Mau bang nguong bi tinh sai");
        for (int i=1; i<=256; i++) apply_cycle(8'd101);
        assert(result_count == 9'd256) else $fatal(1, "Loi: Ket qua toi da sai, ky vong 256");
        $display("C06 core verification PASS");
        $finish;
    end
endmodule
