
module Main (main) where

import Control.Monad.IO.Class
import Control.Monad.Logger
import qualified Data.ByteString as B
import qualified Data.ByteString.Base64 as Base64
import Data.Default
import Data.String.Interpolate
import qualified Data.Text.Encoding as T
import Database.LevelDB.Base
import System.FilePath
import UnliftIO.Concurrent
import UnliftIO.Exception
import UnliftIO.Process
import UnliftIO.Temporary


main :: IO ()
main = do
  putStrLn "HI"
