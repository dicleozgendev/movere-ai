const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const OpenAI = require("openai");

// The API key never lives in this file or in git — it's stored as a
// Firebase Secret and injected at runtime (see Sprint 5 notes for how it's set).
const openaiApiKey = defineSecret("OPENAI_API_KEY");

/**
 * AI Recommendation Prototype (Sprint 5) — real-AI upgrade.
 * Receives a short JSON summary of the user's real local activity
 * (already computed by the Flutter app from SQLite — no raw personal
 * data beyond what the rule-based prototype already used) and asks
 * OpenAI to phrase ONE short, friendly recommendation from it.
 *
 * This function does not decide WHAT to recommend — the Flutter app's
 * rule engine still picks the category (focus/reading/listening/
 * explore) and the facts. This function's only job is to write the
 * sentence in natural language, so the underlying logic stays
 * auditable and the AI's role stays scoped and honest.
 */
exports.aiRecommendation = onRequest(
    {secrets: [openaiApiKey], cors: true},
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Use POST");
        return;
      }

      const {category, facts, question, language} = req.body || {};
      if (!category && !question) {
        res.status(400).json({error: "Missing category or question"});
        return;
      }

      const client = new OpenAI({apiKey: openaiApiKey.value()});

      // `language` (the app's current UI language) is only a fallback —
      // when there's a real question, respond in whatever language it
      // was actually asked in, so switching keyboards works naturally
      // without needing to also flip the app's language setting.
      const fallbackLanguage = language === "tr" ? "Turkish" : "English";
      const systemPrompt =
        "You are the in-app assistant for Movere AI, a digital wellbeing " +
        "app. You write ONE short (max 2 sentences), warm, encouraging " +
        "recommendation or answer based only on the facts given to you. " +
        "Never invent data you weren't given. Keep it concrete and brief. " +
        (question ?
          "Respond in the same language the user's question is written " +
          "in — detect it yourself from the question text." :
          `Respond in ${fallbackLanguage}.`);

      const userPrompt = question ?
        `The user asked: "${question}". Known facts about their activity ` +
        `today: ${JSON.stringify(facts)}. Answer their question using ` +
        `only these facts.` :
        `Category: ${category}. Facts: ${JSON.stringify(facts)}. Write ` +
        "the recommendation.";

      try {
        const completion = await client.chat.completions.create({
          model: "gpt-4o-mini",
          max_tokens: 120,
          messages: [
            {role: "system", content: systemPrompt},
            {role: "user", content: userPrompt},
          ],
        });
        const text = completion.choices[0]?.message?.content?.trim() ||
          "I couldn't come up with anything right now — try again shortly.";
        res.json({text});
      } catch (err) {
        console.error("OpenAI call failed:", err);
        res.status(500).json({error: "AI request failed"});
      }
    },
);
