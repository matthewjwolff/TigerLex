# TigerLex
A lexical analyzer for the Tiger language using JLex.

Because we had to use a language named after the school's mascot.

##CSC4351 Project 1
- Kristen Barrett
- Matthew Wolff

##Information for graders:
1. This file is formatted with Markdown, simply because we used git to collaborate.
2. Contained in the git repository are the class files for JavaCup and JLex. We used this to test code on our local machines instead of using 'classes.csc.lsu.edu'. Connection speeds got too slow for our comfort. Didn't use any bash environment variables.
3. We initially made heavy use of the [sample JLex file(http://www.csc.lsu.edu/~gb/csc4351/JLex/sample.lex) but as we got a better understanding of NFA, DFA and JLex, we departed from the strategies in that file, namely:
   - Using separate lexical states for string construction and comment destruction
   - Using more explicity regular expressions (I wasn't comfortable using a regular expresssion macro that I didn't fully understand like the {STRING_TEXT} macro.
