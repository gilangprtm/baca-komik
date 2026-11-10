import type { NextConfig } from 'next';
const nextConfig: NextConfig = { async rewrites() { return [{ source: '/api/shinigami/:path*', destination: 'https://api.shngm.io/v1/:path*' }, { source: '/api/comment/:path*', destination: 'https://commento.shngm.io/api/:path*' }]; } };
export default nextConfig;
