// Run from the repository root: node tests/test_students.mjs
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";

const page = readFileSync("students/index.html", "utf8");
const catalog = JSON.parse(page.match(/<script id="catalog" type="application\/json">([\s\S]*?)<\/script>/)[1]);
const router = readFileSync("students/src/routes.js", "utf8");
const { routeHash, resolveRoute } = runInNewContext(router + "\n;({routeHash, resolveRoute});");
assert(page.includes(router.trimEnd()), "Rebuild the offline page after routing changes.");
const terminal = new Set();
let paths = 0;
function visit(node, answers = []) {
  const question = catalog.questions[node];
  for (const language of ["ar", "en"]) {
    const state = resolveRoute(catalog, routeHash(language, answers));
    assert.equal(state.language, language);
    assert.equal(state.node, node);
    assert.equal(state.trail.length, answers.length);
    assert.deepEqual(Array.from(state.answers), answers);
    if (question) {
      assert(question.label[language]);
      for (const choice of Object.values(question.choices)) assert(choice.label[language]);
    } else {
      const result = catalog.methods[node];
      for (const field of ["method", "rationale", "checks", "report"]) assert(result[language][field]);
      assert(result.code && result.reference.startsWith("https://"));
    }
  }
  if (!question) { terminal.add(node); paths++; return; }
  for (const [code, option] of Object.entries(question.choices)) {
    assert(answers.length < 8, "Decision graph contains a cycle");
    visit(option.to, [...answers, code]);
  }
}
visit("goal");
assert.deepEqual([...terminal].sort(), Object.keys(catalog.methods).sort());
assert.equal(paths, 44);
assert.equal(resolveRoute(catalog, "").language, "ar");
assert.equal(resolveRoute(catalog, "#en/__proto__").node, "goal");
assert.equal(resolveRoute(catalog, "#en/prediction/invalid").node, "outcome");
for (const lang of ["ar", "en"]) {
  for (const [choice, id] of [["adjusted_followup", "ancova"], ["change", "change_scores"]]) {
    const url = routeHash(lang, ["comparison", "pre_post", choice], true);
    const state = resolveRoute(catalog, url);
    assert.equal(state.example, true);
    assert.equal(state.node, id);
    assert.equal(routeHash(lang, state.answers, true), url);
  }
}
assert.equal(catalog.example.adjusted.toFixed(2), "3.26");
assert.equal(catalog.example.gain.toFixed(2), "2.00");
assert.deepEqual(catalog.example.means.control, {pre: 10.5, post: 13});
assert.deepEqual(catalog.example.means.program, {pre: 12.5, post: 17});
console.log("Passed all " + paths + " student decision paths in both languages, share links and classroom calculations.");
