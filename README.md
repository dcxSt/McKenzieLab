# Steve's readme
The code we care about is the `IHKA` folder. The workflow is as follows
- `sm_MakeAll_getPowerPerChannel` calculates feature files to save to disk as `.dat` files for later use
  - which calls `sm_getPowerPerChannel`
- `sm_PredictIHKA_getAllFeatures` calculates features for the subset of relevant times and save as `.mat` for more immediate use
- `sm_PredictIHKA` trains a model(s?) and computes performance metrics
- `sm_MakeAllSeizurePred` runs model(s?) for all times for all files

**Local Utility scripts used**
- Some functions from the `/helpers` directory
- Buzcode (1)

I've moved these local utility scripts to the (newly created) `/IHKA/utils/` folder, and then I only append this `utils` folder to the path, bringing functions from these `.m` files into scope. This forces me to move all the local dependencies into this `utils` folder—and nothing else; so that I can know exactly what is and what isn't being used. 

**Matlab Dependencies**
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox (required by `zscore`)

## Notes

My laptop is not able to handle a full 24 hour recording .edf file due to memory concerns. When I run the matlab script on one of these files my laptop's RAM gets over-full and my computer has to use it's SWAP, which greatly slows computation time. Because the `.edf` file format is not human readable I turned it into a `.csv`, cut out everything except for a 5 minute sample, and saved converted that back into an `.edf`. I assumed that the `.txt` file by the same name is merely full of metadata about the `.edf` and left it unchanged. 


