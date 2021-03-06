#' modelr Model Assembly Functions
#'
#' The \code{modelr} package provides a natural syntax for researchers to describe PLS
#' structural equation models. \code{modelr} is copatible with semPLS, simplePLS and matrixPLS,
#' meaning that once a model is specified, it can be used across models for comparison.
#'
#' @param data A \code{data.frame} intendend to use for the fitting method
#'
#' @param measurement_model A source-to-target matrix representing the outer/structural model,
#'   generated by \code{measure}.
#'
#' @param interactions A object of type \code{interact} as generated by the \code{interact}
#'   method. Default setting is \code{NULL} and can be excluded for models with no interactions.
#'
#' @param structural_model A source-to-target matrix representing the inner/structural model,
#'   generated by \code{structure}.
#'
#' @usage
#' modelr(data, measurement_model, interactions=NULL, structural_model, ...)
#'
#' @seealso \code{\link{structure}} \code{\link{measure}} \code{\link{paths}} \code{\link{interact}}
#'
#' @examples
#' data("mobi", package = "semPLS")
#'
#' #modelr syntax for creating measurement model
#' mobi_mm <- measure(
#'              reflect("Image",        multi_items("IMAG", 1:5)),
#'              reflect("Expectation",  multi_items("CUEX", 1:3)),
#'              reflect("Quality",      multi_items("PERQ", 1:7)),
#'              reflect("Value",        multi_items("PERV", 1:2)),
#'              reflect("Satisfaction", multi_items("CUSA", 1:3)),
#'              reflect("Complaints",   single_item("CUSCO")),
#'              reflect("Loyalty",      multi_items("CUSL", 1:3))
#'            )
#' #modelr syntax for creating structural model
#' mobi_sm <- structure(
#'   paths(from = "Image",        to = c("Expectation", "Satisfaction", "Loyalty")),
#'   paths(from = "Expectation",  to = c("Quality", "Value", "Satisfaction")),
#'   paths(from = "Quality",      to = c("Value", "Satisfaction")),
#'   paths(from = "Value",        to = c("Satisfaction")),
#'   paths(from = "Satisfaction", to = c("Complaints", "Loyalty")),
#'   paths(from = "Complaints",   to = "Loyalty")
#' )
#'
#' mobi_pls <- modelr(data = mobi,
#'                    measurement_model = mobi_mm,
#'                    structural_model = mobi_sm)
#'
#' print_paths(mobi_pls)
#' plot_scores(mobi_pls)
#'
modelr <- function(data, measurement_model, interactions=NULL, structural_model, ...) {
  if(!is.null(interactions)) {
    # update data with new iteraction items
    intxns_list <- interactions(data, measurement_model)
    get_data <- function(intxn) { intxn$data }
    interaction_data <- do.call("cbind", lapply(intxns_list, get_data))
    data <- cbind(data, interaction_data)

    # update measurement model with
    measure_interaction <- function(intxn) {
      reflect(intxn$name, names(intxn$data))
    }
    intxns_mm <- measure(do.call("c", lapply(intxns_list, measure_interaction)))
    measurement_model <- rbind(measurement_model, intxns_mm)
  }

  model = semPLS::plsm(data = data, strucmod = structural_model, measuremod = measurement_model)
  cat("Estimating model using semPLS::sempls...\n")
  mobi_pls_fitted <- semPLS::sempls(model, data, ...)
}
