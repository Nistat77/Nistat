const catalog = JSON.parse(document.getElementById("catalog").textContent);
const publicGuide = "https://nistat-students.lilacsunbird8.chatgpt.site/";
const wording = {
  ar: {
    title: "دليل اختيار التحليل الإحصائي", subtitle: "ابدأ بسؤالك البحثي، ثم حدّد تصميم دراستك للوصول إلى الأسلوب المناسب وما تحتاج إلى فحصه وتقريره.",
    student: "دليل الطالب", home: "نيستات | البداية", share: "نسخ الرابط", skip: "انتقل إلى الدليل", footer: "روابط الدليل",
    download: "تنزيل نسخة دون اتصال", repository: "المشروع على GitHub", step: "السؤال", recommendation: "الأسلوب المقترح",
    back: "الرجوع", reset: "بدء دراسة جديدة", choices: "اختياراتك", edit: "تعديل الإجابة", check: "قبل استخدام الأسلوب",
    report: "ما الذي تذكره في التقرير؟", code: "عرض قالب R", copyCode: "نسخ كود R", source: "المرجع العلمي",
    print: "طباعة التوصية", openExample: "جرّب هذا المثال", exampleLabel: "مثال تطبيقي", exampleTitle: "هل تحسّنت درجات الطلاب؟",
    exampleText: "بيانات توضيحية لاثني عشر طالبًا في مجموعتين. أُجري اختبار قبل البرنامج التعليمي وبعده.",
    chartTitle: "متوسط درجة الاختبار", program: "مجموعة البرنامج", control: "المجموعة الضابطة", pre: "قبلي", post: "بعدي",
    caseResult: "النتيجة في المثال", interval: "فترة الثقة ٩٥٪", point: "نقطة", programVsControl: "لصالح مجموعة البرنامج",
    adjustedEstimate: "بعد ضبط الدرجة القبلية، بلغ فرق المتوسط البعدي", changeEstimate: "بلغ الفرق بين متوسطي التحسّن",
    copied: "نُسخ الرابط", copiedCode: "نُسخ كود R", manualLink: "انسخ هذا الرابط", manualCode: "انسخ كود R", close: "إغلاق",
    optionTitles: { association: "العلاقات والارتباط", comparison: "الفروق والمقارنات", prediction: "النمذجة والتنبؤ", distribution: "التوزيع والافتراضات" },
    examples: { association: "هل يرتبط وقت المذاكرة بدرجة الاختبار؟", comparison: "هل تختلف النتائج بين مجموعتين؟",
      prediction: "هل يمكن التنبؤ بالتحصيل من الحضور؟", distribution: "هل توزيع الدرجات قريب من الطبيعي؟" }
  },
  en: {
    title: "Find the right analysis for your study", subtitle: "Start with your research question, then describe your study design to find a method, its assumptions and what to report.",
    student: "Student guide", home: "Nistat home", share: "Copy link", skip: "Skip to guide", footer: "Guide links",
    download: "Download for offline use", repository: "Project on GitHub", step: "Question", recommendation: "Recommended approach",
    back: "Back", reset: "Start a new study", choices: "Your choices", edit: "Edit answer", check: "Before you use it",
    report: "What to report", code: "View R template", copyCode: "Copy R code", source: "Method reference",
    print: "Print recommendation", openExample: "Explore this example", exampleLabel: "Worked example", exampleTitle: "Did the students’ scores improve?",
    exampleText: "Illustrative scores for twelve students in two groups, tested before and after a learning program.",
    chartTitle: "Mean test score", program: "Program", control: "Control", pre: "Before", post: "After",
    caseResult: "Result in this example", interval: "95% CI", point: "points", programVsControl: "in favor of the program group",
    adjustedEstimate: "After adjustment for baseline, the difference in follow-up means was", changeEstimate: "The difference in mean improvement was",
    copied: "Link copied", copiedCode: "R code copied", manualLink: "Copy this link", manualCode: "Copy this R code", close: "Close",
    optionTitles: { association: "Association", comparison: "Group differences", prediction: "Prediction", distribution: "Distributions & assumptions" },
    examples: { association: "Does study time relate to exam scores?", comparison: "Do scores differ between two groups?",
      prediction: "Does attendance predict achievement?", distribution: "Are the scores approximately normal?" }
  }
};

const byId = id => document.getElementById(id);
function element(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}
function link(text, url, className) {
  const anchor = element("a", className, text);
  anchor.href = url;
  return anchor;
}
function button(text, className, action) {
  const control = element("button", className, text);
  control.type = "button";
  control.addEventListener("click", action);
  return control;
}
function arrow() {
  const item = element("span", "arrow flow-arrow", "→");
  item.setAttribute("aria-hidden", "true");
  return item;
}
function number(value, lang, digits = 0) {
  return new Intl.NumberFormat(lang === "ar" ? "ar-EG" : "en", {
    minimumFractionDigits: digits, maximumFractionDigits: digits, useGrouping: false
  }).format(value);
}
function canvasFor(width, height, className) {
  const canvas = element("canvas", className);
  canvas.width = width * 2;
  canvas.height = height * 2;
  const ctx = canvas.getContext("2d");
  if (ctx) ctx.scale(2, 2);
  return { canvas, ctx };
}
function miniPlot(kind) {
  const { canvas, ctx } = canvasFor(44, 34, "tile-plot");
  canvas.setAttribute("aria-hidden", "true");
  if (!ctx) return canvas;
  const palette = { association: ["#e0eee7","#26725c"], comparison: ["#f4e8d3","#93651f"],
    prediction: ["#e0ebf3","#3a6c8b"], distribution: ["#ece5f1","#775a8c"] };
  const [background, ink] = palette[kind];
  ctx.fillStyle = background; ctx.fillRect(0, 0, 44, 34);
  ctx.fillStyle = ink; ctx.strokeStyle = ink; ctx.lineWidth = 1.7; ctx.lineCap = "round";
  if (kind === "comparison") {
    [9,16,12,21].forEach((h,i) => ctx.fillRect(8 + i * 8, 27 - h, 5, h));
  } else if (kind === "distribution") {
    ctx.beginPath();
    for (let x = 5; x <= 39; x++) {
      const y = 26 - 18 * Math.exp(-Math.pow((x - 22) / 8, 2) / 2);
      if (x === 5) ctx.moveTo(x,y); else ctx.lineTo(x,y);
    }
    ctx.stroke();
  } else {
    const dots = kind === "association" ? [[8,25],[12,17],[17,23],[22,16],[27,12],[32,15],[36,8]]
      : [[9,24],[15,19],[20,21],[27,12],[34,9]];
    for (const [x,y] of dots) { ctx.beginPath(); ctx.arc(x,y,2,0,2*Math.PI); ctx.fill(); }
    if (kind === "prediction") { ctx.beginPath(); ctx.moveTo(7,27); ctx.lineTo(37,7); ctx.stroke(); }
  }
  return canvas;
}

function exampleChart(state) {
  const lang = state.language;
  const w = wording[lang];
  const fig = element("figure");
  fig.append(element("figcaption", "", w.chartTitle));
  const { canvas, ctx } = canvasFor(304, 128, "case-chart");
  const means = catalog.example.means;
  const legend = element("div", "legend");
  const description = [];
  for (const series of ["program", "control"]) {
    const item = element("span", series);
    item.append(element("i"), document.createTextNode(w[series]));
    legend.append(item);
    description.push(w[series] + " · " + w.pre + " " + number(means[series].pre,lang,1)
      + " · " + w.post + " " + number(means[series].post,lang,1));
  }
  canvas.setAttribute("role","img");
  canvas.setAttribute("aria-label", w.chartTitle + ". " + description.join(". "));
  fig.append(canvas, legend);
  if (!ctx) { fig.append(element("p","",description.join(" · "))); return fig; }
  const x0 = 56, x1 = 232;
  const yAt = score => 103 - (score - 9) * 10;
  ctx.font = '11px Tahoma, Arial, sans-serif'; ctx.lineWidth = 1;
  for (const score of [10, 12, 14, 16, 18]) {
    const y = yAt(score);
    ctx.strokeStyle = "#ffffff2c"; ctx.beginPath(); ctx.moveTo(32,y); ctx.lineTo(273,y); ctx.stroke();
    ctx.fillStyle = "#ccded5"; ctx.textAlign = "center"; ctx.fillText(number(score,lang),15,y+4);
  }
  for (const series of ["program","control"]) {
    const data = means[series], color = series === "program" ? "#9de0c7" : "#f6ce8d";
    ctx.strokeStyle = color; ctx.fillStyle = color; ctx.lineWidth = 2.4;
    ctx.setLineDash(series === "control" ? [5,4] : []);
    ctx.beginPath(); ctx.moveTo(x0,yAt(data.pre)); ctx.lineTo(x1,yAt(data.post)); ctx.stroke(); ctx.setLineDash([]);
    for (const [x,y] of [[x0,yAt(data.pre)],[x1,yAt(data.post)]]) {
      ctx.beginPath(); ctx.arc(x,y,3.8,0,2*Math.PI); ctx.fill();
    }
    ctx.font = "bold 12px Tahoma, Arial, sans-serif"; ctx.textAlign = "start"; ctx.direction = "ltr";
    ctx.fillText(number(data.post,lang), x1+9, yAt(data.post)+4);
    ctx.fillText(number(data.pre,lang,1), x0+5, yAt(data.pre)-7);
  }
  ctx.textAlign = "center"; ctx.font = "12px Tahoma, Arial, sans-serif"; ctx.fillStyle = "#e4eee6";
  ctx.fillText(w.pre,x0,121); ctx.fillText(w.post,x1,121);
  return fig;
}

function casePanel(state) {
  const w = wording[state.language];
  const card = element("section","case");
  card.append(element("span","case-label",w.exampleLabel), element("h2","",w.exampleTitle),
    element("p","",w.exampleText), exampleChart(state));
  if (!state.example) {
    const start = link(w.openExample, routeHash(state.language, exampleBase, true), "case-action");
    start.append(arrow()); card.append(start);
  }
  return card;
}
function trailPanel(state) {
  const lang = state.language, w = wording[lang];
  const trail = element("section", "panel trail");
  trail.append(element("h2","",w.choices));
  const list = element("ol");
  state.trail.forEach((entry, index) => {
    const row = element("li");
    // The two built-in choices describe the teaching case itself.
    if (state.example && index < exampleBase.length) {
      row.append(element("span","trail-item",entry.choice[lang]));
    } else {
      const edit = link(entry.choice[lang],routeHash(lang,state.answers.slice(0,index),state.example));
      edit.setAttribute("aria-label", w.edit + " · " + entry.choice[lang]);
      row.append(edit);
    }
    list.append(row);
  });
  trail.append(list);
  return trail;
}
function topLine(state, text) {
  const w = wording[state.language], line = element("div", "panel-line");
  line.append(element("span","step-tag",text));
  if (state.answers.length) {
    const back = state.example && state.answers.length === exampleBase.length
      ? routeHash(state.language, []) : routeHash(state.language, state.answers.slice(0,-1), state.example);
    line.append(link(w.back, back, "quiet"));
  }
  return line;
}
function titleHeading(text) {
  const title = element("h2","",text);
  title.id = "question-title"; title.tabIndex = -1;
  return title;
}
function renderQuestion(state, question) {
  const lang = state.language, w = wording[lang], root = state.node === "goal";
  const items = element("div",root ? "choice-grid" : "option-list");
  for (const [key, choice] of Object.entries(question.choices)) {
    const item = link("",routeHash(lang,[...state.answers,key],state.example), root ? "tile" : "option");
    if (root) {
      item.append(miniPlot(key), arrow(), element("span","tile-name",w.optionTitles[key]),
        element("span","tile-caption",w.examples[key]));
    } else { item.append(element("span","",choice.label[lang]), arrow()); }
    items.append(item);
  }
  byId("guide-panel").replaceChildren(topLine(state, w.step + " " + number(state.trail.length+1,lang)),
    titleHeading(question.label[lang]), items);
}

function exampleAnswer(id, lang) {
  const data = catalog.example, w = wording[lang], adjusted = id === "ancova";
  const estimate = adjusted ? data.adjusted : data.gain;
  const ci = adjusted ? data.adjusted_ci : data.gain_ci;
  const box = element("div","example-answer");
  const summary = element("p");
  const bounds = element("bdi","",number(ci[0],lang,2) + " – " + number(ci[1],lang,2));
  bounds.dir = "ltr";
  summary.append(document.createTextNode((adjusted ? w.adjustedEstimate : w.changeEstimate)+" "),
    element("strong","",number(estimate,lang,2)+" "+w.point), document.createTextNode(" "+w.programVsControl+" ("+w.interval+" "),
    bounds, document.createTextNode(")."));
  box.append(element("h3","",w.caseResult),summary);
  return box;
}
function renderMethod(state, method) {
  const lang = state.language, w = wording[lang], content = method[lang], panel = byId("guide-panel");
  panel.replaceChildren(topLine(state,w.recommendation),titleHeading(content.method),element("p","result-why",content.rationale));
  if (state.example) panel.append(exampleAnswer(state.node,lang));
  for (const [heading,field] of [[w.check,"checks"],[w.report,"report"]]) {
    const block = element("section","result-block");
    block.append(element("h3","",heading),element("p","",content[field])); panel.append(block);
  }
  const details = element("details","code-box");
  const body = element("div","code-body");
  const pre = element("pre"); pre.append(element("code","",method.code));
  body.append(pre,button(w.copyCode,"text-button",() => copyText(method.code,w.copiedCode,w.manualCode)));
  details.append(element("summary","",w.code),body); panel.append(details);
  const actions = element("div","result-links");
  const reference = link(w.source+" ↗",method.reference,"reference-link");
  reference.target = "_blank"; reference.rel = "noopener noreferrer";
  actions.append(reference,button(w.print,"text-button",() => window.print()),link(w.reset,routeHash(lang,[]),"quiet"));
  panel.append(actions,element("p","print-reference",w.source+" · "+method.reference));
}

let noticeTimer;
function notify(message) {
  clearTimeout(noticeTimer); byId("notice").textContent = message;
  noticeTimer = setTimeout(() => { byId("notice").textContent = ""; }, 2600);
}
async function copyText(value, success, fallback) {
  try {
    await navigator.clipboard.writeText(value);
    notify(success);
  } catch {
    byId("copy-title").textContent = fallback;
    byId("manual-copy").value = value;
    byId("copy-dialog").showModal();
    byId("manual-copy").focus(); byId("manual-copy").select();
  }
}
function render(focus = false) {
  const state = resolveRoute(catalog,window.location.hash);
  const lang = state.language, w = wording[lang], other = lang === "ar" ? "en" : "ar";
  const canonical = routeHash(lang,state.answers,state.example);
  if (location.hash && location.hash !== canonical) history.replaceState(null,"",canonical);
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
  const labels = { "page-heading":w.title, "intro-text":w.subtitle, "product-label":w.student,
    "skip":w.skip, "share":w.share, "download":w.download, "repository":w.repository,
    "footer-name":"Nistat · "+w.student, "close-dialog":w.close };
  for (const [id,label] of Object.entries(labels)) byId(id).textContent = label;
  byId("footer-nav").setAttribute("aria-label",w.footer);
  byId("home").setAttribute("aria-label",w.home); byId("home").href = routeHash(lang,[]);
  const switcher = byId("language");
  switcher.href = routeHash(other,state.answers,state.example); switcher.lang = other;
  switcher.textContent = other === "en" ? "English" : "العربية";
  const downloadURL = new URL(location.href); downloadURL.hash = "";
  byId("download").href = downloadURL.href;
  byId("intro").classList.toggle("compact",state.answers.length > 0);
  const question = catalog.questions[state.node];
  if (question) renderQuestion(state,question); else renderMethod(state,catalog.methods[state.node]);
  const side = byId("side-panel"); side.replaceChildren();
  if (!state.answers.length || state.example) side.append(casePanel(state));
  if (state.trail.length) side.append(trailPanel(state));
  const title = byId("question-title");
  document.title = (question ? w.title : catalog.methods[state.node][lang].method) + " | Nistat";
  if (focus) {
    title.focus({preventScroll:true});
    const position = byId("guide-panel").getBoundingClientRect().top;
    if (position < 0 || position > innerHeight*.65) byId("guide-panel").scrollIntoView({block:"start"});
  }
}

byId("share").addEventListener("click",() => {
  const state = resolveRoute(catalog,location.hash), w = wording[state.language];
  const url = new URL(location.protocol === "file:" ? publicGuide : location.href);
  url.search = ""; url.hash = routeHash(state.language,state.answers,state.example);
  copyText(url.href,w.copied,w.manualLink);
});
byId("close-dialog").addEventListener("click",() => byId("copy-dialog").close());
byId("skip").addEventListener("click",event => {
  event.preventDefault(); byId("main-content").focus(); byId("main-content").scrollIntoView();
});
let printDetails;
window.addEventListener("beforeprint",() => {
  const details = document.querySelector(".code-box");
  if (details) { printDetails = details.open; details.open = true; }
});
window.addEventListener("afterprint",() => {
  const details = document.querySelector(".code-box");
  if (details && printDetails !== undefined) details.open = printDetails;
  printDetails = undefined;
});
window.addEventListener("hashchange",() => render(true));
render();
