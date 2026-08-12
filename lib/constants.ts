import { generateDummyPassword } from "./db/utils";

export const isProductionEnvironment = process.env.NODE_ENV === "production";
export const isDevelopmentEnvironment = process.env.NODE_ENV === "development";
export const guestRegex = /^guest-\d+$/;

export const DUMMY_PASSWORD = generateDummyPassword();

export const suggestions = [
  "What is the weather in San Francisco?",
  "What are the advantages of using Next.js?",
  "Explain how HTTP streaming works",
  "Give me three ideas for a weekend project",
];
