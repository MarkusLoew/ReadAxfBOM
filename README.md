# ReadAxfBOM

[![Build Status](https://travis-ci.org/MarkusLoew/ReadAxfBOM.svg?branch=master)](https://travis-ci.org/MarkusLoew/ReadAxfBOM)

R package to Import a weather station observation axf-file downloaded from a Australian Bureau of Meteorology station

See 

	help(package = "ReadAxfBOM") 

for details on the function provided by this package.
The import functions returns a data frame with the weather observations.


### Installation

Installation straight from github (if package "devtools" is already installed) via

```{r}
devtools::install_github("MarkusLoew/ReadAxfBOM")
```

### Example session
```{r}
# load ReadAxfBOM package from the library
library(ReadAxfBOM)

# importing the file
obs <- ReadAxfBOM("observationfile.axf")

```
