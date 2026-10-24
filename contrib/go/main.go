package main

import (
	"bufio"
	"flag"
	"fmt"
	"math/rand/v2"
	"os"
	"slices"
	"strings"
	"syscall"
	"unsafe"
)

const tmpl = `
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle
`

var quoteFiles = []string{
	"./quotes.txt",
	"/usr/lib/potatoe/quotes.txt",
	"/var/lib/potatoe/quotes.txt",
}

func terminalWidth() int {
	var ws [4]uint16
	_, _, errno := syscall.Syscall(syscall.SYS_IOCTL, 0, syscall.TIOCGWINSZ, uintptr(unsafe.Pointer(&ws)))
	if errno != 0 || ws[1] == 0 {
		return 100
	}
	return int(ws[1])
}

func wrapText(text string, width int) []string {
	var lines []string
	line := ""
	for word := range strings.FieldsSeq(text) {
		switch {
		case line == "":
			line = word
		case len(line)+1+len(word) > width:
			lines = append(lines, line)
			line = word
		default:
			line += " " + word
		}
	}
	return append(lines, line)
}

func show(quote string, width int) {
	lines := wrapText(quote, width)
	maxWidth := len(slices.MaxFunc(lines, func(a, b string) int { return len(a) - len(b) }))
	buf := bufio.NewWriter(os.Stdout)
	defer buf.Flush()
	fmt.Fprintf(buf, " %s\n", strings.Repeat("_", maxWidth+2))
	for i, line := range lines {
		l, r := "| ", " |"
		switch {
		case len(lines) == 1:
			l, r = "< ", " >"
		case i == 0:
			l, r = "/ ", " \\"
		case i == len(lines)-1:
			l, r = "\\ ", " /"
		}
		fmt.Fprintf(buf, "%s%-*s%s\n", l, maxWidth, line, r)
	}
	fmt.Fprintf(buf, " %s\n%s", strings.Repeat("-", maxWidth+2), tmpl)
}

func loadQuotes() []string {
	var quotes []string
	for _, path := range quoteFiles {
		data, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		for line := range strings.Lines(string(data)) {
			line = strings.TrimSpace(line)
			if len(line) > 4 && !strings.HasPrefix(line, "#") {
				quotes = append(quotes, line)
			}
		}
	}
	slices.Sort(quotes)
	quotes = slices.Compact(quotes)
	if len(quotes) == 0 {
		quotes = []string{"no quotes"}
	}
	return quotes
}

func main() {
	text := flag.Bool("t", false, "print quote text only")
	width := flag.Int("w", 0, "specify width for text wrapping")
	flag.Parse()

	quotes := loadQuotes()
	quote := quotes[rand.IntN(len(quotes))]
	if *text {
		fmt.Println(quote)
		return
	}
	if *width == 0 {
		*width = int(0.64 * float64(terminalWidth()))
	}
	show(quote, *width)
}
