# This example recreates the ECSI model on mobile users found at:
#  https://cran.r-project.org/web/packages/semPLS/vignettes/semPLS-intro.pdf

source("R/syntax.R")

data("mobi")

# modelr syntax for creating measurement model

mobi_mm <- measure(
  reflect("Image", "IMAG", 1:5),
  reflect("Expectation", "CUEX", 1:3),
  reflect("Quality", "PERQ", 1:7),
  reflect("Value", "PERV", 1:2),
  reflect("Satisfaction", "CUSA", 1:3),
  single_item("Complaints", "CUSCO"),
  reflect("Loyalty", "CUSL", 1:3)
)

# modelr syntax for creating structural model
# - note, three ways to represent the structure

mobi_sm <- structure(
  paths(from = "Image", to = c("Expectation", "Satisfaction", "Loyalty")),
  paths(from = "Expectation", to = c("Quality", "Value", "Satisfaction")),
  paths(from = "Quality", to = c("Value", "Satisfaction")),
  paths(from = "Value", to = c("Satisfaction")),
  paths(from = "Satisfaction", to = c("Complaints", "Loyalty")),
  paths(from = "Complaints", to = "Loyalty")
)

# Regular semPLS functions to create andestimate model, and report estimates
mobi_pls <- plsm(data = mobi, strucmod = mobi_sm, measuremod = mobi_mm)
mobi_pls_fitted <- sempls(model = mobi_pls, data = mobi)
pathCoeff(mobi_pls_fitted)
rSquared(mobi_pls_fitted)

# modelr function to see scatterplot of scores
plot_scores(mobi_pls_fitted)