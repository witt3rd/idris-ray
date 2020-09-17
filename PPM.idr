module PPM

import Data.Matrix

savePPM : (image : Matrix n m a) -> (filepath : String) -> IO (Either String )
-- savePPM [] filepath = ?savePPM_rhs_1
-- savePPM {n=rows} {m=cols} (x :: xs) filepath = do
