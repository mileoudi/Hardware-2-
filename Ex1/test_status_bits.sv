module test_status_bits(
    input logic clk,
    input logic [7:0] status_bits
);

    always @(posedge clk) begin
	if (!$isunknown(status_bits)) begin
        assert (!(status_bits[0] & status_bits[1])) else $error("Zero and Infinity bits are both asserted");
        assert (!(status_bits[0] && status_bits[2])) else $error("Zero and Invalid bits are both asserted");
        assert (!(status_bits[0] && status_bits[3])) else $error("Zero and Tiny bits are both asserted");
        assert (!(status_bits[0] && status_bits[4])) else $error("Zero and Huge bits are both asserted");
        assert (!(status_bits[0] && status_bits[5])) else $error("Zero and Inexact bits are both asserted");
        assert (!(status_bits[1] && status_bits[3])) else $error("Infinity and Tiny bits are both asserted");
        assert (!(status_bits[1] && status_bits[4])) else $error("Infinity and Huge bits are both asserted");
        assert (!(status_bits[1] && status_bits[5])) else $error("Infinity and Inexact bits are both asserted");
        assert (!(status_bits[2] && status_bits[3])) else $error("Invalid and Tiny bits are both asserted");
        assert (!(status_bits[2] && status_bits[4])) else $error("Invalid and Huge bits are both asserted");
        assert (!(status_bits[2] && status_bits[5])) else $error("Invalid and Inexact bits are both asserted");
	end
    end
endmodule

