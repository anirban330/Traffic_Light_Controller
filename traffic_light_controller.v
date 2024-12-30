`timescale 1ns/1ps

module tlc_fsm(
    input wire i_clk,
    input wire i_rst,
    input wire i_EW_vd,
    output wire o_NS_red,
    output wire o_NS_yellow,
    output wire o_NS_green,
    output wire o_EW_red,
    output wire o_EW_yellow,
    output wire o_EW_green,
    output reg [5:0] count
);

    localparam [2:0] NS_GREEN = 3'b001,
                     YELLOW   = 3'b010,
                     EW_GREEN = 3'b100;

    reg [2:0] state, next_state;
    reg r_NS_red, r_next_NS_red;
    reg r_NS_yellow, r_next_NS_yellow;
    reg r_NS_green, r_next_NS_green;
    reg r_EW_red, r_next_EW_red;
    reg r_EW_yellow, r_next_EW_yellow;
    reg r_EW_green, r_next_EW_green;
    reg ns_to_ew;
    

    always @(posedge i_clk) begin
        if (i_rst) begin
            r_NS_red    <= 1'b0;
            r_NS_yellow <= 1'b0;
            r_NS_green  <= 1'b1;
            r_EW_red    <= 1'b1;
            r_EW_yellow <= 1'b0;
            r_EW_green  <= 1'b0;
            state       <= NS_GREEN;
            ns_to_ew    <= 1'b0;
            count       <= 10'b0;
        end else begin
            r_NS_red    <= r_next_NS_red;
            r_NS_yellow <= r_next_NS_yellow;
            r_NS_green  <= r_next_NS_green;
            r_EW_red    <= r_next_EW_red;
            r_EW_yellow <= r_next_EW_yellow;
            r_EW_green  <= r_next_EW_green;
            state       <= next_state;
        end

        // Counter Logic
        if (i_rst || (count >= 25 && i_EW_vd && state == NS_GREEN) || 
            (count == 4 && state == YELLOW) || 
            (count >= 25 && state == EW_GREEN && ~i_EW_vd)) 
            count <= 0;
        else 
            count <= count + 1;
    end

    always @(*) begin
        r_next_NS_red    = r_NS_red;
        r_next_NS_yellow = r_NS_yellow;
        r_next_NS_green  = r_NS_green;
        r_next_EW_red    = r_EW_red;
        r_next_EW_yellow = r_EW_yellow;
        r_next_EW_green  = r_EW_green;
        next_state       = state;

        case (state)
            NS_GREEN: begin
                if (count >= 25 && i_EW_vd) begin
                    next_state = YELLOW;
                    ns_to_ew   = 1'b0;
                end else begin
                    r_next_NS_red    = 1'b0;
                    r_next_NS_yellow = 1'b0;
                    r_next_NS_green  = 1'b1;
                    r_next_EW_red    = 1'b1;
                    r_next_EW_yellow = 1'b0;
                    r_next_EW_green  = 1'b0;
                end
            end

            YELLOW: begin
                if (count == 4) begin
                    if (ns_to_ew)
                        next_state = NS_GREEN;
                    else
                        next_state = EW_GREEN;
                end else begin
                    r_next_NS_red    = 1'b0;
                    r_next_NS_yellow = 1'b1;
                    r_next_NS_green  = 1'b0;
                    r_next_EW_red    = 1'b0;
                    r_next_EW_yellow = 1'b1;
                    r_next_EW_green  = 1'b0;
                end
            end

           EW_GREEN: begin
                if (count >= 25 && ~i_EW_vd) begin
                    next_state = YELLOW;
                    ns_to_ew   = 1'b1;
                end else begin
                    r_next_NS_red    = 1'b1;
                    r_next_NS_yellow = 1'b0;
                    r_next_NS_green  = 1'b0;
                    r_next_EW_red    = 1'b0;
                    r_next_EW_yellow = 1'b0;
                    r_next_EW_green  = 1'b1;
                end
            end

            default: begin
                r_next_NS_red    = 1'b0;
                r_next_NS_yellow = 1'b0;
                r_next_NS_green  = 1'b1;
                r_next_EW_red    = 1'b1;
                r_next_EW_yellow = 1'b0;
                r_next_EW_green  = 1'b0;
                next_state       = NS_GREEN;
                ns_to_ew         = 1'b0;
            end
        endcase
    end

    assign o_NS_red    = r_next_NS_red;
    assign o_NS_yellow = r_next_NS_yellow;
    assign o_NS_green  = r_next_NS_green;
    assign o_EW_red    = r_next_EW_red;
    assign o_EW_yellow = r_next_EW_yellow;
    assign o_EW_green  = r_next_EW_green;

endmodule
