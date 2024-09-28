package main

import (
	"bufio"
	"flag"
	"fmt"
	"math/rand"
	"os"
	"strings"

	"golang.org/x/term"
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

func terminalSize() (int, int) {
	width, height, err := term.GetSize(0)
	if err != nil {
		return 100, 100
	}
	return width, height
}

func show(quote string, width int) {
	lines := wrapText(quote, width)
	maxWidth := maxLineLength(lines)
	buf := bufio.NewWriter(os.Stdout)
	fmt.Fprintf(buf, " %s\n", strings.Repeat("_", maxWidth+2))
	for i, line := range lines {
		if i == 0 {
			if len(lines) == 1 {
				buf.WriteString("< ")
			} else {
				buf.WriteString("/ ")
			}
		} else if i == len(lines)-1 {
			buf.WriteString("\\ ")
		} else {
			buf.WriteString("| ")
		}
		fmt.Fprintf(buf, "%-*s", maxWidth, line)
		if i == 0 {
			if len(lines) == 1 {
				buf.WriteString(" >")
			} else {
				buf.WriteString(" \\")
			}
		} else if i == len(lines)-1 {
			buf.WriteString(" /")
		} else {
			buf.WriteString(" |")
		}
		buf.WriteString("\n")
	}
	fmt.Fprintf(buf, " %s\n", strings.Repeat("-", maxWidth+2))
	fmt.Fprintf(buf, tmpl)
	buf.Flush()
}

func wrapText(text string, width int) []string {
	var result []string
	words := strings.Fields(text)
	if len(words) == 0 {
		return []string{}
	}

	var currentLine strings.Builder
	currentLine.WriteString(words[0])

	for _, word := range words[1:] {
		if currentLine.Len()+1+len(word) > width {
			result = append(result, currentLine.String())
			currentLine.Reset()
			currentLine.WriteString(word)
		} else {
			currentLine.WriteString(" ")
			currentLine.WriteString(word)
		}
	}
	result = append(result, currentLine.String())
	return result
}

func maxLineLength(lines []string) int {
	max := 0
	for _, line := range lines {
		if len(line) > max {
			max = len(line)
		}
	}
	return max
}

func loadQuotes() map[string]struct{} {
	quoteMap := make(map[string]struct{}, 128)
	for _, path := range quoteFiles {
		file, err := os.Open(path)
		if err != nil {
			continue
		}
		defer file.Close()
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if len(line) > 4 && !strings.HasPrefix(line, "#") {
				quoteMap[line] = struct{}{}
			}
		}
	}
	if len(quoteMap) == 0 {
		quoteMap["no quotes"] = struct{}{}
	}
	return quoteMap
}

func main() {
	textFlag := flag.Bool("t", false, "print quote text only")
	widthFlag := flag.Int("w", 0, "specify width for text wrapping")
	flag.Parse()

	var width int
	if *widthFlag != 0 {
		width = *widthFlag
	} else {
		w, _ := terminalSize()
		width = int(0.64 * float64(w))
	}

	quotes := loadQuotes()
	r := rand.Intn(len(quotes))
	idx := 0
	var selectedQuote string
	for k := range quotes {
		if idx == r {
			selectedQuote = k
			break
		}
		idx++
	}
	if *textFlag {
		fmt.Println(selectedQuote)
	} else {
		show(selectedQuote, width)
	}
}
