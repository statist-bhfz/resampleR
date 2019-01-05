#' @title Creates folds stratified by target variable.
#'
#' @param y Target variable vector.
#' @param nfolds Number of folds.
#' @param probs Numeric vector of probabilities with values in \emph{[0, 1]} range.
#'
#' @return Folds numbers vector.
create_folds <- function(y,
                         nfolds = 5L,
                         probs = seq(0, 1, length.out = 11)) {

    if (is.numeric(y)) {
        # Quantile binning
        breaks <- unique(quantile(1:100, probs = probs))
        y <- .bincode(y, breaks, include.lowest = TRUE)
    }

    if (is.character(y)) {
        y <- as.factor(y)
    }

    if (is.factor(y)) {
        y <- as.integer(y)
    }

    res <- data.table(y = y, fold = NA_integer_)
    res[, fold := sample.int(nfolds, .N, replace = TRUE), by = y]
    return(res[, fold])
}


#' Resamples for K-fold cross-validation with stratification by target variable.
#'
#' Creates resamples for K-fold cross-validation stratified by target variable.
#'
#' @param data data.table with target variable.
#' @param y Target variable name (character).
#' @param nfolds Number of folds (min 2, max 20).
#' @param probs Numeric vector of probabilities with values in \emph{[0, 1]} range.
#'
#' @return data.table with \code{nfolds} columns. Each column is an indicator variable
#' with 1 corresponds to observations in validation dataset (stratified by target).
#'
#' @examples
#' cv_base(as.data.table(iris), "Species")
#'
#' @details
#' Numeric target: quantile binning is used for stratification.
#' Character/categorical target: resampling performs within categories.
#' \code{probs} can be a vector like \code{c(0, seq(0.99, 1, length.out = 10))}
#' for target with very skewed distribution, e.g. for financial data with 99\% of 0's.
#'
#' @import data.table
#' @import checkmate
#' @export
cv_base <- function(data,
                    y,
                    nfolds = 5L,
                    probs = seq(0, 1, length.out = 11)) {

    assert_data_table(data)
    assert_names(names(data), must.include = y)
    assert_integerish(nfolds, lower = 2L, upper = 20L)

    splits <- data.table(fold = create_folds(y = data[, get(y)],
                         nfolds = nfolds,
                         probs = probs))

    # One hot for each split
    for (i in seq_along(1:nfolds)) {
        splits[, paste0("split_", i) := 0L]
        splits[fold == i, paste0("split_", i) := 1L]
    }

    cn <- paste0("split_", seq_len(nfolds))
    return(splits[, ..cn])
}

#' Resamples for group K-fold cross-validation with stratification by target variable.
#'
#' @param data data.table with \code{y} and \code{id}.
#' @param y Target variable name (character).
#' @param id Identifier of each time series (character).
#' @param nfolds Number of folds (min 2, max 20).
#' @param probs Numeric vector of probabilities with values in \emph{[0, 1]} range.
#'
#' @return data.table with \code{nfolds} columns. Each column is an indicator variable
#' with 1 corresponds to observations in validation dataset (stratified by target).
#'
#'@examples
#' dt <- data.table(
#'     user = rep(1:100, each = 5),
#'     target = rnorm(5e2)
#' )
#' cv_split_group_kfold(dt, "target", "user")
#'
#' @details
#' Numeric target: quantile binning is used for stratification.
#'
#' Character/categorical target: resampling performs within categories.
#'
#' \code{probs} can be a vector like \code{c(0, seq(0.99, 1, length.out = 10))}
#' for target with very skewed distribution, e.g. for financial data with 99\% of 0's.
#'
#' Ensures that all observations for each \code{id} will be placed in the same fold.
#' @export
cv_split_group_kfold <- function(data,
                                 y,
                                 id,
                                 nfolds = 5L,
                                 probs = seq(0, 1, length.out = 11)) {

    cols <- c(y, id)
    assert_data_table(data)
    assert_names(names(data), must.include = cols)
    assert_integerish(nfolds, lower = 2L, upper = 20L)

    data <- data[, .SD, .SDcols = cols]
    splits <- data[, .(target = mean(get(y))), by = id]
    splits[, fold := create_folds(y = get(y), nfolds = nfolds, probs = probs)]
    splits <- splits[match(data[, get(id)], splits[, get(id)])]

    cn <- paste0("split_", seq_len(nfolds))

    # One hot for each split
    for (i in seq_along(1:nfolds)) {
        splits[, paste0("split_", i) := 0L]
        splits[fold == i, paste0("split_", i) := 1L]
    }

    return(splits[, ..cn])

}


#' Special resampling strategy for K-fold cross-validation on time series data
#' with stratification by target variable.
#'
#' @param data data.table with \code{y}, \code{id} and \code{time}.
#' @param y Target variable name (character).
#' @param id Identifier of each time series (character).
#' @param time Time variable name (character).
#' @param nfolds Number of folds (min 2, max 20).
#' @param probs Numeric vector of probabilities with values in \emph{[0, 1]} range.

#' @return data.table with \code{nfolds} columns. Each column is an indicator variable
#' with 1 corresponds to observations in validation dataset (stratified by target).
#'
#' @examples
#' dt <- data.table(
#'     user = rep(1:100, each = 5),
#'     date = as.POSIXct(rep(seq(1.8*10e8, 1.8*10e8 + 388800, by = 86400), 100),
#'                       origin = "1960-01-01"),
#'     target = rnorm(5e2)
#' )
#' cv_split_temporal(dt, "target", "user", "date")
#'
#' @details
#' Numeric target: quantile binning is used for stratification.
#'
#' Character/categorical target: resampling performs within categories.
#'
#' \code{probs} can be a vector like \code{c(0, seq(0.99, 1, length.out = 10))}
#' for target with very skewed distribution, e.g. for financial data with 99\% of 0's.
#'
#' When some observations from one time series fall into validation fold, train/validation
#' indices for this time series will be reassigned: only last observation will be in validation fold.
#' This ensures that training performs on past data and predictions are made for future observations.
#'
#' TODO: allow to specify arbitrary number of observations for validation set.
#'
#' @export
cv_split_temporal <- function(data,
                              y,
                              id,
                              time,
                              nfolds = 5L,
                              probs = seq(0, 1, length.out = 11)
                              ) {

    cols <- c(y, id, time)
    assert_data_table(data)
    assert_names(names(data), must.include = cols)
    assert_integerish(nfolds, lower = 2L, upper = 20L)

    splits <- data[, .SD, .SDcols = cols]

    # Sort by time within id
    setorderv(splits, c(id, time))

    splits[, fold := create_folds(y = get(y), nfolds = nfolds, probs = probs)]

    cn <- paste0("split_", seq_len(nfolds))
    # One hot for each split
    for (i in seq_along(1:nfolds)) {
        splits[, paste0("split_", i) := 0L]
        splits[fold == i, paste0("split_", i) := 1L]
    }

    to_replace <- splits[, .N, by = id][N > 1]
    f <- function(x) {
        if (any(x > 0L)) x <- c(rep(0L, length(x) - 1L), 1L)
        return(x)
    }
    splits[to_replace,
           (cn) := lapply(.SD, f),
           on = id,
           .SDcols = cn,
           by = id]

    return(splits[, ..cn])
}
