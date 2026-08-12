import { createOpenAI } from "@ai-sdk/openai";
import { titleModel } from "./models";

const openai = createOpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export function getLanguageModel(modelId: string) {
  return openai(modelId);
}

export function getTitleModel() {
  return openai(titleModel.id);
}
