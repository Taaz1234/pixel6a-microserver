/* =========================================================
   PixelSubs Pro - Logic & Interactivity v2.3
   With Direct High-Resolution Official Brand SVGs
   ========================================================= */

const state = {
  subscriptions: [],
  currentCategory: 'all',
  currentSort: 'saving_eur',
  searchQuery: '',
  lastUpdated: '',
  favorites: JSON.parse(localStorage.getItem('pixelsubs_favs') || '[]'),
  calcSelected: JSON.parse(localStorage.getItem('pixelsubs_calc') || '["gamepass", "netflix", "spotify", "youtube", "chatgpt", "googleone"]'),
};

// Diccionario de Logotipos Oficiales Vectoriales SVG
const BRAND_SVGS = {
  google: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="36" height="36">
      <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
      <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
      <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
      <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
    </svg>`,

  netflix: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 111 200" width="34" height="34">
      <path fill="#E50914" d="M0 0h34v194.5C22.6 197.8 11.3 200 0 200V0z"/>
      <path fill="#E50914" d="M77 0h34v200c-11.3 0-22.6-2.2-34-5.5V0z"/>
      <path fill="#B20710" d="M0 0h34l43 194.5c-11.4-3.3-22.7-5.5-34-5.5L0 0z"/>
      <path fill="#E50914" d="M34 0l43 194.5h34L68 0H34z"/>
    </svg>`,

  spotify: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 168 168" width="36" height="36">
      <path fill="#1ED760" d="M83.996.002C37.607.002 0 37.608 0 83.997c0 46.39 37.607 83.996 83.996 83.996 46.39 0 83.997-37.607 83.997-83.996C167.993 37.608 130.386.002 83.996.002zm38.403 121.273c-1.5 2.459-4.708 3.242-7.167 1.742-19.646-12.001-44.372-14.717-73.498-8.067-2.812.64-5.608-1.127-6.25-3.94-.64-2.812 1.128-5.61 3.94-6.25 31.89-7.29 59.27-4.184 81.233 9.349 2.459 1.5 3.242 4.708 1.742 7.166zm10.252-22.799c-1.884 3.069-5.908 4.043-8.977 2.16-22.486-13.823-56.77-17.828-83.37-9.752-3.46 1.049-7.14-0.93-8.19-4.39-.105-3.46.93-7.14 4.39-8.19 30.407-9.227 68.18-4.762 94.027 11.134 3.07 1.884 4.043 5.908 2.12 8.978zm.882-23.743c-26.968-16.018-71.503-17.496-97.23-9.684-4.137 1.255-8.528-1.082-9.784-5.22-1.256-4.137 1.082-8.528 5.22-9.784 29.58-8.98 78.756-7.261 109.839 11.196 3.727 2.214 4.954 7.042 2.74 10.77-2.214 3.727-7.042 4.954-10.77 2.74z"/>
    </svg>`,

  youtube: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 288 200" width="36" height="36">
      <path fill="#FF0000" d="M278.8 31.4C275.5 19 265.8 9.2 253.4 5.9 231 0 144 0 144 0S57 0 34.6 5.9C22.2 9.2 12.5 19 9.2 31.4 3.3 53.8 3.3 100 3.3 100s0 46.2 5.9 68.6c3.3 12.4 13 22.2 25.4 25.5C57 200 144 200 144 200s87 0 109.4-5.9c12.4-3.3 22.1-13.1 25.4-25.5 5.9-22.4 5.9-68.6 5.9-68.6s0-46.2-5.9-68.6z"/>
      <polygon fill="#FFFFFF" points="115.3,142.9 190.4,100 115.3,57.1"/>
    </svg>`,

  gamepass: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#107C10" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M353.4 122.7c-21.7-18.7-49.3-31.5-79.6-35.6 15.3 18.2 27.6 42.1 36.3 70 23.3-15.6 42.3-24.9 43.3-24.4zm-194.8 0c1 0 20 9.8 43.3 24.4 8.7-27.9 21-51.8 36.3-70-30.3 4.1-57.9 16.9-79.6 35.6zm233 138.8c0-36.6-11.4-70.5-30.8-98.6-10.4 7.6-36.7 26.5-62.4 40.5 7.1 26.2 9.5 53.6 7.1 80.3 31.7 49 67.9 81.3 70.4 81.3 9.9-28.7 15.7-65.4 15.7-103.5zm-271.2 0c0 38.1 5.8 74.8 15.7 103.5 2.5 0 38.7-32.3 70.4-81.3-2.4-26.7 0-54.1 7.1-80.3-25.7-14-52-32.9-62.4-40.5-19.4 28.1-30.8 62-30.8 98.6zm135.6 30.1c-16.1 29.5-35.5 53.8-54.6 69.8 24.5 10.7 51.5 16.8 80 16.8s55.5-6.1 80-16.8c-19.1-16-38.5-40.3-54.6-69.8-8.4-15.4-16.5-32.8-23.7-51.7-7.2 18.9-15.3 36.3-23.7 51.7z"/>
    </svg>`,

  psplus: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#003791" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M174.5 125v167.3l52.6 15.2V167c0-11.4 3.8-21.5 16.5-18.4 14.6 3.6 14.6 17.5 14.6 28.5v72.8l52.6 15.2V165.7c0-30.4-12.7-52.6-47.5-61.4-36.1-9.5-88.8-4.4-88.8 20.7zm-40.5 220.3c-23.4 8.2-39.2 18.4-39.2 30.4 0 22.8 55.7 34.2 119 34.2 36.1 0 72.8-3.8 98.7-10.8l-15.2-12.7c-21.5 5.7-49.4 8.9-83.5 8.9-53.2 0-82.9-8.9-82.9-20.9 0-7.6 12-14.6 34.2-20.3l-31.1-8.8zm239.9 22.8c-12-3.8-26.6-6.3-42.4-8.2l-10.1 12c14.6 1.9 27.2 4.4 36.7 7.6 15.8 5.1 20.3 10.8 20.3 16.5 0 8.2-12.7 15.2-34.8 20.3l14.6 12c27.8-6.3 46.8-17.1 46.8-33.5 0-14-11.4-23.4-31.1-26.7z"/>
    </svg>`,

  nintendo: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#E60012" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M128 112c-53 0-96 43-96 96v96c0 53 43 96 96 96h64V112h-64zm0 64c17.7 0 32 14.3 32 32s-14.3 32-32 32-32-14.3-32-32 14.3-32 32-32zm256-64h-64v288h64c53 0 96-43 96-96v-96c0-53-43-96-96-96zm-32 176c-17.7 0-32-14.3-32-32s14.3-32 32-32 32 14.3 32 32-14.3 32-32 32z"/>
    </svg>`,

  disney: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#113CCF" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M370 236h-44v-44c0-6.6-5.4-12-12-12s-12 5.4-12 12v44h-44c-6.6 0-12 5.4-12 12s5.4 12 12 12h44v44c0 6.6 5.4 12 12 12s12-5.4 12-12v-44h44c6.6 0 12-5.4 12-12s-5.4-12-12-12zM218 160c-48 0-88 38-88 86 0 46 36 84 82 86-42-20-56-54-44-84 10-26 34-44 50-88z"/>
      <path fill="#00D2FF" d="M140 330c60 40 160 30 220-40-10 16-60 60-150 50-30-4-50-6-70-10z"/>
    </svg>`,

  chatgpt: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#10A37F" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M422.3 218.4a123.6 123.6 0 0 0-10.7-101.4 124.8 124.8 0 0 0-134.5-59.9 125.2 125.2 0 0 0-102.8 61.5 123.5 123.5 0 0 0-82.5 59.9 124.9 124.9 0 0 0 15.3 146.5 123.5 123.5 0 0 0 10.5 101.4 125 125 0 0 0 134.5 59.9 125.1 125.1 0 0 0 102.8-61.5 123.7 123.7 0 0 0 82.5-59.9 125.1 125.1 0 0 0-15.1-146.5zM274.7 463.3a92.4 92.4 0 0 1-59.4-21.5l2.9-1.7 98.7-57a16.4 16.4 0 0 0 8.1-14.1v-139.1l41.7 24.1a1.5 1.5 0 0 1 .8 1.1v115.3a93 93 0 0 1-92.8 92.9zm-200.7-85.3a92.3 92.3 0 0 1-11.1-62.2l2.9 1.8 98.8 57a15.9 15.9 0 0 0 16.1 0l120.7-69.6v48.2a1.7 1.7 0 0 1-.7 1.3L200.4 412a93.2 93.2 0 0 1-126.4-34zm-23.2-198.5a92.4 92.4 0 0 1 48.3-40.8v3.5l-.1 113.9a15.7 15.7 0 0 0 8 13.9l120.7 69.6-41.7 24.1a1.7 1.7 0 0 1-1.5 0L84.8 243.8a93.2 93.2 0 0 1-34-124.3zm346.7-41.2a92.6 92.6 0 0 1 11.1 62.3l-2.9-1.8-98.8-57a15.9 15.9 0 0 0-16.1 0L170.2 211.4v-48.2a1.7 1.7 0 0 1 .7-1.3l100.3-57.4a93.2 93.2 0 0 1 126.4 34.2zm23.2 198.5a92.4 92.4 0 0 1-48.3 40.8v-3.5l.1-113.9a15.7 15.7 0 0 0-8-13.9l-120.7-69.6 41.7-24.1a1.7 1.7 0 0 1 1.5 0l100.3 57.7a93.2 93.2 0 0 1 34 124.3zM203 277.5l-53.9-31.1 53.9-31.1 53.9 31.1z"/>
    </svg>`,

  appletv: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#222222" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M318.7 345c-15.6 23.3-32.2 46.1-57.3 46.5-25.2.6-33.3-14.8-61.9-14.8-28.7 0-37.6 14.4-61.5 15.4-24.6 1-43.2-24.8-59-47.5-32.3-46.7-57.1-132-23.7-189.5 16.4-28.6 45.7-46.6 77.5-47.2 24.1-.4 47 16.3 61.8 16.3 14.7 0 42.5-20.1 71.7-17.1 12.2.6 46.5 4.9 68.5 37.2-1.7 1.1-40.8 24-40.4 71.6.6 56.8 49.8 75.8 50.4 76-0.6 1.3-7.9 27-26.1 53.1M267.2 108c12-14.6 20.3-34.9 18.1-55.2-17.5.8-38.7 11.7-51.3 26.3-10.9 12.6-20.7 33.1-18.1 53 19.5 1.5 39.3-9.5 51.3-24.1z"/>
    </svg>`,

  applemusic: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <defs>
        <linearGradient id="amGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#FC3C44"/>
          <stop offset="100%" stop-color="#FA243C"/>
        </linearGradient>
      </defs>
      <path fill="url(#amGrad)" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M336 128v176c0 26.5-21.5 48-48 48s-48-21.5-48-48 21.5-48 48-48c7.8 0 15.2 1.9 21.7 5.2V176l-96 24v128c0 26.5-21.5 48-48 48s-48-21.5-48-48 21.5-48 48-48c7.8 0 15.2 1.9 21.7 5.2V144c0-7.7 5.5-14.3 13.1-15.7l128-32c8.2-2.1 16.2 4.1 16.2 12.5v19.2z"/>
    </svg>`,

  prime: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#00A8E1" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M366.8 316.5c-44 23.6-97.4 23.6-141.4 0-4.7-2.5-6.3-8.5-3.8-13.2 2.5-4.7 8.5-6.3 13.2-3.8 36.3 19.5 80.3 19.5 116.6 0 4.7-2.5 10.7-.9 13.2 3.8 2.5 4.7.9 10.7-3.8 13.2zm18.9-50.4c-4.7 6.3-14.2 7.9-20.5 3.2-20.5-14.2-45.7-23.6-69.3-23.6-23.6 0-48.8 9.4-69.3 23.6-6.3 4.7-15.8 3.2-20.5-3.2-4.7-6.3-3.2-15.8 3.2-20.5 25.2-18.9 56.7-28.3 86.6-28.3 29.9 0 61.4 9.4 86.6 28.3 6.3 4.7 7.9 14.2 3.2 20.5z"/>
    </svg>`,

  crunchyroll: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#F47521" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 100c-86.2 0-156 69.8-156 156s69.8 156 156 156 156-69.8 156-156-69.8-156-156-156zm0 252c-53 0-96-43-96-96s43-96 96-96 96 43 96 96-43 96-96 96zm48-96c0 26.5-21.5 48-48 48s-48-21.5-48-48 21.5-48 48-48 48 21.5 48 48z"/>
    </svg>`,

  max: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#002BE7" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M96 176l56 160h40l32-96 32 96h40l56-160h-48l-36 104-32-104h-24l-32 104-36-104H96zm256 0v160h48V176h-48z"/>
    </svg>`,

  office365: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#222222" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#F25022" d="M128 128h112v112H128z"/>
      <path fill="#7FBA00" d="M272 128h112v112H272z"/>
      <path fill="#00A4EF" d="M128 272h112v112H128z"/>
      <path fill="#FFB900" d="M272 272h112v112H272z"/>
    </svg>`,

  claudepro: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#CC785C" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 64l36 99 99-36-36 99 99 36-99 36 36 99-99-36-36 99-36-99-99 36 36-99-99-36 99-36-36-99 99 36z"/>
    </svg>`,

  geforcenow: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#76B900" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 128c-70.7 0-128 57.3-128 128s57.3 128 128 128 128-57.3 128-128-57.3-128-128-128zm0 192c-35.3 0-64-28.7-64-64s28.7-64 64-64 64 28.7 64 64-28.7 64-64 64z"/>
    </svg>`,

  eaplaypro: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#FF4747" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 64L64 160v192l192 96 192-96V160L256 64zm0 64l128 64-128 64-128-64 128-64zm-128 96l96 48v96l-96-48v-96zm160 144v-96l96-48v96l-96 48z"/>
    </svg>`,

  tidal: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#000000" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 160l64 64-64 64-64-64 64-64zm-128 0l64 64-64 64-64-64 64-64zm256 0l64 64-64 64-64-64 64-64zm-128-128l64 64-64 64-64-64 64-64z"/>
    </svg>`,

  canvapro: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#00C4CC" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M280 140c-60 0-100 40-100 100s40 100 100 100c40 0 70-20 85-45l-35-25c-10 15-25 25-50 25-35 0-55-25-55-55s20-55 55-55c25 0 40 10 50 25l35-25c-15-25-45-45-85-45z"/>
    </svg>`,

  nordvpn: `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="36" height="36">
      <path fill="#4687FF" d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0z"/>
      <path fill="#FFFFFF" d="M256 96L96 160v128c0 106.7 68.3 206.9 160 228 91.7-21.1 160-121.3 160-228V160L256 96zm0 84l88 124h-52.8l-35.2-68.8-35.2 68.8H168l88-124z"/>
    </svg>`
};

function getBrandLogo(sub, size = 36) {
  const iconId = sub.icon_id || sub.id;
  const svg = BRAND_SVGS[iconId] || BRAND_SVGS[sub.id];
  if (svg) return svg;
  return `<i class="${sub.icon || 'fa-solid fa-bolt'}" style="font-size: ${size}px; color: #1e293b;"></i>`;
}

// DOM Elements
const searchInput = document.getElementById('searchInput');
const clearSearchBtn = document.getElementById('clearSearchBtn');
const subsGrid = document.getElementById('subsGrid');
const loader = document.getElementById('loader');
const currentCategoryTitle = document.getElementById('currentCategoryTitle');
const resultsCount = document.getElementById('resultsCount');
const totalSubsCount = document.getElementById('totalSubsCount');
const favCountSpan = document.getElementById('favCount');
const calcSelectedCountSpan = document.getElementById('calcSelectedCount');
const sortSelect = document.getElementById('sortSelect');
const bannerUpdated = document.getElementById('bannerUpdated');

// Modals
const detailModal = document.getElementById('detailModal');
const detailModalContent = document.getElementById('detailModalContent');
const closeDetailModalBtn = document.getElementById('closeDetailModalBtn');

const calcModal = document.getElementById('calcModal');
const closeCalcModalBtn = document.getElementById('closeCalcModalBtn');
const calcItemsList = document.getElementById('calcItemsList');
const calcTotalSpain = document.getElementById('calcTotalSpain');
const calcTotalOpt = document.getElementById('calcTotalOpt');
const calcTotalSaving = document.getElementById('calcTotalSaving');
const calcTotalSavingPct = document.getElementById('calcTotalSavingPct');

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
  setupEventListeners();
  loadSubscriptions();
  updateHeaderBadges();
});

function setupEventListeners() {
  searchInput.addEventListener('input', (e) => {
    state.searchQuery = e.target.value.trim().toLowerCase();
    clearSearchBtn.style.display = state.searchQuery ? 'block' : 'none';
    renderGrid();
  });

  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    state.searchQuery = '';
    clearSearchBtn.style.display = 'none';
    renderGrid();
  });

  closeDetailModalBtn.addEventListener('click', closeDetailModal);
  detailModal.addEventListener('click', (e) => {
    if (e.target === detailModal) closeDetailModal();
  });

  closeCalcModalBtn.addEventListener('click', closeCalcModal);
  calcModal.addEventListener('click', (e) => {
    if (e.target === calcModal) closeCalcModal();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeDetailModal();
      closeCalcModal();
    }
  });
}

function updateHeaderBadges() {
  favCountSpan.textContent = state.favorites.length;
  calcSelectedCountSpan.textContent = state.calcSelected.length;
}

// Carga de Suscripciones
async function loadSubscriptions(forceRefresh = false) {
  showLoader(true);
  try {
    const url = forceRefresh ? '/api/subscriptions/refresh' : '/api/subscriptions';
    const res = await fetch(url);
    const data = await res.json();

    state.subscriptions = data.subscriptions || [];
    state.lastUpdated = data.last_updated || 'Hoy';

    bannerUpdated.innerHTML = `<i class="fa-solid fa-arrows-rotate text-green"></i> Actualizado: ${state.lastUpdated}`;
    totalSubsCount.textContent = state.subscriptions.length;

    renderGrid();
    updateCalculatorSummary();
  } catch (err) {
    console.error(err);
    subsGrid.innerHTML = `<div class="loader-container">Error al conectar con el microservidor.</div>`;
  } finally {
    showLoader(false);
  }
}

async function forceRefreshRates() {
  const btn = document.querySelector('.refresh-rates-btn');
  if (btn) btn.style.transform = 'rotate(360deg)';
  await loadSubscriptions(true);
}

// Filtrar Categoría
function filterCategory(cat) {
  state.currentCategory = cat;

  document.querySelectorAll('.cat-pill').forEach(pill => {
    pill.classList.toggle('active', pill.dataset.cat === cat);
  });

  const titles = {
    all: '<i class="fa-solid fa-list-check"></i> Todas las Suscripciones',
    Videojuegos: '<i class="fa-solid fa-gamepad text-green"></i> Videojuegos & Gaming',
    'Cine & Series': '<i class="fa-solid fa-film text-cyan"></i> Cine & Series en Streaming',
    'Música & Audio': '<i class="fa-solid fa-music text-gold"></i> Música & Podcasts HiFi',
    'Inteligencia Artificial': '<i class="fa-solid fa-robot text-purple"></i> Inteligencia Artificial & Nube',
    'Productividad & VPN': '<i class="fa-solid fa-shield-halved text-blue"></i> Productividad, Nube & VPN',
    favorites: '<i class="fa-solid fa-star text-gold"></i> Mis Suscripciones Favoritas'
  };

  currentCategoryTitle.innerHTML = titles[cat] || `<i class="fa-solid fa-tag"></i> ${cat}`;
  renderGrid();
}

// Ordenación
function handleSortChange() {
  state.currentSort = sortSelect.value;
  renderGrid();
}

// Renderizado de Tarjetas
function renderGrid() {
  let filtered = [...state.subscriptions];

  if (state.currentCategory === 'favorites') {
    filtered = filtered.filter(s => state.favorites.includes(s.id));
  } else if (state.currentCategory !== 'all') {
    filtered = filtered.filter(s => s.category === state.currentCategory);
  }

  if (state.searchQuery) {
    filtered = filtered.filter(s => 
      s.name.toLowerCase().includes(state.searchQuery) ||
      s.category.toLowerCase().includes(state.searchQuery) ||
      (s.notes || '').toLowerCase().includes(state.searchQuery)
    );
  }

  filtered.sort((a, b) => {
    if (state.currentSort === 'saving_eur') {
      return (b.yearly_saving || 0) - (a.yearly_saving || 0);
    } else if (state.currentSort === 'saving_pct') {
      const pctA = a.cheapest_region ? a.cheapest_region.saved_pct : 0;
      const pctB = b.cheapest_region ? b.cheapest_region.saved_pct : 0;
      return pctB - pctA;
    } else if (state.currentSort === 'cheapest_price') {
      const prA = a.cheapest_region ? a.cheapest_region.eur_price : a.spain_price;
      const prB = b.cheapest_region ? b.cheapest_region.eur_price : b.spain_price;
      return prA - prB;
    } else if (state.currentSort === 'spain_price') {
      return a.spain_price - b.spain_price;
    } else if (state.currentSort === 'name') {
      return a.name.localeCompare(b.name);
    }
    return 0;
  });

  resultsCount.textContent = `${filtered.length} servicios`;

  if (filtered.length === 0) {
    subsGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 4rem 1rem; color: var(--text-muted);">
        <i class="fa-solid fa-magnifying-glass" style="font-size: 3rem; margin-bottom: 1rem; color: var(--text-dark);"></i>
        <h3>No se encontraron suscripciones</h3>
        <p style="margin-top: 0.5rem;">Prueba con otra categoría o término de búsqueda.</p>
      </div>
    `;
    return;
  }

  subsGrid.innerHTML = filtered.map(sub => {
    const cheapest = sub.cheapest_region;
    const isFav = state.favorites.includes(sub.id);
    const inCalc = state.calcSelected.includes(sub.id);
    const brandSvg = getBrandLogo(sub, 36);

    return `
      <div class="sub-card" onclick="openDetailModal('${sub.id}')">
        
        <!-- Acciones Rápidas (Favorito & Calculadora) -->
        <div class="card-top-actions">
          <button class="icon-action-btn fav-btn ${isFav ? 'active' : ''}" title="Guardar en Favoritos" onclick="toggleFavorite(event, '${sub.id}')">
            <i class="fa-${isFav ? 'solid' : 'regular'} fa-star"></i>
          </button>
          <button class="icon-action-btn basket-btn ${inCalc ? 'active' : ''}" title="Añadir a Calculadora de Ahorro" onclick="toggleCalcItem(event, '${sub.id}')">
            <i class="fa-solid fa-calculator"></i>
          </button>
        </div>

        <div class="sub-header-banner" style="background: linear-gradient(135deg, ${sub.color}25, #111827);">
          <img src="${sub.image}" class="bg-banner" alt="${sub.name}" onerror="this.style.display='none'">
          <span class="sub-badge-category">${sub.category}</span>
          <div class="sub-icon-badge">
            ${brandSvg}
          </div>
        </div>

        <div class="sub-body">
          <h4 class="sub-title">${sub.name}</h4>
          
          <div class="sub-price-comparison">
            <div class="price-row-compare">
              <span class="label">🇪🇸 España (Oficial):</span>
              <span class="val-spain">${sub.spain_price.toFixed(2)}€ / mes</span>
            </div>
            <div class="price-row-compare">
              <span class="label">${cheapest ? cheapest.flag + ' ' + cheapest.region : 'Global'}:</span>
              <span class="val-cheapest">${cheapest ? cheapest.eur_price.toFixed(2) + '€ / mes' : '-'}</span>
            </div>
          </div>

          <div class="sub-saving-banner">
            <i class="fa-solid fa-piggy-bank"></i> Ahorras ${cheapest ? cheapest.saved_pct : 0}% (¡${sub.yearly_saving.toFixed(2)}€/año!)
          </div>

          <div class="card-footer-box">
            <span style="font-size: 0.78rem; color: var(--text-muted);">${(sub.notes || '').substring(0, 46)}...</span>
            <div class="card-btn">
              <span>Comparar</span>
              <i class="fa-solid fa-arrow-right"></i>
            </div>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

// Modal de Detalle Comparativo por Países
function openDetailModal(subId) {
  const sub = state.subscriptions.find(s => s.id === subId);
  if (!sub) return;

  const cheapest = sub.cheapest_region;
  const brandSvg = getBrandLogo(sub, 54);
  detailModal.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  detailModalContent.innerHTML = `
    <div class="modal-header-hero">
      <div style="width: 85px; height: 85px; border-radius: var(--radius-md); background: #ffffff; display: flex; align-items: center; justify-content: center; box-shadow: var(--shadow-md); flex-shrink: 0; padding: 0.5rem; border: 2px solid rgba(255, 255, 255, 0.2);">
        ${brandSvg}
      </div>
      <div class="modal-info">
        <h3 class="modal-title">${sub.name}</h3>
        <div class="modal-meta">
          <span class="meta-chip score"><i class="fa-solid fa-tag"></i> ${sub.category}</span>
          <span class="meta-chip"><i class="fa-solid fa-piggy-bank text-green"></i> Ahorro: ~${sub.yearly_saving.toFixed(2)}€ / año</span>
          <span class="meta-chip"><i class="fa-solid fa-arrows-rotate"></i> Actualizado: ${state.lastUpdated}</span>
        </div>
        <p class="modal-desc">${sub.notes}</p>
      </div>
    </div>

    ${cheapest && cheapest.saved_pct > 0 ? `
      <div class="best-region-banner">
        <div class="best-region-left">
          <h4><i class="fa-solid fa-trophy"></i> Mejor Precio Global</h4>
          <div class="best-region-name">
            <span class="flag-icon">${cheapest.flag}</span>
            <span>${cheapest.region}</span>
          </div>
        </div>
        <div class="best-region-right">
          <div class="best-price-highlight">${cheapest.eur_price.toFixed(2)}€ <span style="font-size: 0.9rem; font-weight: normal;">/ mes</span></div>
          <div class="savings-highlight">¡Ahorras un ${cheapest.saved_pct}% (${cheapest.saved_eur.toFixed(2)}€ menos al mes vs España)!</div>
        </div>
      </div>
    ` : ''}

    <h4 class="table-header-title"><i class="fa-solid fa-earth-americas"></i> Comparativa de Precios Oficiales por País</h4>
    <div class="regional-table-wrapper">
      <table class="regional-table">
        <thead>
          <tr>
            <th>País / Región</th>
            <th>Precio Moneda Local</th>
            <th>Precio Convertido en EUR (€)</th>
            <th>Ahorro vs España</th>
          </tr>
        </thead>
        <tbody>
          ${(sub.regional_prices || []).map(r => `
            <tr class="${r.region === cheapest.region && r.saved_pct > 0 ? 'cheapest-row' : ''} ${r.region.includes('España') ? 'spain-row' : ''}">
              <td>
                <div class="region-cell">
                  <span class="flag-icon">${r.flag}</span>
                  <span>${r.region}</span>
                  ${r.region.includes('España') ? '<span style="font-size: 0.75rem; color: var(--accent-blue); font-weight: 700;">(Oficial)</span>' : ''}
                </div>
              </td>
              <td style="font-family: var(--font-mono);">${r.local_amount.toFixed(2)} ${r.currency} / mes</td>
              <td style="font-family: var(--font-mono); font-weight: 700; color: ${r.region === cheapest.region ? 'var(--accent-green)' : 'var(--text-main)'};">
                ${r.eur_price.toFixed(2)}€ / mes
              </td>
              <td>
                ${r.saved_pct > 0 
                  ? `<span class="savings-badge">-${r.saved_pct}% (-${r.saved_eur.toFixed(2)}€/mes)</span>` 
                  : `<span class="savings-badge zero">-</span>`
                }
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  `;
}

function closeDetailModal() {
  detailModal.style.display = 'none';
  document.body.style.overflow = 'auto';
}

// Calculadora de Cesta de Ahorro
function openCalculatorModal() {
  renderCalculatorList();
  updateCalculatorSummary();
  calcModal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
}

function closeCalcModal() {
  calcModal.style.display = 'none';
  document.body.style.overflow = 'auto';
}

function renderCalculatorList() {
  calcItemsList.innerHTML = state.subscriptions.map(sub => {
    const isSelected = state.calcSelected.includes(sub.id);
    const cheapest = sub.cheapest_region;
    const brandSvg = getBrandLogo(sub, 24);

    return `
      <div class="calc-item-row ${isSelected ? 'selected' : ''}" onclick="toggleCalcRow('${sub.id}')">
        <div class="calc-item-left">
          <div class="calc-checkbox">
            ${isSelected ? '<i class="fa-solid fa-check"></i>' : ''}
          </div>
          <div style="width: 32px; height: 32px; border-radius: 6px; background: #ffffff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; padding: 3px;">
            ${brandSvg}
          </div>
          <div>
            <div class="calc-item-name">${sub.name}</div>
            <div class="calc-item-category">${sub.category} &bull; España: ${sub.spain_price.toFixed(2)}€/mes</div>
          </div>
        </div>
        <div class="calc-item-price">
          <div style="color: var(--accent-green); font-weight: 700;">${cheapest ? cheapest.eur_price.toFixed(2) + '€' : '-'}</div>
          <div style="font-size: 0.72rem; color: var(--text-muted);">${cheapest ? cheapest.flag + ' ' + cheapest.region : ''}</div>
        </div>
      </div>
    `;
  }).join('');
}

function toggleCalcRow(id) {
  const idx = state.calcSelected.indexOf(id);
  if (idx >= 0) {
    state.calcSelected.splice(idx, 1);
  } else {
    state.calcSelected.push(id);
  }
  localStorage.setItem('pixelsubs_calc', JSON.stringify(state.calcSelected));
  updateHeaderBadges();
  renderCalculatorList();
  updateCalculatorSummary();
  renderGrid();
}

function toggleCalcItem(e, id) {
  e.stopPropagation();
  toggleCalcRow(id);
}

function updateCalculatorSummary() {
  let spainYearlyTotal = 0;
  let optYearlyTotal = 0;

  state.calcSelected.forEach(id => {
    const sub = state.subscriptions.find(s => s.id === id);
    if (sub) {
      spainYearlyTotal += sub.spain_yearly || (sub.spain_price * 12);
      optYearlyTotal += sub.cheapest_yearly || (sub.cheapest_region ? sub.cheapest_region.eur_price * 12 : sub.spain_price * 12);
    }
  });

  const savingYearly = Math.max(0, spainYearlyTotal - optYearlyTotal);
  const savingPct = spainYearlyTotal > 0 ? Math.round((savingYearly / spainYearlyTotal) * 100) : 0;

  calcTotalSpain.textContent = `${spainYearlyTotal.toFixed(2)}€ / año (${(spainYearlyTotal / 12).toFixed(2)}€/mes)`;
  calcTotalOpt.textContent = `${optYearlyTotal.toFixed(2)}€ / año (${(optYearlyTotal / 12).toFixed(2)}€/mes)`;
  calcTotalSaving.textContent = `${savingYearly.toFixed(2)}€ / año`;
  calcTotalSavingPct.textContent = `¡Ahorras un ${savingPct}% neto al año (${(savingYearly / 12).toFixed(2)}€ al mes)!`;
}

// Favoritos
function toggleFavorite(e, id) {
  e.stopPropagation();
  const idx = state.favorites.indexOf(id);
  if (idx >= 0) {
    state.favorites.splice(idx, 1);
  } else {
    state.favorites.push(id);
  }
  localStorage.setItem('pixelsubs_favs', JSON.stringify(state.favorites));
  updateHeaderBadges();
  renderGrid();
}

function showLoader(show) {
  loader.style.display = show ? 'block' : 'none';
  if (show) subsGrid.style.display = 'none';
  else subsGrid.style.display = 'grid';
}
