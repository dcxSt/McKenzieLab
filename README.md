# Steve's readme
Code we care about is the `IHKA` folder

**Local Utility scripts used**
Functions from the `/helpers` directory

**Dependencies**
Signal Processing Toolbox
Statistics and Machine Learning Toolbox (required by `zscore`)

## Notes

My laptop is not able to handle a full 24 hour recording .edf file due to memory concerns. When I run the matlab script on one of these files my laptop's RAM gets over-full and my computer has to use it's SWAP, which greatly slows computation time. Because the `.edf` file format is not human readable I turned it into a `.csv`, cut out everything except for a 5 minute sample, and saved converted that back into an `.edf`. I assumed that the `.txt` file by the same name is merely full of metadata about the `.edf` and left it unchanged. 


