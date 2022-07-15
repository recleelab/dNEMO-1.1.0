#!/usr/bin/env python
# coding: utf-8
#
# AUTHOR: David Schipper [DS]
# Additions by Gabriel Kowalczyk [GJK] where noted

# In[1]:

import sys
import numpy as np
import matplotlib.pyplot as plt
import skimage.io
from cellpose import models
import time, os, sys
from urllib.parse import urlparse
import matplotlib as mpl
# get_ipython().run_line_magic('matplotlib', 'inline')
mpl.rcParams['figure.dpi'] = 300
from cellpose import utils
import glob
from pathlib import Path
import scipy.misc
import imageio
from tkinter import Tk
from tkinter.filedialog import askdirectory


# In[3]:


#Input Path to Working folder

# commented out by GJK
# path = askdirectory(title='Select Folder') # shows dialog box and return the path

# workingFolder = path
# print(workingFolder)

#workingFolder = r'C:\Users\David\Desktop\LeeLab\DataToAnalize\90049_100'


# added by GJK, was having trouble accessing return print statement from MATLAB
inputArgs = sys.argv
workingFolder = inputArgs[1]

# temporary
# print(workingFolder)

# In[3]:


#Generate file paths to inport multiple images from the file location
filePath = os.path.join(workingFolder,'*.tif')
filePath

files = glob.glob(filePath)
NumberToAnalize = len(files)
NumberToAnalize


# In[4]:


#Create Save names     
y = os.path.basename(files[0])
size = len(y)
y1 = y[:size - 7]
filePathMasks = os.path.join(workingFolder, y1 + 'Masks.tif')
filePathFlows = os.path.join(workingFolder, y1 + 'Flows.tif')

filePathMasks


# In[5]:


#loop though data and run cellpose segmentation 
for i in range(NumberToAnalize): 
    #Import Tiff stack
    ImageStack = skimage.io.imread(files[i])
    shape1 = ImageStack.shape
    NumStacks = shape1[0]

    #reformat data
    Split = np.split(ImageStack,NumStacks,axis=0)
    len(Split)
    SplitImages = [item.squeeze() for item in Split]
    
    from cellpose import models, io

    # DEFINE CELLPOSE MODEL
    # model_type='cyto' or model_type='nuclei'
    model = models.Cellpose(gpu=False, model_type='cyto')
        
    # define CHANNELS to run segementation on
    # grayscale=0, R=1, G=2, B=3
    # channels = [cytoplasm, nucleus]
    # if NUCLEUS channel does not exist, set the second channel to 0
    # channels = [0,0]
    # IF ALL YOUR IMAGES ARE THE SAME TYPE, you can give a list with 2 elements
    channels = [0,0] # IF YOU HAVE GRAYSCALE
    # channels = [2,3] # IF YOU HAVE G=cytoplasm and B=nucleus
    # channels = [2,1] # IF YOU HAVE G=cytoplasm and R=nucleus

    # or if you have different types of channels in each image
    #channels = [[2,3], [0,0], [0,0]]

    # if diameter is set to None, the size of the cells is estimated on a per image basis
    # you can set the average cell `diameter` in pixels yourself (recommended) 
    # diameter can be a list or a single number for all images
    masks, flows, styles, diams = model.eval(SplitImages, diameter=None, channels=channels)

    #Use if you want to save
    # save results so you can load in gui
    #io.masks_flows_to_seg(SplitImages, masks, flows, diams, files, channels)

    # save results as png
    #io.save_to_png(SplitImages, masks, flows, files)
    
        #record progress
    print(i)
       
    #Create Save names     
    y = os.path.basename(files[i])
    size = len(y)
    y1 = y[:size - 7]
    filePathMasks = os.path.join(workingFolder, y1 + 'Masks.tif')
    filePathFlows = os.path.join(workingFolder, y1 + 'Flows.tif')
            
    #save masks to tiff stacks
    imageio.mimwrite(filePathMasks,masks)
    #imageio.mimwrite(filePathFlows,flows)
    
    # save results as png
    #io.save_to_png(SplitImages, masks, flows, filePathFlows)

        
        
        
        


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




