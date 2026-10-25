{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase, MultiWayIf, TupleSections, RecordWildCards, BangPatterns #-}
{-# LANGUAGE ScopedTypeVariables, GADTs, BinaryLiterals, NumericUnderscores, RankNTypes #-}
{-# LANGUAGE DerivingStrategies, GeneralizedNewtypeDeriving #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module ObjHash
  (
    objhash
  , hashValue
  , hashNull
  , hashBool
  , hashScientific
  , hashList
  , hashString
  ) where

import Data.List (sort)
import Data.Aeson (ToJSON, toJSON)
import qualified Data.Text as Text
import qualified Data.ByteString as B
import qualified Data.Scientific as Sci
import qualified Data.Aeson.Types as A
import qualified Crypto.Hash.SHA256 as SHA256
import Data.HashMap.Strict (HashMap, toList)
import Data.ByteString.Char8 (pack)
import qualified Data.Map.Strict as M
import Data.Map.Strict (Map)
import Data.Char (toUpper, isDigit, ord)
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Ratio ((%), numerator)
import Data.Complex (Complex((:+)), magnitude)
import Control.Monad (forM_, when, unless, foldM)
import Data.List (sortBy, intercalate)
import Data.Ord (comparing, Down(..))
import Data.Function ((&))
import Data.Bits ((.&.), (.|.), shiftL, xor)

data Hash = Hash {
    name :: String
  , age  :: Double
  } deriving (Generic, Show)

instance ToJSON Hash where
  toEncoding = genericToEncoding defaultOptions

hash :: String -> B.ByteString -> B.ByteString
hash prefix bs = SHA256.hash $ B.append (pack prefix) bs

hashString :: String -> B.ByteString
hashString s = hash "u" $ pack s

hashNull :: B.ByteString
hashNull = B.empty

hashBool :: Bool -> B.ByteString
hashBool b = hash "b" $ pack bs
  where
    bs = if b then "1" else "0"

significandString :: Double -> String
significandString d
  | d == 0    = ""
  | d >= 1    = "1" ++ significandString ((d - 1) * 2)
  | otherwise = "0" ++ significandString (d * 2)

normalizeDouble :: Double -> String
normalizeDouble d
  | isInfinite d = if d > 0 then "Infinity" else "-Infinity"
  | isNaN d      = "NaN"
  | d == 0       = "+0:"
  | d < 0        = "-" ++ stringified (-d)
  | d > 0        = "+" ++ stringified d
  where
    stringified n =
      show (exponent n) ++ ":" ++ significandString (significand n)

hashScientific :: Sci.Scientific -> B.ByteString
hashScientific sci =
  case num of
    Left double -> hash "f" $ pack $ normalizeDouble double
    Right int -> hash "i" $ pack $ show int
  where
    num = Sci.floatingOrInteger sci

hashList :: A.Array -> B.ByteString
hashList _ = B.empty
-- hashList a = concat $ Vector.map hashValue a

hashObject :: HashMap Text.Text A.Value -> B.ByteString
hashObject obj = hash "d" $ B.concat $ sort $ hashElements $ obj
  where
    hashElement (k, v) = B.append (hashString $ Text.unpack k) (hashValue v)
    hashElements hm = map hashElement (toList hm)

hashValue :: A.Value -> B.ByteString
hashValue A.Null = hashNull
hashValue (A.String s) = hashString $ Text.unpack s
hashValue (A.Bool b) = hashBool b
hashValue (A.Array xs) = hashList xs
hashValue (A.Number n) = hashScientific n
hashValue (A.Object o) = hashObject o

objhash :: ToJSON a => a -> B.ByteString
objhash = hashValue . toJSON

-- --- Additional syntax coverage ----------------------------------------------

{- A block comment
   {- with a nested block comment -}
   spanning several lines. -}

-- | A haddock comment describing 'Algo'.
data Algo
  = Sha256   -- ^ the default algorithm
  | Sha512   -- ^ the longer one
  | Blake2
  deriving (Eq, Ord, Show, Read, Enum, Bounded)

-- | A record with a strict field and an annotation on every field.
data Fingerprint = Fingerprint
  { fpAlgo   :: !Algo
  , fpDigest :: B.ByteString
  , fpLength :: Int
  , fpLabel  :: Maybe String
  } deriving stock (Eq, Show)

newtype Salt = Salt { unSalt :: B.ByteString }
  deriving newtype (Eq, Ord, Show)

data Tree a
  = Leaf
  | Node (Tree a) a (Tree a)
  deriving (Show, Eq)

type Registry = Map String Fingerprint

type Normalizer a = forall b. Show b => a -> b -> String

-- | A GADT for a tiny expression language.
data Expr a where
  IntE  :: Int -> Expr Int
  BoolE :: Bool -> Expr Bool
  Add   :: Expr Int -> Expr Int -> Expr Int
  If    :: Expr Bool -> Expr a -> Expr a -> Expr a
  Eq    :: Expr Int -> Expr Int -> Expr Bool

eval :: Expr a -> a
eval (IntE n)   = n
eval (BoolE b)  = b
eval (Add l r)  = eval l + eval r
eval (If c t e) = if eval c then eval t else eval e
eval (Eq l r)   = eval l == eval r

infixl 6 <+>
infixr 5 +++
infix 4 ~=

-- | Combine two digests by xor-ing them byte-wise.
(<+>) :: B.ByteString -> B.ByteString -> B.ByteString
a <+> b = B.pack $ B.zipWith xor a b

(+++) :: [a] -> [a] -> [a]
xs +++ ys = foldr (:) ys xs

(~=) :: Double -> Double -> Bool
x ~= y = abs (x - y) < 1.0e-9

class (Eq a, Show a) => Hashable a where
  {-# MINIMAL tag #-}
  hashOf :: a -> B.ByteString
  hashOf = hashString . show
  tag :: a -> Char

instance Hashable Int where
  tag _ = 'i'
  hashOf n = hash "i" (pack (show n))

instance Hashable Bool where
  tag _ = 'b'

instance Hashable a => Hashable [a] where
  tag _ = 'l'
  hashOf xs = hash "l" $ B.concat (map hashOf xs)

instance (Hashable a, Hashable b) => Hashable (a, b) where
  tag _ = 't'
  hashOf (a, b) = hashOf a <+> hashOf b

instance Semigroup Salt where
  Salt a <> Salt b = Salt (a <+> b)

instance Monoid Salt where
  mempty = Salt B.empty

instance Functor Tree where
  fmap _ Leaf = Leaf
  fmap f (Node l x r) = Node (fmap f l) (f x) (fmap f r)

instance Foldable Tree where
  foldr _ z Leaf = z
  foldr f z (Node l x r) = foldr f (f x (foldr f z r)) l

magicNumbers :: [Integer]
magicNumbers = [0xFF, 0o17, 0b1010, 1_000_000, 42, -7]

floats :: [Double]
floats = [1.5e-3, 6.022e23, 0.5, 1e10]

ratio :: Rational
ratio = 3 % 4 + 1 % 3

complexNum :: Complex Double
complexNum = 2 :+ (-3)

chars :: [Char]
chars = ['a', '\n', '\t', '\x41', '\101', '\'', '\\', '\SOH', '\1234']

escaped :: String
escaped = "tab\there \"quoted\" back\\slash \x41\&1 unicode\1234 \
          \with a string gap continuing here"

multiline :: String
multiline = unlines
  [ "first line"
  , "second line"
  ]

-- | Pattern matching with as-patterns, record wildcards, pattern guards and where.
describe :: Fingerprint -> String
describe fp@Fingerprint{ fpAlgo = algo, fpLength = len, .. }
  | len == 0                 = "empty " ++ show algo
  | Just lbl <- fpLabel      = lbl ++ ": " ++ summary
  | len > 32, algo == Sha512 = "strong " ++ summary
  | otherwise                = summary
  where
    summary = show (fpAlgo fp) ++ "/" ++ show len ++ bytesNote
    bytesNote
      | B.null fpDigest = " (no bytes)"
      | otherwise       = " (" ++ show (B.length fpDigest) ++ " bytes)"

relabel :: String -> Fingerprint -> Fingerprint
relabel lbl fp = fp { fpLabel = Just lbl, fpLength = fpLength fp + 1 }

classify :: Int -> String
classify = \case
  0 -> "zero"
  n | n < 0 -> "negative"
    | even n -> "even"
  _ -> "odd"

rank :: Double -> Ordering
rank x = if | x ~= 0    -> EQ
            | x < 0     -> LT
            | otherwise -> GT

-- | List comprehensions, sections, point-free style and arithmetic sequences.
pairs :: [(Int, Int)]
pairs = [ (x, y) | x <- [1, 3 .. 9], y <- [10, 8 .. 2], let s = x + y, even s, x /= y ]

squares :: [Int]
squares = map (^ 2) . filter ((== 0) . (`mod` 3)) $ takeWhile (< 100) (iterate (+ 7) 1)

alphabet :: [(Char, Int)]
alphabet = zip ['a' .. 'z'] (map (subtract 96 . ord) ['a' ..])

lookupAll :: Registry -> [String] -> [Fingerprint]
lookupAll reg = mapMaybe (`M.lookup` reg)

sortedByLength :: [Fingerprint] -> [Fingerprint]
sortedByLength = sortBy (comparing (Down . fpLength) <> comparing fpAlgo)

-- | Explicit forall with a scoped type variable and a local annotation.
chunked :: forall a. Int -> [a] -> [[a]]
chunked n = go
  where
    go :: [a] -> [[a]]
    go [] = []
    go xs = let (h, t) = splitAt n xs in h : go t

-- | Maybe in do-notation, with Functor, Applicative and Monad operators.
parseEntry :: String -> Maybe (String, Int)
parseEntry s = do
  let (name, rest) = span (/= '=') s
  digits <- case rest of
    ('=' : ds) | all isDigit ds, not (null ds) -> Just ds
    _ -> Nothing
  value <- (* 2) <$> readMaybe' digits
  pure (map toUpper name, value)
  where
    readMaybe' str = case reads str of
      [(n, "")] -> Just n
      _ -> Nothing

combined :: Maybe Int
combined = (+) <$> Just 1 <*> Just 2 >>= \n -> if n > 2 then Just (n * 10) else Nothing

eitherChain :: Either String Int
eitherChain = Right 5 >>= check >>= pure . (`shiftL` 1)
  where
    check n
      | n .&. 1 == 1 = Right (n .|. 2)
      | otherwise    = Left ("even: " ++ show n)

folds :: [Int] -> (Int, Int, Int)
folds xs = (foldr (+) 0 xs, foldl (flip (:)) [] xs & length, sum . zipWith (*) xs $ tail xs)

strictSum :: [Int] -> Int
strictSum = go 0
  where
    go !acc []       = acc
    go !acc (y : ys) = go (acc + y) ys

tupleSections :: [(Int, String)]
tupleSections = map (,"x") [1, 2] +++ map (0,) ["y"]

tree :: Tree Int
tree = Node (Node Leaf 1 Leaf) 2 (Node Leaf 3 Leaf)

-- | IO with do-notation, let, where, when/unless, forM_ and foldM.
main :: IO ()
main = do
  let registry :: Registry
      registry = M.fromList
        [ (lbl, Fingerprint algo (hashString lbl) (length lbl) (Just lbl))
        | (lbl, algo) <- zip ["alpha", "beta", "gamma"] [minBound .. maxBound]
        ]
      total = M.size registry
  forM_ (M.toList registry) $ \(k, v) -> putStrLn (k ++ " -> " ++ describe v)
  when (total > 1) $ putStrLn "multiple"
  unless (null squares) . print $ take 3 squares
  result <- foldM (\acc n -> pure (acc + n)) 0 magicNumbers
  print (result, ratio, numerator ratio, magnitude complexNum)
  print $ eval (If (Eq (IntE 1) (IntE 1)) (IntE 1) (Add (IntE 2) (IntE 3)))
  mapM_ (putStrLn . intercalate ", " . map show) (chunked 2 [1 .. 5 :: Int])
  putStrLn $ classify (read "42") ++ show (rank 0.0) ++ fromMaybe "none" (fst <$> parseEntry "key=12")
  print (sum (fmap (* 2) tree), length tree, maximum tree, elem 3 tree)
  print (either length id eitherChain, maybe 0 negate combined, relabel "x" <$> lookupAll registry ["alpha"])
  print (describeLast, floats !! 1, chars, escaped, multiline, words "a b" ++ lines "c\nd", unSalt mempty)
  where
    describeLast = unwords ["last", show (last magicNumbers)]
