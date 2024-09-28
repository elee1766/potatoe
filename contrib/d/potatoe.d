import std.stdio;
import std.getopt;

bool text

void main(string[] args)
{
    auto helpInformation = getopt(
            args,
            "length",  &length,    // numeric
            "file",    &data,      // string
            "text", &text);
    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Some information about the program.",
                helpInformation.options);
    }
}
