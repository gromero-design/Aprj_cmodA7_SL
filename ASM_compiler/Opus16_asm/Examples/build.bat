perl ..\exec\oasm16.pl -t ..\exec\opus1_asm.tab -f %1.asm

copy %1.coe ..\..\Opus16_cores_xil\prog_ram_example.coe
copy %1.mem ..\..\Opus16_cores_xil\prog_ram_example.mem
copy %1_xil.mif ..\..\Opus16_cores_xil\prog_ram_example.mif

move %1.mem .\temp\.
move %1.coe .\temp\.
move %1.hex .\temp\.
move %1.lst .\temp\.
move %1_alt.mif .\temp\.
move %1_xil.mif .\temp\.

echo "Directory is:..\..\Opus16_cores_xil" 
echo "%1.coe is renamed to prog_ram_example.coe"
echo "%1.mif is renamed to prog_ram_example.mif"
echo "%1.mem is renamed to prog_ram_example.mem"
echo "DONE"

