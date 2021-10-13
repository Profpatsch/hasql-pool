module Main where

import BasePrelude
import Test.Hspec
import Hasql.Pool
import qualified Hasql.Connection as Connection
import qualified Hasql.Decoders as Decoders
import qualified Hasql.Encoders as Encoders
import qualified Hasql.Session as Session
import qualified Hasql.Statement as Statement


main = hspec $ do
  describe "Hasql.Pool.use" $ do
    it "releases a spot in the pool when there is an error" $ do
      pool <- acquire Settings {
        poolSize = 1,
        timeout = 1,
        connectionSettings = "host=localhost port=5432 user=postgres dbname=postgres"
      }
      let
        statement = Statement.Statement "" Encoders.noParams Decoders.noResult True
        session = Session.statement () statement
        in do
          use pool session `shouldNotReturn` (Right ())
      let
        session = let
          statement = let
            decoder = Decoders.singleRow (Decoders.column (Decoders.nonNullable Decoders.int8))
            in Statement.Statement "SELECT 1" Encoders.noParams decoder True
          in Session.statement () statement
        in do
          use pool session `shouldReturn` (Right 1)
