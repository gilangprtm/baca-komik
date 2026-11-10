import './globals.css';import Link from 'next/link';import Image from 'next/image';import type {Metadata} from 'next';import {PillNavigation} from '@/components/pill-navigation';
import { Geist } from "next/font/google";
import { cn } from "@/lib/utils";

const geist = Geist({subsets:['latin'],variable:'--font-sans'});

export const metadata:Metadata={title:'BacaKomik',description:'Jelajahi dan baca komik',manifest:'/manifest.json'};
export const viewport={themeColor:'#232728'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="id" className={cn("font-sans", geist.variable)}><body><header className="top"><Link className="brand" href="/" aria-label="Baca Komik - Beranda"><Image src="/logo.png" alt="" width={42} height={42}/><span>Baca Komik</span></Link></header><PillNavigation/><main className="shell">{children}</main><script dangerouslySetInnerHTML={{__html:"if('serviceWorker' in navigator) addEventListener('load',()=>navigator.serviceWorker.register('/sw.js').catch(()=>{}));"}}/></body></html>}
