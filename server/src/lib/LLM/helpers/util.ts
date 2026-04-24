/**
 * Extract JSON object from a string that may contain extra text.
 * Searches backwards to find the last complete JSON object.
 */
export function extractJsonInString(content: string): any {
  let depth = 0;
  let jsonEnd = -1;

  // Find the last closing brace
  for (let i = content.length - 1; i >= 0; i--) {
    if (content[i] === '}') {
      jsonEnd = i;
      break;
    }
  }

  if (jsonEnd === -1) return null;

  // Walk backwards to find matching opening brace
  let jsonStart = -1;
  depth = 1;
  for (let i = jsonEnd - 1; i >= 0; i--) {
    if (content[i] === '}') depth++;
    if (content[i] === '{') depth--;
    if (depth === 0) {
      jsonStart = i;
      break;
    }
  }

  if (jsonStart === -1) return null;

  let jsonString = content.substring(jsonStart, jsonEnd + 1);
  // LLMs sometimes emit `undefined` (JS-only) instead of the JSON-valid `null`
  jsonString = jsonString.replace(/:\s*undefined\b/g, ': null');
  try {
    return JSON.parse(jsonString);
  } catch (error) {
    console.error('JSON parse error:', error);
    console.error('Attempted to parse:', jsonString.substring(0, 200) + '...');
    return null;
  }
}
