import { test } from "node:test";
import assert from "node:assert/strict";
import { greeting } from "../site/app.js";

test("bonjour le matin", () => {
  assert.equal(greeting(new Date(2026, 9, 5, 9)), "Bonjour !");
});

test("bel après-midi l'après-midi", () => {
  assert.equal(greeting(new Date(2026, 9, 5, 15)), "Bel après-midi !");
});

test("bonsoir le soir", () => {
  assert.equal(greeting(new Date(2026, 9, 5, 21)), "Bonsoir !");
});
