import std.stdio;
import std.getopt;
import std.process;

bool text;
int width;


string tmpl = (`
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle
`);

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
    writeln(text, width);
}
