//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections
    wire mux_not_o;

    mux mux_not (.d0(1'b1), .d1(1'b0), .sel(b), .y(mux_not_o));
    mux mux0 (.d0(b), .d1(mux_not_o), .sel(a), .y(o));


endmodule
