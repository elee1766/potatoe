import std.stdio;
import std.getopt;

void main()
{
    auto helpInformation = getopt(
            args,
            "length",  &length,    // numeric
            "file",    &data,      // string
            "verbose", &verbose,   // flag
            "color", "Information about this color", &color);    // enum
    ...

        if (helpInformation.helpWanted)
        {
            defaultGetoptPrinter("Some information about the program.",
                    helpInformation.options);
        }
}
