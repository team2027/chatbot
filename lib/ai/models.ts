export const DEFAULT_CHAT_MODEL = "gpt-5-mini";

export type ModelCapabilities = {
  tools: boolean;
  vision: boolean;
  reasoning: boolean;
};

export type ChatModel = {
  id: string;
  name: string;
  provider: string;
  description: string;
  capabilities: ModelCapabilities;
  reasoningEffort?: "none" | "minimal" | "low" | "medium" | "high";
};

// One model on purpose: chat and title generation both use it, so a run is
// never a mix of models.
export const chatModels: ChatModel[] = [
  {
    capabilities: { reasoning: true, tools: true, vision: true },
    description: "Fast, low-cost model with tool use",
    id: DEFAULT_CHAT_MODEL,
    name: "GPT-5 mini",
    provider: "openai",
    reasoningEffort: "low",
  },
];

export const titleModel = chatModels[0];

export const allowedModelIds = new Set(chatModels.map((m) => m.id));

export const modelsByProvider = chatModels.reduce(
  (acc, model) => {
    if (!acc[model.provider]) {
      acc[model.provider] = [];
    }
    acc[model.provider].push(model);
    return acc;
  },
  {} as Record<string, ChatModel[]>
);
