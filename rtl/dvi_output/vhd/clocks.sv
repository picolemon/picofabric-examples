// ###############################################################################
// # [ clocks - Clock generation ]
// # =========================================================================== #
// # PLL clock simulation
// ###############################################################################
module clocks
(
    // Inputs
    input clk_i,			// External system clock input (clock wired directly to fpga IO)
    // Outputs	    
    output clk0_o,			// Clock 0 output @ 48000000Hz ( Target: 48000000Hz, error: 0Hz ) Sys clock
    output clk1_o,			// Clock 1 output @ 38100000Hz ( Target: 38250000Hz, error: 150000Hz ) VGA pixel clock
    output clk2_o,			// Clock 2 output @ 190500000Hz ( Target: 191250000Hz, error: 750000Hz ) VGA pixel shift clock x 5
    output clk3_o,			// Clock 3 output @ 0Hz ( Target: 0Hz, error: 0Hz ) 
    output locked			// PLL locked
);

    wire CLKOP_internal;

    (* ICP_CURRENT="12" *) 
    (* LPF_RESISTOR="8" *) 
    (* MFG_ENABLE_FILTEROPAMP="1" *) 
    (* MFG_GMCREF_SEL="2" *)    
    EHXPLLL
    #(
            
        .INTFB_WAKE     ("DISABLED"),
        .PLL_LOCK_MODE  (0),
        .STDBY_ENABLE   ("DISABLED"),
        .PLLRST_ENA     ("DISABLED"),
        .DPHASE_SOURCE  ("DISABLED"),        

        .CLKI_DIV       (1),
        .CLKFB_DIV      (1),
        .FEEDBK_PATH    ("CLKOP"),
    
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE   ("ENABLED"),
        .CLKOP_DIV      (12),
        .CLKOP_CPHASE   (11),
        .CLKOP_FPHASE   (0),
    
        .OUTDIVIDER_MUXB("DIVB"),
        .CLKOS_ENABLE   ("ENABLED"),
        .CLKOS_DIV      (15),
        .CLKOS_CPHASE   (14),
        .CLKOS_FPHASE   (0),
    
        .OUTDIVIDER_MUXC("DIVC"),
        .CLKOS2_ENABLE  ("ENABLED"),
        .CLKOS2_DIV   (3),
        .CLKOS2_CPHASE(2),
        .CLKOS2_FPHASE(0),
    
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKOS3_ENABLE("DISABLED"),
        .CLKOS3_DIV   (1),
        .CLKOS3_CPHASE(0),
        .CLKOS3_FPHASE(0),
        
    )
    clocks_pll_inst
    (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk_i),
        .CLKOP(CLKOP_internal),
        .CLKOS (clk1_o),
        .CLKOS2(clk2_o),
        .CLKOS3(clk3_o),
        .CLKFB(CLKOP_internal),
        .CLKINTFB(),
        .PHASESEL1(1'b0),
        .PHASESEL0(1'b0),
        .PHASEDIR(1'b0),
        .PHASESTEP(1'b0),
        .PHASELOADREG(1'b0),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .ENCLKOS(1'b0),
        .ENCLKOS2(1'b0),
        .ENCLKOS3(1'b0),
        .LOCK(locked)
    );

    assign clk0_o = CLKOP_internal;

endmodule 