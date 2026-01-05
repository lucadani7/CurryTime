import Data.Time (getCurrentTime, utctDay, toGregorian, fromGregorian, addGregorianMonthsClip)
import Data.Time.Calendar (gregorianMonthLength)
import Data.Time.Calendar.WeekDate (toWeekDate)
import Text.Printf (printf)
import Text.Read (readMaybe)
import System.IO (hSetBuffering, stdin, BufferMode(NoBuffering, LineBuffering), hSetEcho, hFlush, stdout)
import System.Environment (getArgs)

monthName :: Int -> String
monthName m = ["January", "February", "March", "April", "May", "June", 
               "July", "August", "September", "October", "November", "December"] !! (m - 1)

chunksOf :: Int -> [a] -> [[a]]
chunksOf _ [] = []
chunksOf n xs = take n xs : chunksOf n (drop n xs)

getDayOfWeek :: Integer -> Int -> Int -> Int
getDayOfWeek y m d = let (_, _, w) = toWeekDate (fromGregorian y m d) in w

showCalendar :: Integer -> Int -> Integer -> Int -> Int -> IO ()
showCalendar y m realY realM realD = do
    putStr "\ESC[2J\ESC[H"
    let firstDayIdx = getDayOfWeek y m 1
        daysInMonth = gregorianMonthLength y m
        padding = replicate (firstDayIdx - 1) ""
        formatDay d = if y == realY && m == realM && d == realD
                      then "[" ++ show d ++ "]"
                      else show d
        days = padding ++ map formatDay [1..daysInMonth]
        weeks = chunksOf 7 days

    putStrLn "=============================="
    putStrLn $ printf "      %s %d" (monthName m) y
    putStrLn "=============================="
    putStrLn "  Mo  Tu  We  Th  Fr  Sa  Su"
    mapM_ (putStrLn . concatMap (printf "%4s")) weeks
    putStrLn "\n------------------------------"
    putStrLn " [n] Next | [p] Prev | [g] Year"
    putStrLn " [t] Today| [q] Exit"
    putStrLn "------------------------------"

calendarLoop :: Integer -> Int -> Integer -> Int -> Int -> IO ()
calendarLoop y m realY realM realD = do
    showCalendar y m realY realM realD
    input <- getChar
    case input of
        'n' -> let d = addGregorianMonthsClip 1 (fromGregorian y m 1)
                   (ny, nm, _) = toGregorian d in calendarLoop ny nm realY realM realD
        'p' -> let d = addGregorianMonthsClip (-1) (fromGregorian y m 1)
                   (py, pm, _) = toGregorian d in calendarLoop py pm realY realM realD
        'g' -> do
            hSetBuffering stdin LineBuffering
            hSetEcho stdin True
            putStr "\nEnter year: "
            hFlush stdout
            yStr <- getLine
            hSetBuffering stdin NoBuffering
            hSetEcho stdin False
            case readMaybe yStr of
                Just ny -> calendarLoop ny m realY realM realD
                _       -> calendarLoop y m realY realM realD
        't' -> calendarLoop realY realM realY realM realD
        'q' -> putStrLn "\nGoodbye!"
        _   -> calendarLoop y m realY realM realD

main :: IO ()
main = do
    hSetBuffering stdin NoBuffering
    hSetEcho stdin False
    now <- getCurrentTime
    let (ry, rm, rd) = toGregorian (utctDay now)
    args <- getArgs
    let (sY, sM) = case args of
            [yS, mS] -> (maybe ry id (readMaybe yS), maybe rm id (readMaybe mS))
            _        -> (ry, rm)
    calendarLoop sY sM ry rm rd
