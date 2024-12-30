`timescale 1ns / 1ps

module traffic_tb();

  // Inputs
  reg i_clk;
  reg i_rst;
  reg i_EW_vd;

  // Outputs
  wire o_NS_red;  
  wire o_NS_yellow;
  wire o_NS_green; 
  wire o_EW_red;  
  wire o_EW_yellow;
  wire o_EW_green;
  wire [5:0] count;

  // Instantiate Traffic Light Controller
  tlc_fsm uut (
    .i_clk(i_clk),   
    .i_rst(i_rst),   
    .i_EW_vd(i_EW_vd),            
    .o_NS_red(o_NS_red),  
    .o_NS_yellow(o_NS_yellow),
    .o_NS_green(o_NS_green),
    .o_EW_red(o_EW_red),  
    .o_EW_yellow(o_EW_yellow),
    .o_EW_green(o_EW_green),
    .count(count)
   );

  // Clock generation
  always #5 i_clk = ~i_clk;
  always #25 i_EW_vd=~i_EW_vd;

  // Initial block for reset and input signal generation
  initial begin
    i_clk = 0;
    i_rst = 1;
    i_EW_vd = 0;
    
    
    #20 i_rst =0 ;    
         
         
  end

  // Monitor traffic light states
  initial begin
    $display("  NorthSouth    |   EastWest  ");
    $display(" R   Y    G     |   R   Y   G");
    $monitor(" %b   %b    %b     |   %b   %b   %b", 
      o_NS_red, o_NS_yellow, o_NS_green,
      o_EW_red, o_EW_yellow, o_EW_green);

    // Simulate for a period of time
    #5000 $finish;
  end


endmodule
