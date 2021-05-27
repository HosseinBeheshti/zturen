# configure voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# I2C
set_property PACKAGE_PIN P15 [get_ports IIC_0_SDA]
set_property PACKAGE_PIN P16 [get_ports IIC_0_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports IIC_0_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports IIC_0_SDA]

# SW and LED
set_property IOSTANDARD LVCMOS33 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW[3]}]
set_property PACKAGE_PIN R19 [get_ports {SW[0]}]
set_property PACKAGE_PIN T19 [get_ports {SW[1]}]
set_property PACKAGE_PIN G14 [get_ports {SW[2]}]
set_property PACKAGE_PIN J15 [get_ports {SW[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN Y16 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN Y17 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN R14 [get_ports {LEDS[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports BP]
set_property PACKAGE_PIN P18 [get_ports BP]