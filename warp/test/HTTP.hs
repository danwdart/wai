module HTTP (
    sendGET
  , sendGETwH
  , sendHEAD
  , sendHEADwH
  , responseBody
  , responseStatus
  , responseHeaders
  , getHeaderValue
  , HeaderName
  ) where

import           Data.ByteString
import qualified Data.ByteString.Lazy as BL
import           Network.HTTP.Client
import           Network.HTTP.Types

sendGET :: String -> IO (Response BL.ByteString)
sendGET url = sendGETwH url []

sendGETwH :: String -> [Header] -> IO (Response BL.ByteString)
sendGETwH url hdr = do
    manager <- newManager defaultManagerSettings
    request <- parseRequest url
    let request' = request { requestHeaders = hdr }
    httpLbs request' manager

sendHEAD :: String -> IO (Response BL.ByteString)
sendHEAD url = sendHEADwH url []

sendHEADwH :: String -> [Header] -> IO (Response BL.ByteString)
sendHEADwH url hdr = do
    manager <- newManager defaultManagerSettings
    request <- parseRequest url
    let request' = request { requestHeaders = hdr, method = methodHead }
    httpLbs request' manager

getHeaderValue :: HeaderName -> [Header] -> Maybe ByteString
getHeaderValue = lookup
