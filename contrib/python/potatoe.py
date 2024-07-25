#!/usr/bin/env python
import random
import sys
import textwrap
import argparse


def terminal_size():
    w = 100
    h = 100
    try:
        import fcntl
        import termios
        import struct
        h, w, _, _ = struct.unpack('HHHH', fcntl.ioctl(0, termios.TIOCGWINSZ,
                                   struct.pack('HHHH', 0, 0, 0, 0)))
    except:
        pass
    return w, h


tmpl = r'''
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle'''


def show(quote, width):
    out = ""
    wraps = textwrap.wrap(quote, width)
    if len(wraps) == 0:
        wraps.append("...")
    maxwidth = len(wraps[0])
    for line in wraps:
        if len(line) > maxwidth:
            maxwidth = len(line)
    out = out + " " + "_" * (maxwidth+2) + "\n"
    for idx, line in enumerate(wraps):
        if idx == 0:
            out = out + ("< " if len(wraps) == 1 else "/ ")
        elif (idx == (len(wraps) - 1)):
            out = out + "\\ "
        else:
            out = out + "| "
        out = out + line.ljust(maxwidth, " ")
        if idx == 0:
            out = out + (" >" if len(wraps) == 1 else " \\")
        elif (idx == (len(wraps) - 1)):
            out = out + " /"
        else:
            out = out + " |"
        out = out + "\n"
    out = out + " " + "-" * (maxwidth+2)

    out = out + tmpl

    print(out)

# get the quote list


def loadFile(path, quoteL):
    try:
        with open(path) as f:
            content = f.readlines()
            for k in content:
                if len(k) > 4:
                    if k[0] != "#":
                        quoteL.append(k.replace("\n", ""))
    except:
        pass


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--text",
                        help="show only the text",
                        action="store_true")

    parser.add_argument("-w", "--width",
                        help="override width",
                        )
    args = parser.parse_args()
    if args.width is not None:
        defaultFill = int(args.width)
    else:
        (w, h) = terminal_size()
        defaultFill = 0.64 * w
    quoteL = []
    for fileName in [
            "./quotes.txt",
            "/usr/lib/potatoe/quotes.txt",
            "/var/lib/potatoe/quotes.txt",
    ]:
        loadFile(fileName, quoteL)
    # ok we loaded the quote list, now filter unique ones
    if len(quoteL) == 0:
        quoteL = ["no quotes"]
    quoteL = list(set(quoteL))
    # now select a random one
    toread = random.randint(0, len(quoteL)-1)
    selected = quoteL[toread]
    if args.text:
        print(selected)
        return
    show(selected, defaultFill)
    return 0


if __name__ == '__main__':
    sys.exit(main())
