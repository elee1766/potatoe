{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE CApiFFI #-}
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Control.Exception (SomeException, try)
import Data.List (nub)
import Data.Word (Word16)
import Foreign.Marshal.Array (allocaArray, peekArray)
import Foreign.Ptr (Ptr)
import System.Environment (getArgs)
import System.IO (hFlush, stdout)
import System.Random (randomRIO)
import Text.Read (readMaybe)

foreign import ccall "exit" c_exit :: Int -> IO ()
foreign import capi "sys/ioctl.h ioctl" c_ioctl :: Int -> Word -> Ptr Word16 -> IO Int
foreign import capi "sys/ioctl.h value TIOCGWINSZ" tiocgwinsz :: Word

tmpl :: T.Text
tmpl = "\n        \\        ___--===--___\n         \\    __=     ___   - \\\n            _/     o           |\n         /==   \\     __-- o    |\n        |   o   -            _/\n         \\__    \\    -   o //\n          -===============-       - dan quayle"

quoteFiles :: [FilePath]
quoteFiles = ["./quotes.txt", "/usr/lib/potatoe/quotes.txt", "/var/lib/potatoe/quotes.txt"]

terminalWidth :: IO (Maybe Int)
terminalWidth = allocaArray 4 $ \ws -> do
    rc <- c_ioctl 1 tiocgwinsz ws
    [_, cols, _, _] <- peekArray 4 ws
    pure $ if rc == 0 && cols > 0 then Just (fromIntegral cols) else Nothing

wrap :: Int -> T.Text -> [T.Text]
wrap width = reverse . foldl step [""] . T.words
  where
    step (l:ls) w
        | T.null l = w : ls
        | T.length l + 1 + T.length w > width = w : l : ls
        | otherwise = (l <> " " <> w) : ls
    step [] w = [w]

showQuote :: Int -> T.Text -> IO ()
showQuote width quote = TIO.putStr . T.unlines $
    [" " <> T.replicate (m + 2) "_"]
    ++ zipWith line [0 ..] ls
    ++ [" " <> T.replicate (m + 2) "-" <> tmpl]
  where
    ls = wrap width quote
    n = length ls
    m = maximum (map T.length ls)
    line i l = let (a, b) = edges i in a <> " " <> T.justifyLeft m ' ' l <> " " <> b
    edges i
        | n == 1 = ("<", ">")
        | i == 0 = ("/", "\\")
        | i == n - 1 = ("\\", "/")
        | otherwise = ("|", "|")

loadQuotes :: IO [T.Text]
loadQuotes = nub . concat <$> mapM load quoteFiles
  where
    load p = either (const []) parse <$> (try (TIO.readFile p) :: IO (Either SomeException T.Text))
    parse = filter (\l -> T.length l > 4 && not ("#" `T.isPrefixOf` l)) . map T.strip . T.lines

parseWidth :: [String] -> Maybe Int
parseWidth ("-w" : w : _) = readMaybe w
parseWidth (a : rest) = maybe (parseWidth rest) readMaybe (T.unpack <$> T.stripPrefix "-w=" (T.pack a))
parseWidth [] = Nothing

main :: IO ()
main = do
    args <- getArgs
    quotes <- loadQuotes
    quote <- if null quotes then pure "no quotes" else (quotes !!) <$> randomRIO (0, length quotes - 1)
    if "-t" `elem` args then TIO.putStrLn quote else do
        tw <- terminalWidth
        let width = maybe (floor (0.64 * fromIntegral (maybe 62 id tw) :: Double)) id (parseWidth args)
        showQuote width quote
    hFlush stdout
    -- thanks tomsmeding
    c_exit 0
