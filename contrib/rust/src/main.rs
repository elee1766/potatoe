extern crate getopts;

use getopts::Options;
use std::env;
use std::fs::File;
use std::io::{self, BufRead, Write, BufWriter};
use std::path::Path;
use textwrap;

use rand::Rng;

static TMPL: &'static str = r#"
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle"#;

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn show(val: &str, width: usize) -> io::Result<()> {
    let wrapped = textwrap::wrap(&val, width);
    let mut f = BufWriter::new(io::stdout().lock());
    let maxwidth = wrapped.iter().map(|x| x.len()).max().unwrap_or(wrapped[0].len());
    write!(f, " {}\n","_".repeat(maxwidth+2))?;
    for (idx,line) in wrapped.iter().enumerate() {
        if idx == 0 {
            match wrapped.len() == 1 {
                true =>f.write_all(b"< "),
                false =>f.write_all(b"/ "),
            }?
        } else if idx == wrapped.len() - 1 {
            f.write_all(b"\\ ")?;
        }else {
            f.write_all(b"| ")?;
        }
        write!(f, "{: <pwidth$}", line, pwidth = maxwidth)?;
        if idx == 0 {
            match wrapped.len() == 1 {
                true =>f.write_all(b" >"),
                false =>f.write_all(b" \\"),
            }?
        } else if idx == wrapped.len() - 1 {
            f.write_all(b" /")?;
        }else {
            f.write_all(b" |")?;
        }
        f.write_all(b" \n")?;
    }
    write!(f, " {}\n{}\n","-".repeat(maxwidth+2),TMPL)?;
    f.flush()
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let program = args[0].clone();
    let mut opts = Options::new();
    opts.optopt("w", "width", "the width", "40");
    opts.optflag("t", "text", "text-only");
    opts.optflag("h", "help", "print this help menu");
    let matches = match opts.parse(&args[1..]) {
        Ok(m) => { m }
        Err(f) => { panic!("{}", f.to_string()) }
    };
    if matches.opt_present("h") {
        let str_ref = format!("Usage: {} FILE [options]", program);
        print!("{}", opts.usage(&str_ref));
        return;
    }
    let text_only = matches.opt_present("t");
    let mut width: usize = 40;
    if let Some((w, _h)) = termize::dimensions() {
        width = ((w as f64)*0.64) as usize;
    }
    let mut all_lines: Vec<String> = Vec::new();
    let file_names = vec![
        "./quotes.txt",
        "/usr/lib/potatoe/quotes.txt",
        "/var/lib/potatoe/quotes.txt",
    ];
    for file_name in file_names {
        if let Ok(lines) = read_lines(file_name) {
            // Consumes the iterator, returns an (Optional) String
            for line in lines.flatten() {
                let trimmed = line.trim().to_owned();
                if trimmed.starts_with("#") || trimmed.len() == 0 {
                    continue;
                }
                all_lines.push(trimmed);
            }
        }
    }
    if all_lines.len() == 0 {
        all_lines.push("no quotes".to_owned());
    }
    let num = rand::thread_rng().gen_range(0..all_lines.len());
    if !text_only {
        let _ = show(&all_lines[num], width);
        return;
    }
    println!("{}", all_lines[num]);
}

