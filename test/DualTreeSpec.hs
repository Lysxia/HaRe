module DualTreeSpec (main, spec) where

import           Test.Hspec

-- import qualified FastString as GHC
import qualified GHC        as GHC
-- import qualified Lexer      as GHC

-- import qualified GHC.SYB.Utils as SYB

-- import Control.Monad.State
-- import Data.List
-- import Data.Maybe
-- import Data.Tree

import Language.Haskell.Refact.Utils.DualTree
import Language.Haskell.Refact.Utils.GhcBugWorkArounds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LocUtils
-- import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
-- import Language.Haskell.Refact.Utils.TokenUtilsTypes
-- import Language.Haskell.Refact.Utils.TypeSyn
-- import Language.Haskell.Refact.Utils.TypeUtils

-- import Data.Tree.DUAL

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do


  -- ---------------------------------------------

  describe "layoutTreeToSourceTree" $ do
    it "retrieves the tokens in SourceTree format LetExpr" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/LetExpr.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (GHC.showRichTokenStream toks) `shouldBe` "-- A simple let expression, to ensure the layout is detected\n\n module Layout.LetExpr where\n\n foo = let x = 1\n           y = 2\n       in x + y\n\n "
      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(9,1))\n"++
          "1:((1,1),(3,7))\n"++
          "1:((3,8),(3,22))\n"++
          "1:((3,23),(3,28))\n"++
          "1:((5,1),(7,15))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(7,15))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(7,15))\n"++
          "4:((5,7),(5,10))\n"++
          "4:((5,11),(6,16))(Above None (5,11) (6,16) FromAlignCol (1,-9))\n"++
          "5:((5,11),(5,16))\n"++
          "6:((5,11),(5,12))\n"++
          "6:((5,13),(5,16))\n"++
          "7:((5,13),(5,14))\n"++
          "7:((5,15),(5,16))\n"++
          "5:((6,11),(6,16))\n"++
          "6:((6,11),(6,12))\n"++
          "6:((6,13),(6,16))\n"++
          "7:((6,13),(6,14))\n"++
          "7:((6,15),(6,16))\n"++
          "4:((7,10),(7,15))\n"++
          "5:((7,10),(7,11))\n"++
          "5:((7,12),(7,13))\n"++
          "5:((7,14),(7,15))\n"++
          "1:((9,1),(9,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (showGhc srcTree) `shouldBe` ""
      -- (show $ retrieveLines srcTree) `shouldBe` ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LetStmt" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/LetStmt.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      (GHC.showRichTokenStream $ bypassGHCBug7351 toks) `shouldBe` "-- A simple let statement, to ensure the layout is detected\n\nmodule Layout.LetStmt where\n\nfoo = do\n        let x = 1\n            y = 2\n        x+y\n\n"

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(10,1))\n"++
          "1:((1,1),(3,7))\n"++
          "1:((3,8),(3,22))\n"++
          "1:((3,23),(3,28))\n"++
          "1:((5,1),(8,12))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(8,12))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(8,12))\n"++
          "4:((5,7),(5,9))\n"++
          "4:((6,9),(8,12))(Above FromAlignCol (1,-1) (6,9) (8,12) FromAlignCol (2,-11))\n"++
          "5:((6,9),(7,18))\n"++
          "6:((6,9),(6,12))\n"++
          "6:((6,13),(7,18))(Above None (6,13) (7,18) FromAlignCol (1,-9))\n"++
          "7:((6,13),(6,18))\n"++
          "8:((6,13),(6,14))\n"++
          "8:((6,15),(6,18))\n"++
          "9:((6,15),(6,16))\n"++
          "9:((6,17),(6,18))\n"++
          "7:((7,13),(7,18))\n"++
          "8:((7,13),(7,14))\n"++
          "8:((7,15),(7,18))\n"++
          "9:((7,15),(7,16))\n"++
          "9:((7,17),(7,18))\n"++
          "5:((8,9),(8,12))\n"++
          "6:((8,9),(8,10))\n"++
          "6:((8,10),(8,11))\n"++
          "6:((8,11),(8,12))\n"++
          "1:((10,1),(10,1))\n"


      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --    ""

      (renderSourceTree srcTree) `shouldBe`
          "-- A simple let statement, to ensure the layout is detected\n\nmodule Layout.LetStmt where\n\nfoo = do\n        let x = 1\n            y = 2\n        x+y\n\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LayoutIn2" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Renaming/LayoutIn2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (GHC.showRichTokenStream $ bypassGHCBug7351 toks) `shouldBe` "module LayoutIn2 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'list' to 'ls'.\n\nsilly :: [Int] -> Int\nsilly list = case list of  (1:xs) -> 1\n--There is a comment\n                           (2:xs)\n                             | x < 10    -> 4  where  x = last xs\n                           otherwise -> 12\n\n"

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(14,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,17))\n"++
          "1:((1,18),(1,23))\n"++
          "1:((7,1),(7,22))\n"++
          "2:((7,1),(7,6))\n"++
          "2:((7,7),(7,9))\n"++
          "2:((7,10),(7,11))\n"++
          "2:((7,11),(7,14))\n"++
          "2:((7,14),(7,15))\n"++
          "2:((7,16),(7,18))\n"++
          "2:((7,19),(7,22))\n"++
          "1:((8,1),(12,43))\n"++
          "2:((8,1),(8,6))\n"++
          "2:((8,7),(12,43))\n"++
          "3:((8,7),(8,11))\n"++
          "3:((8,12),(8,13))\n"++
          "3:((8,14),(12,43))\n"++
          "4:((8,14),(8,18))\n"++
          "4:((8,19),(8,23))\n"++
          "4:((8,24),(8,26))\n"++
          "4:((8,28),(12,43))(Above SameLine 1 (8,28) (12,43) FromAlignCol (2,-42))\n"++
          "5:((8,28),(8,39))\n"++
          "6:((8,28),(8,34))\n"++
          "6:((8,35),(8,37))\n"++
          "6:((8,38),(8,39))\n"++
          "5:((9,1),(11,66))\n"++
          "6:((9,1),(10,34))\n"++
          "6:((11,30),(11,46))\n"++
          "7:((11,30),(11,31))\n"++
          "7:((11,32),(11,38))\n"++
          "8:((11,32),(11,33))\n"++
          "8:((11,34),(11,35))\n"++
          "8:((11,36),(11,38))\n"++
          "7:((11,45),(11,46))\n"++
          "6:((11,48),(11,53))\n"++
          "6:((11,55),(11,66))(Above SameLine 1 (11,55) (11,66) FromAlignCol (1,-38))\n"++
          "7:((11,55),(11,66))\n"++
          "8:((11,55),(11,56))\n"++
          "8:((11,57),(11,66))\n"++
          "9:((11,57),(11,58))\n"++
          "9:((11,59),(11,66))\n"++
          "10:((11,59),(11,63))\n"++
          "10:((11,64),(11,66))\n"++
          "5:((12,28),(12,43))\n"++
          "6:((12,28),(12,37))\n"++
          "6:((12,38),(12,40))\n"++
          "6:((12,41),(12,43))\n"++
          "1:((14,1),(14,1))\n"

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LetIn1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/LiftToToplevel/LetIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Where" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/Where.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format PatBind" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/PatBind.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(13,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,22))\n"++
         "1:((1,23),(1,28))\n"++
         "1:((4,1),(4,18))\n"++
         "2:((4,1),(4,4))\n"++
         "2:((4,5),(4,7))\n"++
         "2:((4,8),(4,9))\n"++
         "2:((4,9),(4,12))\n"++
         "2:((4,12),(4,13))\n"++
         "2:((4,14),(4,17))\n"++
         "2:((4,17),(4,18))\n"++
         "1:((5,1),(5,9))\n"++
         "2:((5,1),(5,2))\n"++
         "2:((5,3),(5,5))\n"++
         "2:((5,6),(5,9))\n"++
         "1:((6,1),(6,9))\n"++
         "2:((6,1),(6,2))\n"++
         "2:((6,3),(6,5))\n"++
         "2:((6,6),(6,9))\n"++
         "1:((7,1),(10,12))\n"++
         "2:((7,1),(7,10))\n"++
         "2:((7,11),(7,12))\n"++
         "2:((7,13),(7,38))\n"++
         "3:((7,13),(7,17))\n"++
         "3:((7,18),(7,19))\n"++
         "3:((7,20),(7,38))\n"++
         "4:((7,20),(7,30))\n"++
         "5:((7,20),(7,23))\n"++
         "5:((7,24),(7,30))\n"++
         "6:((7,24),(7,25))\n"++
         "6:((7,25),(7,26))\n"++
         "6:((7,28),(7,30))\n"++
         "4:((7,32),(7,38))\n"++
         "5:((7,32),(7,33))\n"++
         "5:((7,33),(7,34))\n"++
         "5:((7,36),(7,38))\n"++
         "2:((8,3),(8,8))\n"++
         "2:((9,5),(10,12))(Above FromAlignCol (1,-4) (9,5) (10,12) FromAlignCol (3,-11))\n"++
         "3:((9,5),(9,14))\n"++
         "4:((9,5),(9,7))\n"++
         "4:((9,8),(9,10))\n"++
         "4:((9,11),(9,14))\n"++
         "3:((10,5),(10,12))\n"++
         "4:((10,5),(10,7))\n"++
         "4:((10,8),(10,12))\n"++
         "5:((10,8),(10,9))\n"++
         "5:((10,10),(10,12))\n"++
         "1:((13,1),(13,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format TokenTest" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/TokenTest.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(26,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,17))\n"++
          "1:((1,18),(1,23))\n"++
          "1:((5,1),(6,14))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(6,14))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(5,8))\n"++
          "3:((5,9),(5,10))\n"++
          "3:((5,11),(5,12))\n"++
          "3:((6,3),(6,8))\n"++
          "3:((6,9),(6,14))(Above None (6,9) (6,14) FromAlignCol (2,-13))\n"++
          "4:((6,9),(6,14))\n"++
          "5:((6,9),(6,10))\n"++
          "5:((6,11),(6,14))\n"++
          "6:((6,11),(6,12))\n"++
          "6:((6,13),(6,14))\n"++
          "1:((8,1),(10,10))\n"++
          "2:((8,1),(8,4))\n"++
          "2:((8,5),(10,10))\n"++
          "3:((8,5),(8,6))\n"++
          "3:((8,7),(8,8))\n"++
          "3:((8,9),(8,10))\n"++
          "3:((8,11),(8,12))\n"++
          "3:((9,3),(9,8))\n"++
          "3:((10,5),(10,10))(Above FromAlignCol (1,-4) (10,5) (10,10) FromAlignCol (3,-9))\n"++
          "4:((10,5),(10,10))\n"++
          "5:((10,5),(10,6))\n"++
          "5:((10,7),(10,10))\n"++
          "6:((10,7),(10,8))\n"++
          "6:((10,9),(10,10))\n"++
          "1:((13,1),(15,17))\n"++
          "2:((13,1),(13,4))\n"++
          "2:((13,5),(15,17))\n"++
          "3:((13,5),(13,6))\n"++
          "3:((13,7),(13,8))\n"++
          "3:((13,9),(13,10))\n"++
          "3:((14,3),(15,17))\n"++
          "4:((14,3),(14,6))\n"++
          "4:((14,7),(14,14))(Above None (14,7) (14,14) FromAlignCol (1,-11))\n"++
          "5:((14,7),(14,14))\n"++
          "6:((14,7),(14,10))\n"++
          "6:((14,11),(14,14))\n"++
          "7:((14,11),(14,12))\n"++
          "7:((14,13),(14,14))\n"++
          "4:((15,10),(15,17))\n"++
          "5:((15,10),(15,11))\n"++
          "5:((15,12),(15,13))\n"++
          "5:((15,14),(15,17))\n"++
          "1:((19,1),(21,14))\n"++
          "2:((19,1),(19,4))\n"++
          "2:((19,5),(21,14))\n"++
          "3:((19,5),(19,6))\n"++
          "3:((19,7),(19,8))\n"++
          "3:((19,9),(19,10))\n"++
          "3:((20,3),(21,14))\n"++
          "4:((20,3),(20,5))\n"++
          "4:((20,6),(21,14))(Above None (20,6) (21,14) FromAlignCol (5,-13))\n"++
          "5:((20,6),(20,18))\n"++
          "6:((20,6),(20,7))\n"++
          "6:((20,11),(20,18))\n"++
          "5:((21,6),(21,14))\n"++
          "6:((21,6),(21,12))\n"++
          "6:((21,13),(21,14))\n"++
          "1:((26,1),(26,1))\n"

      let srcTree = layoutTreeToSourceTree layout
{-
      srcTree `shouldBe`
          []
-}
      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Md1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(44,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,2))\n"++
          "2:((6,2),(6,3))\n"++
          "2:((6,3),(6,4))\n"++
          "2:((6,5),(6,7))\n"++
          "2:((6,8),(6,15))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
          "2:((8,1),(8,2))\n"++
          "2:((8,3),(8,6))\n"++
          "3:((8,3),(8,4))\n"++
          "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,18))\n"++
          "2:((11,1),(11,4))\n"++
          "2:((11,5),(11,7))\n"++
          "2:((11,8),(11,9))\n"++
          "2:((11,9),(11,12))\n"++
          "2:((11,12),(11,13))\n"++
          "2:((11,14),(11,17))\n"++
          "2:((11,17),(11,18))\n"++
          "1:((12,1),(12,9))\n"++
          "2:((12,1),(12,2))\n"++
          "2:((12,3),(12,5))\n"++
          "2:((12,6),(12,9))\n"++
          "1:((13,1),(13,9))\n"++
          "2:((13,1),(13,2))\n"++
          "2:((13,3),(13,5))\n"++
          "2:((13,6),(13,9))\n"++
          "1:((14,1),(17,12))\n"++
          "2:((14,1),(14,10))\n"++
          "2:((14,11),(14,12))\n"++
          "2:((14,13),(14,38))\n"++
          "3:((14,13),(14,17))\n"++
          "3:((14,18),(14,19))\n"++
          "3:((14,20),(14,38))\n"++
          "4:((14,20),(14,30))\n"++
          "5:((14,20),(14,23))\n"++
          "5:((14,24),(14,30))\n"++
          "6:((14,24),(14,25))\n"++
          "6:((14,25),(14,26))\n"++
          "6:((14,28),(14,30))\n"++
          "4:((14,32),(14,38))\n"++
          "5:((14,32),(14,33))\n"++
          "5:((14,33),(14,34))\n"++
          "5:((14,36),(14,38))\n"++
          "2:((15,3),(15,8))\n"++
          "2:((16,5),(17,12))(Above FromAlignCol (1,-4) (16,5) (17,12) FromAlignCol (2,-11))\n"++
          "3:((16,5),(16,14))\n"++
          "4:((16,5),(16,7))\n"++
          "4:((16,8),(16,10))\n"++
          "4:((16,11),(16,14))\n"++
          "3:((17,5),(17,12))\n"++
          "4:((17,5),(17,7))\n"++
          "4:((17,8),(17,12))\n"++
          "5:((17,8),(17,9))\n"++
          "5:((17,10),(17,12))\n"++
          "1:((19,1),(19,26))\n"++
          "2:((19,1),(19,5))\n"++
          "2:((19,6),(19,7))\n"++
          "2:((19,8),(19,26))\n"++
          "3:((19,8),(19,9))\n"++
          "3:((19,10),(19,11))\n"++
          "3:((19,12),(19,13))\n"++
          "3:((19,14),(19,22))\n"++
          "4:((19,14),(19,15))\n"++
          "4:((19,16),(19,22))\n"++
          "3:((19,23),(19,24))\n"++
          "3:((19,25),(19,26))\n"++
          "1:((21,1),(21,17))\n"++
          "2:((21,1),(21,3))\n"++
          "2:((21,4),(21,6))\n"++
          "2:((21,7),(21,10))\n"++
          "2:((21,11),(21,13))\n"++
          "2:((21,14),(21,17))\n"++
          "1:((22,1),(24,11))\n"++
          "2:((22,1),(22,3))\n"++
          "2:((22,4),(24,11))\n"++
          "3:((22,4),(22,5))\n"++
          "3:((22,6),(22,7))\n"++
          "3:((22,8),(22,14))\n"++
          "4:((22,8),(22,9))\n"++
          "4:((22,10),(22,11))\n"++
          "4:((22,12),(22,14))\n"++
          "3:((23,3),(23,8))\n"++
          "3:((24,5),(24,11))(Above FromAlignCol (1,-4) (24,5) (24,11) FromAlignCol (2,-10))\n"++
          "4:((24,5),(24,11))\n"++
          "5:((24,5),(24,7))\n"++
          "5:((24,8),(24,11))\n"++
          "6:((24,8),(24,9))\n"++
          "6:((24,10),(24,11))\n"++
          "1:((26,1),(29,12))\n"++
          "2:((26,1),(26,2))\n"++
          "2:((26,3),(29,12))\n"++
          "3:((26,3),(26,4))\n"++
          "3:((26,5),(26,6))\n"++
          "3:((27,3),(29,12))\n"++
          "4:((27,3),(27,6))\n"++
          "4:((28,5),(28,12))(Above FromAlignCol (1,-2) (28,5) (28,12) FromAlignCol (1,-9))\n"++
          "5:((28,5),(28,12))\n"++
          "6:((28,5),(28,7))\n"++
          "6:((28,8),(28,12))\n"++
          "7:((28,8),(28,9))\n"++
          "7:((28,10),(28,12))\n"++
          "4:((29,6),(29,12))\n"++
          "5:((29,6),(29,8))\n"++
          "5:((29,9),(29,10))\n"++
          "5:((29,11),(29,12))\n"++
          "1:((31,1),(33,18))\n"++
          "2:((31,1),(31,3))\n"++
          "2:((31,4),(33,18))\n"++
          "3:((31,4),(31,5))\n"++
          "3:((31,6),(31,7))\n"++
          "3:((31,8),(33,18))\n"++
          "4:((31,8),(31,10))\n"++
          "4:((32,3),(33,18))(Above FromAlignCol (1,-8) (32,3) (33,18) FromAlignCol (2,-17))\n"++
          "5:((32,3),(32,13))\n"++
          "6:((32,3),(32,6))\n"++
          "6:((32,7),(32,13))(Above None (32,7) (32,13) FromAlignCol (1,-10))\n"++
          "7:((32,7),(32,13))\n"++
          "8:((32,7),(32,9))\n"++
          "8:((32,10),(32,13))\n"++
          "9:((32,10),(32,11))\n"++
          "9:((32,12),(32,13))\n"++
          "5:((33,3),(33,18))\n"++
          "6:((33,3),(33,9))\n"++
          "6:((33,10),(33,18))\n"++
          "7:((33,10),(33,11))\n"++
          "7:((33,11),(33,17))\n"++
          "8:((33,11),(33,13))\n"++
          "8:((33,14),(33,15))\n"++
          "8:((33,16),(33,17))\n"++
          "7:((33,17),(33,18))\n"++
          "1:((35,1),(35,23))\n"++
          "2:((35,1),(35,4))\n"++
          "2:((35,5),(35,23))\n"++
          "3:((35,5),(35,6))\n"++
          "3:((35,7),(35,8))\n"++
          "3:((35,9),(35,23))\n"++
          "4:((35,9),(35,10))\n"++
          "4:((35,11),(35,12))\n"++
          "4:((35,13),(35,23))\n"++
          "5:((35,13),(35,21))\n"++
          "5:((35,22),(35,23))\n"++
          "1:((39,1),(39,29))\n"++
          "2:((39,1),(39,7))\n"++
          "2:((39,8),(39,10))\n"++
          "2:((39,11),(39,18))\n"++
          "2:((39,19),(39,21))\n"++
          "2:((39,22),(39,29))\n"++
          "1:((40,1),(40,17))\n"++
          "2:((40,1),(40,7))\n"++
          "2:((40,8),(40,17))\n"++
          "3:((40,8),(40,9))\n"++
          "3:((40,10),(40,11))\n"++
          "3:((40,12),(40,17))\n"++
          "4:((40,12),(40,13))\n"++
          "4:((40,14),(40,15))\n"++
          "4:((40,16),(40,17))\n"++
          "1:((44,1),(44,1))\n"


      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Layout.LetIn1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/TypeUtils/LayoutLet1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((6,1),(8,25))\n"++
         "2:((6,1),(6,4))\n"++
         "2:((6,5),(8,25))\n"++
         "3:((6,5),(6,8))\n"++
         "3:((6,9),(6,10))\n"++
         "3:((6,11),(8,25))\n"++
         "4:((6,11),(6,14))\n"++
         "4:((6,15),(7,20))(Above None (6,15) (7,20) FromAlignCol (1,-9))\n"++
         "5:((6,15),(6,20))\n"++
         "6:((6,15),(6,16))\n"++
         "6:((6,17),(6,20))\n"++
         "7:((6,17),(6,18))\n"++
         "7:((6,19),(6,20))\n"++
         "5:((7,15),(7,20))\n"++
         "6:((7,15),(7,16))\n"++
         "6:((7,17),(7,20))\n"++
         "7:((7,17),(7,18))\n"++
         "7:((7,19),(7,20))\n"++
         "4:((8,14),(8,25))\n"++
         "5:((8,14),(8,21))\n"++
         "6:((8,14),(8,17))\n"++
         "6:((8,18),(8,19))\n"++
         "6:((8,20),(8,21))\n"++
         "5:((8,22),(8,23))\n"++
         "5:((8,24),(8,25))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Layout.Comments1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/Comments1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,24))\n"++
          "1:((1,25),(1,30))\n"++
          "1:((3,1),(4,19))\n"++
          "2:((3,1),(3,5))\n"++
          "2:((3,6),(4,19))\n"++
          "3:((3,6),(3,7))\n"++
          "3:((3,8),(3,9))\n"++
          "3:((3,10),(3,15))\n"++
          "4:((3,10),(3,11))\n"++
          "4:((3,12),(3,13))\n"++
          "4:((3,14),(3,15))\n"++
          "3:((4,10),(4,15))\n"++
          "3:((4,16),(4,19))(Above None (4,16) (4,43) FromAlignCol (2,-42))\n"++
          "4:((4,16),(4,19))\n"++
          "5:((4,16),(4,17))\n"++
          "5:((4,17),(4,19))\n"++
          "6:((4,17),(4,18))\n"++
          "6:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,11))\n"++
          "2:((6,12),(6,15))\n"++
          "3:((6,12),(6,13))\n"++
          "3:((6,14),(6,15))\n"++
          "1:((8,1),(8,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format LocToName" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/LocToName.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(25,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(12,3))\n"++
         "1:((20,1),(24,18))\n"++
         "2:((20,1),(20,11))\n"++
         "2:((20,12),(20,41))\n"++
         "3:((20,12),(20,18))\n"++
         "3:((20,19),(20,20))\n"++
         "3:((20,21),(20,41))\n"++
         "4:((20,21),(20,25))\n"++
         "5:((20,21),(20,22))\n"++
         "5:((20,23),(20,24))\n"++
         "5:((20,24),(20,25))\n"++
         "4:((20,26),(20,27))\n"++
         "4:((20,28),(20,41))\n"++
         "5:((20,28),(20,38))\n"++
         "5:((20,39),(20,41))\n"++
         "2:((24,1),(24,18))\n"++
         "3:((24,1),(24,11))\n"++
         "3:((24,12),(24,14))\n"++
         "3:((24,15),(24,16))\n"++
         "3:((24,17),(24,18))\n"++
         "1:((25,1),(25,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format DupDef.Dd1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(34,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,18))\n"++
          "1:((1,19),(1,24))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,2))\n"++
          "2:((6,2),(6,3))\n"++
          "2:((6,3),(6,4))\n"++
          "2:((6,5),(6,7))\n"++
          "2:((6,8),(6,15))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
          "2:((8,1),(8,2))\n"++
          "2:((8,3),(8,6))\n"++
          "3:((8,3),(8,4))\n"++
          "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,18))\n"++
          "2:((11,1),(11,4))\n"++
          "2:((11,5),(11,7))\n"++
          "2:((11,8),(11,9))\n"++
          "2:((11,9),(11,12))\n"++
          "2:((11,12),(11,13))\n"++
          "2:((11,14),(11,17))\n"++
          "2:((11,17),(11,18))\n"++
          "1:((12,1),(12,9))\n"++
          "2:((12,1),(12,2))\n"++
          "2:((12,3),(12,5))\n"++
          "2:((12,6),(12,9))\n"++
          "1:((13,1),(13,9))\n"++
          "2:((13,1),(13,2))\n"++
          "2:((13,3),(13,5))\n"++
          "2:((13,6),(13,9))\n"++
          "1:((14,1),(17,12))\n"++
          "2:((14,1),(14,10))\n"++
          "2:((14,11),(14,12))\n"++
          "2:((14,13),(14,38))\n"++
          "3:((14,13),(14,17))\n"++
          "3:((14,18),(14,19))\n"++
          "3:((14,20),(14,38))\n"++
          "4:((14,20),(14,30))\n"++
          "5:((14,20),(14,23))\n"++
          "5:((14,24),(14,30))\n"++
          "6:((14,24),(14,25))\n"++
          "6:((14,25),(14,26))\n"++
          "6:((14,28),(14,30))\n"++
          "4:((14,32),(14,38))\n"++
          "5:((14,32),(14,33))\n"++
          "5:((14,33),(14,34))\n"++
          "5:((14,36),(14,38))\n"++
          "2:((15,3),(15,8))\n"++
          "2:((16,5),(17,12))(Above FromAlignCol (1,-4) (16,5) (17,12) FromAlignCol (2,-11))\n"++
          "3:((16,5),(16,14))\n"++
          "4:((16,5),(16,7))\n"++
          "4:((16,8),(16,10))\n"++
          "4:((16,11),(16,14))\n"++
          "3:((17,5),(17,12))\n"++
          "4:((17,5),(17,7))\n"++
          "4:((17,8),(17,12))\n"++
          "5:((17,8),(17,9))\n"++
          "5:((17,10),(17,12))\n"++
          "1:((19,1),(19,26))\n"++
          "2:((19,1),(19,5))\n"++
          "2:((19,6),(19,7))\n"++
          "2:((19,8),(19,26))\n"++
          "3:((19,8),(19,9))\n"++
          "3:((19,10),(19,11))\n"++
          "3:((19,12),(19,13))\n"++
          "3:((19,14),(19,22))\n"++
          "4:((19,14),(19,15))\n"++
          "4:((19,16),(19,22))\n"++
          "3:((19,23),(19,24))\n"++
          "3:((19,25),(19,26))\n"++
          "1:((21,1),(23,11))\n"++
          "2:((21,1),(21,3))\n"++
          "2:((21,4),(23,11))\n"++
          "3:((21,4),(21,5))\n"++
          "3:((21,6),(21,7))\n"++
          "3:((21,8),(21,14))\n"++
          "4:((21,8),(21,9))\n"++
          "4:((21,10),(21,11))\n"++
          "4:((21,12),(21,14))\n"++
          "3:((22,3),(22,8))\n"++
          "3:((23,5),(23,11))(Above FromAlignCol (1,-4) (23,5) (23,11) FromAlignCol (2,-10))\n"++
          "4:((23,5),(23,11))\n"++
          "5:((23,5),(23,7))\n"++
          "5:((23,8),(23,11))\n"++
          "6:((23,8),(23,9))\n"++
          "6:((23,10),(23,11))\n"++
          "1:((25,1),(28,12))\n"++
          "2:((25,1),(25,2))\n"++
          "2:((25,3),(28,12))\n"++
          "3:((25,3),(25,4))\n"++
          "3:((25,5),(25,6))\n"++
          "3:((26,3),(28,12))\n"++
          "4:((26,3),(26,6))\n"++
          "4:((27,5),(27,12))(Above FromAlignCol (1,-2) (27,5) (27,12) FromAlignCol (1,-9))\n"++
          "5:((27,5),(27,12))\n"++
          "6:((27,5),(27,7))\n"++
          "6:((27,8),(27,12))\n"++
          "7:((27,8),(27,9))\n"++
          "7:((27,10),(27,12))\n"++
          "4:((28,6),(28,12))\n"++
          "5:((28,6),(28,8))\n"++
          "5:((28,9),(28,10))\n"++
          "5:((28,11),(28,12))\n"++
          "1:((30,1),(32,18))\n"++
          "2:((30,1),(30,3))\n"++
          "2:((30,4),(32,18))\n"++
          "3:((30,4),(30,5))\n"++
          "3:((30,6),(30,7))\n"++
          "3:((30,8),(32,18))\n"++
          "4:((30,8),(30,10))\n"++
          "4:((31,3),(32,18))(Above FromAlignCol (1,-8) (31,3) (32,18) FromAlignCol (2,-17))\n"++
          "5:((31,3),(31,13))\n"++
          "6:((31,3),(31,6))\n"++
          "6:((31,7),(31,13))(Above None (31,7) (31,13) FromAlignCol (1,-10))\n"++
          "7:((31,7),(31,13))\n"++
          "8:((31,7),(31,9))\n"++
          "8:((31,10),(31,13))\n"++
          "9:((31,10),(31,11))\n"++
          "9:((31,12),(31,13))\n"++
          "5:((32,3),(32,18))\n"++
          "6:((32,3),(32,9))\n"++
          "6:((32,10),(32,18))\n"++
          "7:((32,10),(32,11))\n"++
          "7:((32,11),(32,17))\n"++
          "8:((32,11),(32,13))\n"++
          "8:((32,14),(32,15))\n"++
          "8:((32,16),(32,17))\n"++
          "7:((32,17),(32,18))\n"++
          "1:((34,1),(34,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe` ""

{-
      srcTree `shouldBe`
          []
-}

      (renderSourceTree srcTree) `shouldBe` origSource

    -- --------------------------------------

    it "retrieves the tokens in SourceTree format Renaming.LayoutIn4" $ do
      (t, toks) <- parsedFileGhc "./test/testdata/Renaming/LayoutIn4.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []


      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(12,53))\n"++
         "2:((7,1),(7,5))\n"++
         "2:((7,6),(12,53))\n"++
         "3:((7,6),(7,7))\n"++
         "3:((7,8),(7,21))\n"++
         "4:((7,8),(7,13))\n"++
         "4:((7,14),(7,21))\n"++
         "3:((7,22),(7,27))\n"++
         "3:((7,28),(12,53))(Above None (7,28) (12,53) FromAlignCol (2,-52))\n"++
         "4:((7,28),(12,53))\n"++
         "5:((7,28),(7,33))\n"++
         "5:((7,34),(12,53))\n"++
         "6:((7,34),(7,35))\n"++
         "6:((7,35),(7,36))\n"++
         "6:((7,37),(12,53))\n"++
         "7:((7,37),(7,39))\n"++
         "7:((7,41),(12,53))(Above SameLine 1 (7,41) (12,53) FromAlignCol (2,-52))\n"++
         "8:((7,41),(7,59))\n"++
         "9:((7,41),(7,44))\n"++
         "9:((7,46),(7,59))(Above SameLine 1 (7,46) (7,59) FromAlignCol (1,-57))\n"++
         "10:((7,46),(7,59))\n"++
         "11:((7,46),(7,47))\n"++
         "11:((7,48),(7,59))\n"++
         "12:((7,48),(7,49))\n"++
         "12:((7,50),(7,59))\n"++
         "13:((7,50),(7,57))\n"++
         "13:((7,58),(7,59))\n"++
         "8:((8,2),(9,53))\n"++
         "9:((8,2),(9,42))\n"++
         "9:((9,46),(9,53))\n"++
         "8:((10,41),(10,58))\n"++
         "9:((10,41),(10,44))\n"++
         "9:((10,46),(10,58))(Above SameLine 1 (10,46) (10,58) FromAlignCol (1,-17))\n"++
         "10:((10,46),(10,58))\n"++
         "11:((10,46),(10,47))\n"++
         "11:((10,48),(10,58))\n"++
         "12:((10,48),(10,49))\n"++
         "12:((10,50),(10,58))\n"++
         "13:((10,50),(10,51))\n"++
         "13:((10,51),(10,57))\n"++
         "14:((10,51),(10,52))\n"++
         "14:((10,53),(10,55))\n"++
         "14:((10,56),(10,57))\n"++
         "13:((10,57),(10,58))\n"++
         "8:((11,41),(11,49))\n"++
         "9:((11,41),(11,47))\n"++
         "9:((11,48),(11,49))\n"++
         "8:((12,41),(12,53))\n"++
         "9:((12,41),(12,47))\n"++
         "9:((12,48),(12,53))\n"++
         "1:((14,1),(14,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- --------------------------------------

    it "retrieves the tokens in SourceTree format Layout.Lift with deletion/insertion 1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Lift.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
          "3:((3,4),(3,5))\n"++
          "3:((3,6),(3,7))\n"++
          "3:((3,8),(3,14))\n"++
          "4:((3,8),(3,9))\n"++
          "4:((3,10),(3,11))\n"++
          "4:((3,12),(3,14))\n"++
          "3:((4,3),(4,8))\n"++
          "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
          "4:((5,5),(5,11))\n"++
          "5:((5,5),(5,7))\n"++
          "5:((5,8),(5,11))\n"++
          "6:((5,8),(5,9))\n"++
          "6:((5,10),(5,11))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-
getToksForSpan test/testdata/MoveDef/Md1.hs:24:5-10:("(((False,0,0,24),5),((False,0,0,24),11))",[((((24,5),(24,5)),ITvocurly),""),((((24,5),(24,7)),ITvarid "zz"),"zz"),((((24,8),(24,9)),ITequal),"="),((((24,10),(24,11)),ITinteger 1),"1")])

removeToksForPos ((24,5),(24,11))


rmLocalDecl: where/let tokens are at((23,3),(23,8))
removeToksForPos ((23,3),(23,8))

putDeclToksAfterSpan test/testdata/MoveDef/Md1.hs:(22,1)-(24,10):("(((False,0,0,22),1),((False,0,0,24),11))",PlaceOffset 2 0 2,[((((1,6),(1,8)),ITvarid "zz"),"zz"),((((1,9),(1,10)),ITequal),"="),((((1,11),(1,12)),ITinteger 1),"1")])


-}

      let sspan1 = posToSrcSpan layout ((5,5),(5,11))
      (showGhc sspan1) `shouldBe` "test/testdata/Layout/Lift.hs:5:5-10"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan1)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan2 = posToSrcSpan layout ((4,3),(4,8))
      (showGhc sspan2) `shouldBe` "test/testdata/Layout/Lift.hs:4:3-7"

      let (layout3,_old) = removeSrcSpan layout2 (srcSpanToForestSpan sspan2)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan3 = posToSrcSpan layout ((3,1),(5,11))
      (showGhc sspan3) `shouldBe` "test/testdata/Layout/Lift.hs:(3,1)-(5,10)"
      newToks <- basicTokenise "zz = 1"
      -- let (layout4,_newSpan) = addToksAfterSrcSpan layout3 sspan3 (PlaceOffset 2 0 2) newToks
      let (layout4,_newSpan) = addToksAfterSrcSpan layout3 sspan3 (PlaceOffset 2 0 2) newToks

      (drawTreeCompact layout4) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(5,11))\n"++
           "2:((3,1),(3,3))\n"++
           "2:((3,4),(5,11))\n"++
            "3:((3,4),(3,5))\n"++
            "3:((3,6),(3,7))\n"++
            "3:((3,8),(3,14))\n"++
             "4:((3,8),(3,9))\n"++
             "4:((3,10),(3,11))\n"++
             "4:((3,12),(3,14))\n"++
            "3:((4,3),(4,8))(1,-3)D\n"++
            "3:((5,5),(5,11))(2,-10)D\n"++
          "1:((1000005,1),(1000005,7))\n"++
          "1:((7,1),(7,6))\n"++
           "2:((7,1),(7,2))\n"++
           "2:((7,3),(7,6))\n"++
            "3:((7,3),(7,4))\n"++
            "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,1))\n"

      -- show layout4 `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout4
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Lift where\n\nff y = y + zz\n\nzz = 1\n\nx = 1\n"

    -- ---------------------------------

    it "retrieves the tokens in SourceTree format MoveDef.Demote with deletion/insertion 2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
           "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource


{-
removeToksForPos ((7,1),(7,6))

putToksAfterPos ((4,14),(4,19)) at PlaceOffset 1 4 2:[
   ((((0,1),(0,6)),ITwhere),"where"),
   ((((1,4),(1,21)),ITlineComment "-- c,d :: Integer"),"-- c,d ::
                                  -- Integer"),
   ((((2,4),(2,4)),ITvocurly),""),
   ((((2,4),(2,5)),ITvarid "c"),"c"),
   ((((2,6),(2,7)),ITequal),"="),
   ((((2,8),(2,9)),ITinteger 7),"7"),
   ((((3,1),(3,1)),ITvccurly),"")]
-}


      let sspan1 = posToSrcSpan layout ((7,1),(7,6))
      (showGhc sspan1) `shouldBe` "test/testdata/MoveDef/Demote.hs:7:1-5"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan1)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan2 = posToSrcSpan layout ((4,14),(4,19))
      (showGhc sspan2) `shouldBe` "test/testdata/MoveDef/Demote.hs:4:14-18"

      newToks <- basicTokenise "where\n   -- c,d :: Integer\n   c = 7\n"
      show newToks `shouldBe`
         "[((((0,1),(0,6)),ITwhere),\"where\"),((((1,4),(1,21)),ITlineComment \"-- c,d :: Integer\"),\"-- c,d :: Integer\"),((((2,4),(2,4)),ITvocurly),\"\"),((((2,4),(2,5)),ITvarid \"c\"),\"c\"),((((2,6),(2,7)),ITequal),\"=\"),((((2,8),(2,9)),ITinteger 7),\"7\"),((((3,1),(3,1)),ITvccurly),\"\")]"

      let (layout3,_newSpan) = addToksAfterSrcSpan layout2 sspan2 (PlaceOffset 1 4 2) newToks

      (drawTreeCompact layout3) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
           "2:((4,1),(4,9))\n"++
           "2:((4,10),(4,19))\n"++
            "3:((4,10),(4,11))\n"++
            "3:((4,12),(4,13))\n"++
            "3:((4,14),(4,19))\n"++
             "4:((4,14),(4,15))\n"++
             "4:((4,16),(4,17))\n"++
             "4:((4,18),(4,19))\n"++
            "3:((1000005,5),(1000007,13))\n"++
          "1:((7,1),(7,6))(1,-5)D\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
            "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout3

      -- (showGhc srcTree2) `shouldBe` ""
{-
      (showGhc $ getU srcTree2) `shouldBe`
          "Just (Up\n"++
          "       (Span (1, 1) (11, 1))\n"++
          "       [(Line 1 1 SOriginal \"module MoveDef.Demote where\"),\n"++
          "        (Line 3 1 SOriginal \"toplevel :: Integer -> Integer\"),\n"++
          "        (Line 4 1 SOriginal \"toplevel x = c * x\"),\n"++
          "        (Line 5 5 SAdded \"where\"), (Line 6 8 SAdded \"-- c,d :: Integer\"),\n"++
          "        (Line 7 8 SAdded \"c = 7\"), (Line 8 5 SAdded \"\"),\n"++
          "        (Line 9 1 SAdded \"\"), (Line 7 1 SOriginal \"d = 9\"),\n"++
          "        (Line 10 1 SOriginal \"\")]\n"++
          "       [(DeletedSpan (Span (7, 1) (7, 6)) 3 (1, -5))])"
-}

      (renderSourceTree srcTree2) `shouldBe` "module MoveDef.Demote where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n    where\n       -- c,d :: Integer\n       c = 7\n    \n\nd = 9\n\n\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))\n"++
           "2:((5,1),(5,3))\n"++
           "2:((5,4),(5,6))\n"++
           "2:((5,7),(5,10))\n"++
           "2:((5,11),(5,13))\n"++
           "2:((5,14),(5,17))\n"++
          "1:((6,1),(8,11))\n"++
           "2:((6,1),(6,3))\n"++
           "2:((6,4),(8,11))\n"++
            "3:((6,4),(6,5))\n"++
            "3:((6,6),(6,7))\n"++
            "3:((6,8),(6,14))\n"++
             "4:((6,8),(6,9))\n"++
             "4:((6,10),(6,11))\n"++
             "4:((6,12),(6,14))\n"++
            "3:((7,3),(7,8))\n"++
            "3:((8,5),(8,11))(Above FromAlignCol (1,-4) (8,5) (8,11) FromAlignCol (2,-10))\n"++
             "4:((8,5),(8,11))\n"++
              "5:((8,5),(8,7))\n"++
              "5:((8,8),(8,11))\n"++
               "6:((8,8),(8,9))\n"++
               "6:((8,10),(8,11))\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span
      -- removeToksForSpan test/testdata/MoveDef/Md1.hs:21:1-16:(((False,0,0,21),1),((False,0,0,21),17))
      -- Is line 5 in FromMd1

      let sspan = posToSrcSpan layout ((5,1),(5,17))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:5:1-16"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      (drawTreeCompact layout2) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))(1,-16)D\n"++
          "1:((6,1),(8,11))\n"++
           "2:((6,1),(6,3))\n"++
           "2:((6,4),(8,11))\n"++
            "3:((6,4),(6,5))\n"++
            "3:((6,6),(6,7))\n"++
            "3:((6,8),(6,14))\n"++
             "4:((6,8),(6,9))\n"++
             "4:((6,10),(6,11))\n"++
             "4:((6,12),(6,14))\n"++
            "3:((7,3),(7,8))\n"++
            "3:((8,5),(8,11))(Above FromAlignCol (1,-4) (8,5) (8,11) FromAlignCol (2,-10))\n"++
             "4:((8,5),(8,11))\n"++
              "5:((8,5),(8,7))\n"++
              "5:((8,8),(8,11))\n"++
               "6:((8,8),(8,9))\n"++
               "6:((8,10),(8,11))\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span
      -- removeToksForPos ((22,1),(24,11))
      -- Is line 6 in FromMd1

      let sspan = posToSrcSpan layout ((6,1),(8,11))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:(6,1)-(8,10)"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (show srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nff :: Int -> Int\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 3" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      let sspan = posToSrcSpan layout ((5,1),(5,17))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:5:1-16"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)


      -- Now check removing a span
      -- removeToksForPos ((22,1),(24,11))
      -- Is line 6 in FromMd1

      let sspan2 = posToSrcSpan layout ((6,1),(8,11))
      (showGhc sspan2) `shouldBe` "test/testdata/Layout/FromMd1.hs:(6,1)-(8,10)"

      let (layout3,_old) = removeSrcSpan layout2 (srcSpanToForestSpan sspan2)
      (drawTreeCompact layout3) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))(1,-16)D\n"++
          "1:((6,1),(8,11))(2,-10)D\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout3
      -- (showGhc srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.Where2 with deletion 4" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Where2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span

      let sspan = posToSrcSpan layout ((5,5),(5,14))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/Where2.hs:5:5-13"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      (drawTreeCompact layout2) `shouldBe`
          "0:((1,1),(9,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,21))\n"++
          "1:((1,22),(1,27))\n"++
          "1:((3,1),(6,12))\n"++
           "2:((3,1),(3,10))\n"++
           "2:((3,11),(3,12))\n"++
           "2:((3,13),(3,38))\n"++
            "3:((3,13),(3,17))\n"++
            "3:((3,18),(3,19))\n"++
            "3:((3,20),(3,38))\n"++
             "4:((3,20),(3,30))\n"++
              "5:((3,20),(3,23))\n"++
              "5:((3,24),(3,30))\n"++
               "6:((3,24),(3,25))\n"++
               "6:((3,25),(3,26))\n"++
               "6:((3,28),(3,30))\n"++
             "4:((3,32),(3,38))\n"++
              "5:((3,32),(3,33))\n"++
              "5:((3,33),(3,34))\n"++
              "5:((3,36),(3,38))\n"++
           "2:((4,3),(4,8))\n"++
           "2:((5,5),(6,12))(Above FromAlignCol (1,-4) (5,5) (6,12) FromAlignCol (2,-11))\n"++
            "3:((5,5),(5,14))(1,-9)D\n"++
            "3:((6,5),(6,12))\n"++
             "4:((6,5),(6,7))\n"++
             "4:((6,8),(6,12))\n"++
              "5:((6,8),(6,9))\n"++
              "5:((6,10),(6,12))\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
            "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((9,1),(9,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Where2 where\n\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff = 15\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format TypeUtils.LayoutLet2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/TypeUtils/LayoutLet2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((7,1),(8,35))\n"++
         "2:((7,1),(7,4))\n"++
         "2:((7,5),(8,35))\n"++
         "3:((7,5),(7,8))\n"++
         "3:((7,9),(7,10))\n"++
         "3:((7,11),(8,35))\n"++
         "4:((7,11),(7,14))\n"++
         "4:((7,15),(8,20))(Above None (7,15) (8,20) SameLine 1)\n"++
         "5:((7,15),(7,20))\n"++
         "6:((7,15),(7,16))\n"++
         "6:((7,17),(7,20))\n"++
         "7:((7,17),(7,18))\n"++
         "7:((7,19),(7,20))\n"++
         "5:((8,15),(8,20))\n"++
         "6:((8,15),(8,16))\n"++
         "6:((8,17),(8,20))\n"++
         "7:((8,17),(8,18))\n"++
         "7:((8,19),(8,20))\n"++
         "4:((8,24),(8,35))\n"++
         "5:((8,24),(8,31))\n"++
         "6:((8,24),(8,27))\n"++
         "6:((8,28),(8,29))\n"++
         "6:((8,30),(8,31))\n"++
         "5:((8,32),(8,33))\n"++
         "5:((8,34),(8,35))\n"++
         "1:((10,1),(10,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format Renaming.LayoutIn1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/LayoutIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
         "2:((7,1),(7,11))\n"++
         "2:((7,12),(9,40))\n"++
         "3:((7,12),(7,13))\n"++
         "3:((7,14),(7,15))\n"++
         "3:((7,15),(7,16))\n"++
         "3:((7,17),(7,28))\n"++
         "4:((7,17),(7,21))\n"++
         "5:((7,17),(7,19))\n"++
         "5:((7,20),(7,21))\n"++
         "4:((7,22),(7,23))\n"++
         "4:((7,24),(7,28))\n"++
         "5:((7,24),(7,26))\n"++
         "5:((7,27),(7,28))\n"++
         "3:((7,29),(7,34))\n"++
         "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
         "4:((7,35),(7,46))\n"++
         "5:((7,35),(7,37))\n"++
         "5:((7,38),(7,46))\n"++
         "6:((7,38),(7,39))\n"++
         "6:((7,39),(7,40))\n"++
         "6:((7,41),(7,46))\n"++
         "7:((7,41),(7,42))\n"++
         "7:((7,42),(7,43))\n"++
         "7:((7,43),(7,46))\n"++
         "4:((9,35),(9,40))\n"++
         "5:((9,35),(9,38))\n"++
         "5:((9,38),(9,40))\n"++
         "6:((9,38),(9,39))\n"++
         "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming Renaming.LayoutIn1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/LayoutIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
         "2:((7,1),(7,11))\n"++
         "2:((7,12),(9,40))\n"++
         "3:((7,12),(7,13))\n"++
         "3:((7,14),(7,15))\n"++
         "3:((7,15),(7,16))\n"++
         "3:((7,17),(7,28))\n"++
         "4:((7,17),(7,21))\n"++
         "5:((7,17),(7,19))\n"++
         "5:((7,20),(7,21))\n"++
         "4:((7,22),(7,23))\n"++
         "4:((7,24),(7,28))\n"++
         "5:((7,24),(7,26))\n"++
         "5:((7,27),(7,28))\n"++
         "3:((7,29),(7,34))\n"++
         "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
         "4:((7,35),(7,46))\n"++
         "5:((7,35),(7,37))\n"++
         "5:((7,38),(7,46))\n"++
         "6:((7,38),(7,39))\n"++
         "6:((7,39),(7,40))\n"++
         "6:((7,41),(7,46))\n"++
         "7:((7,41),(7,42))\n"++
         "7:((7,42),(7,43))\n"++
         "7:((7,43),(7,46))\n"++
         "4:((9,35),(9,40))\n"++
         "5:((9,35),(9,38))\n"++
         "5:((9,38),(9,40))\n"++
         "6:((9,38),(9,39))\n"++
         "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-

replaceToken test/testdata/Renaming/LayoutIn1.hs:7:17-18:(((False,0,0,7),17),((False,0,0,7),19))((((7,17),(7,23)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:24-25:(((False,0,0,7),24),((False,0,0,7),26))((((7,24),(7,30)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:35-36:(((False,0,0,7),35),((False,0,0,7),37))((((7,35),(7,41)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:35-36:(((False,0,0,7),35),((False,0,0,7),37))((((7,35),(7,41)),ITvarid "square"),"square")
-}

      let ss1 = posToSrcSpan layout ((7,17),(7,19))
      (showGhc ss1) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:17-18"

      [tok1] <- basicTokenise "\n\n\n\n\n\n\n                square"
      (show tok1) `shouldBe` "((((7,17),(7,23)),ITvarid \"square\"),\"square\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

      -- -- -- --

      let ss2 = posToSrcSpan layout ((7,24),(7,26))
      (showGhc ss2) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:24-25"

      [tok2] <- basicTokenise "\n\n\n\n\n\n\n                       square"
      (show tok2) `shouldBe` "((((7,24),(7,30)),ITvarid \"square\"),\"square\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

      -- -- -- --

      let ss3 = posToSrcSpan layout ((7,35),(7,37))
      (showGhc ss3) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:35-36"

      [tok3] <- basicTokenise "\n\n\n\n\n\n\n                                  square"
      (show tok3) `shouldBe` "((((7,35),(7,41)),ITvarid \"square\"),\"square\")"

      let layout4 = replaceTokenForSrcSpan layout3 ss3 tok3

      -- -- -- --

      let layout5 = replaceTokenForSrcSpan layout4 ss3 tok3

      -- -- -- --

      (drawTreeCompact layout5) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
          "2:((7,1),(7,11))\n"++
          "2:((7,12),(9,40))\n"++
           "3:((7,12),(7,13))\n"++
           "3:((7,14),(7,15))\n"++
           "3:((7,15),(7,16))\n"++
           "3:((7,17),(7,28))\n"++
            "4:((7,17),(7,21))\n"++
             "5:((7,17),(7,19))\n"++
             "5:((7,20),(7,21))\n"++
            "4:((7,22),(7,23))\n"++
            "4:((7,24),(7,28))\n"++
             "5:((7,24),(7,26))\n"++
             "5:((7,27),(7,28))\n"++
           "3:((7,29),(7,34))\n"++
           "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
            "4:((7,35),(7,46))\n"++
             "5:((7,35),(7,37))\n"++
             "5:((7,38),(7,46))\n"++
              "6:((7,38),(7,39))\n"++
              "6:((7,39),(7,40))\n"++
              "6:((7,41),(7,46))\n"++
               "7:((7,41),(7,42))\n"++
               "7:((7,42),(7,43))\n"++
               "7:((7,43),(7,46))\n"++
            "4:((9,35),(9,40))\n"++
             "5:((9,35),(9,38))\n"++
             "5:((9,38),(9,40))\n"++
              "6:((9,38),(9,39))\n"++
              "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"



      let srcTree2 = layoutTreeToSourceTree layout5
      -- (showGhc srcTree2) `shouldBe` ""


      (renderSourceTree srcTree2) `shouldBe` "module LayoutIn1 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'sq' to 'square'.\n\nsumSquares x y= square x + square y where square x= x^pow\n          --There is a comment.\n                                          pow=2\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after adding a local decl Layout.Lift" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Lift.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(1,25))\n"++
         "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
           "3:((3,4),(3,5))\n"++
           "3:((3,6),(3,7))\n"++
           "3:((3,8),(3,14))\n"++
            "4:((3,8),(3,9))\n"++
            "4:((3,10),(3,11))\n"++
            "4:((3,12),(3,14))\n"++
           "3:((4,3),(4,8))\n"++
           "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
            "4:((5,5),(5,11))\n"++
             "5:((5,5),(5,7))\n"++
             "5:((5,8),(5,11))\n"++
              "6:((5,8),(5,9))\n"++
              "6:((5,10),(5,11))\n"++ -- "zz = 1"
         "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
           "3:((7,3),(7,4))\n"++
           "3:((7,5),(7,6))\n"++
         "1:((8,1),(8,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- NOTE: sspan is different, using simpler file
      -- putToksAfterPos ((6,5),(6,10)) at PlaceIndent 1 0 2:[((((0,1),(0,3)),ITvarid "nn"),"nn"),((((0,4),(0,5)),ITequal),"="),((((0,6),(0,9)),ITvarid "nn2"),"nn2")]

      let ss1 = posToSrcSpan layout ((5,5),(5,11))
      (showGhc ss1) `shouldBe` "test/testdata/Layout/Lift.hs:5:5-10"

      toks1 <- basicTokenise "nn = nn2"
      (show toks1) `shouldBe` "[((((0,1),(0,3)),ITvarid \"nn\"),\"nn\"),((((0,4),(0,5)),ITequal),\"=\"),((((0,6),(0,9)),ITvarid \"nn2\"),\"nn2\")]"

      let (layout2,_ss2) = addToksAfterSrcSpan layout ss1 (PlaceIndent 1 0 2) toks1

      -- -- -- --

      (drawTreeCompact layout2) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(1,25))\n"++
         "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
           "3:((3,4),(3,5))\n"++
           "3:((3,6),(3,7))\n"++
           "3:((3,8),(3,14))\n"++
            "4:((3,8),(3,9))\n"++
            "4:((3,10),(3,11))\n"++
            "4:((3,12),(3,14))\n"++
           "3:((4,3),(4,8))\n"++
           "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
            "4:((5,5),(5,11))\n"++
             "5:((5,5),(5,7))\n"++
             "5:((5,8),(5,11))\n"++
              "6:((5,8),(5,9))\n"++
              "6:((5,10),(5,11))\n"++          -- "zz = 1"
            "4:((1000006,5),(1000006,13))\n"++ -- "nn = nn2"
         "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
           "3:((7,3),(7,4))\n"++
           "3:((7,5),(7,6))\n"++
         "1:((8,1),(8,1))\n"

      -- (show layout2) `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Lift where\n\nff y = y + zz\n  where\n    zz = 1\n    nn = nn2\n\nx = 1\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after demoting Demote.D2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Demote/D2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((5,1),(6,18))\n"++
         "2:((5,1),(5,11))\n"++
         "2:((5,12),(5,41))\n"++
         "3:((5,12),(5,18))\n"++
         "3:((5,19),(5,20))\n"++
         "3:((5,21),(5,41))\n"++
         "4:((5,21),(5,25))\n"++
         "5:((5,21),(5,23))\n"++
         "5:((5,24),(5,25))\n"++
         "4:((5,26),(5,27))\n"++
         "4:((5,28),(5,41))\n"++
         "5:((5,28),(5,38))\n"++
         "5:((5,39),(5,41))\n"++
         "2:((6,1),(6,18))\n"++
         "3:((6,1),(6,11))\n"++
         "3:((6,12),(6,14))\n"++
         "3:((6,15),(6,16))\n"++
         "3:((6,17),(6,18))\n"++
         "1:((8,1),(8,14))\n"++
         "2:((8,1),(8,3))\n"++
         "2:((8,4),(8,14))\n"++
         "3:((8,4),(8,5))\n"++
         "3:((8,6),(8,7))\n"++
         "3:((8,8),(8,14))\n"++
         "4:((8,8),(8,9))\n"++
         "4:((8,10),(8,11))\n"++
         "4:((8,11),(8,14))\n"++
         "1:((10,1),(10,8))\n"++
         "2:((10,1),(10,4))\n"++
         "2:((10,5),(10,8))\n"++
         "3:((10,5),(10,6))\n"++
         "3:((10,7),(10,8))\n"++
         "1:((12,1),(12,25))\n"++
          "2:((12,1),(12,5))\n"++
          "2:((12,6),(12,24))\n"++
           "3:((12,6),(12,7))\n"++
           "3:((12,8),(12,24))\n"++
            "4:((12,8),(12,18))\n"++
            "4:((12,19),(12,24))\n"++
             "5:((12,19),(12,20))\n"++
             "5:((12,20),(12,21))\n"++
             "5:((12,23),(12,24))\n"++
         "1:((14,1),(14,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-

removeToksForPos ((5,1),(6,18))

getToksForSpan test/testdata/Demote/D2.hs:(33554437,1)-(33554438,17):("(((False,1,0,5),1),((False,1,0,6),18))",[((((3,1),(3,62)),ITlineComment "--demote  'sumSquares' should fail as it used by module 'A2'."),"--demote  'sumSquares' should fail as it used by module 'A2'."),((((5,1),(5,1)),ITvocurly),""),((((5,1),(5,11)),ITvarid "sumSquares"),"sumSquares"),((((5,12),(5,13)),IToparen),"("),((((5,13),(5,14)),ITvarid "x"),"x"),((((5,14),(5,15)),ITcolon),":"),((((5,15),(5,17)),ITvarid "xs"),"xs"),((((5,17),(5,18)),ITcparen),")"),((((5,19),(5,20)),ITequal),"="),((((5,21),(5,23)),ITvarid "sq"),"sq"),((((5,24),(5,25)),ITvarid "x"),"x"),((((5,26),(5,27)),ITvarsym "+"),"+"),((((5,28),(5,38)),ITvarid "sumSquares"),"sumSquares"),((((5,39),(5,41)),ITvarid "xs"),"xs"),((((6,1),(6,1)),ITsemi),""),((((6,1),(6,11)),ITvarid "sumSquares"),"sumSquares"),((((6,12),(6,13)),ITobrack),"["),((((6,13),(6,14)),ITcbrack),"]"),((((6,15),(6,16)),ITequal),"="),((((6,17),(6,18)),ITinteger 0),"0")])

putToksAfterPos ((12,8),(12,25)) at PlaceOffset 1 4 2:[((((0,1),(0,6)),ITwhere),"where"),((((1,5),(1,66)),ITlineComment "--demote  'sumSquares' should fail as it used by module 'A2'."),"--demote  'sumSquares' should fail as it used by module 'A2'."),((((3,5),(3,5)),ITvocurly),""),((((3,5),(3,15)),ITvarid "sumSquares"),"sumSquares"),((((3,16),(3,17)),IToparen),"("),((((3,17),(3,18)),ITvarid "x"),"x"),((((3,18),(3,19)),ITcolon),":"),((((3,19),(3,21)),ITvarid "xs"),"xs"),((((3,21),(3,22)),ITcparen),")"),((((3,23),(3,24)),ITequal),"="),((((3,25),(3,27)),ITvarid "sq"),"sq"),((((3,28),(3,29)),ITvarid "x"),"x"),((((3,30),(3,31)),ITvarsym "+"),"+"),((((3,32),(3,42)),ITvarid "sumSquares"),"sumSquares"),((((3,43),(3,45)),ITvarid "xs"),"xs"),((((4,5),(4,5)),ITsemi),""),((((4,5),(4,15)),ITvarid "sumSquares"),"sumSquares"),((((4,16),(4,17)),ITobrack),"["),((((4,17),(4,18)),ITcbrack),"]"),((((4,19),(4,20)),ITequal),"="),((((4,21),(4,22)),ITinteger 0),"0"),((((5,1),(5,1)),ITvccurly),"")]


-}


      let ss1 = posToSrcSpan layout ((5,1),(6,18))
      (showGhc ss1) `shouldBe` "test/testdata/Demote/D2.hs:(5,1)-(6,17)"

      let (layout2,_old)  = removeSrcSpan layout (srcSpanToForestSpan ss1)


      -- let (_tree,toks1) = getTokensForNoIntros True layout ss1
      toks1 <- basicTokenise $
                 "where\n"++
                 "    --demote  'sumSquares' should fail as it used by module 'A2'.\n"++
                 "\n"++
                 "    sumSquares (x:xs) = sq x + sumSquares xs\n"++
                 "    sumSquares [] = 0\n"++
                 ""

      (show toks1) `shouldBe` "[((((0,1),(0,6)),ITwhere),\"where\"),((((1,5),(1,66)),ITlineComment \"--demote  'sumSquares' should fail as it used by module 'A2'.\"),\"--demote  'sumSquares' should fail as it used by module 'A2'.\"),((((3,5),(3,5)),ITvocurly),\"\"),((((3,5),(3,15)),ITvarid \"sumSquares\"),\"sumSquares\"),((((3,16),(3,17)),IToparen),\"(\"),((((3,17),(3,18)),ITvarid \"x\"),\"x\"),((((3,18),(3,19)),ITcolon),\":\"),((((3,19),(3,21)),ITvarid \"xs\"),\"xs\"),((((3,21),(3,22)),ITcparen),\")\"),((((3,23),(3,24)),ITequal),\"=\"),((((3,25),(3,27)),ITvarid \"sq\"),\"sq\"),((((3,28),(3,29)),ITvarid \"x\"),\"x\"),((((3,30),(3,31)),ITvarsym \"+\"),\"+\"),((((3,32),(3,42)),ITvarid \"sumSquares\"),\"sumSquares\"),((((3,43),(3,45)),ITvarid \"xs\"),\"xs\"),((((4,5),(4,5)),ITsemi),\"\"),((((4,5),(4,15)),ITvarid \"sumSquares\"),\"sumSquares\"),((((4,16),(4,17)),ITobrack),\"[\"),((((4,17),(4,18)),ITcbrack),\"]\"),((((4,19),(4,20)),ITequal),\"=\"),((((4,21),(4,22)),ITinteger 0),\"0\"),((((5,1),(5,1)),ITvccurly),\"\")]"

      let ss2 = posToSrcSpan layout ((12,8),(12,25))
      (showGhc ss2) `shouldBe` "test/testdata/Demote/D2.hs:12:8-24"

      let (layout3,_ss2) = addToksAfterSrcSpan layout2 ss2 (PlaceOffset 1 4 2) toks1

      -- -- -- --

      (drawTreeCompact layout3) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((5,1),(6,18))(2,-17)D\n"++
         "1:((8,1),(8,14))\n"++
          "2:((8,1),(8,3))\n"++
          "2:((8,4),(8,14))\n"++
           "3:((8,4),(8,5))\n"++
           "3:((8,6),(8,7))\n"++
           "3:((8,8),(8,14))\n"++
            "4:((8,8),(8,9))\n"++
            "4:((8,10),(8,11))\n"++
            "4:((8,11),(8,14))\n"++
         "1:((10,1),(10,8))\n"++
          "2:((10,1),(10,4))\n"++
          "2:((10,5),(10,8))\n"++
           "3:((10,5),(10,6))\n"++
           "3:((10,7),(10,8))\n"++
         "1:((12,1),(12,25))\n"++
          "2:((12,1),(12,5))\n"++
          "2:((12,6),(12,7))\n"++
          "2:((12,8),(12,25))\n"++
           "3:((12,8),(12,18))\n"++
           "3:((12,19),(12,20))\n"++
           "3:((12,20),(12,21))\n"++
           "3:((12,23),(12,24))\n"++
          "2:((1000013,5),(1000017,26))\n"++
         "1:((14,1),(14,1))\n"


      -- (show layout2) `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout3
      -- (showGhc srcTree2) `shouldBe` ""

      -- let ll = retrieveLinesFromLayoutTree layout3
      (renderSourceTree srcTree2) `shouldBe` "module Demote.D2 where\n\n\n\nsq x = x ^pow\n\npow = 2\n\nmain = sumSquares [1..4]\n    where\n        --demote  'sumSquares' should fail as it used by module 'A2'.\n\n        sumSquares (x:xs) = sq x + sumSquares xs\n        sumSquares [] = 0\n    \n\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after add params AddParams1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/AddParams1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((3,1),(4,12))\n"++
          "2:((3,1),(3,3))\n"++   -- "sq"
          "2:((3,5),(3,10))\n"++
           "3:((3,5),(3,6))\n"++  -- "0"
           "3:((3,7),(3,8))\n"++  -- "="
           "3:((3,9),(3,10))\n"++ -- "0"
          "2:((4,1),(4,12))\n"++
           "3:((4,1),(4,3))\n"++
           "3:((4,5),(4,6))\n"++
           "3:((4,7),(4,8))\n"++
           "3:((4,9),(4,12))\n"++
            "4:((4,9),(4,10))\n"++
            "4:((4,10),(4,11))\n"++
            "4:((4,11),(4,12))\n"++
         "1:((6,1),(6,8))\n"++
          "2:((6,1),(6,4))\n"++
          "2:((6,5),(6,8))\n"++
           "3:((6,5),(6,6))\n"++
           "3:((6,7),(6,8))\n"++
         "1:((8,1),(8,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-

getToksForSpan test/testdata/AddParams1.hs:3:5:("(((False,0,0,3),5),((False,0,0,3),6))",[((((3,5),(3,6)),ITinteger 0),"0")])
putToksForSpan test/testdata/AddParams1.hs:3:5:(((False,0,0,3),5),((False,0,0,3),6))[((((3,6),(3,9)),ITvarid "pow"),"pow")]
putToksAfterSpan test/testdata/AddParams1.hs:3:5:(((False,0,0,3),5),((False,0,0,3),6)) at PlaceAdjacent:[(((3,5),(3,6)),ITinteger 0,"0")]
-}

      let ss1 = posToSrcSpan layout ((3,5),(3,6))
      (showGhc ss1) `shouldBe` "test/testdata/AddParams1.hs:3:5"

      toks1 <- basicTokenise "\n\n\n    0"
      (show toks1) `shouldBe` "[((((3,5),(3,6)),ITinteger 0),\"0\")]"

      toks2 <- basicTokenise "\n\n\n     pow"
      (show toks2) `shouldBe` "[((((3,6),(3,9)),ITvarid \"pow\"),\"pow\")]"

      let (layout2,_newSpan,_oldTree) = updateTokensForSrcSpan layout ss1 toks2

      let (layout3,_newSpan2) = addToksAfterSrcSpan layout2 ss1 PlaceAdjacent toks1

----------
{-
getToksForSpan test/testdata/AddParams1.hs:4:5:("(((False,0,0,4),5),((False,0,0,4),6))",[((((4,5),(4,6)),ITvarid "z"),"z")])
putToksForSpan test/testdata/AddParams1.hs:4:5:(((False,0,0,4),5),((False,0,0,4),6))[((((4,6),(4,9)),ITvarid "pow"),"pow")]
putToksAfterSpan test/testdata/AddParams1.hs:4:5:(((False,0,0,4),5),((False,0,0,4),6)) at PlaceAdjacent:[(((4,5),(4,6)),ITvarid "z","z")]


-}

      let ss2 = posToSrcSpan layout ((4,5),(4,6))
      (showGhc ss2) `shouldBe` "test/testdata/AddParams1.hs:4:5"

      toks3 <- basicTokenise "\n\n\n\n    z"
      (show toks3) `shouldBe` "[((((4,5),(4,6)),ITvarid \"z\"),\"z\")]"

      toks4 <- basicTokenise "\n\n\n\n     pow"
      (show toks4) `shouldBe` "[((((4,6),(4,9)),ITvarid \"pow\"),\"pow\")]"

      let (layout4,_newSpan3,_oldTree2) = updateTokensForSrcSpan layout3 ss2 toks4

      let (layout5,_newSpan4) = addToksAfterSrcSpan layout4 ss2 PlaceAdjacent toks3


      -- -- -- --

      (drawTreeCompact layout5) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((3,1),(4,12))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,5),(3,10))\n"++
           "3:((10000000003,5),(10000000003,8))\n"++
            "4:((3,5),(3,6))\n"++
            "4:((1000003,9),(1000003,10))\n"++
           "3:((3,7),(3,8))\n"++
           "3:((3,9),(3,10))\n"++
          "2:((4,1),(4,12))\n"++
           "3:((4,1),(4,3))\n"++
           "3:((10000000004,5),(10000000004,8))\n"++
            "4:((4,5),(4,6))\n"++                -- "pow"
            "4:((1000004,9),(1000004,10))\n"++   -- "z"
           "3:((4,7),(4,8))\n"++
           "3:((4,9),(4,12))\n"++
            "4:((4,9),(4,10))\n"++
            "4:((4,10),(4,11))\n"++
            "4:((4,11),(4,12))\n"++
         "1:((6,1),(6,8))\n"++
          "2:((6,1),(6,4))\n"++
          "2:((6,5),(6,8))\n"++
           "3:((6,5),(6,6))\n"++
           "3:((6,7),(6,8))\n"++
         "1:((8,1),(8,1))\n"


      -- (show layout2) `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout5
      -- (showGhc srcTree2) `shouldBe` ""

      -- (showGhc $ retrieveLinesFromLayoutTree layout5) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module AddParams1 where\n\nsq  pow 0= 0\nsq  pow z= z^2\n\nfoo = 3\n\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming Renaming.D5" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/D5.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(25,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(4,64))\n"++
         "1:((6,1),(6,48))\n"++
         "2:((6,1),(6,5))\n"++
         "2:((6,6),(6,10))\n"++
         "2:((6,11),(6,12))\n"++
         "2:((6,13),(6,48))\n"++
         "3:((6,13),(6,14))\n"++
         "3:((6,15),(6,21))\n"++
         "4:((6,15),(6,19))\n"++
         "4:((6,20),(6,21))\n"++
         "3:((6,22),(6,23))\n"++
         "3:((6,24),(6,48))\n"++
         "4:((6,24),(6,30))\n"++
         "4:((6,31),(6,39))\n"++
         "4:((6,40),(6,48))\n"++
         "1:((8,1),(8,24))\n"++
         "2:((8,1),(8,7))\n"++
         "2:((8,8),(8,10))\n"++
         "2:((8,11),(8,15))\n"++
         "2:((8,16),(8,17))\n"++
         "2:((8,18),(8,20))\n"++
         "2:((8,21),(8,22))\n"++
         "2:((8,22),(8,23))\n"++
         "2:((8,23),(8,24))\n"++
         "1:((9,1),(10,57))\n"++
         "2:((9,1),(9,7))\n"++
         "2:((9,8),(9,23))\n"++
         "3:((9,8),(9,17))\n"++
         "3:((9,18),(9,19))\n"++
         "3:((9,20),(9,23))\n"++
         "4:((9,20),(9,21))\n"++
         "4:((9,21),(9,22))\n"++
         "4:((9,22),(9,23))\n"++
         "2:((10,1),(10,57))\n"++
         "3:((10,1),(10,7))\n"++
         "3:((10,8),(10,27))\n"++
         "3:((10,28),(10,29))\n"++
         "3:((10,30),(10,57))\n"++
         "4:((10,30),(10,41))\n"++
         "5:((10,30),(10,36))\n"++
         "5:((10,37),(10,41))\n"++
         "4:((10,42),(10,44))\n"++
         "4:((10,45),(10,57))\n"++
         "5:((10,45),(10,51))\n"++
         "5:((10,52),(10,57))\n"++
         "1:((12,1),(14,31))\n"++
         "2:((12,1),(12,6))\n"++
         "2:((12,7),(12,16))\n"++
         "2:((12,17),(12,18))\n"++
         "2:((12,19),(12,24))\n"++
         "2:((13,4),(13,29))\n"++
         "3:((13,4),(13,10))\n"++
         "3:((13,12),(13,14))\n"++
         "3:((13,15),(13,16))\n"++
         "3:((13,17),(13,19))\n"++
         "3:((13,20),(13,21))\n"++
         "3:((13,22),(13,24))\n"++
         "3:((13,25),(13,29))\n"++
         "2:((14,4),(14,31))\n"++
         "3:((14,4),(14,13))\n"++
         "3:((14,14),(14,16))\n"++
         "3:((14,17),(14,18))\n"++
         "3:((14,19),(14,21))\n"++
         "3:((14,22),(14,23))\n"++
         "3:((14,24),(14,26))\n"++
         "3:((14,27),(14,31))\n"++
         "1:((16,1),(18,26))\n"++
         "2:((16,1),(16,9))\n"++
         "2:((16,10),(16,19))\n"++
         "2:((16,20),(16,23))\n"++
         "2:((16,24),(16,29))\n"++
         "2:((17,4),(17,24))\n"++
         "3:((17,4),(17,10))\n"++
         "3:((17,11),(17,24))\n"++
         "4:((17,11),(17,12))\n"++
         "4:((17,14),(17,15))\n"++
         "4:((17,16),(17,17))\n"++
         "4:((17,18),(17,24))\n"++
         "5:((17,18),(17,19))\n"++
         "5:((17,20),(17,22))\n"++
         "5:((17,23),(17,24))\n"++
         "2:((18,4),(18,26))\n"++
         "3:((18,4),(18,13))\n"++
         "3:((18,14),(18,26))\n"++
         "4:((18,14),(18,15))\n"++
         "4:((18,16),(18,17))\n"++
         "4:((18,18),(18,19))\n"++
         "4:((18,20),(18,26))\n"++
         "5:((18,20),(18,21))\n"++
         "5:((18,22),(18,24))\n"++
         "5:((18,25),(18,26))\n"++
         "1:((20,1),(24,18))\n"++
         "2:((20,1),(20,11))\n"++
         "2:((20,12),(22,18))\n"++
         "3:((20,12),(20,18))\n"++
         "3:((20,19),(20,20))\n"++
         "3:((20,21),(20,41))\n"++
         "4:((20,21),(20,25))\n"++
         "5:((20,21),(20,23))\n"++
         "5:((20,24),(20,25))\n"++
         "4:((20,26),(20,27))\n"++
         "4:((20,28),(20,41))\n"++
         "5:((20,28),(20,38))\n"++
         "5:((20,39),(20,41))\n"++
         "3:((21,5),(21,10))\n"++
         "3:((21,11),(22,18))(Above None (21,11) (22,18) FromAlignCol (2,-17))\n"++
         "4:((21,11),(21,24))\n"++
         "5:((21,11),(21,13))\n"++
         "5:((21,14),(21,24))\n"++
         "6:((21,14),(21,15))\n"++
         "6:((21,16),(21,17))\n"++
         "6:((21,18),(21,24))\n"++
         "7:((21,18),(21,19))\n"++
         "7:((21,20),(21,21))\n"++
         "7:((21,21),(21,24))\n"++
         "4:((22,11),(22,18))\n"++
         "5:((22,11),(22,14))\n"++
         "5:((22,15),(22,18))\n"++
         "6:((22,15),(22,16))\n"++
         "6:((22,17),(22,18))\n"++
         "2:((24,1),(24,18))\n"++
         "3:((24,1),(24,11))\n"++
         "3:((24,12),(24,14))\n"++
         "3:((24,15),(24,16))\n"++
         "3:((24,17),(24,18))\n"++
         "1:((25,1),(25,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

-- replaceToken test/testdata/Renaming/D5.hs:20:1-10: (((False,0,0,20), 1),((False,0,0,20),11))  ((((20, 1),(20,16)),ITvarid "Renaming.D5.sum"),"Renaming.D5.sum")

      let ss1 = posToSrcSpan layout ((20,1),(20,11))
      (showGhc ss1) `shouldBe` "test/testdata/Renaming/D5.hs:20:1-10"

      [tok1] <- basicTokenise "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nRenaming.D5.sum"
      (show tok1) `shouldBe` "((((20,1),(20,16)),ITqvarid (\"Renaming.D5\",\"sum\")),\"Renaming.D5.sum\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

-- replaceToken test/testdata/Renaming/D5.hs:20:28-37:(((False,0,0,20),28),((False,0,0,20),38))  ((((20,28),(20,43)),ITvarid "Renaming.D5.sum"),"Renaming.D5.sum")

      let ss2 = posToSrcSpan layout ((20,28),(20,38))
      (showGhc ss2) `shouldBe` "test/testdata/Renaming/D5.hs:20:28-37"

      [tok2] <- basicTokenise "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                           Renaming.D5.sum"
      (show tok2) `shouldBe` "((((20,28),(20,43)),ITqvarid (\"Renaming.D5\",\"sum\")),\"Renaming.D5.sum\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

-- replaceToken test/testdata/Renaming/D5.hs:20:1-10: (((False,0,0,20), 1),((False,0,0,20),11))  ((((20, 1),(20, 4)),ITvarid "sum"),"sum")

      let ss3 = posToSrcSpan layout ((20,1),(20,11))
      (showGhc ss3) `shouldBe` "test/testdata/Renaming/D5.hs:20:1-10"

      [tok3] <- basicTokenise "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nsum"
      (show tok3) `shouldBe` "((((20,1),(20,4)),ITvarid \"sum\"),\"sum\")"

      let layout4 = replaceTokenForSrcSpan layout3 ss3 tok3

-- replaceToken test/testdata/Renaming/D5.hs:24:1-10: (((False,0,0,24), 1),((False,0,0,24),11))  ((((24, 1),(24, 4)),ITvarid "sum"),"sum")

      let ss4 = posToSrcSpan layout ((24,1),(24,11))
      (showGhc ss4) `shouldBe` "test/testdata/Renaming/D5.hs:24:1-10"

      [tok4] <- basicTokenise "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nsum"
      (show tok4) `shouldBe` "((((24,1),(24,4)),ITvarid \"sum\"),\"sum\")"


      let layout5 = replaceTokenForSrcSpan layout4 ss4 tok4

      -- -- -- --

      (drawTreeCompact layout5) `shouldBe`
         "0:((1,1),(25,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(4,64))\n"++
         "1:((6,1),(6,48))\n"++
         "2:((6,1),(6,5))\n"++
         "2:((6,6),(6,10))\n"++
         "2:((6,11),(6,12))\n"++
         "2:((6,13),(6,48))\n"++
         "3:((6,13),(6,14))\n"++
         "3:((6,15),(6,21))\n"++
         "4:((6,15),(6,19))\n"++
         "4:((6,20),(6,21))\n"++
         "3:((6,22),(6,23))\n"++
         "3:((6,24),(6,48))\n"++
         "4:((6,24),(6,30))\n"++
         "4:((6,31),(6,39))\n"++
         "4:((6,40),(6,48))\n"++
         "1:((8,1),(8,24))\n"++
         "2:((8,1),(8,7))\n"++
         "2:((8,8),(8,10))\n"++
         "2:((8,11),(8,15))\n"++
         "2:((8,16),(8,17))\n"++
         "2:((8,18),(8,20))\n"++
         "2:((8,21),(8,22))\n"++
         "2:((8,22),(8,23))\n"++
         "2:((8,23),(8,24))\n"++
         "1:((9,1),(10,57))\n"++
         "2:((9,1),(9,7))\n"++
         "2:((9,8),(9,23))\n"++
         "3:((9,8),(9,17))\n"++
         "3:((9,18),(9,19))\n"++
         "3:((9,20),(9,23))\n"++
         "4:((9,20),(9,21))\n"++
         "4:((9,21),(9,22))\n"++
         "4:((9,22),(9,23))\n"++
         "2:((10,1),(10,57))\n"++
         "3:((10,1),(10,7))\n"++
         "3:((10,8),(10,27))\n"++
         "3:((10,28),(10,29))\n"++
         "3:((10,30),(10,57))\n"++
         "4:((10,30),(10,41))\n"++
         "5:((10,30),(10,36))\n"++
         "5:((10,37),(10,41))\n"++
         "4:((10,42),(10,44))\n"++
         "4:((10,45),(10,57))\n"++
         "5:((10,45),(10,51))\n"++
         "5:((10,52),(10,57))\n"++
         "1:((12,1),(14,31))\n"++
         "2:((12,1),(12,6))\n"++
         "2:((12,7),(12,16))\n"++
         "2:((12,17),(12,18))\n"++
         "2:((12,19),(12,24))\n"++
         "2:((13,4),(13,29))\n"++
         "3:((13,4),(13,10))\n"++
         "3:((13,12),(13,14))\n"++
         "3:((13,15),(13,16))\n"++
         "3:((13,17),(13,19))\n"++
         "3:((13,20),(13,21))\n"++
         "3:((13,22),(13,24))\n"++
         "3:((13,25),(13,29))\n"++
         "2:((14,4),(14,31))\n"++
         "3:((14,4),(14,13))\n"++
         "3:((14,14),(14,16))\n"++
         "3:((14,17),(14,18))\n"++
         "3:((14,19),(14,21))\n"++
         "3:((14,22),(14,23))\n"++
         "3:((14,24),(14,26))\n"++
         "3:((14,27),(14,31))\n"++
         "1:((16,1),(18,26))\n"++
         "2:((16,1),(16,9))\n"++
         "2:((16,10),(16,19))\n"++
         "2:((16,20),(16,23))\n"++
         "2:((16,24),(16,29))\n"++
         "2:((17,4),(17,24))\n"++
         "3:((17,4),(17,10))\n"++
         "3:((17,11),(17,24))\n"++
         "4:((17,11),(17,12))\n"++
         "4:((17,14),(17,15))\n"++
         "4:((17,16),(17,17))\n"++
         "4:((17,18),(17,24))\n"++
         "5:((17,18),(17,19))\n"++
         "5:((17,20),(17,22))\n"++
         "5:((17,23),(17,24))\n"++
         "2:((18,4),(18,26))\n"++
         "3:((18,4),(18,13))\n"++
         "3:((18,14),(18,26))\n"++
         "4:((18,14),(18,15))\n"++
         "4:((18,16),(18,17))\n"++
         "4:((18,18),(18,19))\n"++
         "4:((18,20),(18,26))\n"++
         "5:((18,20),(18,21))\n"++
         "5:((18,22),(18,24))\n"++
         "5:((18,25),(18,26))\n"++
         "1:((20,1),(24,18))\n"++
          "2:((20,1),(20,11))\n"++
          "2:((20,12),(22,18))\n"++
           "3:((20,12),(20,18))\n"++
           "3:((20,19),(20,20))\n"++
           "3:((20,21),(20,41))\n"++
            "4:((20,21),(20,25))\n"++
             "5:((20,21),(20,23))\n"++
             "5:((20,24),(20,25))\n"++
            "4:((20,26),(20,27))\n"++
            "4:((20,28),(20,41))\n"++
              "5:((20,28),(20,38))\n"++
              "5:((20,39),(20,41))\n"++
           "3:((21,5),(21,10))\n"++   -- "where"
           "3:((21,11),(22,18))(Above None (21,11) (22,18) FromAlignCol (2,-17))\n"++
            "4:((21,11),(21,24))\n"++
             "5:((21,11),(21,13))\n"++
             "5:((21,14),(21,24))\n"++
              "6:((21,14),(21,15))\n"++
              "6:((21,16),(21,17))\n"++
              "6:((21,18),(21,24))\n"++
               "7:((21,18),(21,19))\n"++
               "7:((21,20),(21,21))\n"++
               "7:((21,21),(21,24))\n"++
            "4:((22,11),(22,18))\n"++
             "5:((22,11),(22,14))\n"++
             "5:((22,15),(22,18))\n"++
              "6:((22,15),(22,16))\n"++
              "6:((22,17),(22,18))\n"++
          "2:((24,1),(24,18))\n"++
           "3:((24,1),(24,11))\n"++
           "3:((24,12),(24,14))\n"++
           "3:((24,15),(24,16))\n"++
           "3:((24,17),(24,18))\n"++
         "1:((25,1),(25,1))\n"


      let srcTree2 = layoutTreeToSourceTree layout5
      -- (showGhc srcTree2) `shouldBe` ""

      -- (showGhc $ retrieveLinesFromLayoutTree layout3) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Renaming.D5 where\n\n{-Rename top level identifier 'sumSquares' to 'sum'.\n  This refactoring affects module `D5', 'B5' , 'C5' and 'A5' -}\n\ndata Tree a = Leaf a | Branch (Tree a) (Tree a)\n\nfringe :: Tree a -> [a]\nfringe (Leaf x ) = [x]\nfringe (Branch left right) = fringe left ++ fringe right\n\nclass SameOrNot a where\n   isSame  :: a -> a -> Bool\n   isNotSame :: a -> a -> Bool\n\ninstance SameOrNot Int where\n   isSame a  b = a == b\n   isNotSame a b = a /= b\n\nsum (x:xs) = sq x + Renaming.D5.sum xs\n    where sq x = x ^pow\n          pow = 2\n\nsum [] = 0\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming Layout.D5Simple" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/D5Simple.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,23))\n"++
         "1:((1,24),(1,29))\n"++
         "1:((3,1),(7,18))\n"++
         "2:((3,1),(3,11))\n"++
         "2:((3,12),(5,18))\n"++
         "3:((3,12),(3,18))\n"++
         "3:((3,19),(3,20))\n"++
         "3:((3,21),(3,41))\n"++
         "4:((3,21),(3,25))\n"++
         "5:((3,21),(3,23))\n"++
         "5:((3,24),(3,25))\n"++
         "4:((3,26),(3,27))\n"++
         "4:((3,28),(3,41))\n"++
         "5:((3,28),(3,38))\n"++
         "5:((3,39),(3,41))\n"++
         "3:((4,5),(4,10))\n"++
         "3:((4,11),(5,18))(Above None (4,11) (5,18) FromAlignCol (2,-17))\n"++
         "4:((4,11),(4,24))\n"++
         "5:((4,11),(4,13))\n"++
         "5:((4,14),(4,24))\n"++
         "6:((4,14),(4,15))\n"++
         "6:((4,16),(4,17))\n"++
         "6:((4,18),(4,24))\n"++
         "7:((4,18),(4,19))\n"++
         "7:((4,20),(4,21))\n"++
         "7:((4,21),(4,24))\n"++
         "4:((5,11),(5,18))\n"++
         "5:((5,11),(5,14))\n"++
         "5:((5,15),(5,18))\n"++
         "6:((5,15),(5,16))\n"++
         "6:((5,17),(5,18))\n"++
         "2:((7,1),(7,18))\n"++
         "3:((7,1),(7,11))\n"++
         "3:((7,12),(7,14))\n"++
         "3:((7,15),(7,16))\n"++
         "3:((7,17),(7,18))\n"++
         "1:((8,1),(8,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

-- replaceToken test/testdata/Renaming/D5.hs:20:1-10: (((False,0,0,20), 1),((False,0,0,20),11))  ((((20, 1),(20,16)),ITvarid "Renaming.D5.sum"),"Renaming.D5.sum")

      let ss1 = posToSrcSpan layout ((3,1),(3,11))
      (showGhc ss1) `shouldBe` "test/testdata/Layout/D5Simple.hs:3:1-10"

      [tok1] <- basicTokenise "\n\n\nRenaming.D5.sum"
      (show tok1) `shouldBe` "((((3,1),(3,16)),ITqvarid (\"Renaming.D5\",\"sum\")),\"Renaming.D5.sum\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

-- replaceToken test/testdata/Renaming/D5.hs:20:28-37:(((False,0,0,20),28),((False,0,0,20),38))  ((((20,28),(20,43)),ITvarid "Renaming.D5.sum"),"Renaming.D5.sum")

      let ss2 = posToSrcSpan layout ((3,28),(3,38))
      (showGhc ss2) `shouldBe` "test/testdata/Layout/D5Simple.hs:3:28-37"

      [tok2] <- basicTokenise "\n\n\n                           Renaming.D5.sum"
      (show tok2) `shouldBe` "((((3,28),(3,43)),ITqvarid (\"Renaming.D5\",\"sum\")),\"Renaming.D5.sum\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

-- replaceToken test/testdata/Renaming/D5.hs:20:1-10: (((False,0,0,20), 1),((False,0,0,20),11))  ((((20, 1),(20, 4)),ITvarid "sum"),"sum")

      let ss3 = posToSrcSpan layout ((3,1),(3,11))
      (showGhc ss3) `shouldBe` "test/testdata/Layout/D5Simple.hs:3:1-10"

      [tok3] <- basicTokenise "\n\n\nsum"
      (show tok3) `shouldBe` "((((3,1),(3,4)),ITvarid \"sum\"),\"sum\")"

      let layout4 = replaceTokenForSrcSpan layout3 ss3 tok3

-- replaceToken test/testdata/Renaming/D5.hs:24:1-10: (((False,0,0,24), 1),((False,0,0,24),11))  ((((24, 1),(24, 4)),ITvarid "sum"),"sum")

      let ss4 = posToSrcSpan layout ((7,1),(7,11))
      (showGhc ss4) `shouldBe` "test/testdata/Layout/D5Simple.hs:7:1-10"

      [tok4] <- basicTokenise "\n\n\n\n\n\n\nsum"
      (show tok4) `shouldBe` "((((7,1),(7,4)),ITvarid \"sum\"),\"sum\")"


      let layout5 = replaceTokenForSrcSpan layout4 ss4 tok4

      -- -- -- --

      (drawTreeCompact layout5) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,23))\n"++
         "1:((1,24),(1,29))\n"++
         "1:((3,1),(7,18))\n"++
          "2:((3,1),(3,11))\n"++   -- sumSquares (x:xs) = sq x + sumSquares xs
          "2:((3,12),(5,18))\n"++
           "3:((3,12),(3,18))\n"++
           "3:((3,19),(3,20))\n"++
           "3:((3,21),(3,41))\n"++
            "4:((3,21),(3,25))\n"++
             "5:((3,21),(3,23))\n"++
             "5:((3,24),(3,25))\n"++
            "4:((3,26),(3,27))\n"++
            "4:((3,28),(3,41))\n"++
             "5:((3,28),(3,38))\n"++
             "5:((3,39),(3,41))\n"++
           "3:((4,5),(4,10))\n"++          -- "where"
           "3:((4,11),(5,18))(Above None (4,11) (5,18) FromAlignCol (2,-17))\n"++
            "4:((4,11),(4,24))\n"++       -- sq x = x ^pow
             "5:((4,11),(4,13))\n"++
             "5:((4,14),(4,24))\n"++
              "6:((4,14),(4,15))\n"++
              "6:((4,16),(4,17))\n"++
              "6:((4,18),(4,24))\n"++
               "7:((4,18),(4,19))\n"++
               "7:((4,20),(4,21))\n"++
               "7:((4,21),(4,24))\n"++
            "4:((5,11),(5,18))\n"++       -- pow = 2
             "5:((5,11),(5,14))\n"++
             "5:((5,15),(5,18))\n"++
              "6:((5,15),(5,16))\n"++
              "6:((5,17),(5,18))\n"++
          "2:((7,1),(7,18))\n"++        -- sumSquares [] = 0
           "3:((7,1),(7,11))\n"++
           "3:((7,12),(7,14))\n"++
           "3:((7,15),(7,16))\n"++
           "3:((7,17),(7,18))\n"++
         "1:((8,1),(8,1))\n"


      let srcTree2 = layoutTreeToSourceTree layout5
      -- (showGhc srcTree2) `shouldBe` ""

      -- (showGhc $ retrieveLinesFromLayoutTree layout3) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.D5Simple where\n\nsum (x:xs) = sq x + Renaming.D5.sum xs\n    where sq x = x ^pow\n          pow = 2\n\nsum [] = 0\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming TypeUtils.LayoutLet2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/TypeUtils/LayoutLet2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((7,1),(8,35))\n"++
         "2:((7,1),(7,4))\n"++
         "2:((7,5),(8,35))\n"++
         "3:((7,5),(7,8))\n"++
         "3:((7,9),(7,10))\n"++
         "3:((7,11),(8,35))\n"++
         "4:((7,11),(7,14))\n"++
         "4:((7,15),(8,20))(Above None (7,15) (8,20) SameLine 1)\n"++
         "5:((7,15),(7,20))\n"++
         "6:((7,15),(7,16))\n"++
         "6:((7,17),(7,20))\n"++
         "7:((7,17),(7,18))\n"++
         "7:((7,19),(7,20))\n"++
         "5:((8,15),(8,20))\n"++
         "6:((8,15),(8,16))\n"++
         "6:((8,17),(8,20))\n"++
         "7:((8,17),(8,18))\n"++
         "7:((8,19),(8,20))\n"++
         "4:((8,24),(8,35))\n"++
         "5:((8,24),(8,31))\n"++
         "6:((8,24),(8,27))\n"++
         "6:((8,28),(8,29))\n"++
         "6:((8,30),(8,31))\n"++
         "5:((8,32),(8,33))\n"++
         "5:((8,34),(8,35))\n"++
         "1:((10,1),(10,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource


-- replaceToken test/testdata/TypeUtils/LayoutLet2.hs:7:5-7:(((False,0,0,7),5),((False,0,0,7),8))((((7,5),(7,12)),ITvarid "xxxlong"),"xxxlong")

      let ss1 = posToSrcSpan layout ((7,5),(7,8))
      (showGhc ss1) `shouldBe` "test/testdata/TypeUtils/LayoutLet2.hs:7:5-7"

      [tok1] <- basicTokenise "\n\n\n\n\n\n\n    xxxlong"
      (show tok1) `shouldBe` "((((7,5),(7,12)),ITvarid \"xxxlong\"),\"xxxlong\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

-- replaceToken test/testdata/TypeUtils/LayoutLet2.hs:8:24-26:(((False,0,0,8),24),((False,0,0,8),27))((((8,24),(8,31)),ITvarid "xxxlong"),"xxxlong")

      let ss2 = posToSrcSpan layout ((8,24),(8,27))
      (showGhc ss2) `shouldBe` "test/testdata/TypeUtils/LayoutLet2.hs:8:24-26"

      [tok2] <- basicTokenise "\n\n\n\n\n\n\n\n                       xxxlong"
      (show tok2) `shouldBe` "((((8,24),(8,31)),ITvarid \"xxxlong\"),\"xxxlong\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

      -- -- -- --

      (drawTreeCompact layout3) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((7,1),(8,35))\n"++
          "2:((7,1),(7,4))\n"++
          "2:((7,5),(8,35))\n"++
           "3:((7,5),(7,8))\n"++
           "3:((7,9),(7,10))\n"++
           "3:((7,11),(8,35))\n"++
            "4:((7,11),(7,14))\n"++ -- "let"
            "4:((7,15),(8,20))(Above None (7,15) (8,20) SameLine 1)\n"++
             "5:((7,15),(7,20))\n"++  -- "a = 1"
              "6:((7,15),(7,16))\n"++
              "6:((7,17),(7,20))\n"++
               "7:((7,17),(7,18))\n"++
               "7:((7,19),(7,20))\n"++
             "5:((8,15),(8,20))\n"++  -- b = 2
              "6:((8,15),(8,16))\n"++
              "6:((8,17),(8,20))\n"++
               "7:((8,17),(8,18))\n"++
               "7:((8,19),(8,20))\n"++
            "4:((8,24),(8,35))\n"++
             "5:((8,24),(8,31))\n"++
              "6:((8,24),(8,27))\n"++  -- "in xxxlong"
              "6:((8,28),(8,29))\n"++
              "6:((8,30),(8,31))\n"++
             "5:((8,32),(8,33))\n"++
             "5:((8,34),(8,35))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout3
      -- (showGhc srcTree2) `shouldBe` ""

      -- (showGhc $ retrieveLinesFromLayoutTree layout3) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module LayoutLet2 where\n\n-- Simple let expression, rename xxx to something longer or shorter\n-- and the let/in layout should adjust accordingly\n-- In this case the tokens for xxx + a + b should also shift out\n\nfoo xxxlong = let a = 1\n                  b = 2 in xxxlong + a + b\n\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming Renaming.LayoutIn3" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/LayoutIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(12,86))\n"++
         "2:((7,1),(7,4))\n"++
         "2:((7,5),(12,86))\n"++
         "3:((7,5),(7,6))\n"++
         "3:((7,7),(7,8))\n"++
         "3:((7,9),(8,51))\n"++
         "4:((7,9),(7,12))\n"++
         "4:((7,13),(7,19))(Above None (7,13) (7,19) SameLine 1)\n"++
         "5:((7,13),(7,19))\n"++
         "6:((7,13),(7,14))\n"++
         "6:((7,15),(7,19))\n"++
         "7:((7,15),(7,16))\n"++
         "7:((7,17),(7,19))\n"++
         "4:((7,20),(8,51))\n"++
         "5:((7,20),(7,24))\n"++
         "5:((7,24),(8,50))\n"++
         "6:((7,24),(7,27))\n"++
         "6:((7,28),(8,33))(Above None (7,28) (8,33) SameLine 1)\n"++
         "7:((7,28),(7,33))\n"++
         "8:((7,28),(7,29))\n"++
         "8:((7,30),(7,33))\n"++
         "9:((7,30),(7,31))\n"++
         "9:((7,32),(7,33))\n"++
         "7:((8,28),(8,33))\n"++
         "8:((8,28),(8,29))\n"++
         "8:((8,30),(8,33))\n"++
         "9:((8,30),(8,31))\n"++
         "9:((8,32),(8,33))\n"++
         "6:((8,37),(8,50))\n"++
         "7:((8,37),(8,46))\n"++
         "8:((8,37),(8,42))\n"++
         "9:((8,37),(8,38))\n"++
         "9:((8,39),(8,40))\n"++
         "9:((8,41),(8,42))\n"++
         "8:((8,43),(8,44))\n"++
         "8:((8,45),(8,46))\n"++
         "7:((8,47),(8,48))\n"++
         "7:((8,49),(8,50))\n"++
         "5:((8,50),(8,51))\n"++
         "3:((8,52),(8,57))\n"++
         "3:((8,60),(12,86))(Above SameLine 2 (8,60) (12,86) FromAlignCol (2,-85))\n"++
         "4:((8,60),(8,65))\n"++
         "5:((8,60),(8,61))\n"++
         "5:((8,62),(8,65))\n"++
         "6:((8,62),(8,63))\n"++
         "6:((8,64),(8,65))\n"++
         "4:((10,60),(12,86))\n"++
         "5:((10,60),(10,61))\n"++
         "5:((10,62),(12,86))\n"++
         "6:((10,62),(10,63))\n"++
         "6:((10,64),(10,65))\n"++
         "6:((11,62),(11,67))\n"++
         "6:((12,64),(12,86))(Above FromAlignCol (1,-4) (12,64) (12,86) FromAlignCol (2,-85))\n"++
         "7:((12,64),(12,86))\n"++
         "8:((12,64),(12,65))\n"++
         "8:((12,66),(12,86))\n"++
         "9:((12,66),(12,67))\n"++
         "9:((12,68),(12,86))\n"++
         "10:((12,68),(12,71))\n"++
         "10:((12,72),(12,77))(Above None (12,72) (12,77) SameLine 1)\n"++
         "11:((12,72),(12,77))\n"++
         "12:((12,72),(12,73))\n"++
         "12:((12,74),(12,77))\n"++
         "13:((12,74),(12,75))\n"++
         "13:((12,76),(12,77))\n"++
         "10:((12,81),(12,86))\n"++
         "11:((12,81),(12,82))\n"++
         "11:((12,83),(12,84))\n"++
         "11:((12,85),(12,86))\n"++
         "1:((14,1),(14,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource


-- replaceToken test/testdata/Renaming/LayoutIn3.hs:7:13:(((False,0,0,7),13),((False,0,0,7),14))((((7,13),(7,21)),ITvarid "anotherX"),"anotherX")

      let ss1 = posToSrcSpan layout ((7,13),(7,14))
      (showGhc ss1) `shouldBe` "test/testdata/Renaming/LayoutIn3.hs:7:13"

      [tok1] <- basicTokenise "\n\n\n\n\n\n\n            anotherX"
      (show tok1) `shouldBe` "((((7,13),(7,21)),ITvarid \"anotherX\"),\"anotherX\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

-- replaceToken test/testdata/Renaming/LayoutIn3.hs:7:13:(((False,0,0,7),13),((False,0,0,7),14))((((7,13),(7,21)),ITvarid "anotherX"),"anotherX")

      let ss2 = posToSrcSpan layout ((7,13),(7,14))
      (showGhc ss2) `shouldBe` "test/testdata/Renaming/LayoutIn3.hs:7:13"

      [tok2] <- basicTokenise "\n\n\n\n\n\n\n            anotherX"
      (show tok2) `shouldBe` "((((7,13),(7,21)),ITvarid \"anotherX\"),\"anotherX\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

-- replaceToken test/testdata/Renaming/LayoutIn3.hs:8:37:(((False,0,0,8),37),((False,0,0,8),38))((((8,37),(8,45)),ITvarid "anotherX"),"an

      let ss3 = posToSrcSpan layout ((8,37),(8,38))
      (showGhc ss3) `shouldBe` "test/testdata/Renaming/LayoutIn3.hs:8:37"

      [tok3] <- basicTokenise "\n\n\n\n\n\n\n\n                                    anotherX"
      (show tok3) `shouldBe` "((((8,37),(8,45)),ITvarid \"anotherX\"),\"anotherX\")"

      let layout4 = replaceTokenForSrcSpan layout3 ss3 tok3

      -- -- -- --

      (drawTreeCompact layout4) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(12,86))\n"++
         "2:((7,1),(7,4))\n"++
         "2:((7,5),(12,86))\n"++
         "3:((7,5),(7,6))\n"++
         "3:((7,7),(7,8))\n"++
         "3:((7,9),(8,51))\n"++
         "4:((7,9),(7,12))\n"++
         "4:((7,13),(7,19))(Above None (7,13) (7,19) SameLine 1)\n"++
         "5:((7,13),(7,19))\n"++
         "6:((7,13),(7,14))\n"++
         "6:((7,15),(7,19))\n"++
         "7:((7,15),(7,16))\n"++
         "7:((7,17),(7,19))\n"++
         "4:((7,20),(8,51))\n"++
         "5:((7,20),(7,24))\n"++
         "5:((7,24),(8,50))\n"++
         "6:((7,24),(7,27))\n"++
         "6:((7,28),(8,33))(Above None (7,28) (8,33) SameLine 1)\n"++
         "7:((7,28),(7,33))\n"++
         "8:((7,28),(7,29))\n"++
         "8:((7,30),(7,33))\n"++
         "9:((7,30),(7,31))\n"++
         "9:((7,32),(7,33))\n"++
         "7:((8,28),(8,33))\n"++
         "8:((8,28),(8,29))\n"++
         "8:((8,30),(8,33))\n"++
         "9:((8,30),(8,31))\n"++
         "9:((8,32),(8,33))\n"++
         "6:((8,37),(8,50))\n"++
         "7:((8,37),(8,46))\n"++
         "8:((8,37),(8,42))\n"++
         "9:((8,37),(8,38))\n"++
         "9:((8,39),(8,40))\n"++
         "9:((8,41),(8,42))\n"++
         "8:((8,43),(8,44))\n"++
         "8:((8,45),(8,46))\n"++
         "7:((8,47),(8,48))\n"++
         "7:((8,49),(8,50))\n"++
         "5:((8,50),(8,51))\n"++
         "3:((8,52),(8,57))\n"++
         "3:((8,60),(12,86))(Above SameLine 2 (8,60) (12,86) FromAlignCol (2,-85))\n"++
         "4:((8,60),(8,65))\n"++
         "5:((8,60),(8,61))\n"++
         "5:((8,62),(8,65))\n"++
         "6:((8,62),(8,63))\n"++
         "6:((8,64),(8,65))\n"++
         "4:((10,60),(12,86))\n"++
         "5:((10,60),(10,61))\n"++
         "5:((10,62),(12,86))\n"++
         "6:((10,62),(10,63))\n"++
         "6:((10,64),(10,65))\n"++
         "6:((11,62),(11,67))\n"++
         "6:((12,64),(12,86))(Above FromAlignCol (1,-4) (12,64) (12,86) FromAlignCol (2,-85))\n"++
         "7:((12,64),(12,86))\n"++
         "8:((12,64),(12,65))\n"++
         "8:((12,66),(12,86))\n"++
         "9:((12,66),(12,67))\n"++
         "9:((12,68),(12,86))\n"++
         "10:((12,68),(12,71))\n"++
         "10:((12,72),(12,77))(Above None (12,72) (12,77) SameLine 1)\n"++
         "11:((12,72),(12,77))\n"++
         "12:((12,72),(12,73))\n"++
         "12:((12,74),(12,77))\n"++
         "13:((12,74),(12,75))\n"++
         "13:((12,76),(12,77))\n"++
         "10:((12,81),(12,86))\n"++
         "11:((12,81),(12,82))\n"++
         "11:((12,83),(12,84))\n"++
         "11:((12,85),(12,86))\n"++
         "1:((14,1),(14,1))\n"


      let srcTree2 = layoutTreeToSourceTree layout4
      -- (showGhc srcTree2) `shouldBe` ""

      -- (showGhc $ retrieveLinesFromLayoutTree layout3) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module LayoutIn3 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'x' after 'let'  to 'anotherX'.\n\nfoo x = let anotherX = 12 in (let y = 3\n                                  z = 2 in anotherX * y * z * w)where   y = 2\n                                                                        --there is a comment.\n                                                                        w = x\n                                                                          where\n                                                                            x = let y = 5 in y + 3\n\n"

    -- -----------------------------------------------------------------

  -- -----------------------------------
