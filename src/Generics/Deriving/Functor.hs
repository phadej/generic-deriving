{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}
#if __GLASGOW_HASKELL__ >= 701
{-# LANGUAGE DefaultSignatures #-}
#endif

module Generics.Deriving.Functor (
  -- * GFunctor class
    GFunctor(..)

  -- * Default method
  , gmapdefault

  ) where

import Control.Applicative (Const, ZipList)

import Data.Monoid (First, Last)

import Generics.Deriving.Base
import Generics.Deriving.Instances ()

#if MIN_VERSION_base(4,4,0)
import Data.Complex (Complex)
#endif

#if MIN_VERSION_base(4,7,0)
import Data.Proxy (Proxy)
#endif

#if MIN_VERSION_base(4,8,0)
import Data.Functor.Identity (Identity)
import Data.Monoid (Alt)
#endif

--------------------------------------------------------------------------------
-- Generic fmap
--------------------------------------------------------------------------------

class GFunctor' f where
  gmap' :: (a -> b) -> f a -> f b

instance GFunctor' U1 where
  gmap' _ U1 = U1

instance GFunctor' Par1 where
  gmap' f (Par1 a) = Par1 (f a)

instance GFunctor' (K1 i c) where
  gmap' _ (K1 a) = K1 a

instance (GFunctor f) => GFunctor' (Rec1 f) where
  gmap' f (Rec1 a) = Rec1 (gmap f a)

instance (GFunctor' f) => GFunctor' (M1 i c f) where
  gmap' f (M1 a) = M1 (gmap' f a)

instance (GFunctor' f, GFunctor' g) => GFunctor' (f :+: g) where
  gmap' f (L1 a) = L1 (gmap' f a)
  gmap' f (R1 a) = R1 (gmap' f a)

instance (GFunctor' f, GFunctor' g) => GFunctor' (f :*: g) where
  gmap' f (a :*: b) = gmap' f a :*: gmap' f b

instance (GFunctor f, GFunctor' g) => GFunctor' (f :.: g) where
  gmap' f (Comp1 x) = Comp1 (gmap (gmap' f) x)


class GFunctor f where
  gmap :: (a -> b) -> f a -> f b
#if __GLASGOW_HASKELL__ >= 701
  default gmap :: (Generic1 f, GFunctor' (Rep1 f))
               => (a -> b) -> f a -> f b
  gmap = gmapdefault
#endif

gmapdefault :: (Generic1 f, GFunctor' (Rep1 f))
            => (a -> b) -> f a -> f b
gmapdefault f = to1 . gmap' f . from1

-- Base types instances
instance GFunctor ((->) r) where
  gmap = fmap

instance GFunctor ((,) a) where
  gmap = gmapdefault

instance GFunctor [] where
  gmap = gmapdefault

#if MIN_VERSION_base(4,8,0)
instance GFunctor f => GFunctor (Alt f) where
  gmap = gmapdefault
#endif

#if MIN_VERSION_base(4,4,0)
instance GFunctor Complex where
  gmap = gmapdefault
#endif

instance GFunctor (Const m) where
  gmap = gmapdefault

instance GFunctor (Either a) where
  gmap = gmapdefault

instance GFunctor First where
  gmap = gmapdefault

#if MIN_VERSION_base(4,8,0)
instance GFunctor Identity where
  gmap = gmapdefault
#endif

instance GFunctor IO where
  gmap = fmap

instance GFunctor Last where
  gmap = gmapdefault

instance GFunctor Maybe where
  gmap = gmapdefault

#if MIN_VERSION_base(4,7,0)
instance GFunctor Proxy where
  gmap = gmapdefault
#endif

instance GFunctor ZipList where
  gmap = gmapdefault
