{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Environment (getArgs)
import System.IO (hFlush, stdout)
import System.Random (randomRIO)
import System.Directory (doesFileExist)
import System.Console.Terminal.Size
import Control.Monad (forM_)
import Data.List (intercalate, maximumBy)
import Data.Ord
import Text.Printf (printf)
import Text.Wrap

tmpl :: T.Text
tmpl = T.pack "\n        \\        ___--===--___\n         \\    __=     ___   - \n            _/     o           |\n         /==   \\     __-- o    |\n        |   o   -            _/\n         \\__    \\    -   o //\n          -===============-       - dan quayle\n"

quoteFiles :: [FilePath]
quoteFiles = ["./quotes.txt", "/usr/lib/potatoe/quotes.txt", "/var/lib/potatoe/quotes.txt"]


showQuote :: T.Text -> Int -> IO ()
showQuote quote width = do
    let lines = wrapTextToLines defaultWrapSettings width quote
        maxWidth = maxLineLength lines
    TIO.putStr " "
    TIO.putStrLn $ T.replicate (maxWidth + 2) "_"
    forM_ (zip [0..] lines) $ \(i, line) -> do
        let prefix = case (i, length lines) of
                        (0, 1) -> "< "
                        (0, _) -> "/ "
                        (n, _) | n == length lines - 1 -> "\\ "
                        _ -> "| "
            suffix = case (i, length lines) of
                        (0, 1) -> " >"
                        (0, _) -> " \\"
                        (n, _) | n == length lines - 1 -> " /"
                        _ -> " |"
        TIO.putStrLn $ prefix <> T.justifyRight maxWidth ' ' line <> suffix
    TIO.putStr " "
    TIO.putStrLn $ T.replicate (maxWidth + 2) "-"
    TIO.putStr tmpl

breakLine :: [T.Text] -> Int -> ([T.Text], [T.Text])
breakLine [] _ = ([], [])
breakLine (w:ws) width
    | T.length w > width = ([], w:ws)
    | otherwise = let (line, rest) = breakLine ws (width - T.length w - 1)
                  in (w : line, rest)

maxLineLength :: [T.Text] -> Int
maxLineLength = maximum . map T.length

loadQuotes :: IO T.Text
loadQuotes = do
    quotes <- concatMapM loadQuotesFromFile quoteFiles
    if null quotes then return "no quotes" else do
        idx <- randomRIO (0, length quotes - 1)
        return (quotes !! idx)

loadQuotesFromFile :: FilePath -> IO [T.Text]
loadQuotesFromFile path = do
    exists <- doesFileExist path
    if not exists then return [] else do
        contents <- TIO.readFile path
        return [T.strip line | line <- T.lines contents, T.length line > 4, not (T.isPrefixOf "#" line)]

concatMapM :: (Monad m) => (a -> m [b]) -> [a] -> m [b]
concatMapM f xs = concat <$> mapM f xs

main :: IO ()
main = do
    args <- getArgs
    let textFlag = "-t" `elem` args
        widthFlag = lookup "-w" (zip args (tail args))
    width <- case widthFlag of
                Just w -> return (read w :: Int)
                Nothing -> do
                    maybeTermW <- hSize stdout
                    w <- case maybeTermW of
                      Just termW -> return (width termW)
                      Nothing -> return 40
                    return (floor (0.64 * fromIntegral w))
    selectedQuote <- loadQuotes
    if textFlag then TIO.putStrLn selectedQuote else showQuote selectedQuote width

