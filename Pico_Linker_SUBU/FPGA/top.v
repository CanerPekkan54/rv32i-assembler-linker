module top (
    input clk,
    input reset_n,
    output reg [5:0] led
);
    // 1. OTOMATİK RESET
    reg [15:0] reset_counter = 0;
    wire internal_resetn = (reset_counter == 16'hFFFF);

    always @(posedge clk) begin
        if (reset_counter < 16'hFFFF) 
            reset_counter <= reset_counter + 1;
    end

    // 2. BELLEK (BRAM)
    reg [31:0] memory [0:4095]; 
    initial begin
        $readmemh("output.mem", memory); 
        led = 6'b111111; // Başlangıçta hepsi sönük
    end

    // 3. İŞLEMCİ (PicoRV32)
    wire mem_valid, mem_ready;
    wire [31:0] mem_addr, mem_wdata;
    wire [3:0] mem_wstrb;
    reg  [31:0] mem_rdata;

    picorv32 cpu (
        .clk(clk),
        .resetn(internal_resetn),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    assign mem_ready = mem_valid;

    // 4. LED KONTROLÜ (6 LED birden işlemcide)
    always @(posedge clk) begin
        if (!internal_resetn) begin
            led <= 6'b000000; // Reset anında hepsi yansın
        end else begin
            // İşlemci 128 adresine yazarsa 6 biti de LED'lere bas
            if (mem_valid && mem_wstrb == 4'b1111 && mem_addr == 32'd128) begin
                led[5:0] <= ~mem_wdata[5:0]; // 1 olan bitler yanacak
            end
        end
    end

    // BELLEK OKUMA
    always @(*) begin
        if (mem_valid && mem_wstrb == 4'b0000)
            mem_rdata = memory[mem_addr >> 2];
        else
            mem_rdata = 32'b0;
    end
endmodule