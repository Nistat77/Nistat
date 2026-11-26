# Source this UTF-8 file to use Nistat(), nistat_recommend(), or nistat_options().
# Rscript Nistat.R [ar|en] starts the guide directly.

.nistat_questions <- local({
  question <- function(key, en, ar, ...) {
    list(key = key, label = c(en = en, ar = ar), choices = list(...))
  }
  choice <- function(to, en, ar) list(to = to, label = c(en = en, ar = ar))

  counts <- choice("table_counts", "Category proportions", "نسب الفئات")
  list(
    goal = question("goal", "What is your research question?", "ما هدف التحليل؟",
      association = choice("variables", "Assess an association", "دراسة علاقة بين متغيرين"),
      comparison = choice("design", "Compare groups, occasions or a reference value", "المقارنة بين مجموعات أو قياسات أو بقيمة مرجعية"),
      prediction = choice("outcome", "Model or predict an outcome", "نمذجة متغير تابع أو التنبؤ به"),
      distribution = choice("diagnostic", "Check a distribution or a model assumption", "فحص توزيع أو أحد افتراضات النموذج")),

    variables = question("variables", "Which two variables are recorded for each independent unit?", "ما نوع المتغيرين المقاسين لكل وحدة مستقلة؟",
      continuous = choice("pattern", "Two quantitative variables", "متغيران كميان"),
      ordinal = choice("spearman", "Ordered scores, with a monotonic relationship of interest", "درجات ترتيبية لدراسة علاقة رتيبة (في اتجاه واحد)"),
      categorical = choice("table_counts", "Two categorical variables", "متغيران فئويان")),
    pattern = question("pattern", "Which pattern do you want to describe?", "ما نمط العلاقة المراد وصفها؟",
      linear = choice("pearson", "Linear", "خطية"),
      monotonic = choice("spearman", "Consistently increasing or decreasing, possibly curved", "متزايدة أو متناقصة في اتجاه واحد وقد تكون منحنية"),
      unknown = choice("scatterplot", "Non-monotonic or still unknown", "يتغير اتجاهها أو لم يتضح نمطها بعد")),
    table_counts = question("expected", "Are expected cell counts adequate for the chi-squared approximation under independence?", "هل التكرارات المتوقعة تحت فرض الاستقلال كافية لتقريب كاي تربيع؟",
      adequate = choice("chisq_independence", "Adequate", "كافية"),
      sparse = choice("fisher_exact", "Sparse", "منخفضة في بعض الخلايا"),
      unknown = choice("inspect_expected", "I need to inspect the expected counts", "أحتاج إلى فحص التكرارات المتوقعة")),

    design = question("design", "How were the observations collected?", "كيف جُمعت المشاهدات؟",
      one_sample = choice("one_target", "One sample against a reference", "عينة واحدة مقارنة بقيمة أو بتوزيع مرجعي"),
      independent_two = choice("two_target", "Two independent groups, one observation per person", "مجموعتان مستقلتان وقياس واحد لكل فرد"),
      paired_two = choice("paired_target", "Two measurements on the same people or matched pairs", "قياسان للأفراد أنفسهم أو لأزواج متطابقة"),
      independent_many = choice("many_target", "Three or more independent groups", "ثلاث مجموعات مستقلة فأكثر"),
      repeated_many = choice("repeated_target", "Three or more occasions on the same people", "ثلاثة قياسات فأكثر للأفراد أنفسهم"),
      pre_post = choice("pre_post_target", "Two independent groups, each measured before and after on a quantitative outcome", "مجموعتان مستقلتان لكل منهما قياس قبلي وبعدي لنتيجة كمية"),
      factorial = choice("factorial_interaction", "Two crossed group factors, testing their interaction on a quantitative outcome", "عاملان فئويان متقاطعان لدراسة تفاعلهما في نتيجة كمية لدى أفراد مستقلين")),
    one_target = question("target", "What do you want to compare with the reference?", "ما الذي تريد مقارنته بالمرجع؟",
      mean = choice("one_sample_t", "A quantitative mean", "متوسط متغير كمي"),
      proportion = choice("one_proportion", "A binary outcome proportion", "نسبة حدوث نتيجة ثنائية"),
      frequencies = choice("gof_counts", "Counts across several categories", "التكرارات عبر فئات متعددة")),
    two_target = question("target", "What differs between the two independent groups?", "ما الذي تريد مقارنته بين المجموعتين المستقلتين؟",
      means = choice("welch_t", "Quantitative means", "متوسطا متغير كمي"),
      ranks = choice("rank_sum", "Ranks or ordered scores", "الرتب أو الدرجات الترتيبية"),
      proportions = counts),
    paired_target = question("target", "What contrast within pairs answers your question?", "ما المقارنة التي تجيب عن سؤالك داخل الأزواج؟",
      means = choice("paired_t", "Mean of the quantitative differences", "متوسط الفروق الكمية"),
      signed_ranks = choice("signed_rank", "Location of symmetric differences with meaningful magnitudes", "موقع توزيع فروق متماثلة ذات مقادير قابلة للتفسير"),
      direction = choice("sign_test", "Direction of change on an ordered scale", "اتجاه التغير على مقياس ترتيبي"),
      binary = choice("mcnemar_exact", "Change in a binary proportion", "التغير في نسبة نتيجة ثنائية")),
    many_target = question("target", "What differs across independent groups?", "ما الذي تريد مقارنته بين المجموعات المستقلة؟",
      means = choice("welch_anova", "Quantitative means", "متوسطات متغير كمي"),
      ranks = choice("kruskal", "Ranks or ordered scores", "الرتب أو الدرجات الترتيبية"),
      proportions = counts),
    repeated_target = question("target", "What do you compare across occasions?", "ما الذي تريد مقارنته عبر القياسات؟",
      means = choice("rm_anova", "Quantitative means in a complete repeated-measures design", "متوسطات متغير كمي في تصميم قياسات متكررة مكتمل"),
      ranks = choice("friedman", "Within-person ranks in a complete design", "الرتب داخل كل فرد في تصميم مكتمل")),
    pre_post_target = question("target", "Which group difference do you want to estimate?", "أي فرق بين المجموعتين تريد تقديره؟",
      adjusted_followup = choice("ancova", "Difference at follow-up adjusted for baseline", "الفرق في القياس البعدي بعد ضبط القياس القبلي"),
      change = choice("change_scores", "Difference in mean change from baseline", "الفرق بين متوسطي التغير من القياس القبلي إلى البعدي")),

    outcome = question("outcome", "What kind of outcome are you predicting for each independent unit?", "ما نوع المتغير التابع المراد التنبؤ به لكل وحدة مستقلة؟",
      continuous = choice("predictors", "Quantitative continuous", "كمي مستمر"),
      binary = choice("binary_logit", "Two categories", "ثنائي الفئة"),
      nominal = choice("multinomial", "Three or more unordered categories", "ثلاث فئات اسمية غير مرتبة فأكثر"),
      ordinal = choice("ordinal_logit", "Three or more ordered categories", "ثلاث فئات مرتبة فأكثر"),
      count = choice("poisson", "A non-negative event count", "عدد مرات وقوع حدث")),
    predictors = question("predictors", "How many predictors enter the model?", "كم متغيرًا تنبؤيًا يتضمن النموذج؟",
      one = choice("linear_simple", "One", "واحد"),
      multiple = choice("linear_multiple", "Two or more", "اثنان فأكثر")),

    diagnostic = question("target", "What would you like to assess?", "ما الذي تريد فحصه؟",
      normality = choice("normal_quantity", "Normality of observations, paired differences or residuals", "اعتدالية المشاهدات أو الفروق الزوجية أو البواقي"),
      variances = choice("variance_shape", "Equality of variances across independent groups", "تساوي التباينات بين مجموعات مستقلة"),
      frequencies = choice("gof_counts", "Category frequencies against specified probabilities", "مطابقة تكرارات الفئات لاحتمالات محددة"),
      continuous_cdf = choice("cdf_parameters", "Fit to a continuous reference distribution", "المطابقة مع توزيع مرجعي مستمر")),
    normal_quantity = question("quantity", "Which values are you checking?", "ما القيم التي ستفحصها؟",
      independent = choice("normality", "Independent observations or independent within-pair differences", "مشاهدات مستقلة أو فروق زوجية مستقلة بعضها عن بعض"),
      residuals = choice("residual_qq", "Residuals from a fitted linear model", "بواقي نموذج خطي مقدّر")),
    variance_shape = question("shape", "How well justified is within-group normality?", "ما مدى وجاهة افتراض الاعتدالية داخل كل مجموعة؟",
      normal = choice("bartlett", "Well justified", "تدعمه طبيعة البيانات"),
      uncertain = choice("fligner", "Uncertain or affected by outliers", "غير مؤكد أو توجد قيم متطرفة")),
    gof_counts = question("expected", "Are expected counts under the specified probabilities sufficiently large?", "هل تكرارات الفئات المتوقعة وفق الاحتمالات المفترضة كبيرة بما يكفي؟",
      adequate = choice("chisq_gof", "Yes", "نعم"),
      sparse = choice("simulated_gof", "Small expected counts", "توجد تكرارات متوقعة منخفضة")),
    cdf_parameters = question("parameters", "How were the reference distribution's parameters obtained?", "كيف حُددت معلمات التوزيع المرجعي؟",
      fixed = choice("ks_fixed", "Specified independently of this sample", "حُددت بصورة مستقلة عن هذه العينة"),
      fitted = choice("fitted_qq", "Estimated from this sample", "قُدّرت من العينة نفسها"))
  )
})

.nistat_methods <- local({
  words <- function(method, rationale, checks, report) {
    list(method = method, rationale = rationale, checks = checks, report = report)
  }
  card <- function(en, ar, code, reference) {
    list(en = en, ar = ar, code = code, reference = reference)
  }
  manual <- function(topic, package = "stats") {
    sprintf("https://stat.ethz.ch/R-manual/R-patched/library/%s/html/%s.html", package, topic)
  }
  list(
    pearson = card(
      words("Pearson correlation", "Estimates the direction and strength of a linear association.",
        "Inspect a scatterplot for curvature and influential points. The usual small-sample test and interval assume independent pairs from a bivariate normal population.",
        "Report r, the number of complete pairs and a confidence interval."),
      words("معامل ارتباط بيرسون", "يقدّر اتجاه العلاقة الخطية وقوتها بين متغيرين كميين.",
        "افحص شكل الانتشار والنقاط المؤثرة. يفترض الاستدلال المعتاد في العينات الصغيرة استقلال الأزواج واعتدالية التوزيع الثنائي.",
        "أبلغ عن معامل الارتباط وعدد الأزواج المكتملة وفترة الثقة."),
      'stats::cor.test(x, y, method = "pearson")', manual("cor.test")),
    spearman = card(
      words("Spearman rank correlation", "Measures whether higher ranks on one variable tend to accompany higher or lower ranks on the other.",
        "Use independent pairs and an interpretable ordering. Inspect the shape and ties. The example uses an approximate p-value.",
        "Report Spearman's rho, the number of pairs and the direction of association."),
      words("معامل ارتباط سبيرمان للرتب", "يقدّر مدى اقتران الرتب الأعلى في متغير برتب أعلى أو أدنى في المتغير الآخر.",
        "تحقق من استقلال الأزواج ومن ترتيب الدرجات، وافحص شكل العلاقة والرتب المتعادلة. يستخدم المثال قيمة احتمالية تقريبية.",
        "أبلغ عن معامل سبيرمان وعدد الأزواج واتجاه العلاقة."),
      'stats::cor.test(x, y, method = "spearman", exact = FALSE)', manual("cor.test")),
    scatterplot = card(
      words("Scatterplot for the form of association", "A curve can rise and fall even when a single correlation is close to zero.",
        "Use one point per independent unit and examine the observed range, clusters and influential points.",
        "Describe the shape and identify which part of the curve answers the research question."),
      words("مخطط الانتشار لفحص شكل العلاقة", "قد ترتفع العلاقة ثم تنخفض رغم اقتراب معامل الارتباط من الصفر.",
        "مثّل كل وحدة مستقلة بنقطة وافحص مدى القيم والتجمعات والنقاط المؤثرة.",
        "صِف شكل العلاقة وحدد الجزء الذي يجيب عن السؤال البحثي."),
      "graphics::plot(x, y)", manual("plot.default", "graphics")),
    inspect_expected = card(
      words("Inspect expected cell counts", "Under independence, each expected count is its row total times its column total divided by the sample size.",
        "Use a two-way frequency table of independent observations with positive margins.",
        "A common guide is at least five expected in every cell of a 2 by 2 table. For larger tables, look for all expected counts at least one and at least 80% of them at least five."),
      words("فحص التكرارات المتوقعة في الخلايا", "تحت فرض الاستقلال يساوي التكرار المتوقع حاصل ضرب مجموع الصف في مجموع العمود مقسومًا على حجم العينة.",
        "استخدم جدول تكرارات ثنائي المدخل لمشاهدات مستقلة بمجاميع صفوف وأعمدة موجبة.",
        "من القواعد الشائعة أن يبلغ التكرار المتوقع خمسة في كل خلية في جدول ٢ × ٢. في الجداول الأكبر افحص بلوغه واحدًا في كل خلية وخمسة في ٨٠٪ من الخلايا على الأقل."),
      "outer(rowSums(tab), colSums(tab)) / sum(tab)", manual("fisher.test")),
    chisq_independence = card(
      words("Pearson chi-squared test of independence", "Compares observed cell counts with counts expected if the two categorical variables were independent.",
        "Each independent unit contributes to one cell. Enter the original frequencies and check the expected counts.",
        "Report the table, row or column percentages, chi-squared statistic, degrees of freedom and p-value."),
      words("اختبار كاي تربيع للاستقلال", "يقارن تكرارات الخلايا المشاهدة بالتكرارات المتوقعة عند استقلال المتغيرين الفئويين.",
        "تسهم كل وحدة مستقلة في خلية واحدة. أدخل التكرارات الأصلية وافحص التكرارات المتوقعة.",
        "اعرض الجدول والنسب الصفية أو العمودية وقيمة كاي تربيع ودرجات الحرية والقيمة الاحتمالية."),
      "stats::chisq.test(tab, correct = FALSE)", manual("chisq.test")),
    fisher_exact = card(
      words("Fisher's exact test", "Tests association in an independent count table by conditioning on its margins.",
        "Use individual counts with independent units. Exact calculations can be costly for large tables with many categories.",
        "Give the cell counts and exact p-value. For a 2 by 2 table, also report the odds ratio and interval with the category order."),
      words("اختبار فيشر الدقيق", "يفحص العلاقة في جدول تكراري لمشاهدات مستقلة مع تثبيت المجاميع الهامشية.",
        "أدخل التكرارات لوحدات مستقلة. قد يتطلب الحساب الدقيق وقتًا طويلًا في الجداول الكبيرة متعددة الفئات.",
        "اعرض التكرارات والقيمة الاحتمالية الدقيقة. في جدول ٢ × ٢ أضف نسبة الأرجحية وفترة الثقة وترتيب الفئات."),
      "stats::fisher.test(tab)", manual("fisher.test")),

    one_sample_t = card(
      words("One-sample t-test", "Estimates the difference between a quantitative mean and a prespecified benchmark.",
        "Use independent observations and justify mean-based inference given the sample size, skew and outliers.",
        "State the benchmark, mean difference, confidence interval, t statistic and degrees of freedom."),
      words("اختبار ت لعينة واحدة", "يقدّر الفرق بين متوسط متغير كمي وقيمة مرجعية محددة مسبقًا.",
        "تحقق من استقلال المشاهدات وملاءمة الاستدلال على المتوسط في ضوء حجم العينة والالتواء والقيم المتطرفة.",
        "اذكر القيمة المرجعية وفرق المتوسط وفترة ثقته وإحصاء ت ودرجات الحرية."),
      "stats::t.test(x, mu = reference_value)", manual("t.test")),
    one_proportion = card(
      words("Exact binomial test for one proportion", "Compares the chance of a binary event with a specified probability.",
        "Supply the number of events and independent trials with the same event probability under the null.",
        "Report events, trials, estimated proportion, confidence interval and the reference probability."),
      words("اختبار ثنائي الحدين الدقيق لنسبة واحدة", "يقارن احتمال حدوث نتيجة ثنائية باحتمال مرجعي محدد.",
        "أدخل عدد مرات وقوع الحدث وعدد المحاولات المستقلة التي تشترك في احتمال الحدث تحت الفرض الصفري.",
        "أبلغ عن العدد والإجمالي والنسبة المقدرة وفترة الثقة والاحتمال المرجعي."),
      "stats::binom.test(events, trials, p = p0)", manual("binom.test")),
    welch_t = card(
      words("Welch two-sample t-test", "Estimates a difference between independent means while allowing unequal variances.",
        "Use a quantitative outcome and one observation per independent unit. Check skew and influential observations, especially in small groups.",
        "Report both means, their difference in a stated order, the 95% interval and Welch degrees of freedom."),
      words("اختبار ت لويلش لعينتين مستقلتين", "يقدّر الفرق بين متوسطي مجموعتين مستقلتين ويسمح باختلاف تباينيهما.",
        "استخدم نتيجة كمية وقياسًا واحدًا لكل وحدة مستقلة. افحص الالتواء والمشاهدات المؤثرة، خصوصًا في المجموعات الصغيرة.",
        "اعرض المتوسطين والفرق بترتيب محدد وفترة الثقة ٩٥٪ ودرجات حرية ويلش."),
      "stats::t.test(score ~ group, data = dat, var.equal = FALSE)", manual("t.test")),
    paired_t = card(
      words("Paired t-test", "Estimates the mean within-pair difference and preserves the matching.",
        "Align values by participant or pair ID. Assess the distribution of the differences and independence across pairs.",
        "Report complete pairs, the mean after-minus-before difference and its 95% confidence interval."),
      words("اختبار ت للعينات المرتبطة", "يقدّر متوسط الفروق داخل الأزواج مع مراعاة الارتباط بين القياسين.",
        "طابق القيم بمعرّف الفرد أو الزوج. افحص توزيع الفروق واستقلال الأزواج عن بعضها.",
        "أبلغ عن عدد الأزواج المكتملة ومتوسط الفرق (البعدي ناقص القبلي) وفترة ثقته ٩٥٪."),
      "stats::t.test(after, before, paired = TRUE)", manual("t.test")),
    rank_sum = card(
      words("Mann–Whitney U / Wilcoxon rank-sum test", "Compares ranks between two independent groups.",
        "Use ordered scores with the same coding in both groups. Interpreting the result as a location shift needs comparably shaped distributions.",
        "Report group distributions, sample sizes, the rank-sum statistic and how the p-value was calculated."),
      words("اختبار مان–ويتني للرتب", "يقارن رتب الدرجات بين مجموعتين مستقلتين.",
        "استخدم درجات مرتبة بترميز موحد في المجموعتين. يتطلب تفسير النتيجة بوصفها إزاحة في الموقع تشابه شكلي التوزيعين.",
        "اعرض توزيعي المجموعتين وحجميهما وإحصاء الرتب وطريقة حساب القيمة الاحتمالية."),
      "stats::wilcox.test(score ~ group, data = dat)", manual("wilcox.test")),
    signed_rank = card(
      words("Wilcoxon signed-rank test", "Uses the signs and ranks of absolute within-pair differences to assess their location.",
        "Differences must have meaningful magnitudes and a plausibly symmetric distribution. Match observations by ID.",
        "Report complete pairs, direction, and the estimated location shift and interval when estimable."),
      words("اختبار ويلكوكسون للرتب الموقعة", "يستخدم إشارات الفروق داخل الأزواج ورتب مقاديرها المطلقة لفحص موقع التوزيع.",
        "ينبغي أن يكون لمقادير الفروق معنى وأن يكون توزيعها متماثلًا بصورة معقولة. طابق القياسات بالمعرّف.",
        "أبلغ عن عدد الأزواج المكتملة واتجاه الفرق وتقدير إزاحة الموقع وفترة الثقة عند إمكان تقديرها."),
      "stats::wilcox.test(after, before, paired = TRUE, conf.int = TRUE)", manual("wilcox.test")),
    sign_test = card(
      words("Paired sign test", "Compares the chances of moving up and down among pairs that changed. Only the ordering is required.",
        "Align complete pairs and use the same ordering at both occasions. Exclude ties from the binomial denominator and record them separately.",
        "Report increases, decreases and ties, and the proportion increasing among changed pairs."),
      words("اختبار الإشارة للأزواج", "يقارن احتمال الارتفاع باحتمال الانخفاض بين الأزواج التي تغيرت، اعتمادًا على ترتيب الفئات.",
        "طابق الأزواج المكتملة ووحّد ترتيب الفئات في القياسين. استبعد التعادلات من مقام الاختبار وسجّل عددها منفصلًا.",
        "اعرض أعداد الارتفاع والانخفاض والتعادل ونسبة الارتفاع بين الأزواج التي تغيرت."),
      paste("up <- sum(after > before, na.rm = TRUE)", "down <- sum(after < before, na.rm = TRUE)",
        'if (up + down > 0) stats::binom.test(up, up + down, p = 0.5) else message("No changed pairs")', sep = "\n"),
      "https://www.itl.nist.gov/div898/software/dataplot/refman1/auxillar/signtest.htm"),
    mcnemar_exact = card(
      words("Exact McNemar test for paired binary outcomes", "Conditions on discordant pairs to compare the two directions of change.",
        "Use a 2 by 2 table with before as rows and after as columns, with the same two levels in the same order. Each independent pair contributes once.",
        "Report both discordant cell counts, the paired proportions and the exact p-value. The template's interval describes the direction of change among discordant pairs."),
      words("اختبار ماكنيمار الدقيق لنتيجة ثنائية مرتبطة", "يقارن اتجاهي التغير بالاعتماد على الأزواج التي اختلفت نتيجتها بين القياسين.",
        "اجعل الصفوف للقياس القبلي والأعمدة للبعدي في جدول ٢ × ٢، بنفس الفئتين والترتيب. يسهم كل زوج مستقل مرة واحدة.",
        "اعرض تكراري الخليتين خارج القطر والنسبتين المرتبطتين والقيمة الاحتمالية الدقيقة. تخص فترة الثقة في القالب اتجاه التغير بين الأزواج التي تغيرت."),
      paste("first_to_second <- tab[1, 2]", "changed <- first_to_second + tab[2, 1]",
        'if (changed > 0) stats::binom.test(first_to_second, changed, p = 0.5) else message("No discordant pairs")', sep = "\n"),
      "https://journal.r-project.org/articles/RJ-2010-008/"),
    welch_anova = card(
      words("Welch one-way ANOVA", "Tests equality of independent group means while allowing unequal variances.",
        "Check independent units, within-group distributions, outliers and enough observations to estimate each variance.",
        "Report group means, Welch F, degrees of freedom and p-value. Identify any planned or multiplicity-adjusted contrasts."),
      words("تحليل التباين الأحادي بطريقة ويلش", "يفحص تساوي متوسطات المجموعات المستقلة مع السماح باختلاف التباينات.",
        "تحقق من استقلال الوحدات وتوزيع كل مجموعة والقيم المتطرفة وكفاية المشاهدات لتقدير تباين كل مجموعة.",
        "اعرض متوسطات المجموعات وإحصاء ف لويلش ودرجات الحرية والقيمة الاحتمالية والمقارنات المخططة أو المصححة للتعدد."),
      "stats::oneway.test(score ~ group, data = dat, var.equal = FALSE)", manual("oneway.test")),
    kruskal = card(
      words("Kruskal–Wallis rank-sum test", "Compares the distributions of ordered scores across independent groups using pooled ranks.",
        "Observations must be independent. A median-shift interpretation requires similarly shaped distributions.",
        "Summarize each distribution and report the omnibus statistic and degrees of freedom."),
      words("اختبار كروسكال–واليس للرتب", "يقارن توزيعات الدرجات المرتبة بين مجموعات مستقلة باستخدام الرتب المجمعة.",
        "تحقق من استقلال المشاهدات. يتطلب تفسير النتيجة بوصفها اختلافًا في الوسيط تشابه أشكال التوزيعات.",
        "لخّص توزيع كل مجموعة وأبلغ عن إحصاء الاختبار الكلي ودرجات الحرية."),
      "stats::kruskal.test(score ~ group, data = dat)", manual("kruskal.test")),
    rm_anova = card(
      words("One-way repeated-measures ANOVA", "Tests mean differences across occasions while accounting for each person's repeated observations.",
        "Use one complete observation per person and occasion. Code id and condition as factors. Assess residuals and sphericity for the uncorrected F test.",
        "Report occasion means, the within-person F test and any sphericity correction. Incomplete profiles may call for a mixed model."),
      words("تحليل التباين الأحادي للقياسات المتكررة", "يفحص اختلاف المتوسطات بين المناسبات مع مراعاة تكرار القياس داخل الفرد.",
        "استخدم قياسًا واحدًا مكتملًا لكل فرد ومناسبة، ورمّز المعرّف والمناسبة كعاملين. افحص البواقي وافتراض الكروية لاختبار ف غير المصحح.",
        "اعرض متوسطات المناسبات واختبار ف داخل الأفراد وأي تصحيح للكروية. قد تلائم النماذج المختلطة الملفات غير المكتملة."),
      "summary(stats::aov(score ~ condition + Error(id/condition), data = dat))", manual("aov")),
    friedman = card(
      words("Friedman test", "Compares occasions by ranking responses within each person or matched block.",
        "Use a complete block design with one observation per person and occasion, independent blocks, and factor codes for id and condition.",
        "Report the number of complete blocks, occasion summaries, the Friedman statistic and degrees of freedom."),
      words("اختبار فريدمان", "يقارن المناسبات بترتيب الاستجابات داخل كل فرد أو كتلة متطابقة.",
        "استخدم تصميم كتل مكتملة بقياس واحد لكل فرد ومناسبة وكتل مستقلة، مع ترميز المعرّف والمناسبة كعاملين.",
        "أبلغ عن عدد الكتل المكتملة وملخص كل مناسبة وإحصاء فريدمان ودرجات الحرية."),
      "stats::friedman.test(score ~ condition | id, data = dat)", manual("friedman.test")),
    ancova = card(
      words("Baseline-adjusted comparison (ANCOVA)", "Estimates the between-group difference at follow-up conditional on a common baseline score.",
        "Use one row per independent participant and a group factor. Check the baseline–follow-up relationship, common slopes and residuals. Nonrandom assignment can leave confounding.",
        "Report the adjusted group contrast, reference group and 95% interval, and describe how missing outcomes were handled."),
      words("المقارنة البعدية المضبوطة بالقياس القبلي (تحليل التغاير)", "تقدّر الفرق البعدي بين المجموعتين عند قيمة قبلية مشتركة.",
        "استخدم صفًا لكل مشارك مستقل وعرّف المجموعة كعامل. افحص علاقة القبلي بالبعدي وتجانس ميول الانحدار والبواقي. قد تبقى عوامل مربكة عند غياب التخصيص العشوائي.",
        "اعرض فرق المجموعتين المعدّل والمجموعة المرجعية وفترة الثقة ٩٥٪ وطريقة التعامل مع القياسات المفقودة."),
      paste("fit <- stats::lm(post ~ pre + group, data = dat)", "summary(fit)", "stats::confint(fit)", sep = "\n"),
      "https://pmc.ncbi.nlm.nih.gov/articles/PMC1121605/"),
    change_scores = card(
      words("Welch comparison of individual change scores", "Estimates the difference between groups in mean after-minus-before change.",
        "Use aligned pre/post measurements in one row per participant, independent groups and a quantitative scale. Check change-score distributions and missing pairs.",
        "Report mean change in each group and the between-group difference in change with its 95% interval."),
      words("اختبار ويلش للمقارنة بين متوسطي التغير", "يقدّر الفرق بين المجموعتين في متوسط التغير من القياس القبلي إلى البعدي.",
        "اجمع القياسين لكل مشارك في صف واحد، مع مجموعتين مستقلتين ومقياس كمي. افحص توزيعات التغير والأزواج الناقصة.",
        "اعرض متوسط التغير في كل مجموعة والفرق بين متوسطي التغير وفترة الثقة ٩٥٪."),
      "stats::t.test(I(post - pre) ~ group, data = dat, var.equal = FALSE)", manual("t.test")),
    factorial_interaction = card(
      words("Two-way factorial ANOVA for an interaction", "Tests whether the mean contrast for one factor varies across levels of the other.",
        "Use independent observations, two crossed factors with observations in each cell and residual variation. Check residual spread and shape.",
        "Report the interaction F test and cell means. Use estimated contrasts and intervals to describe the interaction."),
      words("تحليل التباين الثنائي لاختبار التفاعل", "يختبر ما إذا كان فرق المتوسطات المرتبط بأحد العاملين يتغير عبر مستويات العامل الآخر.",
        "استخدم مشاهدات مستقلة وعاملين متقاطعين وخلايا ممثلة وتباينًا متبقيًا. افحص تشتت البواقي وشكلها.",
        "اعرض اختبار ف للتفاعل ومتوسطات الخلايا. صِف التفاعل بمقارنات مقدّرة وفترات ثقة."),
      paste("additive <- stats::lm(score ~ factor_a + factor_b, data = dat)",
        "full <- stats::update(additive, . ~ . + factor_a:factor_b)",
        "stats::anova(additive, full)", sep = "\n"), manual("anova.lm")),

    linear_simple = card(
      words("Simple linear regression", "Models a continuous outcome using one predictor.",
        "Check the proposed functional form, independent errors, influential points and the residual spread used for inference.",
        "Report the coefficient and interval. For prediction, assess error on observations held out from fitting."),
      words("الانحدار الخطي البسيط", "ينمذج نتيجة مستمرة باستخدام متغير تنبؤي واحد.",
        "افحص الشكل الدالي المقترح واستقلال الأخطاء والنقاط المؤثرة وتشتت البواقي المستخدم في الاستدلال.",
        "أبلغ عن المعامل وفترة الثقة. ولغرض التنبؤ قيّم الخطأ على مشاهدات محجوبة عن بناء النموذج."),
      "stats::lm(y ~ x, data = dat)", manual("lm")),
    linear_multiple = card(
      words("Multiple linear regression", "Models a continuous outcome conditional on several predictors.",
        "Check functional form, residuals, independence, influential observations and collinearity. Choose predictors with the sample size in mind.",
        "Report adjusted coefficients and intervals. For prediction, report out-of-sample error."),
      words("الانحدار الخطي المتعدد", "ينمذج نتيجة مستمرة في ضوء عدة متغيرات تنبؤية معًا.",
        "افحص الشكل الدالي والبواقي والاستقلال والمشاهدات المؤثرة وتعدد الارتباط الخطي. راعِ حجم العينة عند اختيار المتغيرات.",
        "أبلغ عن المعاملات المعدلة وفترات الثقة، وعند التنبؤ اعرض الخطأ خارج عينة بناء النموذج."),
      "stats::lm(y ~ x1 + x2, data = dat)", manual("lm")),
    binary_logit = card(
      words("Binary logistic regression", "Models the log odds of a specified event and yields predicted event probabilities.",
        "Code the event explicitly as 1 and its alternative as 0. Check independence, sparse outcomes, separation and the functional form of continuous predictors.",
        "Report the event definition, odds ratios and intervals. Assess calibration and discrimination on validation data."),
      words("الانحدار اللوجستي الثنائي", "ينمذج لوغاريتم أرجحية حدث محدد ويتيح تقدير احتمال وقوعه.",
        "رمّز الحدث بالواحد والبديل بالصفر. افحص الاستقلال وندرة الأحداث والانفصال والشكل الدالي للمتغيرات الكمية.",
        "حدّد الحدث واعرض نسب الأرجحية وفترات الثقة. قيّم المعايرة والقدرة التمييزية في بيانات التحقق."),
      "stats::glm(y ~ x, data = dat, family = stats::binomial())", manual("glm")),
    multinomial = card(
      words("Multinomial logistic regression", "Models membership probabilities for unordered outcome categories using a reference category.",
        "Use a factor outcome and choose its reference level. Check category counts, independence and the model's independence-of-irrelevant-alternatives assumption. The template uses nnet.",
        "Name the reference category and report predicted probabilities and validation performance across categories."),
      words("الانحدار اللوجستي متعدد الفئات الاسمية", "ينمذج احتمالات الانتماء لفئات غير مرتبة بالاستعانة بفئة مرجعية.",
        "عرّف النتيجة كعامل وحدد فئته المرجعية. افحص أعداد الفئات واستقلال المشاهدات وافتراض استقلال البدائل غير ذات الصلة. يستخدم المثال حزمة nnet.",
        "سمِّ الفئة المرجعية واعرض الاحتمالات المتوقعة والأداء في بيانات التحقق عبر الفئات."),
      "nnet::multinom(y ~ x, data = dat, trace = FALSE)", manual("multinom", "nnet")),
    ordinal_logit = card(
      words("Proportional-odds ordinal logistic regression", "Uses the ordering of the response categories to model cumulative odds.",
        "Set y to an ordered factor in the substantive order. Check category counts and whether proportional odds is tenable. The template uses MASS.",
        "Report the category order, common odds ratios with intervals and validation of predicted probabilities."),
      words("الانحدار اللوجستي الترتيبي بافتراض تناسب الأرجحيات", "يستفيد من ترتيب فئات النتيجة لنمذجة الأرجحيات التراكمية.",
        "عرّف المتغير التابع كعامل مرتب حسب معناه وافحص تكرارات الفئات وملاءمة افتراض تناسب الأرجحيات. يستخدم المثال حزمة MASS.",
        "اعرض ترتيب الفئات ونسب الأرجحية المشتركة وفترات الثقة وتقييم الاحتمالات المتوقعة في بيانات التحقق."),
      "MASS::polr(y ~ x, data = dat, Hess = TRUE)", manual("polr", "MASS")),
    poisson = card(
      words("Poisson regression for counts", "Models the expected number of events for each independent unit.",
        "Use non-negative integer counts. Assess conditional dispersion and excess zeros. When exposure varies, include a log-exposure offset for a rate model.",
        "State the exposure unit, report count or rate ratios with intervals, and assess held-out predictions."),
      words("انحدار بواسون للبيانات العددية الحدثية", "ينمذج العدد المتوقع لمرات وقوع الحدث لكل وحدة مستقلة.",
        "استخدم أعدادًا صحيحة غير سالبة. افحص التشتت الشرطي وكثرة الأصفار، وأضف لوغاريتم التعرض كحد إزاحة عند اختلاف مدد التعرض لنمذجة المعدل.",
        "حدد وحدة التعرض واعرض نسب الأعداد أو المعدلات وفترات الثقة، وقيّم التنبؤ على بيانات محجوبة."),
      "stats::glm(y ~ x, data = dat, family = stats::poisson())", manual("family")),

    normality = card(
      words("Normal Q–Q plot and Shapiro–Wilk test", "A Q–Q plot shows where a distribution departs from normality. Shapiro–Wilk offers a formal test for an independent sample.",
        "Use independent values, such as aligned differences from independent pairs. In R the test needs 3–5,000 nonmissing values and nonzero variation.",
        "Describe any tail departures or outliers, the sample size, and W and p if a formal test is appropriate."),
      words("مخطط كمي–كمي طبيعي واختبار شابيرو–ويلك", "يُظهر المخطط مواضع الابتعاد عن الاعتدالية، ويتيح شابيرو–ويلك اختبارًا استدلاليًا لعينة مستقلة.",
        "استخدم قيمًا مستقلة مثل الفروق داخل أزواج مستقلة. يشترط الاختبار في R من ٣ إلى ٥٠٠٠ قيمة صالحة ذات تباين موجب.",
        "صِف الانحرافات في الأطراف والقيم المتطرفة وحجم العينة، وأبلغ عن W والقيمة الاحتمالية عند ملاءمة الاختبار."),
      paste("v <- x[is.finite(x)]", "if (length(v) >= 2L) {", "  stats::qqnorm(v)", "  stats::qqline(v)", "}",
        "if (length(v) >= 3L && length(v) <= 5000L && diff(range(v)) > 0) stats::shapiro.test(v)", sep = "\n"),
      manual("shapiro.test")),
    residual_qq = card(
      words("Normal Q–Q plot of standardized model residuals", "Shows departures of the fitted linear model's standardized residuals from a normal reference.",
        "Supply a fitted linear model. Examine residuals versus fitted values alongside the Q–Q plot for changing spread or curvature.",
        "Describe systematic tail departures and influential cases in the context of the fitted model."),
      words("مخطط كمي–كمي طبيعي لبواقي النموذج المعيارية", "يوضح مواضع ابتعاد البواقي المعيارية للنموذج الخطي عن المرجع الطبيعي.",
        "استخدم نموذجًا خطيًا مقدّرًا. افحص أيضًا البواقي مقابل القيم المقدّرة للتحقق من تغير التشتت أو وجود انحناء.",
        "صِف الانحرافات المنتظمة في الأطراف والحالات المؤثرة في سياق النموذج."),
      "graphics::plot(fit, which = 2)", manual("plot.lm")),
    bartlett = card(
      words("Bartlett test of equal variances", "Tests whether independent, normally distributed groups share a variance.",
        "Check within-group normality and independence. The test is sensitive to departures from normality.",
        "Report each group's spread along with the statistic, degrees of freedom and p-value."),
      words("اختبار بارتليت لتساوي التباينات", "يفحص تساوي التباينات في مجموعات مستقلة تتبع توزيعات طبيعية.",
        "افحص الاعتدالية داخل كل مجموعة واستقلال المشاهدات. يتأثر الاختبار بالابتعاد عن الاعتدالية.",
        "اعرض تشتت كل مجموعة وقيمة الإحصاء ودرجات الحرية والقيمة الاحتمالية."),
      "stats::bartlett.test(score ~ group, data = dat)", manual("bartlett.test")),
    fligner = card(
      words("Fligner–Killeen test of equal variances", "Uses ranks of absolute deviations from group medians and is robust to many departures from normality.",
        "Use independent groups and inspect their distributions and outliers.",
        "Report group spreads together with the test statistic, degrees of freedom and p-value."),
      words("اختبار فلينر–كيلين لتساوي التباينات", "يعتمد على رتب الانحرافات المطلقة عن وسائط المجموعات ويتسم بالمتانة أمام صور عديدة من الابتعاد عن الاعتدالية.",
        "استخدم مجموعات مستقلة وافحص توزيعاتها والقيم المتطرفة.",
        "اعرض تشتت كل مجموعة مع قيمة إحصاء الاختبار ودرجات الحرية والقيمة الاحتمالية."),
      "stats::fligner.test(score ~ group, data = dat)", manual("fligner.test")),
    chisq_gof = card(
      words("Chi-squared goodness-of-fit test", "Compares category counts with the expected counts implied by prespecified probabilities.",
        "Use independent observations, mutually exclusive categories and positive null probabilities in the same order as the counts, summing to one. Inspect sum(counts) * p.",
        "Report the stated probabilities, observed and expected counts, statistic and degrees of freedom."),
      words("اختبار كاي تربيع لجودة المطابقة", "يقارن تكرارات الفئات بالتكرارات المتوقعة وفق احتمالات محددة مسبقًا.",
        "استخدم مشاهدات مستقلة وفئات متنافية واحتمالات موجبة مرتبة كالتكرارات ومجموعها واحد. افحص حاصل ضرب الإجمالي في احتمال كل فئة.",
        "اعرض الاحتمالات المفترضة والتكرارات المشاهدة والمتوقعة وقيمة الإحصاء ودرجات الحرية."),
      "stats::chisq.test(counts, p = p)", manual("chisq.test")),
    simulated_gof = card(
      words("Monte Carlo chi-squared goodness-of-fit test", "Simulates category counts under the stated probabilities to calibrate the goodness-of-fit statistic.",
        "Use independent cases and fixed, positive null probabilities in the category order. Choose enough simulations for the needed p-value precision.",
        "Report counts, null probabilities, the simulation count, seed and Monte Carlo p-value."),
      words("اختبار جودة المطابقة بمحاكاة مونت كارلو", "يحاكي تكرارات الفئات وفق الاحتمالات المفترضة لمعايرة إحصاء جودة المطابقة.",
        "استخدم حالات مستقلة واحتمالات موجبة محددة مسبقًا بترتيب الفئات. اختر عدد محاكاة يتناسب مع دقة القيمة الاحتمالية المطلوبة.",
        "اعرض التكرارات والاحتمالات المفترضة وعدد المحاكاة والبذرة العشوائية والقيمة الاحتمالية بالمحاكاة."),
      "set.seed(1)\nstats::chisq.test(counts, p = p, simulate.p.value = TRUE, B = 9999)", manual("chisq.test")),
    ks_fixed = card(
      words("One-sample Kolmogorov–Smirnov test", "Compares an empirical distribution to a fully specified continuous reference distribution.",
        "Use independent observations and account for ties from rounding. Replace the example normal CDF and its parameters with your prespecified reference.",
        "State the reference distribution and its parameter values, sample size, D and p-value."),
      words("اختبار كولموغوروف–سميرنوف لعينة واحدة", "يقارن التوزيع التجريبي بتوزيع مرجعي مستمر محدد المعلمات مسبقًا.",
        "استخدم مشاهدات مستقلة وانتبه لأثر تعادل القيم الناتج عن التقريب. استبدل دالة التوزيع الطبيعي ومعلماتها في المثال بما يوافق مرجعك المحدد مسبقًا.",
        "حدّد التوزيع المرجعي وقيم معلماته وحجم العينة وإحصاء D والقيمة الاحتمالية."),
      'stats::ks.test(x, "pnorm", mean = mu0, sd = sigma0)', manual("ks.test")),
    fitted_qq = card(
      words("Q–Q plot against the fitted distribution", "Estimating parameters on the same observations changes the null distribution of the usual one-sample KS statistic.",
        "Set q_fitted to the quantile function with the fitted parameters. A formal bootstrap test requires simulating from the fitted family and refitting in each replicate.",
        "Describe departures from the reference line and state how the parameters were estimated."),
      words("مخطط كمي–كمي مقابل التوزيع المقدّر", "يغيّر تقدير المعلمات من المشاهدات نفسها التوزيع الصفري المعتاد لإحصاء كولموغوروف–سميرنوف لعينة واحدة.",
        "عرّف q_fitted كدالة الكميات بالمعلمات المقدّرة. إذا استخدمت اختبار بوتستراب معلميًا فحاكِ التوزيع الملائم وأعد تقدير المعلمات في كل تكرار.",
        "صِف الابتعاد عن الخط المرجعي وحدد طريقة تقدير المعلمات."),
      paste("v <- x[is.finite(x)]", "stats::qqplot(q_fitted(stats::ppoints(length(v))), v)",
        "graphics::abline(0, 1)", sep = "\n"), manual("ks.test"))
  )
})

.nistat_ui <- list(
  en = list(welcome = "Nistat | Statistical method guide", method = "Recommended approach",
    rationale = "Why it fits", checks = "Check before use", report = "What to report",
    code = "R template (adapt the names to your data)", reference = "Reference",
    restart = "What would you like to do?", another = "Start another question", finish = "Finish",
    navigate = "0 or q to finish", back = "b to go back", invalid = "Please enter one of the displayed choices.",
    bye = "Session finished.", named = "Use unique, named study-design arguments.",
    unused = "These arguments do not apply here: %s", needed = "Choose '%s' (%s).",
    bad = "Invalid value for '%s'. Choose one of: %s"),
  ar = list(welcome = "نيستات | دليل اختيار الأسلوب الإحصائي", method = "الأسلوب المقترح",
    rationale = "لماذا يلائم السؤال؟", checks = "ما الذي يُفحص قبل الاستخدام؟", report = "ما الذي يُذكر في التقرير؟",
    code = "قالب R (عدّل الأسماء لتوافق بياناتك)", reference = "المرجع",
    restart = "ماذا تريد أن تفعل الآن؟", another = "البدء بسؤال آخر", finish = "إنهاء الجلسة",
    navigate = "للإنهاء أدخل ٠ أو q", back = "للرجوع أدخل b أو رجوع", invalid = "أدخل أحد الخيارات المعروضة.",
    bye = "انتهت الجلسة.", named = "استخدم اسمًا فريدًا لكل وسيط يصف تصميم الدراسة.",
    unused = "هذه الوسائط لا تنطبق على المسار الحالي: %s", needed = "اختر قيمة للوسيط '%s' (%s).",
    bad = "قيمة غير صالحة للوسيط '%s'. القيم المتاحة: %s")
)

.nistat_language <- function(language) {
  if (!is.character(language) || length(language) != 1L || !language %in% names(.nistat_ui)) {
    stop("Choose language = 'ar' or 'en'. اختر 'ar' أو 'en'.", call. = FALSE)
  }
  language
}

# Follow only applicable questions. A terminal node is a recommendation ID.
.nistat_walk <- function(answers, language) {
  ui <- .nistat_ui[[language]]
  keys <- names(answers)
  if (length(answers) && (is.null(keys) || anyNA(keys) || any(!nzchar(keys)) || anyDuplicated(keys))) {
    stop(ui$named, call. = FALSE)
  }
  used <- character()
  node <- "goal"
  repeat {
    question <- .nistat_questions[[node]]
    if (is.null(question) || !question$key %in% keys) break
    key <- question$key
    value <- answers[[key]]
    choices <- question$choices
    if (!is.character(value) || length(value) != 1L || !value %in% names(choices)) {
      stop(sprintf(ui$bad, key, paste(names(choices), collapse = ", ")), call. = FALSE)
    }
    node <- choices[[value]]$to
    used <- c(used, key)
  }
  unused <- setdiff(keys, used)
  if (length(unused)) stop(sprintf(ui$unused, paste(unused, collapse = ", ")), call. = FALSE)
  list(node = node, answers = answers[used])
}

.nistat_question_view <- function(question, language) {
  list(key = question$key, question = question$label[[language]],
    choices = vapply(question$choices, function(option) option$label[[language]], character(1)))
}

# Discover valid machine-readable answer codes at any point. NULL means complete.
nistat_options <- function(..., language = "ar") {
  language <- .nistat_language(language)
  step <- .nistat_walk(list(...), language)
  question <- .nistat_questions[[step$node]]
  if (is.null(question)) return(NULL)
  .nistat_question_view(question, language)
}

.nistat_result <- function(step, language) {
  entry <- .nistat_methods[[step$node]]
  structure(c(list(id = step$node, language = language), entry[[language]],
    list(code = entry$code, reference = entry$reference, answers = step$answers)),
    class = "nistat_recommendation")
}

# Return a recommendation without prompting or accessing the user's data.
nistat_recommend <- function(goal, ..., language = "ar") {
  language <- .nistat_language(language)
  step <- .nistat_walk(list(goal = goal, ...), language)
  question <- .nistat_questions[[step$node]]
  if (!is.null(question)) {
    stop(sprintf(.nistat_ui[[language]]$needed, question$key,
      paste(names(question$choices), collapse = ", ")), call. = FALSE)
  }
  .nistat_result(step, language)
}

print.nistat_recommendation <- function(x, ...) {
  ui <- .nistat_ui[[x$language]]
  for (field in c("method", "rationale", "checks", "report", "code", "reference")) {
    cat("\n", ui[[field]], "\n", x[[field]], "\n", sep = "")
  }
  invisible(x)
}

.nistat_pick <- function(title, choices, ui, read_input, allow_back) {
  cat("\n", title, "\n", sep = "")
  cat(paste(seq_along(choices), unname(choices), sep = "  "), sep = "\n")
  cat(paste(c(ui$navigate, if (allow_back) ui$back), collapse = " | "), "\n", sep = "")
  repeat {
    cat("> ")
    flush.console()
    line <- read_input()
    if (!length(line)) return("quit")
    token <- tolower(trimws(chartr("٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹", "01234567890123456789", line)))
    if (token %in% c("0", "q", "خروج")) return("quit")
    if (allow_back && token %in% c("b", "رجوع")) return("back")
    index <- match(token, as.character(seq_along(choices)))
    if (!is.na(index)) return(names(choices)[index])
    cat(ui$invalid, "\n", sep = "")
  }
}

.nistat_session <- function(language, read_input) {
  ui <- .nistat_ui[[language]]
  cat(ui$welcome, "\n", sep = "")
  answers <- list()
  last <- NULL
  repeat {
    step <- .nistat_walk(answers, language)
    question <- .nistat_questions[[step$node]]
    if (is.null(question)) {
      last <- .nistat_result(step, language)
      print(last)
      action <- .nistat_pick(ui$restart, c(another = ui$another, quit = ui$finish), ui, read_input, TRUE)
    } else {
      view <- .nistat_question_view(question, language)
      action <- .nistat_pick(view$question, view$choices, ui, read_input, length(answers) > 0L)
    }
    if (action == "quit") break
    if (action == "back") {
      answers <- answers[-length(answers)]
    } else if (is.null(question)) {
      answers <- list()
    } else {
      answers[[question$key]] <- action
    }
  }
  cat(ui$bye, "\n", sep = "")
  invisible(last)
}

# Arabic is the default for the original Nistat() entry point.
Nistat <- function(language = "ar") {
  language <- .nistat_language(language)
  if (interactive()) return(invisible(.nistat_session(language, function() readline())))
  input <- file("stdin", open = "r", encoding = "UTF-8")
  on.exit(close(input))
  invisible(.nistat_session(language, function() readLines(input, n = 1L, warn = FALSE)))
}

if (sys.nframe() == 0L && !interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) == 1L && args %in% c("-h", "--help")) {
    cat("Rscript Nistat.R [ar|en]\n")
  } else if (length(args) > 1L || (length(args) == 1L && !args %in% c("ar", "en"))) {
    cat("Usage: Rscript Nistat.R [ar|en]\n", file = stderr())
    quit(status = 2L)
  } else {
    Nistat(if (length(args)) args[[1L]] else "ar")
  }
}
