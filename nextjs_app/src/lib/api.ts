export const API='/api/shinigami';
export const SHINIGAMI_BASE='https://api.shngm.io/v1';
export function apiUrl(path:string, server=false){return `${server?SHINIGAMI_BASE:API}${path}`;}
export type ApiEnvelope<T> = {retcode:number;message?:string;data:T;meta?:{page:number;total_page:number;total_record:number}};
export async function getEnvelope<T>(path:string):Promise<ApiEnvelope<T>>{const r=await fetch(apiUrl(path,typeof window==='undefined'),{cache:'no-store'});if(!r.ok)throw new Error(`API error (${r.status})`);const j=await r.json() as ApiEnvelope<T>;if(j.retcode!==0)throw new Error(j.message||'API request failed');return j;}
export async function get<T>(path:string):Promise<T>{return (await getEnvelope<T>(path)).data;}
export type ChapterSummary={chapter_id?:string;chapter_number:number;chapter_title?:string;created_at?:string;release_date?:string};
export type Manga={manga_id:string;title:string;description?:string;cover_portrait_url?:string;cover_image_url?:string;country_id?:string;release_year?:string;user_rate?:number;latest_chapter_number?:number;latest_chapter_id?:string;latest_chapter_time?:string;chapters?:ChapterSummary[];taxonomy?:Record<string,{name:string;slug?:string}[]>};
export type Chapter=ChapterSummary;
export type ListMeta={page:number;total_page:number;total_record:number};
export type ListResponse<T>={data:T[];meta?:ListMeta};
