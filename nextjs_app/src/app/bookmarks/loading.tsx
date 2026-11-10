import {Skeleton} from '@/components/ui/skeleton';
export default function Loading(){return <><Skeleton className="h-12 w-full"/><div className="mt-6 grid grid-cols-2 gap-4">{[1,2,3,4].map(i=><Skeleton key={i} className="aspect-[2/3] w-full"/>)}</div></>}
