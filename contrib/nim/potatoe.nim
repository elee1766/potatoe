import system
import std/enumerate
import std/terminal
import strutils
import std/parseopt
import std/sequtils
import std/sugar
import std/random
import std/wordwrap

randomize()

var parser = initOptParser("")

var tmpl = """
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle"""

proc show(quote:string, width:int) =
  var wraps = wrapWords(quote, width).split("\n")
  if wraps.len == 0:
    wraps.add("...")
  var maxwidth = len(wraps[0])
  for line in wraps:
    if len(line) > maxwidth:
      maxwidth = len(line)
  write(stdout, " " & repeat("_",maxwidth+2) & "\n")
  for idx, line in enumerate(wraps):
    if idx == 0:
      write(stdout, (if len(wraps) == 1: "< " else: "/ "))
    elif (idx == (len(wraps) - 1)):
      write(stdout, "\\ ")
    else:
      write(stdout, "| ")

    write(stdout, alignLeft(line, maxwidth))
    if idx == 0:
      write(stdout, (if len(wraps) == 1: " >" else: " \\"))
    elif (idx == (len(wraps) - 1)):
      write(stdout, " /")
    else:
      write(stdout, " |")
    write(stdout, "\n")
  write(stdout, " " & repeat("-",(maxwidth+2)))
  write(stdout,"\n")
  write(stdout, tmpl)
  write(stdout,"\n")
  flushFile(stdout)


var all = newSeqOfCap[string](128)

# get the quote list
proc main(): int =
  var width = 0
  var textonly = false
  for kind, key, val in parser.getopt():
    case kind
    of cmdArgument, cmdEnd:
      discard
    of cmdShortOption, cmdLongOption:
      if key == "w":
        try:
          width = parseint(val)
        except:
          discard
      elif key == "t":
        textonly = true
      else:
        echo "unrecognized parameter flag: " & key
        return 1

  var fileNames = ["./quotes.txt",
     "/usr/lib/potatoe/quotes.txt",
     "/var/lib/potatoe/quotes.txt"]
  for fileName in fileNames:
    try:
      for line in lines fileName:
        if line.len < 5:
          continue
        if line[0] == '#':
          continue
        all.add(line)
    except:
      discard
  if all.len == 0:
    all.add("No Quotes")
  var selected = sample(all)
  if textonly:
    echo selected
    return 0
  if width == 0:
    width = int(float(terminalWidth()) * 0.64)
  if width == 0:
    width = 100
  show(selected, width)

quit(main())
