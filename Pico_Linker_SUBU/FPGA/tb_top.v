`timescale 1ns / 1ps

module tb_top();
    reg clk;
    reg reset_n;
    wire [5:0] led;

    // Anakartimizi (top.v) cagiriyoruz
    top uut (
        .clk(clk),
        .reset_n(reset_n),
        .led(led)
    );

    // Tang Nano 9K saat sinyali (27 MHz)
    initial clk = 0;
    always #18.5 clk = ~clk;

    initial begin
        // --- Kayit Ayarlari ---
        $dumpfile("test.vcd");    // Dalga dosyasi ismi
        $dumpvars(0, tb_top);     // Tum sinyalleri kaydet
        
        // --- Test Senaryosu ---
        reset_n = 0; 
        #100;                     // Sistemin oturmasi icin 100ns bekle
        reset_n = 1;              // Reseti kaldir, islemci calismaya baslasin
        
        #5000;                    // 5 mikrosaniye boyunca calistir
        $display("Simulasyon tamamlandi. Sinyaller test.vcd dosyasina yazildi.");
        $finish;                  // Testi bitir
    end
endmodule