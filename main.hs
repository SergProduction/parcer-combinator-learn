module Main where

import Control.Monad
import Control.Applicative


newtype Parser a = Parser { parse :: String -> [(a, String)] }

runParser :: Parser a -> String -> a
runParser m s =
  case parse m s of
    [(res, [])] -> res
    [(_, rs)]   -> error "Parser did not consume entire stream."
    _           -> error "Parser error."

unit :: a -> Parser a
unit a = Parser (\s -> [(a,s)])

item :: Parser Char
item = Parser $ \s ->
  case s of
   []     -> []
   (c:cs) -> [(c,cs)]

instance Functor Parser where
  fmap f (Parser cs) = Parser (\s -> [ (f a, b) | (a, b) <- cs s])

instance Applicative Parser where
  pure = return
  (Parser cs1) <*> (Parser cs2) = Parser (\s -> [(f a, s2) | (f, s1) <- cs1 s, (a, s2) <- cs2 s1 ])

instance Monad Parser where
  return a = Parser(\s -> [ (a, s) ])
  p >>= f = Parser $ \s -> concatMap (\(a, s') -> parse (f a) s' ) $ parse p s

instance MonadPlus Parser where
  mzero = Parser (\cs -> [])
  p `mplus` q = Parser (\s -> parse p s ++ parse q s )

instance Alternative Parser where
  empty = mzero
  p <|> q = Parser $ \s ->
    case parse p s of
      [] -> parse q s
      res -> res

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = item >>= \c ->
  if p c
  then unit c
  else (Parser (\cs -> []))

oneOf :: [Char] -> Parser Char
oneOf s = satisfy (flip elem s)

main :: IO ()
main = do
  print $ parse item "abcd"