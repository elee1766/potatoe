#!/usr/bin/env kotlinc -script

import kotlinx.cinterop.*
import platform.posix.*
import kotlin.random.Random
import kotlin.system.exitProcess

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
fun terminalSize(): Pair<Int, Int> {
    var w = 100
    var h = 100

    try {
        memScoped {
            val winsize = alloc<winsize>()
            if (ioctl(STDOUT_FILENO.convert(), TIOCGWINSZ.convert(), winsize.ptr) != -1) {
                h = winsize.ws_row.toInt()
                w = winsize.ws_col.toInt()
            }
        }
    } catch (e: Exception) {
        // Fallback to default values if ioctl fails
    }

    return Pair(w, h)
}

val tmpl = """
        \        ___--===--___
         \    **=     **_   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle"""

fun show(quote: String, width: Int) {
    var out = ""
    val wraps = wrapText(quote, width)

    if (wraps.isEmpty()) {
        wraps.add("...")
    }

    var maxwidth = wraps[0].length
    for (line in wraps) {
        if (line.length > maxwidth) {
            maxwidth = line.length
        }
    }

    out += " " + "_".repeat(maxwidth + 2) + "\n"

    for ((idx, line) in wraps.withIndex()) {
        out += when {
            idx == 0 -> if (wraps.size == 1) "< " else "/ "
            idx == wraps.size - 1 -> "\\ "
            else -> "| "
        }

        out += line.padEnd(maxwidth, ' ')

        out += when {
            idx == 0 -> if (wraps.size == 1) " >" else " \\"
            idx == wraps.size - 1 -> " /"
            else -> " |"
        }

        out += "\n"
    }

    out += " " + "-".repeat(maxwidth + 2)
    out += tmpl
    println(out)
}

fun wrapText(text: String, width: Int): MutableList<String> {
    val result = mutableListOf<String>()
    var remaining = text

    while (remaining.isNotEmpty()) {
        val splitIndex = if (remaining.length <= width) {
            remaining.length
        } else {
            val lastSpace = remaining.substring(0, width).lastIndexOf(' ')
            if (lastSpace == -1) width else lastSpace
        }

        result.add(remaining.substring(0, splitIndex))
        remaining = if (splitIndex < remaining.length) {
            remaining.substring(splitIndex).trimStart()
        } else {
            ""
        }
    }

    return result
}

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
fun loadFile(path: String, quoteList: MutableList<String>) {
    try {
        val file = fopen(path, "r") ?: return

        try {
            memScoped {
                val bufferLength = 1024
                val buffer = allocArray<ByteVar>(bufferLength)

                while (true) {
                    val line = fgets(buffer, bufferLength, file)?.toKString() ?: break
                    val trimmed = line.replace("\n", "")

                    if (trimmed.length > 4 && trimmed[0] != '#') {
                        quoteList.add(trimmed)
                    }
                }
            }
        } finally {
            fclose(file)
        }
    } catch (e: Exception) {
        // Ignore file read errors
    }
}

fun Main(args: Array<String>): Int {
    var showTextOnly = false
    var customWidth: Int? = null

    // Simple argument parsing
    var i = 0
    while (i < args.size) {
        when (args[i]) {
            "-t", "--text" -> showTextOnly = true
            "-w", "--width" -> {
                if (i + 1 < args.size) {
                    customWidth = args[i + 1].toIntOrNull()
                    i++
                }
            }
        }
        i++
    }

    val defaultFill = if (customWidth != null) {
        customWidth
    } else {
        val (w, _) = terminalSize()
        (0.64 * w).toInt()
    }

    val quoteList = mutableListOf<String>()

    val fileNames = listOf(
        "./quotes.txt",
        "/usr/lib/potatoe/quotes.txt",
        "/var/lib/potatoe/quotes.txt"
    )

    for (fileName in fileNames) {
        loadFile(fileName, quoteList)
    }

    // Handle empty quote list
    if (quoteList.isEmpty()) {
        quoteList.add("no quotes")
    }

    // Remove duplicates
    val uniqueQuotes = quoteList.toSet().toList()

    // Select a random quote
    val toread = Random.nextInt(uniqueQuotes.size)
    val selected = uniqueQuotes[toread]

    if (showTextOnly) {
        println(selected)
        return 0
    }

    show(selected, defaultFill)
    return 0
}

fun main(args: Array<String>) {
    exitProcess(Main(args))
}
