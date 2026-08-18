class arithmetic_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(arithmetic_seq)

    seq_item req;

    function new(string name = "arithmetic_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i <= 8; i++) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                ce == 1;
                mode == 1;
                inp_valid == 2'b11;
                cmd == i;
                //OA == 8'h04;
                //OB == 8'h04;

                if (i == 2 || i == 3)
                    cin inside {0, 1};
                else
                    cin == 0;
            });
            finish_item(req);
        end
    endtask
endclass

class logical_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(logical_seq)

    seq_item req;

    function new(string name = "logical_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i <= 13; i++) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                ce == 1;
                mode == 0;
                cmd == i;
                inp_valid == 2'b11;
            });
            finish_item(req);
        end
    endtask
endclass

class mul_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(mul_seq)

    seq_item req;

    function new(string name = "mul_seq");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                cin == 0;
                ce == 1;
                mode == 1;
                cmd == 4'd9;
                inp_valid == 2'b11;
            });
            finish_item(req);
        end
    endtask
endclass

class mul_shift_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(mul_shift_seq)

    seq_item req;

    function new(string name = "mul_shift_seq");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                cin == 0;
                ce == 1;
                mode == 1;
                cmd == 4'd10;
                inp_valid == 2'b11;
            });
            finish_item(req);
        end
    endtask
endclass

class rol_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(rol_seq)

    seq_item req;

    function new(string name = "rol_seq");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                ce == 1;
                mode == 0;
                cmd == 4'b1100;
                inp_valid == 2'b11;
            });
            finish_item(req);
        end
    endtask
endclass

class ror_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(ror_seq)

    seq_item req;

    function new(string name = "ror_seq");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {
                ce == 1;
                mode == 0;
                cmd == 4'b1101;
                inp_valid == 2'b11;
            });
            req.wait_cycle = 0;
            finish_item(req);
        end
    endtask
endclass

class err_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(err_seq)

    seq_item req;

    function new(string name = "err_seq");
        super.new(name);
    endfunction

    task body();
        repeat (10) begin
            req = seq_item::type_id::create("req");
            req.c4.constraint_mode(0);
            start_item(req);
            assert(req.randomize() with {
                ce == 1;
                inp_valid == 2'b11;
                mode inside {0, 1};
                solve mode before cmd;
                if (mode == 1)
                    cmd inside {[4'b1011 : 4'b1111]};
                else
                    cmd inside {[4'b1110 : 4'b1111]};
            });
            finish_item(req);
            //req.c4.constraint_mode(1);
        end
    endtask
endclass

class wait_2_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(wait_2_seq)

    function new(string name = "wait_2_seq");
        super.new(name);
    endfunction

    task body();
        seq_item opa_item;
        seq_item opb_item;

        opa_item = seq_item::type_id::create("opa_item");
        start_item(opa_item);
        assert(opa_item.randomize() with {
            ce == 1'b1;
            mode == 1'b1;
            cmd == 4'b0000;
            OA == 8'd02;
            OB == 8'd20;
            cin == 1'b0;
            inp_valid == 2'b01;
        });
        opa_item.wait_cycle = 2;
        finish_item(opa_item);

        opb_item = seq_item::type_id::create("opb_item");
        start_item(opb_item);
        assert(opb_item.randomize() with {
            ce == 1'b1;
            mode == 1'b1;
            cmd == 4'b0000;
            OA == 8'd02;
            OB == 8'd20;
            cin == 1'b0;
            inp_valid == 2'b10;
        });
        opb_item.wait_cycle = 0;
        finish_item(opb_item);
    endtask
endclass

class wait_16_seq extends uvm_sequence #(seq_item);
    `uvm_object_utils(wait_16_seq)

    function new(string name = "wait_16_seq");
        super.new(name);
    endfunction

    task body();
        seq_item opa_item;

        opa_item = seq_item::type_id::create("opa_item");
        start_item(opa_item);
        assert(opa_item.randomize() with {
            ce == 1'b1;
            mode == 1'b1;
            cmd == 4'b0000;
            OA == 8'd02;
            OB == 8'd20;
            cin == 1'b0;
            inp_valid == 2'b01;
        });
        opa_item.wait_cycle = 16;
        finish_item(opa_item);
    endtask
endclass
