const namedEntities: Record<string, string> = {
  amp: '&', apos: "'", gt: '>', lt: '<', nbsp: '\u00a0', quot: '"',
};

function decodeEntity(entity: string): string {
  if (entity[0] === '#') {
    const hex = entity[1]?.toLowerCase() === 'x';
    const value = Number.parseInt(entity.slice(hex ? 2 : 1), hex ? 16 : 10);
    if (Number.isFinite(value) && value > 0 && value <= 0x10ffff && !(value >= 0xd800 && value <= 0xdfff)) {
      return String.fromCodePoint(value);
    }
    return '\ufffd';
  }
  return namedEntities[entity] ?? `&${entity};`;
}

/** Render untrusted Commento markup as text only; never create embedded resources or executable HTML. */
export function commentToText(comment: string): string {
  return comment
    .replace(/<\s*(script|style)\b[^>]*>[\s\S]*?<\s*\/\s*\1\s*>/gi, '\n')
    .replace(/<\s*br\b[^>]*\/?>/gi, '\n')
    .replace(/<\s*\/\s*p\s*>\s*<\s*p\b[^>]*>/gi, '\n\n')
    .replace(/<\s*\/\s*(p|div|li|blockquote)\s*>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/&(#(?:x[\da-f]+|\d+)|[a-z][\da-z]+);/gi, (_, entity: string) => decodeEntity(entity))
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}
