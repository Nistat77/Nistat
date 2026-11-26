# Nistat | نيستات

دليل تفاعلي بلغة R يساعد الباحث على اختيار الأسلوب الإحصائي وفق **السؤال البحثي وتصميم الدراسة والكمية المراد تقديرها**. تعرض كل توصية سبب الاختيار، والافتراضات المطلوب فحصها، وما يُذكر في التقرير، وقالب R ومرجعًا للمنهج. اللغة الافتراضية هي العربية.

Nistat is an Arabic-first statistical method guide with an English interface. Each recommendation gives a rationale, assumptions to check, reporting guidance, an editable R template and a reference. You can use the console or save the same recommendation in an analysis script.

## البدء السريع · Quick start

**للطلاب** افتح الدليل في المتصفح واختر هدف دراستك، أو ابدأ بالمثال التعليمي عن درجات الطلاب قبل البرنامج وبعده. يمكنك نسخ رابط أي خطوة أو طباعة التوصية أو تنزيل نسخة تعمل دون اتصال. [افتح دليل نيستات للطلاب](https://nistat-students.lilacsunbird8.chatgpt.site/)

**For students** the browser guide runs in Arabic or English with no R installation. Use **Copy link** to share the current question or recommendation with a class. [Open the English student guide](https://nistat-students.lilacsunbird8.chatgpt.site/#en)

Download [Nistat.R](Nistat.R) and open R in the directory containing it.

```r
source("Nistat.R", encoding = "UTF-8")
Nistat()                  # العربية
# Nistat(language = "en") # English
```

من سطر الأوامر، استخدم `Rscript Nistat.R` للعربية أو `Rscript Nistat.R en` للإنجليزية. اكتب رقم الخيار، أو `b` للرجوع وتعديل الإجابة السابقة، أو `0` للإنهاء. يقبل الدليل الأرقام 1 و١ و۱.

The guide runs locally in base R. No data upload or package installation is needed to get a recommendation. Run the R template separately after preparing your data. The multinomial and ordinal regression templates use the recommended R packages **nnet** and **MASS**, respectively.

## الأسئلة المتاحة · Research questions

| Goal | What the guide distinguishes |
| --- | --- |
| Association · العلاقات | Linear and monotonic association, exploratory plots, and categorical association with adequate, sparse or unknown expected counts. |
| Comparison · الفروق | A sample against a reference, independent or paired groups, repeated measurements, two-group pre/post designs, and the interaction of two crossed factors. |
| Prediction · التنبؤ | Continuous, binary, unordered categorical, ordered categorical and count outcomes. |
| Distribution · التوزيع | Independent observations or fitted residuals, variance homogeneity, category frequencies, and continuous reference distributions with fixed or estimated parameters. |

## مثال بحثي · A pre/post study

قِيسَ التحصيل قبل برنامج تعليمي وبعده في مجموعتين مستقلتين. إذا كان السؤال عن الفرق في المتوسط البعدي عند مستوى قبلي مشترك، يوجّه نيستات إلى **تحليل التغاير (ANCOVA)**. وإذا كان السؤال عن الفرق بين متوسطي التحسن، يوجّه إلى مقارنة **درجات التغير الفردية** بين المجموعتين. حدّد السؤال عند تخطيط الدراسة.

Record the design and retrieve the baseline-adjusted recommendation in a script.

```r
plan <- nistat_recommend(
  goal = "comparison",
  design = "pre_post",
  target = "adjusted_followup",
  language = "en"
)
print(plan)
plan$answers  # Reproducible record of the choices
```

Run the recommended model on these illustrative scores. Each row represents one participant.

```r
dat <- data.frame(
  group = factor(rep(c("control", "program"), each = 6),
                 levels = c("control", "program")),
  pre = c(8:13, 10:15),
  post = c(12, 12, 13, 14, 12, 15, 16, 17, 17, 16, 19, 17)
)
fit <- stats::lm(post ~ pre + group, data = dat)
cbind(estimate = coef(fit), confint(fit))["groupprogram", ]
with(dat, tapply(post - pre, group, mean))
```

In this example, the program group scored **3.26 points higher** at follow-up after adjusting for baseline (95% CI **1.73 to 4.78**). Mean change was **4.50 points** for the program group and **2.50** for the control group, giving a **2.00-point difference in improvement**. These estimates answer the two questions above. [Vickers & Altman, 2001](https://pmc.ncbi.nlm.nih.gov/articles/PMC1121605/)

## استخدام الدليل في كود R · Script interface

`nistat_options()` lists the next question and its named answer codes. Supply the choices already made to discover the next step. A completed path returns `NULL`. The same codes work in both languages.

```r
nistat_options(language = "en")$choices
nistat_options(goal = "comparison", design = "paired_two", language = "en")$choices

# Binary outcome measured twice on the same participants
paired <- nistat_recommend("comparison", design = "paired_two", target = "binary")
paired$id     # "mcnemar_exact"
paired$code   # R template for a paired 2 by 2 table
```

A recommendation contains `id`, `language`, `method`, `rationale`, `checks`, `report`, `code`, `reference` and `answers`. The console returns its last completed recommendation invisibly. In scripts, missing, invalid and inapplicable design choices produce an error.

Prepare inputs as specified in the recommendation. For example, align paired observations by participant ID, encode ranks in their substantive order, and give matching row and column levels for a paired binary table. The simple independent-group routes assume independent sampling units. Clustered samples, complex surveys and incomplete longitudinal data can require a model tailored to that design.

## الاختبارات · Regression checks

From the repository root, run `Rscript --vanilla tests/test_nistat.R`. The checks exercise the decision paths in both languages, run the R templates on example data and cover console navigation.

The browser guide is built from the same decision tables. After changing the R guide or `students/src/`, run `Rscript students/build.R` with the build-time package `jsonlite`, then `node tests/test_students.mjs`. Use `Rscript students/build.R --check` to check that the standalone `students/index.html` matches its sources.

## License

MIT.
