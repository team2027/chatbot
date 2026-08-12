export const DEFAULT_CHAT_MODEL = "gpt-5-mini";

export const titleModel = {
  description: "Fast model for title generation",
  id: "gpt-5-mini",
  name: "GPT-5 mini",
  provider: "openai",
};

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

export const chatModels: ChatModel[] = [
  {
    capabilities: { reasoning: true, tools: true, vision: true },
    description: "Fast, low-cost model with tool use",
    id: "gpt-5-mini",
    name: "GPT-5 mini",
    provider: "openai",
    reasoningEffort: "low",
  },
  {
    capabilities: { reasoning: true, tools: true, vision: true },
    description: "Most capable model",
    id: "gpt-5",
    name: "GPT-5",
    provider: "openai",
    reasoningEffort: "medium",
  },
  {
    capabilities: { reasoning: false, tools: true, vision: true },
    description: "Fastest model for simple tasks",
    id: "gpt-4.1-mini",
    name: "GPT-4.1 mini",
    provider: "openai",
  },
];

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

export function getCapabilities(): Record<string, ModelCapabilities> {
  return Object.fromEntries(
    chatModels.map((model) => [model.id, model.capabilities])
  );
}

export function getActiveModels(): ChatModel[] {
  return chatModels;
}
