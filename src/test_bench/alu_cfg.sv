class alu_config extends uvm_object;
	`uvm_object_utils(alu_config)
  //virtual
  virtual alu_inf vif;
//input agent
  uvm_active_passive_enum input_agent_is_active;
//output agent
  uvm_active_passive_enum output_agent_is_active;

  
  function new(string name="alu_config");
	super.new(name);
  endfunction

endclass
