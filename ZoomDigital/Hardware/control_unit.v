module control_unit (
    input  wire clock_50MHz,       // Clock de entrada principal (50 MHz)     
    output wire hsync,             // Sinal horizontal de sincronização VGA
    output wire vsync,             // Sinal vertical de sincronização VGA
    output [7:0] red,              // Componente de cor vermelha VGA
    output [7:0] green,            // Componente de cor verde VGA
    output [7:0] blue,             // Componente de cor azul VGA
    output sync,                   // Sinal de sincronização VGA
    output clk,                    // Clock para VGA
    output blank,                   // Sinal de blank VGA

	 input [31:0] instruction,
	 input enable_instruction,
	 input [9:0] option,
	 output [27:0] display
);
	 wire [15:0] selected_bits;
    assign selected_bits = option[0] ? instruction[31:16] : instruction[15:0];
    
	 reg [6:0] dip0, dip1, dip2, dip3;
    
    wire [3:0] nibble0, nibble1, nibble2, nibble3;
    assign nibble0 = selected_bits[3:0];
    assign nibble1 = selected_bits[7:4];
    assign nibble2 = selected_bits[11:8];
    assign nibble3 = selected_bits[15:12];
    
	 assign display = {dip3, dip2, dip1, dip0};
	 
    always @(*) begin
        case(nibble0)
            4'h0: dip0 = 7'b1000000;
            4'h1: dip0 = 7'b1111001;
            4'h2: dip0 = 7'b0100100;
            4'h3: dip0 = 7'b0110000;
            4'h4: dip0 = 7'b0011001;
            4'h5: dip0 = 7'b0010010;
            4'h6: dip0 = 7'b0000010;
            4'h7: dip0 = 7'b1111000;
            4'h8: dip0 = 7'b0000000;
            4'h9: dip0 = 7'b0010000;
            4'hA: dip0 = 7'b0001000;
            4'hB: dip0 = 7'b0000011;
            4'hC: dip0 = 7'b1000110;
            4'hD: dip0 = 7'b0100001;
            4'hE: dip0 = 7'b0000110;
            4'hF: dip0 = 7'b0001110;
        endcase
        
        case(nibble1)
            4'h0: dip1 = 7'b1000000;
            4'h1: dip1 = 7'b1111001;
            4'h2: dip1 = 7'b0100100;
            4'h3: dip1 = 7'b0110000;
            4'h4: dip1 = 7'b0011001;
            4'h5: dip1 = 7'b0010010;
            4'h6: dip1 = 7'b0000010;
            4'h7: dip1 = 7'b1111000;
            4'h8: dip1 = 7'b0000000;
            4'h9: dip1 = 7'b0010000;
            4'hA: dip1 = 7'b0001000;
            4'hB: dip1 = 7'b0000011;
            4'hC: dip1 = 7'b1000110;
            4'hD: dip1 = 7'b0100001;
            4'hE: dip1 = 7'b0000110;
            4'hF: dip1 = 7'b0001110;
        endcase
        
        case(nibble2)
            4'h0: dip2 = 7'b1000000;
            4'h1: dip2 = 7'b1111001;
            4'h2: dip2 = 7'b0100100;
            4'h3: dip2 = 7'b0110000;
            4'h4: dip2 = 7'b0011001;
            4'h5: dip2 = 7'b0010010;
            4'h6: dip2 = 7'b0000010;
            4'h7: dip2 = 7'b1111000;
            4'h8: dip2 = 7'b0000000;
            4'h9: dip2 = 7'b0010000;
            4'hA: dip2 = 7'b0001000;
            4'hB: dip2 = 7'b0000011;
            4'hC: dip2 = 7'b1000110;
            4'hD: dip2 = 7'b0100001;
            4'hE: dip2 = 7'b0000110;
            4'hF: dip2 = 7'b0001110;
        endcase
        
        case(nibble3)
            4'h0: dip3 = 7'b1000000;
            4'h1: dip3 = 7'b1111001;
            4'h2: dip3 = 7'b0100100;
            4'h3: dip3 = 7'b0110000;
            4'h4: dip3 = 7'b0011001;
            4'h5: dip3 = 7'b0010010;
            4'h6: dip3 = 7'b0000010;
            4'h7: dip3 = 7'b1111000;
            4'h8: dip3 = 7'b0000000;
            4'h9: dip3 = 7'b0010000;
            4'hA: dip3 = 7'b0001000;
            4'hB: dip3 = 7'b0000011;
            4'hC: dip3 = 7'b1000110;
            4'hD: dip3 = 7'b0100001;
            4'hE: dip3 = 7'b0000110;
            4'hF: dip3 = 7'b0001110;
        endcase
    end

    wire clock_25MHz; 
    
    // Sinais VGA
    wire [16:0] rd_addr_vga;  
    wire [7:0] q;              
    wire [7:0] color;          
    wire [9:0] next_x;         
    wire [9:0] next_y;         
    
    // Controle de Memórias
    //wire [16:0] rd_addr_primary;     
    //wire [16:0] wr_addr_secondary;  
    //wire [7:0] wr_data_secondary;    
    //wire wr_en_secondary;           
    wire [7:0] pixel_from_primary;  
    
    // Reset e Cópia Inicial
    reg reset_active;                
    reg [16:0] reset_addr_counter;   
    reg [1:0] copy_state;           
    reg trigger_reset_copy;          
    reg internal_rst;    
	 
    localparam CPY_IDLE = 2'b00, CPY_PROCESS = 2'b01; 
    
    // Reset inicial (power-on)
    reg [3:0] power_on_counter; 
    initial begin
        power_on_counter = 4'd0;
        internal_rst = 1'b0;
    end
    
    always @(posedge clock_25MHz) begin
        if (power_on_counter < 4'd10) begin
            power_on_counter <= power_on_counter + 1;
            internal_rst <= 1'b0;
        end else begin
            internal_rst <= 1'b1;
        end
    end
    
    // Modo de Display
    reg display_mode; // 0=320x240, 1=160x120
 
    // Replicação de Pixels
    wire [16:0] addr_counter_repl;    
    wire [16:0] addr_write_repl;      
    wire [31:0] replicated_pixels;   
    wire [7:0] out_pixel_repl;        
    wire pixel_done_repl;             
    wire wren_repl;                  
    wire done_repl;                   
    
    reg [7:0] pixel_repl_r;
    always @(posedge clock_25MHz) pixel_repl_r <= pixel_from_primary;
    
    // Decimação de Pixels
    wire [16:0] rd_addr_dec;    
    wire [16:0] wr_addr_dec;   
    wire [7:0] wr_data_dec;     
    wire wren_dec;              
    wire done_dec;             
    
    // Média de Blocos (Block Average)
    wire [16:0] in_addr_avg;        
    wire [16:0] mem_read_addr_avg;  
    wire [16:0] out_addr_avg;    
    wire [7:0] out_data_avg;        
    wire wren_avg;                  
    wire done_avg;                
    wire processing_avg;            
    wire [7:0] val00, val01, val10, val11; 
    
    // Nearest Neighbor (Interpolação)
    wire [16:0] rd_addr_nn;     
    wire [16:0] wr_addr_nn;     
    wire [7:0] wr_data_nn;      
    wire wren_nn;              
    wire done_nn;             
    
    // Sinais de Controle
    reg repl_active;    
    reg dec_active;     
    reg avg_active;     
    reg nn_active;      
    
    // Detecção de borda (botões)
    reg start_repl_prev;
    reg start_dec_prev;
    reg start_avg_prev;
    reg start_nn_prev;
    wire start_repl_edge;
    wire start_dec_edge;
    wire start_avg_edge;
    wire start_nn_edge;
    
    // Sincronização dos botões
    always @(posedge clock_25MHz) begin
        if (!internal_rst) begin
            start_repl_prev <= 1'b1;
            start_dec_prev <= 1'b1;
            start_avg_prev <= 1'b1;
            start_nn_prev <= 1'b1;
        end else begin
            start_repl_prev <= start_repl;
            start_dec_prev <= start_dec;
            start_avg_prev <= start_avg;
            start_nn_prev <= start_nn;
        end
    end
    
    // Geração dos pulsos de borda
    assign start_repl_edge = !start_repl && start_repl_prev;
    assign start_dec_edge = !start_dec && start_dec_prev;
    assign start_avg_edge = !start_avg && start_avg_prev;
    assign start_nn_edge = !start_nn && start_nn_prev;

    // Detecção de término Block Average
    reg prev_processing_avg;
    wire avg_finished;
    
    always @(posedge clock_25MHz) begin
        if (!internal_rst) begin
            prev_processing_avg <= 1'b0;
        end else begin
            prev_processing_avg <= processing_avg;
        end
    end
    
    assign avg_finished = prev_processing_avg && !processing_avg;
    
	 // sinais para sincronizar start_reset vindo do decoder/HPS
	 wire start_reset_async = start_reset; // sinal externo
	 reg  start_reset_sync_0, start_reset_sync_1;
	 reg  start_reset_pulse;
	 reg  start_reset_prev;
	 
	 // dois FFs para sincronizar o sinal assíncrono
	 always @(posedge clock_25MHz) begin
		 start_reset_sync_0 <= start_reset_async;
		 start_reset_sync_1 <= start_reset_sync_0;
	 end

	 // detectar subida e gerar pulso de 1 ciclo
	 always @(posedge clock_25MHz) begin
		 start_reset_prev <= start_reset_sync_1;
		 start_reset_pulse <= start_reset_sync_1 & ~start_reset_prev;
	 end

    always @(posedge clock_25MHz) begin
      if (!internal_rst || start_reset_pulse) begin
        repl_active <= 1'b0;
        dec_active  <= 1'b0;
        avg_active  <= 1'b0;
        nn_active   <= 1'b0;

        display_mode <= 1'b0;   // padrão (REPL / NN)

        copy_state <= CPY_PROCESS;
        reset_active <= 1'b1;
        reset_addr_counter <= 17'd0;
     end 
     else begin
        case (copy_state)

            // Cópia inicial
            CPY_PROCESS: begin
                reset_active <= 1'b1;

                if (reset_addr_counter < 17'd76800)
                    reset_addr_counter <= reset_addr_counter + 1;
                else begin
                    copy_state <= CPY_IDLE;
                    reset_active <= 1'b0;
                end
            end

            // Idle
            CPY_IDLE: begin
                reset_active <= 1'b0;

                // Ativação direta dos algoritmos
                if (start_repl_edge) begin
                    repl_active <= 1'b1;
                    dec_active  <= 1'b0;
                    avg_active  <= 1'b0;
                    nn_active   <= 1'b0;
                    display_mode <= 1'b0;  // REPL → display_mode 0
                end
                else if (start_dec_edge) begin
                    repl_active <= 1'b0;
                    dec_active  <= 1'b1;
                    avg_active  <= 1'b0;
                    nn_active   <= 1'b0;
                    display_mode <= 1'b1;  // DEC → display_mode 1
                end
                else if (start_avg_edge) begin
                    repl_active <= 1'b0;
                    dec_active  <= 1'b0;
                    avg_active  <= 1'b1;
                    nn_active   <= 1'b0;
                    display_mode <= 1'b1;  // AVG → display_mode 1
                end
                else if (start_nn_edge) begin
                    repl_active <= 1'b0;
                    dec_active  <= 1'b0;
                    avg_active  <= 1'b0;
                    nn_active   <= 1'b1;
                    display_mode <= 1'b0;  // NN → display_mode 0
                end

                // Finalizações
                if (done_repl && repl_active) begin
                    repl_active <= 1'b0;
                end
                else if (done_dec && dec_active) begin
                    dec_active <= 1'b0;
                end
                else if (avg_finished && avg_active) begin
                    avg_active <= 1'b0;
                end
                else if (done_nn && nn_active) begin
                    nn_active <= 1'b0;
                end
            end

            default: begin
                copy_state <= CPY_IDLE;
                reset_active <= 1'b0;
            end
        endcase
    end
	 end
    
    // Flags de start para cada algoritmo
    wire start_repl_sig = repl_active;
    wire start_dec_sig = dec_active;
    wire start_avg_sig = avg_active;
    wire start_nn_sig = nn_active;

    // Multiplexadores
    reg [16:0] rd_addr_primary;
    reg [16:0] wr_addr_secondary;
    reg [7:0] wr_data_secondary;
    reg wr_en_secondary;
    
    always @(posedge clock_25MHz) begin
        if (!internal_rst) begin
            rd_addr_primary <= 17'd0;
            wr_addr_secondary <= 17'd0;
            wr_data_secondary <= 8'd0;
            wr_en_secondary <= 1'b0;
        end else begin
            // Seleciona origem dos sinais
            rd_addr_primary <= reset_active ? reset_addr_counter :
                                dec_active ? rd_addr_dec :
                                avg_active ? mem_read_addr_avg :
                                nn_active ? rd_addr_nn :
                                addr_counter_repl;
            
            wr_addr_secondary <= reset_active ? reset_addr_counter :
                                  dec_active ? wr_addr_dec :
                                  avg_active ? out_addr_avg :
                                  nn_active ? wr_addr_nn :
                                  addr_write_repl;
            
            wr_data_secondary <= reset_active ? pixel_from_primary :
                                  dec_active ? wr_data_dec :
                                  avg_active ? out_data_avg :
                                  nn_active ? wr_data_nn :
                                  out_pixel_repl;
                                    
            wr_en_secondary <= reset_active || 
                               (dec_active && wren_dec) || 
                               (repl_active && wren_repl) ||
                               (avg_active && wren_avg) ||
                               (nn_active && wren_nn);
        end
    end
	 
	 wire wren_image;
	 wire [16:0] address_image;
	 wire [7:0] data_image;
	 wire [8:0] offset_y;
	 wire [8:0] offset_x;
	  
	 // Decodificador de insrtuções
	 decoder (
		.clock_25MHz(clock_25MHz),
		.enable_instruction(enable_instruction),
		.instruction(instruction),
		.start_repl(start_repl),              
      .start_dec(start_dec),               
      .start_avg(start_avg),               
      .start_nn(start_nn),                 
		.wren_image(wren_image),
	   .address_image(address_image),
	   .data_image(data_image),
		.start_reset(start_reset),
		.offset_y(offset_y),
		.offset_x(offset_x)
	 );
	 
	 // Divisor de clock 50 MHz → 25 MHz 
    clock_divider clock_div_inst (
        .clock_50MHz(clock_50MHz),
        .clock_25MHz(clock_25MHz)
    );

    // Replicação de pixels 
    pixel_replication repl_inst (
        .in_data(pixel_repl_r),
        .out_data(replicated_pixels)
    );
    
    // Controle de endereços para replicação
    address_pixel_replication addr_repl_inst (
        .clk(clock_25MHz),
        .rst(~internal_rst),
        .start(start_repl_sig),
        .in_data(replicated_pixels),
        .rd_address(addr_counter_repl),
        .wr_address(addr_write_repl),
        .wr_data(out_pixel_repl),
        .wren(wren_repl),
        .done(done_repl),
        .pixel_done(pixel_done_repl),
		  .offset_row(offset_y),
		  .offset_col(offset_x)
    );

    // Decimação 
    pixel_decimation dec_inst (
        .clk(clock_25MHz),
        .rst(~internal_rst),
        .start(start_dec_sig),
        .pixel_data(pixel_from_primary),
        .rd_address(rd_addr_dec),
        .wr_address(wr_addr_dec),
        .wr_data(wr_data_dec),
        .wren(wren_dec),
        .done(done_dec)
    );

    // Contador de endereços para média de blocos
    address_counter_avg addr_counter_avg_inst (
        .clk(clock_25MHz),
        .rst(~internal_rst),
        .en(done_avg),
        .start(start_avg_sig),
        .value(in_addr_avg),
        .processing(processing_avg)
    );

    // Controle da média de blocos 
    address_block_average block_avg_ctrl (
        .clk(clock_25MHz),
        .rst(~internal_rst),
        .in_address(in_addr_avg),
        .in_data(pixel_from_primary),
        .mem_read_addr(mem_read_addr_avg),
        .out_address(out_addr_avg),
        .out_wren(wren_avg),
        .done(done_avg),
        .val00(val00),
        .val01(val01),
        .val10(val10),
        .val11(val11)
    );

    // Calcula média de 4 pixels
    block_average block_avg_calc (
        .val00(val00),
        .val01(val01),
        .val10(val10),
        .val11(val11),
        .enable(1'b1),
        .media_out(out_data_avg)
    );

    // Interpolação por vizinho mais próximo
    nearest_neighbor nn_inst (
        .clk(clock_25MHz),
        .rst(~internal_rst),
        .start(start_nn_sig),
        .pixel_data(pixel_from_primary),
        .rd_address(rd_addr_nn),
        .wr_address(wr_addr_nn),
        .wr_data(wr_data_nn),
        .wren(wren_nn),
        .done(done_nn),
		  .offset_y(offset_y),
		  .offset_x(offset_x)
    );

    // Memória primária (imagem original)
    primary_memory primary_mem_inst (
		  .data(data_image),
        .rd_aclr(1'b0),
        .rdaddress(rd_addr_primary),
        .rdclock(clock_25MHz),
        .rden(1'b1),
        .wraddress(address_image),
        .wrclock(clock_25MHz),
        .wren(wren_image),
        .q(pixel_from_primary)
    );

    // Memória secundária (imagem processada)
    secondary_memory secondary_mem_inst (
        .data(wr_data_secondary),
        .rd_aclr(1'b0),
        .rdaddress(rd_addr_vga),
        .rdclock(clock_25MHz),
        .rden(1'b1),
        .wraddress(wr_addr_secondary),
        .wrclock(clock_25MHz),
        .wren(wr_en_secondary),
        .q(q)
    );
	 
	 reg [7:0] buf_vga_0;
	 reg [7:0] buf_vga_1;
	 
	 always @(posedge clock_50MHz) begin
		 buf_vga_0 <= q;      
		 buf_vga_1 <= buf_vga_0;
	 end

    // Controlador VGA 
    vga_controller vga_ctrl_inst (
        .clock(clock_25MHz),
        .next_x(next_x),
        .next_y(next_y),
        .data(buf_vga_1),
        .decimation_mode(display_mode),
        .rdaddress(rd_addr_vga),
        .color(color)
    );

    // Driver VGA 
    vga_driver vga_driver_inst (
        .clock(clock_25MHz),
        .reset(1'b0),
        .color_in(color),
        .next_x(next_x),
        .next_y(next_y),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .sync(sync),
        .clk(clk),
        .blank(blank)
    );
	 
endmodule 