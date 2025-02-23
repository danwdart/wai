{-# LANGUAGE OverloadedStrings #-}
import           Control.Concurrent       (forkIO)
import           Control.Exception        (bracket)
import           Control.Monad            (forever)
import           Control.Monad.IO.Class   (liftIO)
import           Data.Enumerator          (run_, ($$))
import qualified Data.Enumerator          as E
import qualified Data.Enumerator.Binary   as EB
import           Network                  (sClose)
import           Network.HTTP.Types       (status200)
import           Network.Socket           (accept)
import           Network.Wai              (responseLBS)
import           Network.Wai.Handler.Warp

app = const $ return $ responseLBS status200 [("Content-type", "text/plain")] "This is not kept alive under any circumstances"

main = withManager 30000000 $ \man -> bracket
    (bindPort (settingsPort set) (settingsHost set))
    sClose
    (\socket -> forever $ do
        (conn, sa) <- accept socket
        th <- liftIO $ registerKillThread man
        _ <- forkIO $ do
            run_ $ enumSocket th 4096 conn $$ do
                liftIO $ pause th
                (len, env) <- parseRequest (settingsPort set) sa
                liftIO $ resume th
                res <- E.joinI $ EB.isolate len $$ app env
                _ <- liftIO $ sendResponse th env conn res
                liftIO $ sClose conn
        return ()
    )
  where
    set = defaultSettings
