{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
module Groups (tests) where

import Protolude hiding (group)

import Crypto.Error (CryptoFailable(..))
import GHC.Base (String)
import Test.QuickCheck (Gen, (===), arbitrary, forAll, property)
import Test.Tasty (TestTree)
import Test.Tasty.Hspec (Spec, testSpec, describe, it, shouldBe)

import Crypto.Spake2.Group (Group(..))
import Crypto.Spake2.Groups
  ( IntegerAddition(..)
  , IntegerGroup(..)
  , Ed25519(..)
  , i1024)
import qualified Crypto.Spake2.Groups.Ed25519 as Ed25519
import qualified Crypto.Spake2.Groups.IntegerGroup as IntegerGroup

tests :: IO TestTree
tests = testSpec "Groups" $ do
  groupProperties "integer addition modulo 7" (IntegerAddition 7) 1 (makeScalar 7)
  groupProperties "integer group" i1024 (IntegerGroup.generator i1024) (makeScalar (subgroupOrder i1024))
  groupProperties "Ed25519" Ed25519 Ed25519.generator (makeScalar Ed25519.l)


makeScalar :: Integer -> Gen Integer
makeScalar k = do
  i <- arbitrary
  pure $ i `mod` k

makeElement :: Group group => group -> Gen (Scalar group) -> Element group -> Gen (Element group)
makeElement group scalars base = do
  scalar <- scalars
  pure (scalarMultiply group scalar base)

groupProperties
  :: (Group group, Eq (Element group), Eq (Scalar group), Show (Element group), Show (Scalar group))
  => String
  -> group
  -> Element group
  -> Gen (Scalar group)
  -> Spec
groupProperties name group base scalars = describe name $ do
  it "addition is associative" $ property $
    forAll triples $ \(x, y, z) -> elementAdd group (elementAdd group x y) z === elementAdd group x (elementAdd group y z)

  it "addition with inverse yields identity" $ property $
    forAll elements $ \x -> elementAdd group x (elementNegate group x) === groupIdentity group

  it "double negative is no-op" $ property $
    forAll elements $ \x -> elementNegate group (elementNegate group x) === x

  it "identity is its own inverse" $
    elementNegate group (groupIdentity group) `shouldBe` groupIdentity group

  it "subtraction is negated addition" $ property $
    forAll pairs $ \(x, y) -> elementSubtract group x y === elementAdd group x (elementNegate group y)

  it "right-hand addition with identity yields original" $ property $
    forAll elements $ \x -> elementAdd group x (groupIdentity group) === x

  it "left-hand addition with identity yields original" $ property $
    forAll elements $ \x -> elementAdd group (groupIdentity group) x === x

  it "element codec roundtrips" $ property $
    forAll elements $ \x -> let bytes = encodeElement group x :: ByteString
                            in decodeElement group bytes == CryptoPassed x

  it "scalar to integer roundtrips" $ property $
    forAll scalars $ \n -> integerToScalar group (scalarToInteger group n) === n

  it "integer to scalar conversion" $ property $
    -- Doesn't roundtrip per se, because negative integers (for example) get
    -- turned into scalars within the subgroup range, losing the original
    -- information.
    \i -> integerToScalar group (scalarToInteger group (integerToScalar group i)) === integerToScalar group i

  it "scalar multiply by 0 is identity" $ property $
    forAll elements $ \x -> scalarMultiply group (integerToScalar group 0) x === groupIdentity group

  it "scalar multiply by 1 is original" $ property $
    forAll elements $ \x -> scalarMultiply group (integerToScalar group 1) x === x

  it "scalar multiply by 2 is equivalent to addition" $ property $
    forAll elements $ \x -> scalarMultiply group (integerToScalar group 2) x === elementAdd group x x

  where
    elements = makeElement group scalars base

    pairs = do
      x <- elements
      y <- elements
      pure (x, y)

    triples = do
      x <- elements
      y <- elements
      z <- elements
      pure (x, y, z)