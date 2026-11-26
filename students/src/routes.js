const exampleBase = ["comparison", "pre_post"];

function routeHash(language, answers, example = false) {
  const path = example ? ["case", ...answers.slice(exampleBase.length)] : answers;
  return "#" + [language, ...path].join("/");
}

function resolveRoute(catalog, hash) {
  const segments = hash.replace(/^#/, "").split("/");
  const language = segments[0] === "en" ? "en" : "ar";
  const example = segments[1] === "case";
  const supplied = example ? [...exampleBase, ...segments.slice(2)] : segments.slice(1);
  let node = "goal";
  const answers = [];
  const trail = [];
  for (const answer of supplied) {
    const question = catalog.questions[node];
    if (!question || !Object.prototype.hasOwnProperty.call(question.choices, answer)) break;
    const choice = question.choices[answer];
    trail.push({ key: question.key, question: question.label, choice: choice.label, answer });
    answers.push(answer);
    node = choice.to;
  }
  return { language, example, answers, trail, node };
}
