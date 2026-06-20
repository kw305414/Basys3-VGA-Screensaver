`timescale 1ns / 1ps

module main(
    input clk_100MHz,     // clock on board
    output reg [3:0] vga_r, // 4 b red
    output reg [3:0] vga_g, // 4 b green
    output reg [3:0] vga_b, // 4 b blue
    output hsync,         // sync h
    output vsync          // sunc v
    );

    // clock devider
    reg [1:0] clk_div = 0;
    wire clk_25MHz = (clk_div == 2'b00); // impulse every 4th clock signal

    always @(posedge clk_100MHz) begin
        clk_div <= clk_div + 1;
    end

    //  enter vga parameters
    parameter H_DISPLAY = 640;
    parameter H_FP      = 16;
    parameter H_SYNC    = 96;
    parameter H_BP      = 48;
    parameter H_MAX     = 800;
    
    parameter V_DISPLAY = 480;
    parameter V_FP      = 10;
    parameter V_SYNC    = 2;
    parameter V_BP      = 29;
    parameter V_MAX     = 521;

 
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_100MHz) begin
        if (clk_25MHz) begin
            if (h_count == H_MAX - 1) begin
                h_count <= 0;
                if (v_count == V_MAX - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end


    assign hsync = ~(h_count >= (H_DISPLAY + H_FP) && h_count < (H_DISPLAY + H_FP + H_SYNC));
    assign vsync = ~(v_count >= (V_DISPLAY + V_FP) && v_count < (V_DISPLAY + V_FP + V_SYNC));

    wire video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);


    parameter IMG_SIZE = 128;
    reg [9:0] box_x = 100;
    reg [9:0] box_y = 100;
    reg box_dir_x = 1; 
    reg box_dir_y = 1; 


    always @(posedge clk_100MHz) begin
        if (clk_25MHz && h_count == 0 && v_count == V_DISPLAY + 1) begin
            if (box_dir_x) begin
                if (box_x + IMG_SIZE >= H_DISPLAY - 2) box_dir_x <= 0;
                else box_x <= box_x + 1;
            end else begin
                if (box_x <= 2) box_dir_x <= 1;
                else box_x <= box_x - 1;
            end
            
            if (box_dir_y) begin
                if (box_y + IMG_SIZE >= V_DISPLAY - 2) box_dir_y <= 0;
                else box_y <= box_y + 1;
            end else begin
                if (box_y <= 2) box_dir_y <= 1;
                else box_y <= box_y - 1;
            end
        end
    end

    
    reg [95:0] image_rom [0:31];
    
     
    // 3'b000 = background
    // 3'b001 = face
    // 3'b010 = blue
    // 3'b011 = red
    // 3'b100 = white
    
    initial begin
    //img 32x32
        image_rom[0]  = {{32{3'b000}}};
        image_rom[1]  = {{32{3'b000}}};
        image_rom[2]  = {{32{3'b000}}};
        image_rom[3]  = {{11{3'b000}}, {10{3'b001}}, {11{3'b000}}};
        image_rom[4]  = {{9{3'b000}}, {14{3'b001}}, {9{3'b000}}};
        image_rom[5]  = {{7{3'b000}}, {18{3'b001}}, {7{3'b000}}};
        image_rom[6]  = {{7{3'b000}}, {18{3'b001}}, {7{3'b000}}};
        image_rom[7]  = {{5{3'b000}}, {22{3'b001}}, {5{3'b000}}};
        image_rom[8]  = {{5{3'b000}}, {22{3'b001}}, {5{3'b000}}};
        image_rom[9]  = {{4{3'b000}}, {4{3'b001}}, {6{3'b000}}, {4{3'b001}}, {6{3'b000}}, {4{3'b001}}, {4{3'b000}}};
        image_rom[10] = {{4{3'b000}}, {4{3'b001}}, {1{3'b000}}, {4{3'b100}}, {1{3'b000}}, {4{3'b001}}, {1{3'b000}}, {4{3'b100}}, {1{3'b000}}, {4{3'b001}}, {4{3'b000}}};
        image_rom[11] = {{9{3'b000}}, {1{3'b100}}, {2{3'b010}}, {1{3'b100}}, {6{3'b000}}, {1{3'b100}}, {2{3'b010}}, {1{3'b100}}, {9{3'b000}}};
        image_rom[12] = {{3{3'b000}}, {5{3'b001}}, {1{3'b000}}, {1{3'b100}}, {2{3'b010}}, {1{3'b100}}, {1{3'b000}}, {4{3'b001}}, {1{3'b000}}, {1{3'b100}}, {2{3'b010}}, {1{3'b100}}, {1{3'b000}}, {5{3'b001}}, {3{3'b000}}};
        image_rom[13] = {{3{3'b000}}, {5{3'b001}}, {1{3'b000}}, {4{3'b100}}, {1{3'b000}}, {4{3'b001}}, {1{3'b000}}, {4{3'b100}}, {1{3'b000}}, {5{3'b001}}, {3{3'b000}}};
        image_rom[14] = {{3{3'b000}}, {5{3'b001}}, {6{3'b000}}, {4{3'b001}}, {6{3'b000}}, {5{3'b001}}, {3{3'b000}}}; 
        image_rom[15] = {{3{3'b000}}, {26{3'b001}}, {3{3'b000}}};
        image_rom[16] = {{3{3'b000}}, {26{3'b001}}, {3{3'b000}}};
        image_rom[17] = {{3{3'b000}}, {26{3'b001}}, {3{3'b000}}};
        image_rom[18] = {{3{3'b000}}, {6{3'b001}}, {14{3'b001}}, {6{3'b001}}, {3{3'b000}}};
        image_rom[19] = {{3{3'b000}}, {6{3'b001}}, {14{3'b011}}, {6{3'b001}}, {3{3'b000}}};
        image_rom[20] = {{3{3'b000}}, {5{3'b001}}, {2{3'b011}}, {12{3'b100}}, {2{3'b011}}, {5{3'b001}}, {3{3'b000}}};
        image_rom[21] = {{4{3'b000}}, {4{3'b001}}, {2{3'b011}}, {12{3'b000}}, {2{3'b011}}, {4{3'b001}}, {4{3'b000}}};
        image_rom[22] = {{4{3'b000}}, {5{3'b001}}, {2{3'b011}}, {10{3'b100}}, {2{3'b011}}, {5{3'b001}}, {4{3'b000}}};
        image_rom[23] = {{5{3'b000}}, {4{3'b001}}, {14{3'b011}}, {4{3'b001}}, {5{3'b000}}};
        image_rom[24] = {{5{3'b000}}, {6{3'b001}}, {10{3'b011}}, {6{3'b001}}, {5{3'b000}}};
        image_rom[25] = {{7{3'b000}}, {18{3'b001}}, {7{3'b000}}};
        image_rom[26] = {{7{3'b000}}, {18{3'b001}}, {7{3'b000}}};
        image_rom[27] = {{10{3'b000}}, {12{3'b001}}, {10{3'b000}}};
        image_rom[28] = {{11{3'b000}}, {10{3'b001}}, {11{3'b000}}};
        image_rom[29] = {{32{3'b000}}};
        image_rom[30] = {{32{3'b000}}};
        image_rom[31] = {{32{3'b000}}};
    end 


    wire in_image_bounds = (h_count >= box_x) && (h_count < box_x + IMG_SIZE) &&
                           (v_count >= box_y) && (v_count < box_y + IMG_SIZE);
                           
    wire [4:0] rom_x = (h_count - box_x) >> 2;
    wire [4:0] rom_y = (v_count - box_y) >> 2;

    wire [2:0] pixel_code = in_image_bounds ? image_rom[rom_y][(31 - rom_x)*3 +: 3] : 3'b000;


    always @(*) begin
        if (video_on) begin
            case (pixel_code)
                3'b001: begin //face
                    vga_r = 4'b1111; 
                    vga_g = 4'b1100; 
                    vga_b = 4'b1000; 
                end
                3'b010: begin // blue
                    vga_r = 4'b0111; 
                    vga_g = 4'b1100; 
                    vga_b = 4'b1111; 
                end
                3'b011: begin // red
                    vga_r = 4'b1111;
                    vga_g = 4'b0000;
                    vga_b = 4'b0000;
                end
                3'b100: begin // white
                    vga_r = 4'b1111;
                    vga_g = 4'b1111;
                    vga_b = 4'b1111;
                end
                default: begin // black
                    vga_r = 4'b0000;
                    vga_g = 4'b0000;
                    vga_b = 4'b0000;
                end
            endcase
        end else begin
          
            vga_r = 4'b0000;
            vga_g = 4'b0000;
            vga_b = 4'b0000;
        end
    end

endmodule