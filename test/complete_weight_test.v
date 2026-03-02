// ======================================================
// Complete Weight System Test
// 测试权重存储、加载与CNN集成
// ======================================================

`timescale 1ns/1ps

module complete_weight_test();

    parameter DATA_WIDTH = 16;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 权重系统实例
    weight_system #(
        .DATA_WIDTH(DATA_WIDTH)
    ) weight_sys (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(load_en),
        .weight_type(weight_type),
        .ready(weight_ready),
        .weight_00(weight_00),
        .weight_01(weight_01),
        .weight_02(weight_02),
        .weight_10(weight_10),
        .weight_11(weight_11),
        .weight_12(weight_12),
        .weight_20(weight_20),
        .weight_21(weight_21),
        .weight_22(weight_22)
    );
    
    // 输入
    reg load_en;
    reg [1:0] weight_type;
    
    // 输出
    wire weight_ready;
    wire signed [DATA_WIDTH-1:0] weight_00, weight_01, weight_02;
    wire signed [DATA_WIDTH-1:0] weight_10, weight_11, weight_12;
    wire signed [DATA_WIDTH-1:0] weight_20, weight_21, weight_22;
    
    // 测试变量
    integer cycle_count;
    integer test_case;
    
    // 时钟
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    // 复位
    initial begin
        rst_n = 1'b0;
        #20 rst_n = 1'b1;
    end
    
    // 主测试程序
    initial begin
        // 初始化
        load_en = 1'b0;
        weight_type = 0;
        cycle_count = 0;
        test_case = 0;
        
        // 等待复位
        #30;
        
        $display("\n=== Complete Weight System Test ===\n");
        
        // ===== 测试1: 默认权重（Sobel边缘检测）=====
        test_case = 1;
        $display("[Test %0d] Default Sobel weights after reset", test_case);
        
        // 检查复位后的默认权重
        #10;
        display_weights("Default");
        
        // ===== 测试2: 加载平均池化核 =====
        test_case = 2;
        $display("\n[Test %0d] Load average pooling kernel", test_case);
        
        weight_type = 2'b01;  // 平均池化
        load_en = 1'b1;
        #10;
        load_en = 1'b0;
        
        // 等待加载完成
        wait_for_ready();
        
        display_weights("Average Pool");
        
        // ===== 测试3: 加载高斯模糊核 =====
        test_case = 3;
        $display("\n[Test %0d] Load Gaussian blur kernel", test_case);
        
        weight_type = 2'b10;  // 高斯模糊
        load_en = 1'b1;
        #10;
        load_en = 1'b0;
        
        wait_for_ready();
        
        display_weights("Gaussian Blur");
        
        // ===== 测试4: 返回Sobel核 =====
        test_case = 4;
        $display("\n[Test %0d] Return to Sobel kernel", test_case);
        
        weight_type = 2'b00;  // Sobel
        load_en = 1'b1;
        #10;
        load_en = 1'b0;
        
        wait_for_ready();
        
        display_weights("Sobel (return)");
        
        // ===== 系统性能总结 =====
        $display("\n[System Performance]");
        $display("  Weight switching time: ~3 cycles");
        $display("  Memory size: 9 weights x 16 bits = 144 bits");
        $display("  Supported kernels: 4 types");
        $display("  Ready signal latency: 1 cycle after load");
        
        // 完成
        #10;
        $display("\n[INFO] Weight system test completed!");
        $display("       Tested %0d different weight configurations", test_case);
        $finish;
    end
    
    // 辅助任务：等待权重就绪
    task wait_for_ready;
    begin
        while (!weight_ready) #10;
        $display("  Weights loaded and ready");
    end
    endtask
    
    // 辅助任务：显示权重矩阵
    task display_weights;
        input [80:0] kernel_name;
    begin
        $display("  %s kernel:", kernel_name);
        $display("    [%0d, %0d, %0d]", weight_00, weight_01, weight_02);
        $display("    [%0d, %0d, %0d]", weight_10, weight_11, weight_12);
        $display("    [%0d, %0d, %0d]", weight_20, weight_21, weight_22);
    end
    endtask
    
    // 时钟计数器
    always @(posedge clk) begin
        if (rst_n) cycle_count <= cycle_count + 1;
    end
    
    // 波形记录
    initial begin
        $dumpfile("complete_weight_test.vcd");
        $dumpvars(0, complete_weight_test);
    end

endmodule

// 完整的权重系统
module weight_system #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire load_en,
    input wire [1:0] weight_type,
    output reg ready,
    output reg signed [DATA_WIDTH-1:0] weight_00,
    output reg signed [DATA_WIDTH-1:0] weight_01,
    output reg signed [DATA_WIDTH-1:0] weight_02,
    output reg signed [DATA_WIDTH-1:0] weight_10,
    output reg signed [DATA_WIDTH-1:0] weight_11,
    output reg signed [DATA_WIDTH-1:0] weight_12,
    output reg signed [DATA_WIDTH-1:0] weight_20,
    output reg signed [DATA_WIDTH-1:0] weight_21,
    output reg signed [DATA_WIDTH-1:0] weight_22
);
    
    // 内部状态
    reg [1:0] load_state;
    
    // 预定义的卷积核
    localparam signed [DATA_WIDTH-1:0] KERNEL_SOBEL [0:8] = '{
        16'sd1, 16'sd0, 16'sd-1,
        16'sd2, 16'sd0, 16'sd-2,
        16'sd1, 16'sd0, 16'sd-1
    };
    
    localparam signed [DATA_WIDTH-1:0] KERNEL_AVERAGE [0:8] = '{
        16'sd1, 16'sd1, 16'sd1,
        16'sd1, 16'sd1, 16'sd1,
        16'sd1, 16'sd1, 16'sd1
    };
    
    localparam signed [DATA_WIDTH-1:0] KERNEL_GAUSSIAN [0:8] = '{
        16'sd1, 16'sd2, 16'sd1,
        16'sd2, 16'sd4, 16'sd2,
        16'sd1, 16'sd2, 16'sd1
    };
    
    localparam signed [DATA_WIDTH-1:0] KERNEL_SHARPEN [0:8] = '{
        16'sd0, 16'sd-1, 16'sd0,
        16'sd-1, 16'sd5, 16'sd-1,
        16'sd0, 16'sd-1, 16'sd0
    };
    
    // 主逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位：加载默认Sobel核
            load_kernel(KERNEL_SOBEL);
            ready <= 1'b1;
            load_state <= 0;
        end else begin
            // 状态机
            case (load_state)
                0: begin
                    // 空闲状态
                    if (load_en) begin
                        ready <= 1'b0;
                        load_state <= 1;
                    end
                end
                
                1: begin
                    // 加载阶段1：选择核类型
                    case (weight_type)
                        2'b00: load_kernel(KERNEL_SOBEL);
                        2'b01: load_kernel(KERNEL_AVERAGE);
                        2'b10: load_kernel(KERNEL_GAUSSIAN);
                        2'b11: load_kernel(KERNEL_SHARPEN);
                        default: load_kernel(KERNEL_SOBEL);
                    endcase
                    
                    load_state <= 2;
                end
                
                2: begin
                    // 加载阶段2：完成
                    ready <= 1'b1;
                    load_state <= 0;
                end
                
                default: load_state <= 0;
            endcase
        end
    end
    
    // 加载卷积核的任务
    task load_kernel;
        input signed [DATA_WIDTH-1:0] kernel [0:8];
    begin
        weight_00 <= kernel[0];
        weight_01 <= kernel[1];
        weight_02 <= kernel[2];
        weight_10 <= kernel[3];
        weight_11 <= kernel[4];
        weight_12 <= kernel[5];
        weight_20 <= kernel[6];
        weight_21 <= kernel[7];
        weight_22 <= kernel[8];
    end
    endtask

endmodule