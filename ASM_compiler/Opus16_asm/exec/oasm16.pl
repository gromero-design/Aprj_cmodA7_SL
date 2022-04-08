#!/usr/bin/perl -w  
#---------------------------------------
# Script Name     : oasm_asm.pl
# Script Version  : 6.0
# Date            : 02/12/21
# 
# Author          : Gill Romero
#                   57 Loring Road
#                   Winthrop, MA 02152
#                   (617) 846-1655  Fax: (617) 846-7580
#                   (617)-905-0508 (cell phone)
#                   romero@ieee.org  
#---------------------------------------
# Description     :
# Opus1 assembler, use an opcode table and a assembler file as
# inputs.
# command line:
# perl oasm.pl -t <opcode_table> -u <user> -f <asm_file> [-d n]
# -d 1
# -d 2 display every assembly line
#
# assembler format:
#  case insensitive.
#  comments start with //
#  hex number are written with 'h preceding them.
#  decimal numbers are written straight, starting with non zero digit.
#  'define', 'dw' (define word), 'dt' (define text) and
#  'ds' (define storage or reserve space) are reserved words.
#  'dw' , 'dt' and 'ds' must be terminated with semicolon.
#  Spaces and comma are valid separator for 'dw'
#  'dw' is used for hex ('h0123) and decimal (34) numbers,
#   single ascii characters ('a' or "b") and for ascii strings
#  'help me' or "help me". The order in memory is: the first character
#  goes to the lower memory position.
#  'dt' is for text strings only. It saves the string with a
#  null terminator character at the end. Also the first character
#  correspond to the lower memory address and the last one followed by
#  the null are at the top memory address. It is opposite of 'dw'.
#  Examples:
#
#    define hexnum 'h0123 (hexadecimal digits)
#    define digit    0123 (decimal digits)
#
#    mem1:  dw    1 2 3,4; // decimal numbers
#           dw    'habc,'h128,'hff; // hex numbers
#           dw    'a',"b" "c" '-' '1' '2' '3'; // single ASCII characters
#           dw    "h" "e" 'l' 'p' ' ' 'm' 'e'; // single ASCII characters
#           dw    "define_word"; // ASCII string
#           dw    hexnum; // uses above define.
#           dw    text3; // uses label text3 as an address

#    text3: dt    "define_text with null teminated string.";
#           dt    '9876543210';   // in memory: '9' '8' .... '1' '0' 0
#           dw    '0123456789',0; // behaves like the previous line.
#
#   storage: ds 100;   // reserve 100 words
#            ds 'hff;  // reserve 255 words
#            ds digit; // reserve 123 words
#            ds hexnum;// reserve 291 words
#
#  opcodes are define in opus1_asm.tab
#  labels are any name followed by a colon.
#    main: // is a valid label.
#  assembly line is terminated with a semicolon.
#
# Examples:
#    main:  nop; // comment
#    start: ldrv  r1,'h123; // load reg 1 with hex value
#           cmprv r2,"J";   // compare reg 2 with ASCII char J
#           cmprv r1,'a';   // compare reg 1 with ASCII char a
#
#
#---------------------------------------
# Revision History:
#  1.0 / 12-08-01 : Template.
#  1.0 / 12-08-02 : Initial
#  2.0 / 08-09-05 : Added single ASCII char for inmediate operands.
#                   Added defines and label for dw.
#  2.1 / 09-02-05 : Implemented loop counter field cn
#                   Added set/clear bit field bn on user flags
#                   Added check for tTfT on user flags
#
#  3.0 / 02-25-06 : Implemented for 16 bit processor
#  4.0 / 11-12-06 : Added Altera MIF file
#                   Separate bin file generation.
#  4.0 / 11-18-06 : MEM file is now a hex file
#                   HEX file is now an INTEL Hex format.
#                   Removed option program size, now is fixed to a max of 64K
#                   The program size is calculated automatically.
#  5.0 / 12-24-07 : Added a # terminator to the mem output file.
#  6.0 / 02-09-21 : Define Storage (ds) accepts 'define' constructs
#		 02-12-21 : @ token accept label
#		 11-09-21 : Added mM field, now is rRpPcCmM
#---------------------------------------
# Add package directory into enviroment.
unshift (@INC,"../exec"); #push (@INC,"../packages");
require opus1_pkg; # require ("opus1_pkg.pm");

# Iniialize variables
$rev          = "version 6.1";
$date         = "11-09-21";
# User variables
$help         = 0;
$debug        = 0;
$error        = 0;
@error_msg    = ();
$asm          = "";
$table        = "";
$user         = ""; # user option, not used.
$size         = 65536;
$overwrite    = 0;
#%opcode       = ("",0);  # nemonics , hex value.
#%opbytes      = ("",0);  # nemonics , dec value.
#%oporder      = ("",0);  # nemonics , dec value.
#%program      = (0,0);   # program counter , opcode value.
#%program_gap  = (0,0);   # start and end adrress gap fille with 0s.
#%defines      = ("",0);  # macro defintion table.

# miscellaneous.
$saved_pc     = 0;
$rsrc         = 0; # register field.
$rdst         = 0; # register field.

$temp1        = 0;
$temp2        = 0;

# System variables.
($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
$mon += 1;    ## months got from 0-11
$time_stamp   = "$mon/$mday/$year  $hour:$min:$sec";

$debug_tab    = 0;
$debug_asm    = 0;

################################ USER ARGUMENTS ############################
# get the users arguments
$argnum = 0;
while ($argnum <= $#ARGV) {
    $arg = $ARGV[$argnum];
    if ($arg =~ /^\-(.*)$/) {
        $arg2 = $1; 
#       print " $0\t$argnum\t$#ARGV\t$arg\t$arg2\n";
        $arg2 =~ tr/A-Z/a-z/;
        if ($arg2 =~/^h$/) {
            $help = 1;
        }
        elsif ($arg2 =~/^ow/) {
            $overwrite = 1;
        }
        elsif ($arg2 =~ /^v$/) {
            print "[$0] Info:  Version $rev Runtime $time_stamp\n";
        }
        elsif ($arg2 =~ /^f$/) {
            if ($argnum < $#ARGV) {
                $asm = $ARGV[++$argnum];
            }
            else {
                $error_msg[$error++] = "[$0] Error: -f specified but no file name !\n"; 
            };
        }
        elsif ($arg2 =~ /^t$/) {
            if ($argnum < $#ARGV) {
                $table = $ARGV[++$argnum];
            }
            else {
                $error_msg[$error++] = "[$0] Error: -t specified but no file name!\n"; 
            };
        }
        elsif ($arg2 =~ /^u$/) {
            if ($argnum < $#ARGV) {
                $user = $ARGV[++$argnum];
            }
            else {
                $error_msg[$error++] = "[$0] Error: -u specified but no user option!\n"; 
            };
        }
        elsif ($arg2 =~ /^d$/) {
            if ($argnum < $#ARGV) {
                $debug = $ARGV[++$argnum];
                if ($debug !~/\d+/) {
                    $error_msg[$error++] = "[$0] Error: -d specified but not a number!\n"; 
                };
            }
            else {
                $debug = 1; # default
            };
        }
        else {
            $error_msg[$error++] = "[$0] Error: unknown option >>$arg<<!\n";
        };
    }
    else { # it's an error!
        $error_msg[$error++] = "[$0] Error: unknown option >>$arg<<!\n";
    };  
    $argnum++;
};

# make sure that asm is set 
if (($asm eq "") && ($help == 0)) {
    $error_msg[$error++] = "[$0] Error: Required asm file with -f flag!\n";
};
if (($table eq "") && ($help == 0)) {
    $error_msg[$error++] = "[$0] Error: Required table file with -t flag!\n";
};

################################ ERROR HANDLER and HELP ####################

if ($error) {
    print "\a";
    if (($error > 0) && ($help == 0)) {
        print "[$0] Error:******************************************************\n";
        foreach $error_msg (@error_msg) {
            print "$error_msg";
        };
        print "[$0] Error:******************************************************\n";
    };
    exit(99);
}; 


if ( ($debug >= 1) || $help) {
    print "\n";
    print "[$0] Debug: Asm file    -f <file_name>  = $asm         \n";
    print "[$0] Debug: Table  file -t <file_name>  = $table       \n";
    print "[$0] Debug: Debug       -d <1-9>        = $debug       \n";
    print "[$0] Debug: Version     -v              = $rev         \n";
    print "[$0] Debug: Help        -h              = $help        \n"; 
    print "\n";
};

#################### State Machine for Table Processing ####################

$state  = "BEGIN";

if (open(TABLE,"$table")) {
    while (<TABLE>) {
        chomp;
        # use c preprocessor to strip /* */ comments
        # need to be implemented.
        # get rid of excess whitespace
        # first leading and trailing
        s/^\s*(.*?)\s*$/$1/;
        # then multiple
        s/\s+/ /g;
        # get rid // comments
        s/\/\/.*$//; # it was s/\/\/.*$/$1/
        if ($_) {
            if($debug >= 1 && $debug_tab) {
                print "[$0] Debug: Line  : $_\n";
            }
            # tokenize line
            @tokens = opus1_pkg::tokenize($_);
            if ($debug >= 2 && $debug_tab) {
                print "[$0] Debug: Tokens: \n";
                foreach $token (@tokens) {
                    print "[$0] Debug:    $token\n";
                }; 
                getc(STDIN);
            };

            foreach $token (@tokens) {
                if($debug >= 2 && $debug_tab) {
                    print " : State -> $state \n";
                }
                if ($state eq "BEGIN") {
                    if ($token =~ /[\w]+/) {
                        $state = "LIST_OF_VALUES";
                        $prv_token = lc $token;
                    }
                    else {
                        print "[$0] \aError: no valid opcode name. \n";
                        exit(99); 
                    }; 
                }
                elsif ( $state eq "LIST_OF_VALUES" ) {
                    if ($token =~ /[0-9a-fA-F]/) {
                        $state = "LIST_OF_VALUES2";
                        $opcode{$prv_token} = hex($token);
                    }
                    else {
                        print "[$0] \aError: not a valid hex number. \n";
                        exit(99); 
                    }; 
                }
                elsif ($state eq "LIST_OF_VALUES2") { 
                    if ($token =~ /[0-9]/) {
                        $state = "LIST_OF_VALUES3";
                        $opbytes{$prv_token} = $token;
                    }
                    else {
                        print "[$0] \aError: not a valid decimal number. \n";
                        exit(99); 
                    };
                }
                elsif ($state eq "LIST_OF_VALUES3") { 
                    if ($token =~ /[0-9]/) {
                        $state = "BEGIN";
                        $oporder{$prv_token} = $token;
                    }
                    else {
                        print "[$0] \aError: not a valid decimal number. \n";
                        exit(99); 
                    }; 
                }
                else {
                    print "[$0] \aError: bad parse state = $state. (program error !!)\n";
                    exit(99);
                }; 
            }; # foreach $token
        }; 
    }; #while TABLE
    close(TABLE);
}
else {
    print "\a"; # BELL
    print "[$0] Error: Can't open TABLE: $table for read, please check file name. \n";
    print "[$0] Error: Sorry can't continue. \n";
    exit(99);
};  


if ($debug >= 1 && $debug_tab) {
#if ($debug == 99) {
    print "\n";
    print "[$0] Debug: Table list found: \n";
    foreach $opc (sort keys %opcode) {
        printf ("[$0] Debug: %6s %-4x %4d %2d\n",$opc, $opcode{$opc},$opbytes{$opc},$oporder{$opc});
    };  
    print "\n";
};

if($debug == 99) {
    print "\n";
    do {
        print " Enter opcode : ";
        chomp ($input = <STDIN>);
        if($input ne 'x') {
            $code  = lc $input;
            if($value = $opcode{$code}) {
                $bytes = $opbytes{$code};
                $order = $oporder{$code};
                printf ("\tcode=%s value=%x bytes=%d order=%d\n",$code,$value,$bytes,$order);
            }
            else {
                print ("\n\t !!! Invalid or undefined opcode.\n");
            }
        }
        else {
            print "\n Exit by user. Bye...\n";
        }
    }while ($input ne 'x');
    print "\n";
}

#################### State Machine for Asm Processing ####################

$state     = "BEGIN";
$sub_state = "BEGIN";

if (open(ASM,"$asm")) {
    while (<ASM>) {
        chomp;
        # use c preprocessor to strip /* */ comments
        # need to be implemented.

        # get rid of excess whitespace
        # first leading and trailing
        s/^\s*(.*?)\s*$/$1/;
        # then multiple
        s/\s+/ /g;
        # get rid // comments
        s/\/\/.*$//; # it was s/\/\/.*$/$1/
        if ($_) {
            if($debug >= 1 && $debug_asm) {
                print "\n---\n[$0] Debug: Line  : $_\n";
            }
            # tokenize line
            @tokens = opus1_pkg::tokenize($_);
            if ($debug >= 2 && $debug_asm) {
                print "[$0] Debug: Tokens: \n";
                foreach $token (@tokens) {
                    print "[$0] Debug:    $token\n";
                }; 
                getc(STDIN);
            };

            foreach $token (@tokens) {
                if($debug >= 2 && $debug_asm) {
                    printf (" : State -> %-15s (%s)\n",$state,$sub_state);
                }
                if ($state eq "BEGIN") {
                    if($token =~ /\@/) {
                        # is an address statement.
                        $state     = 'ADDRESS';
                        $sub_state = "BEGIN";
                    }
                    elsif ($token =~ /^[\w]+/) {
                        # is a label or an opcode.
                        $prv_token = lc $token;
                        if($prv_token eq "dw") {
                            # is a define word statement
                            $list{$current_pc} = $_;
                            $state = 'DEFWORD';
                        }
                        elsif($prv_token eq "dt") {
                            # is a define text statement
                            $list{$current_pc} = $_;
                            $state = 'DEFTEXT';
                        }
                        elsif($prv_token eq "ds") {
                            # is a define storage.
                            $state = 'DEFSTORAGE';
                        }
                        elsif($prv_token eq "define") {
                            # is a define statement
                            $state = 'DEFINE';
                        }
                        else {
                            $state = "ASM_LINE";
                        }
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\;/) { # A0
                        # end of assembly line or empty line.
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    else {
                        print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                        exit(99); 
                    }; 
                }
                elsif($state eq "ADDRESS") { # A1
                    # take the address in hex or decimal. 
                    $saved_pc = $current_pc;
                    if($token =~ /^\'h([0-9a-fA-F]+$)/) {
                        # It is an hex number
                        $current_pc   = hex($1);
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^([0-9]+$)/) {
                        # It is a decimal number
                        $current_pc   = $1;
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^([\w]+$)/) {
                        # It is a defined or a label.
                        $value = $labels{$token};
                        if($value =~ /^\'h([0-9a-fA-F]+$)/) {
                        # It is an hex number
	                       $current_pc = hex($value);
                        } 
                        if($value =~ /^([0-9]+$)/) {
                        # It is a decimal number
	                       $current_pc = $value;
                        } 
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    else {
                        print "[$state,$sub_state]\a Error: not a address number.\n\t$_ \n";
                        exit(99); 
                    };
                } 
                elsif($state eq "DEFINE") { # A1
                    if($sub_state eq "BEGIN") {
                        # save the define word.
                        if($token =~ /^([\w]+)/) {
                            # It is a define word.
                            $prv_token = $1;
                            $state     = "DEFINE";
                            $sub_state = "DEFVALUE";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: not a define statement.\n\t$_\n";
                            exit(99); 
                        };
                    }
                    elsif($sub_state eq "DEFVALUE") { #A.
                        if($token =~ /^\'h([0-9a-fA-F]+$)/) {
                            # It is an hex number
                            $labels{$prv_token} = hex($1);
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        elsif($token =~ /^([0-9]+$)/) {
                            # It is a decimal number
                            $labels{$prv_token} = $1;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: incomplete define statement.\n\t$_\n";
                            exit(99); 
                        };
                    }
                    else {
                        print "[$state,$sub_state]\a Error: no valid assembly line. \n\t$_\n";
                        exit(99); 
                    }; 
                } 
                elsif($state eq "DEFWORD") { # Ax
                    # take the address in hex or decimal. 
                    $saved_pc = $current_pc;
                    if($token =~ /^\'h([0-9a-fA-F]+$)/) {
                        # It is an hex number
                        $program{$current_pc} = hex($1);
                        $current_pc++;
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^([0-9]+$)/) {
                        # It is a decimal number
                        $program{$current_pc} = $1;
                        $current_pc++;
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^[\'\"]([\s\w])[\'\"]$/) {
                        # It is an ASCII single character.
                        $program{$current_pc} = ord($1);
                        $current_pc++;
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^[\'\"](.*)[\'\"]$/) {
                        # It is an ASCII string.
                        $string = $1;
                        for($i=0;$string ne '';$i++){
                            $val = chop($string);
                            $program{$current_pc} = ord ($val);
                            $current_pc++;
                        }
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }

                    elsif($token =~ /^([\w]+$)/) {
                        # It is a defined or a label.
                        $program{$current_pc} = $1;
                        $current_pc++;
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\s|\,/) { # AX
                        # end of define word
                        $state     = "DEFWORD";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\;/) { # AX
                        # end of define word
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    else {
                        print "[$state,$sub_state]\a Error: not a define word. \n\t$_\n";
                        exit(99); 
                    }; 
                }
                elsif($state eq "DEFTEXT") { # Ax
                    # take the address in hex or decimal. 
                    $saved_pc = $current_pc;
                    if($token =~ /^[\'\"](.*)[\'\"]$/) {
                        # It is an ASCII string.
                        $string = $1;
                        @new_string = 0; # null terminator
                        for($i=0;$string ne '';$i++){
                            $val  = chop($string);
                            $temp = ord ($val);
                            unshift(@new_string,$temp);
                        }
                        $length = @new_string;
                        for($i=0;$i < $length;$i++){
                            $program{$current_pc} = $new_string[$i];
                            $current_pc++;
                        }
#                       $program{$current_pc} = 0; # null terminator
#                       $current_pc++;
                        $state     = "DEFTEXT";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\s|\,/) { # AX
                        # end of define word
                        $state     = "DEFTEXT";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\;/) { # AX
                        # end of define word
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    else {
                        print "[$state,$sub_state]\a Error: not a define word. \n\t$_\n";
                        exit(99); 
                    }; 
                }
                elsif($state eq "DEFSTORAGE") { # Ax
                    # take the address in hex or decimal. 
                    $saved_pc = $current_pc;
                    if($token =~ /^\'h([0-9a-fA-F]+$)/) {
                        # It is an hex number
                        $current_pc += hex($1);
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^([0-9]+$)/) {
                        # It is a decimal number
                        $current_pc += $1;
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /^([\w]+$)/) {
                        # It is a defined or a label.
                        $value = $labels{$token};
                        if($value =~ /^\'h([0-9a-fA-F]+$)/) {
                        # It is an hex number
	                       $offset = hex($value);
                        } 
                        if($value =~ /^([0-9]+$)/) {
                        # It is a decimal number
	                       $offset = $value;
                        } 
                        $current_pc += $offset;
                        $state     = "DEFSTORAGE";
                        $sub_state = "BEGIN";
                    }
                    elsif($token =~ /\;/) { # AX
                        # end of define word
                        $state     = "BEGIN";
                        $sub_state = "BEGIN";
                    }
                    else {
                        print "[$state,$sub_state]\a Error: not a address number. \n\t$_\n";
                        exit(99); 
                    }; 
                }
                elsif($state eq "ASM_LINE") {
                    $order = $oporder{$prv_token};
                    if($sub_state eq "BEGIN") {
                        if($token =~ /\:/) { # A2
                            # It is a label, save current counter into label
                            # table.
                            $labels{$prv_token} = $current_pc;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        elsif($token =~ /\;/) { # A3
                            # single word instruction.
                            $list{$current_pc} = $_;
                            $program{$current_pc} = $opcode{$prv_token};
                            $current_pc++;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        elsif($token =~ /^[rRpPcCmM]([0-9a-fA-F]$)/) {
                            # It is a register,pointer,counter or memory access field.
                            # is a single letter followed by single hex digit
                            $rsrc = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1A";
                        }
                        elsif($token =~ /^[fF]([0-9a-fA-F]$)/) {
                            # It is a user flag or port bit field.
                            $rsrc = hex($1);
                            $rdst =  0;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1A";
                        }
                        elsif($token =~ /^[tT]([0-9a-fA-F]$)/) {
                            # It is a user flag or port bit field.
                            $rsrc = hex($1);
                            $rdst =  1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1A";
                        }
                        elsif($token =~ /^([\w]+$)/) {
                            # It is a label for a two word instruction.
                            # possible a jump instruction.
                            $word1     = $prv_token;
                            $program{$current_pc} = $opcode{$prv_token};
                            $current_pc++;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1C";
                        }
                        elsif($token =~ /^\'h([0-9a-fA-F]+$)/) {
                            # It is an hex number for a two word instruction
                            # possible a jump instruction
                            $list{$current_pc} = $_;
                            $program{$current_pc} = $opcode{$prv_token};
                            $current_pc++;
                            $prv_token = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1B";
                        }
                        elsif($token =~ /^([0-9]+$)/) {
                            # It is an decimal number for a two word instruction
                            # possible a jump instruction
                            $list{$current_pc} = $_;
                            $program{$current_pc} = $opcode{$prv_token};
                            $current_pc++;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER1B";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER1A") {
                        if($token =~ /\;/) { # A4
                            $list{$current_pc} = $_;
                            if($order == 0) { # default
                                $rdst = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 1){ # reverse
                                $rdst = $rsrc;
                                $rsrc = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 5){ # reverse
				$temp1 = (($rdst << 7) | $rsrc);
                            }
                            else { # copy
                                $rdst = $rsrc;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        elsif($token =~ /\,/) {
                            $state     = "ASM_LINE";
                            $sub_state = "OPER2A";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER2A") {
                        if($token =~ /^[rRpP]([0-9a-fA-F]$)/) {
                            # It is a register or pointer field.
                            $rdst      = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER3A";
                        }
                        elsif($token =~ /^([\w]+$)/) {
                            # It is a label for a two word instruction.
                            # examples are : ldr/ldp/str/stp
                            $list{$current_pc} = $_;
                            if($order == 0) { # default
                                $rdst = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 1){ # reverse
                                $rdst = $rsrc;
                                $rsrc = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 5){ # reverse
				$temp1 = (($rdst << 7) | $rsrc);
                            }
                            else { # copy
                                $rdst = $rsrc;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token  = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        elsif($token =~ /^\'h([0-9a-fA-F]+$)/) {
                            # It is an hex number for a two word instruction
                            # examples are : ldr/ldp/str/stp
                            $list{$current_pc} = $_;
                            if($order == 0) { # default
                                $rdst = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 1){ # reverse
                                $rdst = $rsrc;
                                $rsrc = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 5){ # reverse
                                print "WARNING----oper2A---2-->\n\n";
				$temp1 = (($rdst << 7) | $rsrc);
                            }
                            else { # copy
                                $rdst = $rsrc;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        elsif($token =~ /^([0-9]+$)/) {
                            # It is an dec number for a two word instruction
                            # examples are : ldr/ldp/str/stp
                            $list{$current_pc} = $_;
                            if($order == 0) { # default
                                $rdst = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 1){ # reverse
                                $rdst = $rsrc;
                                $rsrc = 0;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            elsif($order == 5){ # reverse
                                print "WARNING-----oper2A---3->\n\n";
				$temp1 = (($rdst << 7) | $rsrc);
                            }
                            else { # copy
                                $rdst = $rsrc;
				$temp1 = (($rsrc << 4) | $rdst);
                            }
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        elsif($token =~ /^[\'\"](.*)[\'\"]$/) {
                            # It is an ASCII single character
                            # examples are : ldrv/cmprv r,"a"
                            $list{$current_pc} = $_;
                            if($order == 0) { # default
                                $rdst = 0;
                            }
                            elsif($order == 1){ # reverse
                                $rdst = $rsrc;
                                $rsrc = 0;
                            }
                            else { # copy
                                $rdst = $rsrc;
                            }
                            $temp1 = (($rsrc << 4) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token = ord($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER3A") {
                        if( ($order == 1) || ($order == 3) ) { # reverse
                            $temp = $rsrc;
                            $rsrc = $rdst;
                            $rdst = $temp;
                        }
                        elsif($order == 4){
                            $rdst = $rsrc;
                        }
                        else {
                            #default value
                        }
                        if($token =~ /\;/) { # A5
                            $list{$current_pc} = $_;
                            $temp1 = (($rsrc << 4) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        elsif($token =~ /\,/) {
                            $state     = "ASM_LINE";
                            $sub_state = "OPER4A";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER3B") {
                        if( $order == 5 ) { # copy value
                            $temp = $rsrc;
                            $rsrc = $rdst;
                            $rdst = $temp;
                        }
                        else {
                            #default value
                        }
                        if($token =~ /\;/) { # A5
                            $list{$current_pc} = $_;
                                print "WARNING----oper3B------>\n\n";
                            $temp1 = (($rsrc << 7) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $state     = "BEGIN";
                            $sub_state = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER4A") {
                        if($token =~ /^([\w]+$)/) {
                            # It is a label for a two word instruction.
                            # examples are : 
                            $list{$current_pc} = $_;
                            $temp1 = (($rsrc << 4) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token  = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        elsif($token =~ /^\'h([0-9a-fA-F]+$)/) {
                            # It is an hex number for a two word instruction
                            # examples are : xorv r1,'h123
                            $list{$current_pc} = $_;
                            $temp1 = (($rsrc << 4) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        elsif($token =~ /^([0-9]+$)/) {
                            # It is an hex number for a two word instruction
                            # examples are :
                            $list{$current_pc} = $_;
                            $temp1 = (($rsrc << 4) | $rdst);
                            $temp2 = $opcode{$prv_token};
                            $program{$current_pc} = $temp2 | ($temp1 << 8);
                            $current_pc++;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5A";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER5A") {
                        if($token =~ /\;/) { #\A7
                            $program{$current_pc} = $prv_token;
                            $current_pc++;
                            $sub_state = "BEGIN";
                            $state     = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER1B") {
                        if($token =~ /\;/) { # A8
                            $program{$current_pc} = $prv_token;
                            $current_pc++;
                            $sub_state = "BEGIN";
                            $state     = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER1C") {
                        if($token =~ /\;/) { # A9
                            $list{$current_pc-1} = $_;
                            if( ($word1 eq 'bra') || ($word1 eq 'bsr') ){
                                $program{$current_pc} = '_1_'.$prv_token;
                            }
                            else {
                                $program{$current_pc} = $prv_token;
                            }
                            $current_pc++;
                            $sub_state = "BEGIN";
                            $state     = "BEGIN";
                        }
                        elsif($token =~ /\,/) {
                            $sub_state = "OPER2C";
                            $state     = "ASM_LINE";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER2C") {
                        if($token =~ /^\'h([0-9a-fA-F]+$)/) {
                            # It is an hex number for a two word instruction
                            # examples are : bra nz,'h123
                            $list{$current_pc-1} = $_;
                            $temp2 = $opcode{$word1}; # original opcode
                            $cond  = $opcode{$prv_token}; # conditional part
                            $new_opc = ($cond << 12) | $temp2;
                            $program{$current_pc-1} = $new_opc;
                            $prv_token = hex($1);
                            $state     = "ASM_LINE";
                            $sub_state = "OPER3C";
                        }
                        elsif($token =~ /^([0-9]+$)/) {
                            # It is an decimal number for a two word instruction
                            # examples are : bra nz,13
                            $list{$current_pc-1} = $_;
                            $temp2 = $opcode{$word1}; # original opcode
                            $cond  = $opcode{$prv_token}; # conditional part
                            $new_opc = ($cond << 12) | $temp2;
                            $program{$current_pc-1} = $new_opc;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER3C";
                        }
                        elsif($token =~ /^[rRpP]([0-9a-fA-F]$)/) {
                            # It is a register or pointer field.
                            # example are: shl a,rd;
                            $list{$current_pc-1} = $_;
                            $rsrc = hex($1);
                            $temp2 = $opcode{$word1}; # original opcode
                            $mod   = $opcode{$prv_token}; # conditional part
                            $new_opc = ($mod << 12) | ($rsrc << 8) | $temp2;
                            $program{$current_pc-1} = $new_opc;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER5C";
                        }
                        elsif($token =~ /^([\w]+$)/) {
                            # It is an hex number for a two word instruction
                            # examples are : bra nz,label
                            $list{$current_pc-1} = $_;
                            $temp2 = $opcode{$word1}; # original opcode
                            $temp1 = lc $prv_token;
                            $cond  = $opcode{$temp1}; # conditional part
                            $new_opc = ($cond << 12) | $temp2;
                            $program{$current_pc-1} = $new_opc;
                            $prv_token = $1;
                            $state     = "ASM_LINE";
                            $sub_state = "OPER4C";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER3C") {
                        if($token =~ /\;/) {
                            $program{$current_pc} = $prv_token;
                            $current_pc++;
                            $sub_state = "BEGIN";
                            $state     = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        }; 
                    }
                    elsif($sub_state eq "OPER4C") {
                        if($token =~ /\;/) {
                            if( ($word1 eq 'bra') || ($word1 eq 'bsr') ){
                                $program{$current_pc} = '_1_'.$prv_token;
                            }
                            else {
                                $program{$current_pc} = $prv_token;
                                print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                                printf (" Current PC = %x, Opcode = %s \n",$current_pc,$word1);
                            }
                            $current_pc++;
                            $sub_state = "BEGIN";
                            $state     = "BEGIN";
                        }
                        else {
                            print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                            exit(99); 
                        };
                    } 
                    elsif($sub_state eq "OPER5C") {
                        if($token =~ /\;/) {
                            if( ($word1 eq 'shl') || ($word1 eq 'shr') ){
                                $sub_state = "BEGIN";
                                $state     = "BEGIN";
                            }
                            else {
                                print "[$state,$sub_state]\a Error: no valid assembly line.\n\t$_\n";
                                exit(99); 
                            }; 
                        }
                    }
                    else {
                        print "[$0]\a Error: no valid assembly line.\n\t$_\n";
                        exit(99); 
                    }; 
                }
                else {
                    print "[$0] \aError: bad parse state = $state. (program error !!)\n\t$_\n";
                    exit(99);
                }; 
            }; # foreach $token
        }; 
    }; #while ASM
    close(ASM);
}
else {
    print "\a"; #BELL
    print "[$0] Error: Can't open ASM: $asm for read, please check file name. \n";
    print "[$0] Error: Sorry can't continue. \n";
    exit(99);
};  


if ($debug >= 3 && $debug_asm) {
    print "[$0] Debug: Asm list found: \n";
    foreach $opc (sort keys %opcode) {
        printf ("Debug: %6s %-4x %2d %2d \n",$opc, $opcode{$opc},$opbytes{$opc},$oporder{$opc});
    };  
};




#################### Last pass, check labels #########################
foreach $label (sort keys %labels){
    foreach $pc (sort keys %program) {
        $value = $program{$pc};
#       if($value != '') {
            if($label eq $value) {
                $program{$pc} = $labels{$label};
            }
            else {
                if($value =~ /^\_1\_([\w]+$)/) {
                    if($label eq $1) {
                        $offset = $labels{$1} - $pc;
                        $program{$pc} = $offset & 0xffff;
                    }
                }
            }
#       }
    }
}

#################### Calculate the program size ##### ####################
# First define wich address is valid or has been used.
foreach $opc (sort keys %program){
    $valid_address{$opc} = 1;
}
# Default size for a 16 bit address is 64K = 65536
$prog_size = 0;
for($i=0;$i < $size;$i++) {
    if($valid_address{$i}) {
        $prog_size = $i;
    }
}
$prog_size++;

#################### Open files for Processing ###### ####################
if($asm =~ /^([\w]+)./) {
    $list_file    = $1.'.lst';
    $mif_file_alt = $1.'_alt.mif';
    $mif_file_xil = $1.'_xil.mif';
    $hex_file     = $1.'.hex';
    $coe_file     = $1.'.coe';
    $mem_file     = $1.'.mem';
    print "\n***************************************\n";
    print "Assembler and Date    : $rev: ($date)\n";
    print "Program size          : $prog_size\n";
    print "----------\n";
    print "Asm  file name        : $asm\n";
    print "List file name        : $list_file\n";
    print "----------\n";
    print "Hex  file name        : $hex_file\n";
    print "COE  file name        : $coe_file\n";
    print "MEM  file name        : $mem_file\n";
    print "Altera Mif  file name : $mif_file_alt\n";
    print "Xilinx Mif  file name : $mif_file_xil\n";
    print "*****************************************\n";
}
 
open(PROG,   ">$list_file")    || die ("!!! Could not open list file!!!\n");
open(ALT_MIF,">$mif_file_alt") || die ("!!! Could not open Altera mif file !!!\n");
open(XIL_MIF,">$mif_file_xil") || die ("!!! Could not open Xilinx mif file !!!\n");
open(HEX,    ">$hex_file")     || die ("!!! Could not open hex file !!!\n");
open(COE,    ">$coe_file")     || die ("!!! Could not open coe file !!!\n");
open(MEM,    ">$mem_file")     || die ("!!! Could not open mem file !!!\n");

#################### Generate the list file  #########################
# First generate the Header, labels and defines.
#
print PROG ("*****************************************\n");
print PROG ("Assembler and Date    : $rev: ($date)\n");
print PROG ("Program size          : $prog_size\n");
print PROG ("----------\n");
print PROG ("Asm  file name        : $asm\n");
print PROG ("List file name        : $list_file\n");
print PROG ("----------\n");
print PROG ("       Hex  file name : $hex_file\n");
print PROG ("       COE  file name : $coe_file\n");
print PROG ("       MEM  file name : $mem_file\n");
print PROG ("Altera Mif  file name : $mif_file_alt\n");
print PROG ("Xilinx Mif  file name : $mif_file_xil\n");
print PROG ("*****************************************\n");
print PROG ("\nLabels and Defines:\n");
foreach $label (sort keys %labels){
    $address = $labels{$label};
    printf PROG ("%15s: %04x \n",$label,$address);
	if ($debug >= 1) {
	    printf ("\t%15s: %04x \n",$label,$address);
	}
}
print "*****************************************\n";
print PROG ("*****************************************\n");
print PROG ("Opcode listing.\n");
#}

# Finally, generate the listing and binary files.
# Create the MEM file
$code_default = 0x0000;
printf MEM ("\#%04x\n",$prog_size);

for($i=0,$j=0;$i < $prog_size;$i++) {
    if($valid_address{$i}) {
        $code = $program{$i};
    }
    else {
        $code = $code_default;
    }
    $j++;
    if($j==8) {
        $j = 0;
        printf MEM ("%04x\n",$code);
    }
    else {
        printf MEM ("%04x ",$code);
    }
}
#printf MEM ("\#");


# Create the COE file
$code_default = 0x0000;
#printf COE ("Width=16;\n");
#printf COE ("Depth=%d;\n",$prog_size);
printf COE ("Memory_Initialization_Radix=16;\n");
printf COE ("Memory_Initialization_Vector=\n");

for($i=0,$j=0;$i < $prog_size;$i++) {
    if($valid_address{$i}) {
        $code = $program{$i};
    }
    else {
        $code = $code_default;
    }
    $j++;
    if($i==$prog_size-1) {
        printf COE ("%04x;\n",$code);
    }
    else {
        if($j==8) {
            $j = 0;
            printf COE ("%04x,\n",$code);
        }
        else {
            printf COE ("%04x,",$code);
        }
    }
}

# Create ALTERA MIF file
printf ALT_MIF ("Width=16;\n");
printf ALT_MIF ("Depth=%d;\n",$prog_size);
printf ALT_MIF ("Address_Radix=HEX;\n");
printf ALT_MIF ("Data_Radix=HEX;\n");
printf ALT_MIF ("Content\n");
printf ALT_MIF ("Begin\n");
for($i=0;$i < $prog_size;$i++) {
    if($valid_address{$i}) {
        $code = $program{$i};
        printf ALT_MIF ("%04x : %04x;\n",$i,$code);
    }
    else {$table        = "";
        printf ALT_MIF ("%04x : %04x;\n",$i,$code_default);
    }
}
printf ALT_MIF ("End;\n");

# Create XILINX MIF file.
for($i=0;$i < $prog_size;$i++) {
    if($valid_address{$i}) {
        $code = $program{$i};
        printf XIL_MIF ("%016b\n",$code);
    }
    else {$table        = "";
        printf XIL_MIF ("%016b\n",$code_default);
    }
}

# Create HEX file
for($i=0;$i < $prog_size;$i++) {
    $chksum = 2;
    if($valid_address{$i}) {
        $code = $program{$i};
        $chksum = ($chksum + ($i & 0xFF) + ($i >> 8)) & 0xFF;
        $chksum = ($chksum + ($code & 0xFF) + ($code >> 8)) & 0xFF;
        $chksum = -$chksum & 0xFF;
        printf HEX (":02%04x00%04x%02x\n",$i,$code,$chksum);
    }
    else {$table        = "";
        $chksum = ($chksum + ($i & 0xFF) + ($i >> 8)) & 0xFF;
#       $chksum = ($chksum + ($code & 0xFF) + ($code >> 8)) & 0xFF;
        $chksum = -$chksum & 0xFF;
        printf HEX (":02%04x00%04x%02x\n",$i,$code_default,$chksum);
    }
}
printf HEX (":00000001FF\n");

# Create LISTING file.
for($i=0;$i < $prog_size;$i++) {
    if($valid_address{$i}) {
        $code = $program{$i};
        printf PROG ("\n%04x   %04x",$i,$code);
        if($list{$i}) {
            printf PROG ("   %-6s",$list{$i});
        }
    }
}

#################### Close all files #########################
close (PROG);
close (ALT_MIF);
close (XIL_MIF);
close (HEX);
close (COE);
close (MEM);
#################### End Of OASM.PL perl file ################
