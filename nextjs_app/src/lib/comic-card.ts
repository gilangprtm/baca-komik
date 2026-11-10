const flags: Record<string, [string, string]> = { KR: ['KR', 'Korea Selatan'], CN: ['CN', 'China'], JP: ['JP', 'Japan'], JPN: ['JP', 'Japan'], ID: ['ID', 'Indonesia'] };
export function countryFlag(country?: string) { return country ? flags[country.toUpperCase()] : undefined; }
export function isRecentlyUpdated(timestamp?: string, now = Date.now()) {
  if (!timestamp) return false;
  const time = Date.parse(timestamp);
  return Number.isFinite(time) && time <= now && now - time < 24 * 60 * 60 * 1000;
}
export function relativeAge(timestamp?: string, now = Date.now()) {
  if (!timestamp) return undefined;
  const time = Date.parse(timestamp);
  if (!Number.isFinite(time) || time > now) return undefined;
  const minutes = Math.floor((now - time) / 60000);
  if (minutes < 1) return 'baru';
  if (minutes < 60) return `${minutes} mnt`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} jam`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `${days} hari`;
  const months = Math.floor(days / 30);
  if (months < 12) return `${months} bln`;
  return `${Math.floor(days / 365)} thn`;
}
