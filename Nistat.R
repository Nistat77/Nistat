Nistat <- function() {
  # دالة لاختيار الأسلوب الإحصائي المناسب بناءً على نوع السؤال البحثي وأنواع البيانات
  repeat {
    cat("أهلاً بك في نظام اختيار التحليل الإحصائي!\n")
    
    # السؤال الأول: نوع السؤال البحثي
    research_question <- readline("ما هو نوع سؤالك البحثي؟\n1 - البحث عن علاقة\n2 - البحث عن فرق\n3 - التنبؤ بالنتائج\nاختيارك: ")
    
    if (research_question == "1") {
      # البحث عن علاقة
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - فئوية\nاختيارك: ")
      
      if (data_type == "1") {
        # بيانات عددية مستمرة
        parametric <- readline("هل تحقق البيانات افتراضات الإحصاء المعلمي؟\n1 - نعم\n2 - لا\nاختيارك: ")
        if (parametric == "1") {
          cat("التحليل المناسب: Pearson's correlation\n")
        } else {
          cat("التحليل المناسب: Spearman's Rank correlation\n")
        }
      } else if (data_type == "2") {
        cat("التحليل المناسب: اختبار كاي-تربيع للارتباط (Chi-squared test for association)\n")
      }
      
    } else if (research_question == "2") {
      # البحث عن فرق
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - فئوية\nاختيارك: ")
      
      if (data_type == "1") {
        # بيانات عددية مستمرة
        groups <- readline("كم عدد المجموعات أو العينات؟\n1 - اثنان\n2 - ثلاثة أو أكثر\nاختيارك: ")
        
        if (groups == "1") {
          # مجموعتان
          independent <- readline("هل العينات مستقلة؟\n1 - نعم\n2 - لا (مرتبطة)\nاختيارك: ")
          if (independent == "1") {
            cat("التحليل المناسب: اختبار t للعينات المستقلة\n")
          } else {
            cat("التحليل المناسب: اختبار t للعينات المرتبطة\n")
          }
        } else if (groups == "2") {
          # ثلاثة أو أكثر
          num_independent_vars <- readline("كم عدد المتغيرات المستقلة؟\n1 - متغير واحد\n2 - متغيران\n3 - أكثر من متغيرين\nاختيارك: ")
          
          if (num_independent_vars == "1") {
            repeated_measures <- readline("هل هناك قياسات مكررة؟\n1 - نعم\n2 - لا\nاختيارك: ")
            if (repeated_measures == "1") {
              cat("التحليل المناسب: One-way repeated measures ANOVA\n")
            } else {
              cat("التحليل المناسب: One-way independent ANOVA أو Kruskal-Wallis Test\n")
            }
          } else if (num_independent_vars == "2") {
            repeated_measures <- readline("هل هناك قياسات مكررة؟\n1 - نعم\n2 - لا\nاختيارك: ")
            if (repeated_measures == "1") {
              cat("التحليل المناسب: Two-way repeated measures ANOVA\n")
            } else {
              cat("التحليل المناسب: Two-way independent ANOVA\n")
            }
          } else if (num_independent_vars == "3") {
            cat("التحليل المناسب: Factorial ANOVA\n")
          }
        }
      } else if (data_type == "2") {
        # بيانات فئوية
        cat("التحليل المناسب: اختبار كاي-تربيع للاختلافات (Chi-squared test for differences)\n")
      }
      
    } else if (research_question == "3") {
      # التنبؤ بالنتائج
      data_type <- readline("ما هو نوع البيانات التي لديك؟\n1 - عددية مستمرة\n2 - فئوية\nاختيارك: ")
      
      if (data_type == "1") {
        # بيانات عددية مستمرة
        num_independent_vars <- readline("كم عدد المتغيرات المستقلة؟\n1 - متغير واحد\n2 - متغيران أو أكثر\nاختيارك: ")
        
        if (num_independent_vars == "1") {
          cat("التحليل المناسب: الانحدار (Regression)\n")
        } else {
          cat("التحليل المناسب: الانحدار المتعدد (Multiple regression)\n")
        }
        
      } else if (data_type == "2") {
        cat("التحليل المناسب: ليس متاحًا لتحليل التنبؤ بالبيانات الفئوية في هذا السياق.\n")
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
