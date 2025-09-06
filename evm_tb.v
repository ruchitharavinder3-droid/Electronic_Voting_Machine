module tb();
        reg rst,clk,cand1,cand2,cand3,voting_over;
        wire [31:0] rcnt1,rcnt2,rcnt3;
        evm uut(rst,clk,cand1,cand2,cand3,rcnt1,rcnt2,rcnt3,voting_over);
        
        initial begin
        clk = 0;
        forever #5 clk = ~clk;
        end

        initial begin
            rst=1'b1;
            cand1=1'b0;
            cand2=1'b0;
            cand3=1'b0;
            voting_over=1'b0;
            
            #20 rst=1'b0;
            #10 cand1=1'b1;
            #10 cand1=1'b0;
            
            #20 cand2=1'b1;
            #10 cand2=1'b0;
            
            #20 cand1=1'b1;
            #10 cand1=1'b0;
            
            #20 cand3=1'b1;
            #10 cand3=1'b0;
            
            #30 voting_over=1'b1;
            #50 rst=1'b0;
            #60 $stop;
        end
endmodule