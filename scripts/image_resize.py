import numpy as np
from skimage import io
from skimage.transform import resize
import glob


INPUT_PATH = "../data/"
OUTPUT_PATH = "../data_resized/"
# collect all filenames
FILENAMES = glob.glob(INPUT_PATH + "**/*.jpg")

IMAGES = []
for idx, f in enumerate(FILENAMES):
    # Load images
    img = io.imread(f)
    # resize images to size (224, 224, 3)
    # bi-linear downsample
    img = resize(img, (512,512), order=1, mode='reflect', anti_aliasing=True)
    IMAGES.append(img)
    # redirect all files to output folder
    ftmp = f.split("/")[2:]
    outfile = OUTPUT_PATH + "/".join(ftmp)
    io.imsave(outfile, img)
    #print(idx)
