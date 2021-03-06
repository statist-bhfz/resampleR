% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/k_fold.R
\name{cv_base}
\alias{cv_base}
\title{Resamples for K-fold cross-validation with stratification by target variable.}
\usage{
cv_base(data, y, nfolds = 5L, probs = seq(0, 1, length.out = 11))
}
\arguments{
\item{data}{data.table with target variable.}

\item{y}{Target variable name (character).}

\item{nfolds}{Number of folds (min 2, max 20).}

\item{probs}{Numeric vector of probabilities for quantile binning
with values in \emph{[0, 1]} range.}
}
\value{
data.table with \code{nfolds} columns. Each column is an indicator variable
with 1 corresponds to observations in validation dataset (stratified by target).
}
\description{
Creates resamples for K-fold cross-validation stratified by target variable.
}
\details{
Numeric target: quantile binning is used for stratification.
Character/categorical target: resampling performs within categories.
\code{probs} can be a vector like \code{c(0, seq(0.99, 1, length.out = 10))}
for target with very skewed distribution, e.g. for financial data with 99\% of 0's.
}
\examples{
cv_base(as.data.table(iris), "Species")

}
