import std.stdio;
import std.string;
import std.conv;
import std.exception;
import std.getopt;
import std.process;
import std.file;
import std.random;
import std.string;
import std.array;
import std.range;


struct winsize {

    ushort ws_row;
    ushort ws_col;
    ushort ws_xpixel;
    ushort ws_ypixel;

}

enum uint TIOCGWINSZ = 0x5413;
extern(C) int ioctl(int, int, ...);

bool text;
int width;



int getcols() {
	winsize ws;
	ioctl(stdout.fileno, TIOCGWINSZ, &ws);
  return ws.ws_col;
}


string tmpl = (`
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle`);

void show(string quote, int width) {
    auto o = appender!string;
    string[] wraps = strip(wrap(quote, width)).split("\n");
    if (wraps.length == 0) {
        wraps ~= "...";
    }
    int maxwidth = to!int(wraps[0].length);
    foreach (line; wraps) {
        if (line.length > maxwidth) {
            maxwidth = to!int(line.length);
        }
    }

    o.put(" " ~ replicate("_", maxwidth + 2) ~ "\n");
    foreach (idx, line; wraps) {
        if (idx == 0) {
            o.put(wraps.length == 1 ? "< " : "/ ");
        } else if (idx+1 == (wraps.length)) {
            o.put("\\ ");
        } else {
            o.put("| ");
        }

        o.put(line.leftJustify(maxwidth, ' '));

        if (idx == 0) {
            o.put(wraps.length == 1 ? " >" : " \\");
        } else if (idx+1 == (wraps.length)) {
            o.put(" /");
        } else {
            o.put(" |");
        }

        o.put("\n");
    }

    o.put(" " ~ replicate("-", maxwidth + 2));

    o.put(tmpl);
    writeln(o[]);
}

void main(string[] args)
{
    auto flags = getopt(
            args,
            "width|w",  &width,    // numeric
            "text|t", &text);
    if (flags.helpWanted)
    {
        defaultGetoptPrinter("usage: potatoe",flags.options);
        return;
    }

    auto fileNames = ["./quotes.txt",
         "/usr/lib/potatoe/quotes.txt",
         "/var/lib/potatoe/quotes.txt"];

    string[] all = [];
    foreach(fileName; fileNames) {
        try {
            auto file = File(fileName);
            foreach (line; file.byLine) {
                auto stripped = strip(line);
                if (stripped.length< 5) {
                    continue;
                }
                if (stripped[0] == '#') {
                    continue;
                }
                all ~= to!string(stripped);
            }
        }catch(FileException){
        }catch(ErrnoException){
        } finally {
        }
    }
    if(all.length == 0) {
        all ~= "no quotes";
    }
    auto rnd = Random(unpredictableSeed);
    auto elem  = choice(all, rnd);

    if(text) {
        writeln(elem);
        return;
    }
    if(width == 0) {
        width = to!int(to!float(getcols()) * 0.64);
    }
    show(elem, width);
}
