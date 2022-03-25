-- |
--
-- Since 3.0.3
module Network.Wai.Middleware.AddHeaders
    ( addHeaders
    ) where

import           Data.ByteString      (ByteString)
import           Network.HTTP.Types   (Header)
import           Network.Wai          (Middleware, mapResponseHeaders,
                                       modifyResponse)
import           Network.Wai.Internal (Response (..))

import           Control.Arrow        (first)
import qualified Data.CaseInsensitive as CI

addHeaders :: [(ByteString, ByteString)] -> Middleware
-- ^ Prepend a list of headers without any checks
--
-- Since 3.0.3

addHeaders h = modifyResponse $ addHeaders' (map (first CI.mk) h)

addHeaders' :: [Header] -> Response -> Response
addHeaders' h = mapResponseHeaders (h ++)
