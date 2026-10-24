use std::hash::{BuildHasher, RandomState};
use std::io::{self, BufWriter, Write};

const TMPL: &str = r#"
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle"#;

const QUOTE_FILES: [&str; 3] = [
    "./quotes.txt",
    "/usr/lib/potatoe/quotes.txt",
    "/var/lib/potatoe/quotes.txt",
];

unsafe extern "C" {
    fn ioctl(fd: i32, request: u64, ...) -> i32;
}

fn terminal_width() -> Option<usize> {
    let mut ws = [0u16; 4];
    // TIOCGWINSZ on linux
    let ok = unsafe { ioctl(1, 0x5413, ws.as_mut_ptr()) } == 0;
    (ok && ws[1] > 0).then_some(ws[1] as usize)
}

fn wrap(text: &str, width: usize) -> Vec<String> {
    let mut lines = vec![String::new()];
    for word in text.split_whitespace() {
        let line = lines.last_mut().unwrap();
        if line.is_empty() {
            line.push_str(word);
        } else if line.len() + 1 + word.len() > width {
            lines.push(word.to_owned());
        } else {
            line.push(' ');
            line.push_str(word);
        }
    }
    lines
}

fn show(quote: &str, width: usize) -> io::Result<()> {
    let lines = wrap(quote, width);
    let max = lines.iter().map(String::len).max().unwrap_or(0);
    let mut f = BufWriter::new(io::stdout().lock());
    writeln!(f, " {}", "_".repeat(max + 2))?;
    for (i, line) in lines.iter().enumerate() {
        let (l, r) = match i {
            _ if lines.len() == 1 => ("<", ">"),
            0 => ("/", "\\"),
            _ if i == lines.len() - 1 => ("\\", "/"),
            _ => ("|", "|"),
        };
        writeln!(f, "{l} {line:<max$} {r}")?;
    }
    writeln!(f, " {}{TMPL}", "-".repeat(max + 2))?;
    f.flush()
}

fn main() {
    let mut text_only = false;
    let mut width = None;
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "-t" | "--text" => text_only = true,
            "-w" | "--width" => width = args.next().and_then(|w| w.parse().ok()),
            "-h" | "--help" => {
                println!("usage: potatoe [-t|--text] [-w|--width N]");
                return;
            }
            a => match a.strip_prefix("-w=").or(a.strip_prefix("--width=")) {
                Some(w) => width = w.parse().ok(),
                None => {
                    eprintln!("unknown argument: {a}");
                    std::process::exit(1);
                }
            },
        }
    }

    let mut quotes: Vec<String> = QUOTE_FILES
        .iter()
        .filter_map(|p| std::fs::read_to_string(p).ok())
        .flat_map(|s| s.lines().map(str::trim).map(str::to_owned).collect::<Vec<_>>())
        .filter(|l| l.len() > 4 && !l.starts_with('#'))
        .collect();
    if quotes.is_empty() {
        quotes.push("no quotes".to_owned());
    }
    let idx = RandomState::new().hash_one(0u8) as usize % quotes.len();
    let quote = &quotes[idx];

    if text_only {
        println!("{quote}");
        return;
    }
    let width = width.unwrap_or_else(|| (terminal_width().unwrap_or(62) as f64 * 0.64) as usize);
    let _ = show(quote, width);
}
