{-# LANGUAGE PackageImports #-}
import           "mtl" Control.Monad.Reader
import qualified Network.CGI
import qualified Network.Wai.Frontend.MonadCGI
import qualified Network.Wai.Handler.SimpleServer

main :: IO ()
main = Network.Wai.Handler.SimpleServer.run 3000
     $ Network.Wai.Frontend.MonadCGI.cgiToAppGeneric
       monadToIO
       mainCGI

mainCGI :: Network.CGI.CGIT (Reader String) Network.CGI.CGIResult
mainCGI = do
    s <- lift ask
    Network.CGI.output s

monadToIO :: Reader String a -> IO a
monadToIO = return . flip runReader "This is a generic test"
