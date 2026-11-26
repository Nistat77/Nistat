# Run from the repository root with Rscript --vanilla tests/test_nistat.R
loaded <- capture.output(source("Nistat.R", encoding = "UTF-8"))
stopifnot(length(loaded) == 0L)

expect_error <- function(expr) {
  failure <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(failure, "error"))
}
expect_error(nistat_recommend("comparison", design = "paired_two"))
expect_error(nistat_recommend("comparison", design = "paired_two", target = "invalid"))
expect_error(nistat_recommend("prediction", outcome = "binary", predictors = "multiple"))
expect_error(nistat_options(goal = "prediction", "binary"))
expect_error(nistat_options(goal = "prediction", goal = "association"))
expect_error(nistat_options(goal = NA_character_))
expect_error(nistat_options(goal = c("comparison", "prediction")))
expect_error(nistat_options(goal = "comparison", language = "fr"))
stopifnot(identical(nistat_options(language = "en")$key, "goal"))

# Explicit scientific contrasts catch a route changed to a different, valid method.
expect_method <- function(id, ...) {
  for (lang in c("ar", "en")) {
    result <- nistat_recommend(..., language = lang)
    stopifnot(identical(result$id, id))
  }
}
expect_method("welch_t", "comparison", design = "independent_two", target = "means")
expect_method("paired_t", "comparison", design = "paired_two", target = "means")
expect_method("sign_test", "comparison", design = "paired_two", target = "direction")
expect_method("signed_rank", "comparison", design = "paired_two", target = "signed_ranks")
expect_method("mcnemar_exact", "comparison", design = "paired_two", target = "binary")
expect_method("fisher_exact", "comparison", design = "independent_two", target = "proportions", expected = "sparse")
expect_method("chisq_independence", "association", variables = "categorical", expected = "adequate")
expect_method("inspect_expected", "association", variables = "categorical", expected = "unknown")
expect_method("welch_anova", "comparison", design = "independent_many", target = "means")
expect_method("rm_anova", "comparison", design = "repeated_many", target = "means")
expect_method("friedman", "comparison", design = "repeated_many", target = "ranks")
expect_method("ancova", "comparison", design = "pre_post", target = "adjusted_followup")
expect_method("change_scores", "comparison", design = "pre_post", target = "change")
expect_method("factorial_interaction", "comparison", design = "factorial")
expect_method("spearman", "association", variables = "continuous", pattern = "monotonic")
expect_method("scatterplot", "association", variables = "continuous", pattern = "unknown")
expect_method("binary_logit", "prediction", outcome = "binary")
expect_method("ordinal_logit", "prediction", outcome = "ordinal")
expect_method("multinomial", "prediction", outcome = "nominal")
expect_method("ks_fixed", "distribution", target = "continuous_cdf", parameters = "fixed")
expect_method("fitted_qq", "distribution", target = "continuous_cdf", parameters = "fitted")
expect_method("simulated_gof", "distribution", target = "frequencies", expected = "sparse")
expect_method("residual_qq", "distribution", target = "normality", quantity = "residuals")

# Walk the public discovery API as a caller would. Each leaf must be complete
# in both languages, and no menu step may ask again for a chosen answer.
fields <- c("method", "rationale", "checks", "report", "code", "reference")
walk <- function(answers = list()) {
  en <- do.call(nistat_options, c(answers, list(language = "en")))
  ar <- do.call(nistat_options, c(answers, list(language = "ar")))
  if (is.null(en)) {
    stopifnot(is.null(ar))
    a <- do.call(nistat_recommend, c(answers, list(language = "ar")))
    e <- do.call(nistat_recommend, c(answers, list(language = "en")))
    for (result in list(a, e)) {
      stopifnot(inherits(result, "nistat_recommendation"), identical(result$answers, answers),
        all(fields %in% names(result)), all(nzchar(unlist(result[fields]))),
        startsWith(result$reference, "https://"))
    }
    stopifnot(identical(a$id, e$id), identical(a$code, e$code), identical(a$reference, e$reference),
      all(unlist(a[fields[1:4]]) != unlist(e[fields[1:4]])))
    return(list(e))
  }
  stopifnot(identical(en$key, ar$key), !en$key %in% names(answers),
    identical(names(en$choices), names(ar$choices)), length(en$choices) > 1L,
    en$question != ar$question, all(en$choices != ar$choices))
  leaves <- list()
  for (code in names(en$choices)) {
    next_answers <- answers
    next_answers[[en$key]] <- code
    leaves <- c(leaves, walk(next_answers))
  }
  leaves
}
paths <- walk()
ids <- vapply(paths, function(x) x$id, character(1))
stopifnot(setequal(ids, names(.nistat_methods)))
cards <- setNames(paths[!duplicated(ids)], unique(ids))

# Console tests exercise real numeric choices, invalid input, backtracking,
# restarting and end-of-input. Never read the tester's keyboard.
session <- function(lines, language) {
  position <- 0L
  reader <- function() {
    position <<- position + 1L
    if (position > length(lines)) return(character())
    lines[position]
  }
  output <- capture.output(result <- .nistat_session(language, reader))
  list(result = result, output = output)
}
english <- session(c("2", "", "9", "2", "b", "3", "4", "b", "1", "2"), "en")
stopifnot(english$result$id == "paired_t",
  sum(grepl(.nistat_ui$en$invalid, english$output, fixed = TRUE)) == 2L,
  any(grepl("Exact McNemar", english$output)), any(grepl("Paired t-test", english$output)))
arabic <- session(c(" ٢ ", "٣", "رجوع", "٦", "١", "١", "۳", "۲", "۰"), "ar")
stopifnot(arabic$result$id == "binary_logit", arabic$result$language == "ar")
stopifnot(is.null(session(character(), "en")$result),
  is.null(session(c("2", "q"), "en")$result),
  session(c("2", "6", "1"), "en")$result$id == "ancova")

# Exercise the standalone Rscript entry point, including piped stdin and EOF.
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
cli <- function(args, input) {
  system2(rscript, c("--vanilla", "Nistat.R", args), input = input, stdout = TRUE, stderr = TRUE)
}
cli_en <- cli("en", c("2", "6", "1"))
cli_ar <- cli(character(), c("2", "3", "4", "2"))
stopifnot(is.null(attr(cli_en, "status")), any(grepl("ANCOVA", cli_en)),
  is.null(attr(cli_ar, "status")), any(grepl(.nistat_methods$mcnemar_exact$ar$method, cli_ar, fixed = TRUE)),
  identical(cli("--help", character()), "Rscript Nistat.R [ar|en]"))

# Exercise every displayed template with inputs in the documented form.
# Only the two explicitly optional model packages may be skipped.
run_templates <- function(cards) {
  set.seed(42)
  plot_file <- tempfile(fileext = ".pdf")
  grDevices::pdf(plot_file)
  on.exit({ grDevices::dev.off(); unlink(plot_file) })

  x <- stats::rnorm(60)
  y <- 0.35 * x + stats::rnorm(60)
  before <- x
  after <- before + stats::rnorm(60, 0.25)
  reference_value <- 0
  events <- 14L
  trials <- 35L
  p0 <- 0.5
  counts <- c(18, 21, 21)
  p <- c(0.3, 0.4, 0.3)
  tab <- matrix(c(21, 9, 2, 12), nrow = 2, byrow = TRUE)
  mu0 <- 0
  sigma0 <- 1
  q_fitted <- function(p) stats::qnorm(p, mean(x), stats::sd(x))
  base_data <- data.frame(score = y, x = x, x1 = x, x2 = stats::rnorm(60), y = y,
    group = factor(rep(c("control", "program"), each = 30)))
  pre_post <- data.frame(group = factor(rep(c("control", "program"), each = 6)),
    pre = c(8:13, 10:15), post = c(12, 12, 13, 14, 12, 15, 16, 17, 17, 16, 19, 17))
  repeated <- expand.grid(id = factor(1:12), condition = factor(1:3))
  repeated$score <- stats::rnorm(nrow(repeated))
  crossed <- expand.grid(factor_a = factor(1:2), factor_b = factor(1:3), rep = 1:5)
  crossed$score <- stats::rnorm(nrow(crossed))
  skipped <- character()
  for (id in names(cards)) {
    dat <- base_data
    if (id %in% c("ancova", "change_scores")) dat <- pre_post
    if (id %in% c("friedman", "rm_anova")) dat <- repeated
    if (id %in% c("kruskal", "welch_anova")) dat <- transform(dat, group = factor(rep(1:3, each = 20)))
    if (id == "factorial_interaction") dat <- crossed
    if (id == "binary_logit") dat$y <- rep(0:1, 30)
    if (id == "poisson") dat$y <- stats::rpois(nrow(dat), 2)
    if (id == "multinomial") dat$y <- factor(rep(1:3, 20))
    if (id == "ordinal_logit") dat$y <- ordered(rep(1:3, 20))
    if (id == "residual_qq") fit <- stats::lm(y ~ x, data = dat)
    pkg <- switch(id, multinomial = "nnet", ordinal_logit = "MASS", NULL)
    if (!is.null(pkg) && !requireNamespace(pkg, quietly = TRUE)) {
      skipped <- c(skipped, pkg)
      next
    }
    result <- tryCatch(eval(parse(text = cards[[id]]$code)),
      error = function(e) stop(id, ": ", conditionMessage(e), call. = FALSE))
    if (id == "mcnemar_exact") stopifnot(abs(result$p.value - 0.0654296875) < 1e-10)
    if (id == "inspect_expected") stopifnot(isTRUE(all.equal(colSums(result), as.numeric(colSums(tab)))))
    if (id == "ancova") {
      stopifnot(round(stats::coef(fit)[["groupprogram"]], 2) == 3.26,
        identical(as.numeric(round(result["groupprogram", ], 2)), c(1.73, 4.78)))
    }
    if (id == "change_scores") stopifnot(abs(unname(diff(result$estimate)) - 2) < 1e-10)
  }

  # Zero discordant pairs, all ties and out-of-range normality samples are valid
  # inputs for the guidance and must not pass invalid arguments to an R test.
  tab <- diag(c(12L, 9L))
  stopifnot(is.null(suppressMessages(eval(parse(text = cards$mcnemar_exact$code)))))
  after <- before
  stopifnot(is.null(suppressMessages(eval(parse(text = cards$sign_test$code)))))
  for (values in list(numeric(), c(1, 2), rep(5, 7), seq_len(5001))) {
    x <- values
    stopifnot(is.null(eval(parse(text = cards$normality$code))))
  }
  skipped
}

skipped <- run_templates(cards)
cat(sprintf("Passed %d decision paths in Arabic and English and console navigation.\n", length(paths)))
cat(sprintf("Executed %d of %d R templates.\n", length(cards) - length(skipped), length(cards)))
if (length(skipped)) cat("Optional packages unavailable:", paste(skipped, collapse = ", "), "\n")
