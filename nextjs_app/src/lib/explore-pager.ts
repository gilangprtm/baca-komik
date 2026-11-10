import type { Manga } from './api';
import { exploreListUrl, filterExploreRows, type ExploreFilters } from './explore-filters';
type Fetcher = (input: string, init?: RequestInit) => Promise<Response>;
type State = { items: Manga[]; page: number; totalPage: number; ended: boolean; error: string };

export class ExplorePager {
  private state: State = { items: [], page: 0, totalPage: 0, ended: false, error: '' };
  private busy = false;
  private disposed = false;
  private controller?: AbortController;
  constructor(private readonly filters: ExploreFilters, private readonly fetcher: Fetcher = (...args) => fetch(...args)) {}
  get snapshot(): State { return this.state; }
  dispose() { this.disposed = true; this.controller?.abort(); }
  async next(retry = false): Promise<State> {
    if (this.disposed || this.busy || this.state.ended || (this.state.error && !retry)) return this.state;
    this.busy = true; this.state = { ...this.state, error: '' };
    const requested = this.state.page + 1;
    const controller = this.controller = new AbortController();
    try {
      const response = await this.fetcher(exploreListUrl(this.filters, requested), { signal: controller.signal });
      if (!response.ok) throw new Error(`API error (${response.status})`);
      const envelope = await response.json();
      if (envelope.retcode !== 0) throw new Error(envelope.message || 'API request failed');
      if (this.disposed) return this.state;
      const rows: Manga[] = Array.isArray(envelope.data) ? envelope.data : [];
      const ids = new Set(this.state.items.map(row => row.manga_id));
      const items = [...this.state.items, ...filterExploreRows(rows, this.filters).filter(row => { if (ids.has(row.manga_id)) return false; ids.add(row.manga_id); return true; })];
      const totalPage = Number(envelope.meta?.total_page) || (rows.length < 24 ? requested : requested + 1);
      this.state = { items, page: requested, totalPage, ended: requested >= totalPage, error: '' };
    } catch (error) {
      if (!this.disposed) this.state = { ...this.state, error: error instanceof Error ? error.message : 'Unable to load comics' };
    } finally { this.busy = false; }
    return this.state;
  }
}
