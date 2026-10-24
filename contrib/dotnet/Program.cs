const string tmpl = """

        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle
""";

bool textOnly = false;
int width = 0;
for (int i = 0; i < args.Length; i++)
{
    var (key, val) = args[i].Split('=', 2) is [var k, var v] ? (k, v) : (args[i], null);
    switch (key)
    {
        case "-t" or "--text":
            textOnly = true;
            break;
        case "-w" or "--width":
            int.TryParse(val ?? (++i < args.Length ? args[i] : ""), out width);
            break;
        case "-h" or "--help":
            Console.WriteLine("usage: potatoe [-t|--text] [-w|--width N]");
            return;
        default:
            Console.Error.WriteLine($"unknown argument: {args[i]}");
            Environment.Exit(1);
            break;
    }
}

string[] files = ["./quotes.txt", "/usr/lib/potatoe/quotes.txt", "/var/lib/potatoe/quotes.txt"];
var quotes = files.Where(File.Exists)
    .SelectMany(File.ReadLines)
    .Select(l => l.Trim())
    .Where(l => l.Length > 4 && !l.StartsWith('#'))
    .Distinct()
    .DefaultIfEmpty("no quotes")
    .ToArray();
var quote = quotes[Random.Shared.Next(quotes.Length)];

if (textOnly)
{
    Console.WriteLine(quote);
    return;
}
if (width <= 0)
{
    int cols = Console.IsOutputRedirected ? 0 : Console.WindowWidth;
    width = cols > 0 ? (int)(cols * 0.64) : 64;
}

var lines = Wrap(quote, width);
int max = lines.Max(l => l.Length);
var sb = new System.Text.StringBuilder();
sb.Append(' ').Append('_', max + 2).Append('\n');
for (int i = 0; i < lines.Count; i++)
{
    var (l, r) = (lines.Count, i) switch
    {
        (1, _) => ('<', '>'),
        (_, 0) => ('/', '\\'),
        var (n, j) when j == n - 1 => ('\\', '/'),
        _ => ('|', '|'),
    };
    sb.Append($"{l} {lines[i].PadRight(max)} {r}\n");
}
sb.Append(' ').Append('-', max + 2).Append(tmpl).Append('\n');
Console.Out.Write(sb);

static List<string> Wrap(string text, int width)
{
    List<string> lines = [""];
    foreach (var word in text.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries))
    {
        if (lines[^1].Length == 0) lines[^1] = word;
        else if (lines[^1].Length + 1 + word.Length > width) lines.Add(word);
        else lines[^1] += " " + word;
    }
    return lines;
}
