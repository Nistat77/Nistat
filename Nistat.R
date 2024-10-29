Nistat <- function() {
  repeat {
    cat("أهلاً بك في نظام اختيار التحليل الإحصائي!\n")
    
    # السؤال الأول: نوع السؤال البحثي
    research_question <- readline("ما هو نوع سؤالك البحثي؟\n1 - البحث عن علاقة\n2 - البحث عن فرق\n3 - التنبؤ بالنتائج\n4 - اختبار التوزيع\nاختيارك: ")
    
    if (research_question == "1") {
      # البحث عن علاقة
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - عددية ترتيبية\n3 - اسمية\nاختيارك: ")
      
      if (data_type == "1") {
        # بيانات عددية مستمرة
        parametric <- readline("هل تحقق البيانات افتراضات الإحصاء المعلمي؟\n1 - نعم\n2 - لا\nاختيارك: ")
        if (parametric == "1") {
          cat("التحليل المناسب: Pearson's correlation (الارتباط لبيرسون)\n")
        } else {
          cat("التحليل المناسب: Spearman's Rank correlation (الارتباط لسبيرمان)\n")
        }
      } else if (data_type == "2") {
        # بيانات ترتيبية
        cat("التحليل المناسب: Spearman's Rank correlation (الارتباط لسبيرمان) للبيانات الترتيبية\n")
      } else if (data_type == "3") {
        # بيانات اسمية
        cat("التحليل المناسب: اختبار كاي-تربيع للارتباط (Chi-squared test for association) أو معامل ارتباط فيشر (Phi coefficient)\n")
      }
      
    } else if (research_question == "2") {
      # البحث عن فرق
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - عددية ترتيبية\n3 - اسمية\nاختيارك: ")
      
      if (data_type == "1") {
        # بيانات عددية مستمرة
        parametric <- readline("هل تحقق البيانات افتراضات الإحصاء المعلمي؟\n1 - نعم\n2 - لا\nاختيارك: ")
        groups <- readline("كم عدد المجموعات أو العينات؟\n1 - اثنان\n2 - ثلاثة أو أكثر\nاختيارك: ")
        
        if (groups == "1") {
          independent <- readline("هل العينات مستقلة؟\n1 - نعم\n2 - لا (مرتبطة)\nاختيارك: ")
          if (parametric == "1" && independent == "1") {
            cat("التحليل المناسب: اختبار t للعينات المستقلة\n")
          } else if (parametric == "1" && independent == "2") {
            cat("التحليل المناسب: اختبار t للعينات المرتبطة\n")
          } else if (parametric == "2" && independent == "1") {
            cat("التحليل المناسب: اختبار مان–ويتني (Mann-Whitney U Test)\n")
          } else if (parametric == "2" && independent == "2") {
            cat("التحليل المناسب: اختبار ويلكوكسون للعينات المرتبطة (Wilcoxon Signed-Rank Test)\n")
          }
        } else if (groups == "2") {
          repeated_measures <- readline("هل هناك قياسات مكررة؟\n1 - نعم\n2 - لا\nاختيارك: ")
          if (parametric == "1" && repeated_measures == "1") {
            cat("التحليل المناسب: One-way repeated measures ANOVA\n")
          } else if (parametric == "1" && repeated_measures == "2") {
            cat("التحليل المناسب: One-way independent ANOVA\n")
          } else if (parametric == "2" && repeated_measures == "1") {
            cat("التحليل المناسب: اختبار فريدمان (Friedman Test)\n")
          } else if (parametric == "2" && repeated_measures == "2") {
            cat("التحليل المناسب: اختبار كروسكال–واليس (Kruskal-Wallis Test)\n")
          }
        }
      } else if (data_type == "2") {
        # بيانات ترتيبية
        groups <- readline("كم عدد العينات؟\n1 - عينتان\n2 - أكثر من عينتين\nاختيارك: ")
        if (groups == "1") {
          paired <- readline("هل العينات مرتبطة؟\n1 - نعم\n2 - لا\nاختيارك: ")
          if (paired == "1") {
            cat("التحليل المناسب: اختبار الرتب الموقعة لــ ويلكوكسون (Wilcoxon Signed-Rank Test)\n")
          } else {
            cat("التحليل المناسب: اختبار مان–ويتني (Mann-Whitney U Test)\n")
          }
        } else if (groups == "2") {
          paired <- readline("هل العينات مرتبطة؟\n1 - نعم\n2 - لا\nاختيارك: ")
          if (paired == "1") {
            cat("التحليل المناسب: اختبار فريدمان (Friedman Test)\n")
          } else {
            cat("التحليل المناسب: اختبار كروسكال–واليس (Kruskal-Wallis Test)\n")
          }
        }
      } else if (data_type == "3") {
        # بيانات اسمية
        categories <- readline("هل تحتاج لاختبار توزيع فئة واحدة أم العلاقة بين فئتين؟\n1 - فئة واحدة\n2 - فئتين\nاختيارك: ")
        if (categories == "1") {
          cat("التحليل المناسب: اختبار كاي-تربيع لجودة المطابقة (Chi-squared Goodness-of-Fit Test)\n")
        } else if (categories == "2") {
          table_size <- readline("هل الترددات في بعض الخلايا أقل من 5؟\n1 - نعم\n2 - لا\nاختيارك: ")
          if (table_size == "1") {
            cat("التحليل المناسب: اختبار فيشر الدقيق (Fisher’s Exact Test)\n")
          } else {
            cat("التحليل المناسب: اختبار كاي-تربيع للاستقلال (Chi-squared Test for Independence)\n")
          }
        }
      }
      
    } else if (research_question == "3") {
      # التنبؤ بالنتائج
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - اسمية\nاختيارك: ")
      
      if (data_type == "1") {
        num_independent_vars <- readline("كم عدد المتغيرات المستقلة؟\n1 - متغير واحد\n2 - متغيران أو أكثر\nاختيارك: ")
        if (num_independent_vars == "1") {
          cat("التحليل المناسب: الانحدار البسيط (Simple Regression)\n")
        } else {
          cat("التحليل المناسب: الانحدار المتعدد (Multiple Regression)\n")
        }
      } else if (data_type == "2") {
        cat("التحليل المناسب: الانحدار اللوجستي (Logistic Regression) للبيانات الثنائية أو المتعددة\n")
      }
      
    } else if (research_question == "4") {
      # اختبار التوزيع
      goodness_of_fit <- readline("هل تحتاج لاختبار جودة المطابقة؟\n1 - نعم\n2 - لا\nاختيارك: ")
      if (goodness_of_fit == "1") {
        cat("التحليل المناسب: اختبار كاي-تربيع لجودة المطابقة أو اختبار Kolmogorov-Smirnov لعينة واحدة\n")
      } else {
        homogeneity <- readline("هل تحتاج لاختبار التجانس؟\n1 - نعم\n2 - لا\nاختيارك: ")
        if (homogeneity == "1") {
          cat("التحليل المناسب: اختبار Levene أو اختبار Bartlett\n")
        } else {
          normality <- readline("هل تحتاج لاختبار التوزيع الطبيعي؟\n1 - نعم\n2 - لا\nاختيارك: ")
          if (normality == "1") {
            cat("التحليل المناسب: اختبار شابيرو-ويلك (Shapiro-Wilk) أو اختبار أندرسون-دارلينج (Anderson-Darling)\n")
          }
        }
      }
    } else {
      cat("اختيار غير صالح، الرجاء إعادة التشغيل واختيار نوع البيانات المناسب.\n")
    }

    # سؤال المتابعة
    continue <- readline("هل ترغب في إجراء اختبار آخر؟\n1 - نعم\n2 - لا\nاختيارك: ")
    if (continue != "1") {
      cat("شكرًا لاستخدامك نظام اختيار التحليل الإحصائي. وداعًا!\n")
      break
    }
  }
}

# استدعاء الدالة لبدء عملية الاختيار
Nistat()
