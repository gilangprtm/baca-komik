import './globals.css';import Link from 'next/link';import Image from 'next/image';import type {Metadata} from 'next';import {PillNavigation} from '@/components/pill-navigation';
import { Geist } from "next/font/google";
import { cn } from "@/lib/utils";

const geist = Geist({subsets:['latin'],variable:'--font-sans'});

export const metadata:Metadata={
 title:{default:'Baca dan Jelajahi Komik Online | BacaKomik',template:'%s | BacaKomik'},
 description:'Jelajahi katalog komik dan baca chapter favorit Anda di BacaKomik.',
 applicationName:'BacaKomik',
 keywords:['baca komik','komik online','jelajahi komik'],
 openGraph:{type:'website',locale:'id_ID',siteName:'BacaKomik',title:'Baca dan Jelajahi Komik Online | BacaKomik',description:'Jelajahi katalog komik dan baca chapter favorit Anda di BacaKomik.'},
 twitter:{card:'summary',title:'Baca dan Jelajahi Komik Online | BacaKomik',description:'Jelajahi katalog komik dan baca chapter favorit Anda di BacaKomik.'},
 robots:{index:true,follow:true},
 icons:{icon:[{url:'/favicon.ico'},{url:'/icon-192.png',sizes:'192x192',type:'image/png'},{url:'/icon-512.png',sizes:'512x512',type:'image/png'}],apple:'/icon-192.png'},
 manifest:'/manifest.json'
};
export const viewport={themeColor:'#232728'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="id" className={cn("font-sans", geist.variable)}><body><header className="top"><Link className="brand" href="/" aria-label="Baca Komik - Beranda"><Image src="/logo.png" alt="" width={42} height={42}/><span>Baca Komik</span></Link></header><PillNavigation/><main className="shell">{children}</main><script dangerouslySetInnerHTML={{__html:"if('serviceWorker' in navigator) addEventListener('load',()=>navigator.serviceWorker.register('/sw.js').catch(()=>{}));"}}/></body></html>}
