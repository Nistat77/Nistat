# From the repository root: Rscript students/build.R [--check]
# jsonlite is a build-time dependency. The generated page runs in a browser.
source("Nistat.R", encoding = "UTF-8")
if (!requireNamespace("jsonlite", quietly = TRUE)) stop("Install the build dependency with install.packages('jsonlite').")

questions <- lapply(.nistat_questions, function(question) {
  question$label <- as.list(question$label)
  question$choices <- lapply(question$choices, function(choice) {
    choice$label <- as.list(choice$label)
    choice
  })
  question
})

# The illustrative pre/post dataset in the README, one row per student.
scores <- data.frame(group = factor(rep(c("control", "program"), each = 6)),
  pre = c(8:13, 10:15), post = c(12, 12, 13, 14, 12, 15, 16, 17, 17, 16, 19, 17))
fit <- stats::lm(post ~ pre + group, data = scores)
change <- with(scores, split(post - pre, group))
gain_test <- stats::t.test(change$program, change$control)
example <- list(n = nrow(scores), means = lapply(split(scores, scores$group), function(group) {
  list(pre = mean(group$pre), post = mean(group$post))
}), adjusted = unname(stats::coef(fit)["groupprogram"]),
  adjusted_ci = unname(stats::confint(fit)["groupprogram", ]),
  gain = mean(change$program) - mean(change$control), gain_ci = as.numeric(gain_test$conf.int))
guide <- jsonlite::toJSON(list(questions = questions, methods = .nistat_methods, example = example),
  auto_unbox = TRUE, digits = 8)
guide <- gsub("<", "\\u003c", guide, fixed = TRUE)

read_source <- function(name) paste(readLines(file.path("students/src", name), encoding = "UTF-8"), collapse = "\n")
page <- readLines("students/src/page.html", encoding = "UTF-8")
inserts <- list("{{STYLES}}" = read_source("style.css"), "{{CATALOG}}" = guide,
  "{{ROUTES}}" = read_source("routes.js"), "{{APP}}" = read_source("app.js"))
for (marker in names(inserts)) {
  stopifnot(sum(page == marker) == 1L)
  page[page == marker] <- inserts[[marker]]
}
output <- charToRaw(enc2utf8(paste0(paste(page, collapse = "\n"), "\n")))
file <- "students/index.html"
if (identical(commandArgs(trailingOnly = TRUE), "--check")) {
  if (!file.exists(file) || !identical(readBin(file, "raw", n = file.size(file)), output)) {
    stop("Rebuild students/index.html with Rscript students/build.R.")
  }
} else {
  writeBin(output, file)
}
