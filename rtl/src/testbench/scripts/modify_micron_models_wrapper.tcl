# Wrapper for use in development are only.

# Sets up some functions which have same name as cC procedures, so that
# modify_micron_models.tcl can be run outside cC (i.e. in pure tcl)

#Select your environment uncommenting the line:
global ddr_mode src_dir dst_dir top script_dir


set ddr_mode           [lindex $argv 0]
set ddr_dir            [lindex $argv 1]
set script_dir         [lindex $argv 2]
set src_dir            "$ddr_dir/[string tolower $ddr_mode]_unmodified"
set dst_dir            "$ddr_dir/[string tolower $ddr_mode]_modified"
set top                "Phy"


proc get_top_design_name {} {
  return $::top
}
proc get_configuration_parameter {param} {
  switch $param {
    Tc_ddr_mode 	{return $::ddr_mode}
    Source_dir  	{return $::src_dir}
    Dest_dir		{return $::dst_dir}
  }
  return -1
}
source $script_dir/modify_micron_models.tcl


