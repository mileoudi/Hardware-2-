
module test_status_z_combinations(
    input logic clk,
    input logic [7:0] status_bits,
    input logic [31:0] z, a, b
);

    localparam int ZERO    = 0;
    localparam int INF     = 1;
    localparam int NAN     = 2;
    localparam int TINY    = 3;
    localparam int HUGE    = 4;

    sequence nan_condition;
        ($past(a[30:23],3) == 8'h00 && $past(b[30:23],3) == 8'hFF) || 
        ($past(a[30:23],3) == 8'hFF && $past(b[30:23],3) == 8'h00);
    endsequence

    assert property (@(posedge clk) status_bits[ZERO] |-> (z[30:23] == 8'h00))
        else $error("ERROR: ZERO status bit is set but exponent of 'z' is not zero.");

    assert property (@(posedge clk) status_bits[INF] |-> (z[30:23] == 8'hFF)) 
        else $error("ERROR: INF status bit is set but exponent of 'z' is not all ones.");

    assert property (@(posedge clk) status_bits[NAN] |-> nan_condition)
        else $error("ERROR: NAN status bit is set but exponents of 'a' and 'b', 3 cycles ago, are not in required condition.");

    assert property (@(posedge clk) status_bits[HUGE] |-> (
        (z[30:23] == 8'hFF) ||
        (z[30:23] == 8'hFE && z[22:0] == 23'h7FFFFF)
    )) else $error("ERROR: HUGE status bit is set but 'z' is not in a valid maxNormal or inf format.");

    assert property (@(posedge clk) status_bits[TINY] |-> (
        (z[30:23] == 8'h00) ||
        (z[30:23] == 8'h01 && z[22:0] == 23'h000000)
    )) else $error("ERROR: TINY status bit is set but 'z' is not in a valid minNormal or zero format.");

endmodule