const API_URL = "https://integrate.api.nvidia.com/v1/chat/completions";
const AUTH_HEADER = "Bearer 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";

function $(sel) { return document.querySelector(sel); }

function setLoading(isLoading) {
  $("#result").innerHTML = isLoading
    ? `<div class="spinner"></div>`
    : "";
}

function setResult({ downloadLink, error, aiContent }) {
  const resultDiv = $("#result");
  if (downloadLink) {
    resultDiv.innerHTML = `<a class="download-link" href="${downloadLink}" download>Download iOS App (.ipa)</a>`;
  } else if (error) {
    resultDiv.innerHTML = `<pre style="color:#d00; margin-top:16px; white-space:pre-wrap;">${error}</pre>`;
  } else if (aiContent) {
    resultDiv.innerHTML = `<pre style="color:#888; margin-top:16px; white-space:pre-wrap;">AI Response:\n${aiContent}</pre>`;
  } else {
    resultDiv.innerHTML = `<p style="font-size:0.9em; color:#888; margin-top:16px;">Note: Conversion requires a backend AI agent. This demo integrates with NVIDIA’s API.</p>`;
  }
}

document.addEventListener("DOMContentLoaded", function () {
  $("form").addEventListener("submit", async function (e) {
    e.preventDefault();
    setLoading(true);

    const url = $("#urlInput").value;
    const prompt = `Convert this URL into a downloadable iOS app (IPA file): ${url}`;

    try {
      const response = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Authorization": AUTH_HEADER,
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "moonshotai/kimi-k2-instruct",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.6,
          top_p: 0.9,
          frequency_penalty: 0,
          presence_penalty: 0,
          max_tokens: 4096,
          stream: false,
        }),
      });
      if (!response.ok) throw new Error("API error: " + response.statusText);
      const data = await response.json();

      let aiContent = "";
      let downloadLink = "";
      if (data.choices && data.choices.length > 0) {
        aiContent = data.choices[0].message.content || "";
        const match = aiContent.match(/https?:\/\/[^\s]+\.ipa/);
        if (match) downloadLink = match[0];
      }

      setResult({
        downloadLink,
        error: (!downloadLink && aiContent) ? "" : "",
        aiContent: (!downloadLink && aiContent) ? aiContent : "",
      });
    } catch (err) {
      setResult({ error: "Failed to convert: " + err.message });
    }
  });
});
