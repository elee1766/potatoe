using System.CommandLine;

namespace potatoe;

internal class Program
{

    private static string tmpl = @"
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle";

    static void Main(string[] args)
    {
        var rootCommand = new RootCommand(
                description: "dan quayle themed");

        rootCommand.TreatUnmatchedTokensAsErrors = true;
        var textOnlyOption = new Option<bool>(
                aliases: new string[] { "--text-only", "-t" }
                , description: "no potatoe, only dan");

        var widthOption = new Option<int>(
                aliases: new string[] { "--width", "-w" }
                , description: "text width");
        rootCommand.AddOption(textOnlyOption);
        rootCommand.AddOption(widthOption);

        rootCommand.SetHandler(Invoke,textOnlyOption, widthOption);
        rootCommand.Invoke(args);
    }
    static void Show(string text, int width) {
        var wraps = wordWrap(text, width);
        if(wraps.Count == 0) {
            wraps.Add("...");
        }
        var maxwidth = wraps.Max(s=>s.Length);
        var buf = Console.Out;

        buf.Write(" " + new string('_', maxwidth+2)+"\n");
        for (int idx = 0; idx < wraps.Count; idx++)
        {
            var line = wraps[idx];
            if(idx == 0) {
                buf.Write(wraps.Count == 1 ? "< " : "/ ");
            } else if(idx == wraps.Count - 1) {
                buf.Write("\\ ");
            } else {
                buf.Write("| ");
            }
            buf.Write(line.PadRight(maxwidth));
            if(idx == 0) {
                buf.Write(wraps.Count == 1 ? " >" : " \\");
            } else if(idx == wraps.Count - 1) {
                buf.Write(" /");
            } else {
                buf.Write(" |");
            }
            buf.Write('\n');
        }
        buf.Write(" " + new string('-', maxwidth+2)+"\n");
        buf.WriteLine(tmpl);
        buf.Flush();
    }
    static void Invoke(bool textOnly, int width) {
        if(width == 0) {
            width = (int)((float)(Console.WindowWidth)*0.64);
        }
        if(width == 0) {
            width = 64;
        }
        var all = new List<string>();

        foreach(var fileName in new[] {
                "./quotes.txt",
                "/usr/lib/potatoe/quotes.txt",
                "/var/lib/potatoe/quotes.txt",
                }){
            try {
                var lines = File.ReadLines(fileName);
                foreach (var line in lines) {
                    if(line.Length < 5) {
                        continue;
                    }
                    if(line[0] == '#') {
                        continue;
                    }
                    all.Add(line);
                }
            }catch{}
        }
        if(all.Count == 0) {
            all.Add("no quotes");
        }
        var selected = all[(new Random().Next(all.Count))];
        if(textOnly) {
            Console.Out.WriteLine(selected);
            return;
        }
        Show(selected, width);
    }

    private static List<string> wordWrap( string text, int maxLineLength )
    {
        var list = new List<string>();

        int currentIndex;
        var lastWrap = 0;
        var whitespace = new[] { ' ', '\r', '\n', '\t' };
        do
        {
            currentIndex = lastWrap + maxLineLength > text.Length ? text.Length : (text.LastIndexOfAny( new[] { ' ', ',', '.', '?', '!', ':', ';', '-', '\n', '\r', '\t' }, Math.Min( text.Length - 1, lastWrap + maxLineLength)  ) + 1);
            if( currentIndex <= lastWrap )
                currentIndex = Math.Min( lastWrap + maxLineLength, text.Length );
            list.Add( text.Substring( lastWrap, currentIndex - lastWrap ).Trim( whitespace ) );
            lastWrap = currentIndex;
        } while( currentIndex < text.Length );

        return list;
    }
}
