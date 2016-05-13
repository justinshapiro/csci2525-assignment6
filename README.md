For this assignment (strings.asm) you are to create procedures which perform the following functions:

1.  str_cat - concatenates a string to the end of a target string.

      a)  You must be sure there is enough memory allocated at the end of the target string to accomdate the new string.  If not there should be an error message so indicating.
          Sample Call:   INVOKE  str_cat, ADDR source, ADDR target
      
2.  str_n_cat - 
      b)  Copy n characters of the source string to the end of a target string.  Again you must be sure there is enough memory allocated to accomplish this.
                    Sample Call:   INVOKE  str_cat, ADDR source, ADDR target, n
                    
3.  str_str -
      c)  locate a substring in a string.  
      d)  if a match is found; 
               return the position of the first occurance of the substring in eax and
               set the ZERO flag
               
               Sample Call:  INVOKE str_str, ADDR source, ADDR target
               
               
4.  Create a menu that allows the user to chose which of these to test.  Set the default string length to 25.  The user will be able to enter the strings as appropriate for the menu option selected.

5.  As always, basic error checking.

6.  After each menu option has completed have the user press a key to continue.  At this time the window should clear and the menu presented.  

7.  I reserve the right to grade program style, to include commenting, passing of variables, etc.    