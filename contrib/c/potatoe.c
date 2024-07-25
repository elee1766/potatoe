#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <getopt.h>

#define MAX_QUOTES 512
#define MAX_LINE_LENGTH 1024
#define TEMPLATE "\n        \\        ___--===--___\n         \\    __=     ___   - \\\n            _/     o           |\n         /==   \\     __-- o    |\n        |   o   -            _/\n         \\__    \\    -   o //\n          -===============-       - dan quayle"

void terminal_size(int *width, int *height) {
    struct winsize w;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == -1) {
        *width = 100;
        *height = 100;
    } else {
        *width = w.ws_col;
        *height = w.ws_row;
    }
}

void wrap( char *out,const char *str, int columns )
{
    int len, n, w, wordlen=0, linepos=0, outlen=0;
    for( len=0; str[len]; ++len );
    char word[len];
    for( n=0; n<=len; n++ )
    {
        if( str[n] == ' ' || str[n] == '\n' || n == len )
        {
            if( linepos > columns )
            {
                out[outlen++] = '\n';
                linepos = wordlen;
            }

            for( w=0; w<wordlen; w++ )
            {
                out[outlen++] = word[w];
                word[w] = '\0';
            }

            if( n == len )
                out[outlen] = '\0';
            else if( str[n] == '\n' )
            {
                out[outlen] = str[n];
                linepos=0;
            }
            else
            {
                out[outlen] = ' ';
                linepos++;
            }
            outlen++;
            wordlen=0;
        }
        else
        {
            word[wordlen++] = str[n];
            linepos++;
        }
    }
}

void show(const char *quote, int width) {
    char out[MAX_LINE_LENGTH + 300] = "";
    char wrapped[MAX_LINE_LENGTH + 300] = "";
    char wraps[MAX_QUOTES][MAX_LINE_LENGTH];
    int line_count = 0;
    int maxwidth = 0;

    wrap(wrapped, quote, width);
    char *token = strtok(wrapped, "\n");
    while (token != NULL) {
        strncpy(wraps[line_count++], token, MAX_LINE_LENGTH);
        if (strlen(token) > maxwidth) {
            maxwidth = strlen(token);
        }
        token = strtok(NULL, "\n");
    }

    if (line_count == 0) {
        strcpy(wraps[0], "...");
        line_count = 1;
    }

    sprintf(out + strlen(out), " ");
    for(int idx = 0; idx <= maxwidth+1;idx++) {
        sprintf(out + strlen(out), "_");
    }
    sprintf(out + strlen(out), " \n");
    for (int idx = 0; idx < line_count; idx++) {
        if (idx == 0) {
            if(line_count == 1) {
                sprintf(out + strlen(out), "< ");
            }else {
                sprintf(out + strlen(out), "/ ");
            }
        } else if (idx == (line_count - 1)) {
            sprintf(out + strlen(out), "\\ ");
        } else {
            sprintf(out + strlen(out), "| ");
        }
        sprintf(out + strlen(out), "%-*s", maxwidth, wraps[idx]);
        if (idx == 0) {
            if(line_count == 1) {
                sprintf(out + strlen(out), " >");
            }else {
                sprintf(out + strlen(out), " \\");
            }
        } else if (idx == (line_count - 1)) {
            sprintf(out + strlen(out), " /");
        } else {
            sprintf(out + strlen(out), " |");
        }
        sprintf(out + strlen(out), "\n");
    }
    sprintf(out + strlen(out), " ");
    for(int idx = 0; idx <= maxwidth+1;idx++) {
        sprintf(out + strlen(out), "-");
    }
    sprintf(out + strlen(out), " \n");
    strcat(out, TEMPLATE);
    printf("%s\n", out);
}

void loadFile(const char *path, char quoteL[MAX_QUOTES][MAX_LINE_LENGTH], int *quote_count) {
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        return;
    }
    char line[MAX_LINE_LENGTH];
    while (fgets(line, sizeof(line), file)) {
        if (strlen(line) > 4 && line[0] != '#') {
            line[strcspn(line, "\n")] = 0; // Remove newline
            strcpy(quoteL[(*quote_count)++], line);
        }
    }
    fclose(file);
}

int main(int argc, char *argv[]) {
    int width = 0;
    int height = 0;
    int text_flag = 0;
    char quoteL[MAX_QUOTES][MAX_LINE_LENGTH];
    int quote_count = 0;

    int opt;
    while ((opt = getopt(argc, argv, "tw:")) != -1) {
        switch (opt) {
            case 't':
                text_flag = 1;
                break;
            case 'w':
                width = atoi(optarg);
                break;
            default:
                fprintf(stderr, "Usage: %s [-t] [-w width]\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (width == 0) {
        terminal_size(&width, &height);
        width *= 0.64; // Override width
    }

    char *fileNames[] = {
        "./quotes.txt",
        "/usr/lib/potatoe/quotes.txt",
        "/var/lib/potatoe/quotes.txt",
    };

    for (int i = 0; i < 3; i++) {
        loadFile(fileNames[i], quoteL, &quote_count);
    }

    if (quote_count == 0) {
        strcpy(quoteL[quote_count++], "no quotes");
    }

    // Remove duplicates
    for (int i = 0; i < quote_count; i++) {
        for (int j = i + 1; j < quote_count; j++) {
            if (strcmp(quoteL[i], quoteL[j]) == 0) {
                for (int k = j; k < quote_count - 1; k++) {
                    strcpy(quoteL[k], quoteL[k + 1]);
                }
                quote_count--;
                j--;
            }
        }
    }
    struct timespec ts;
    timespec_get(&ts, TIME_UTC);
    char buff[100];
    srandom(ts.tv_nsec);
    int toread = random() % quote_count;
    if (text_flag) {
        printf("%s\n", quoteL[toread]);
        return 0;
    }
    show(quoteL[toread], width);
    return 0;
}
