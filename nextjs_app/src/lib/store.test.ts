import 'fake-indexeddb/auto';
import {beforeEach,describe,expect,it,vi} from 'vitest';
import {IDBFactory} from 'fake-indexeddb';
import {all,getProgress,saveHistory,toggle} from './store';

beforeEach(()=>{vi.stubGlobal('indexedDB',new IDBFactory())});
const manga={manga_id:'m1',title:'Test Comic',cover_portrait_url:'cover.jpg'};
describe('local library storage',()=>{
 it('toggles bookmark state and persists saved manga',async()=>{expect(await toggle(manga)).toBe(true);expect((await all('bookmarks'))[0]).toMatchObject(manga);expect(await toggle(manga)).toBe(false);expect(await all('bookmarks')).toEqual([])});
 it('saves, updates, and resumes reading progress by chapter',async()=>{await saveHistory({chapter_id:'c1',manga_id:'m1',chapter_number:4,title:manga.title,cover:manga.cover_portrait_url,current_page:3,total_pages:12});expect(await getProgress('c1')).toMatchObject({current_page:3,total_pages:12,title:'Test Comic'});await saveHistory({chapter_id:'c1',manga_id:'m1',chapter_number:4,title:manga.title,cover:manga.cover_portrait_url,current_page:8,total_pages:12});expect(await all('history')).toHaveLength(1);expect(await getProgress('c1')).toMatchObject({current_page:8,total_pages:12});});
});
