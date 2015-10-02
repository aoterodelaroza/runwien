#! /usr/bin/gawk -f

/\\begin{quote}\\begin{verbatim}/ {
   getline
   if ($0 ~ /runwien/) {
       print "\\runwienlist"
       print "\\begin{lstlisting}"
       }
   else if ($0 ~ /tessel/) {
       print "\\tessellist"
       print "\\begin{lstlisting}"
       }
   else if ($0 ~ /critic/) {
       print "\\criticlist"
       print "\\begin{lstlisting}"
       }
   else if ($0 ~ /ascii/) {
       print "\\asciilist"
       print "\\begin{lstlisting}"
       }
   else {
       print "\\asciilist"
       print "\\begin{lstlisting}"
       print
       }
   next
   }

/\\end{verbatim}\\end{quote}/ {
   print "\\end{lstlisting}"
   next
   }

{ print }
