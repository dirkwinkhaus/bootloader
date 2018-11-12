jmp lib_dependencies_end
	%include 'lib\data\romDataStructure.asm'								; loads interrupt 81h
	%include 'lib\data\variables.asm'									; 
	%include 'lib\data\strings.asm'										; 

lib_dependencies_end: