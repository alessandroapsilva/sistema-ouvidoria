import { describe, expect, it } from "vitest";
import { canTransition, isManifestationKind } from "./manifestations";
describe("manifestation domain", () => {
 it("recognizes allowed categories", () => {
  expect(isManifestationKind("complaint")).toBe(true);
  expect(isManifestationKind("unknown")).toBe(false);
 });
 it("does not allow skipping straight to closed", () => {
  expect(canTransition("received","closed")).toBe(false);
  expect(canTransition("received","triage")).toBe(true);
 });
 it("requires reopening before closing an answered manifestation", () => {
  expect(canTransition("answered","closed")).toBe(true);
  expect(canTransition("closed","in_progress")).toBe(false);
 });
});
