#---------------------------------------
# Package Name    : opus1_pkg
# Package Version : 1.0
# Date            : 12/18/02
# Author          : Gill Romero
#                   57 Loring Road
#                   Winthrop, MA 02152
#                   (617) 846-1655  Fax: (617) 846-7580
#                   romero@ieee.org  
#---------------------------------------
# Description     :
# General utilities
# @HexToBin, converts a single hex digit number into a four bits binary.
# @tokenize, it separates in tokens the input file. 
#---------------------------------------
# Revision History:5
#  1.0 / <date>   : Template.
#---------------------------------------
package opus1_pkg;

#----------------------------------------------------------------#
# Useful utilities                                               #
#----------------------------------------------------------------# 

#----------------------------------------------------------------#
# HexToBin : Convert an hex number into binary.                  #
#----------------------------------------------------------------# 
sub HexToBin {
    # Subroutine to convert a hex number into binary.
    # Valid inputs are:
    # '0' - '9' and 'a' - 'f' or 'A' to 'F'
    my %htob = ('0','0000','1','0001','2','0010','3','0011',
                '4','0100','5','0101','6','0110','7','0111',
                '8','1000','9','1001','a','1010','b','1011',
                'c','1100','d','1101','e','1110','f','1111' );

    my $hexnum = lc $_[0];
    if(($hexnum le '9' && $hexnum ge '0') ||
       ($hexnum le 'f' && $hexnum ge 'a') ) {
        # Pay attention the use of brackets.
        #print " ---> $htob{$hexnum}\n";
        return $htob{$hexnum};
    }
    else {
        return '';
    }
}

1;


#----------------------------------------------------------------#
# Takes a file and tokenize it                                   #
#----------------------------------------------------------------# 

sub tokenize {

# local variables
  
    my ($line)         = @_;
    my $this_token     = "";
    my $not_done       = 1;
    my $char_index     = 0;
    my $next_char      = "";
    my $inside_token   = 0; 
    my $inside_special = 0;
    my $inside_quotes  = 0; 
    my @tokens         = ();
    my $len            = length($line);

    while ($not_done) {
        if ($char_index >= $len) {
            $not_done = 0;
            if (($inside_token)|($inside_special)) {
                $tokens[++$#tokens] = $this_token; 
            }; 
        }
        else {
            $next_char = substr($line,$char_index++,1);
            if ($inside_token) {
                if ($next_char =~ /\s/) {
                    # end of token so add to list and go back to looking
                    $tokens[++$#tokens] = $this_token;  
                    $inside_token = 0;        
                }
                elsif ($next_char =~ /[\w\'\`\$\.]/) {
                    # add this character to token 
                    $this_token .= $next_char;
                }
                else {
                    # not part of this token so add current token
                    # to the list and back up char so it doesn't get lost
                    $tokens[++$#tokens] = $this_token;  
                    $inside_token = 0;
                    $char_index--;
                };        
            }
            elsif ($inside_quotes) {
                if ($next_char =~ /\"/) {
                    $this_token .= $next_char;
                    $tokens[++$#tokens] = $this_token;  
                    $inside_quotes = 0;        
                }
                else { # add this character to token 
                    $this_token .= $next_char;
                };
            } 
            elsif ($inside_special) {
                if ($next_char =~ /\s/) {
                    # end of token so add to list and go back to looking
                    $tokens[++$#tokens] = $this_token;  
                    $inside_special = 0;        
                }
                elsif ($next_char =~ /[\w\'\`\$\.]/) {
                    # not part of this token so add current token
                    # to the list and back up char so it doesn't get lost  
                    $tokens[++$#tokens] = $this_token;  
                    $inside_special = 0;
                    $char_index--;   
                }
                elsif ($next_char =~ /[\&\=\|\>\<]/) {
                    # another character of a multi charcacter non-word token
                    $this_token .= $next_char;
                }
                else { # must be garbage!
                    print qq![$0] Error: Syntax error in file -> ("$this_token$next_char" ?)\n!;
                    exit(99);
                };
            }
            else { # looking for a token
                if ($next_char =~ /\s/) {
                    # do nothing still looking for a token; 
                }
                elsif ($next_char =~/\"/) {
                    $this_token = $next_char;
                    $inside_quotes = 1;         
                }
                elsif ($next_char =~ /[\w\'\`\$\.]/) { # normal identifiers
                    $this_token = $next_char;
                    $inside_token = 1; 
                }
                elsif ($next_char =~/[\)\(\;\,\]\[\+\-\*\/\%\}\{\:\@\"\#\?]/){
                    # things that are always single character tokens
                    $tokens[++$#tokens] = $next_char;  
                }
                elsif ( $next_char =~ /[\~\!\&\|\^\<\>\=]/ ){
                    # things that may (or may not) be part of a multi character non-word
                    $this_token = $next_char;
                    $inside_special = 1;
                }
                else {
                    print qq![$0] Error: Syntax error in file, whats this character? "$next_char"\n!;
                    exit(99);        
                };  
            };
        };
    };

    return @tokens;
};

1;
