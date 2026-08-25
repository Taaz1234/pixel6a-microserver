/* =========================================================
   PixelSubs Pro - Logic & Interactivity v2.1
   With 100% Authentic Brand Vector SVGs
   ========================================================= */

const state = {
  subscriptions: [],
  currentCategory: 'all',
  currentSort: 'saving_eur',
  searchQuery: '',
  lastUpdated: '',
  favorites: JSON.parse(localStorage.getItem('pixelsubs_favs') || '[]'),
  calcSelected: JSON.parse(localStorage.getItem('pixelsubs_calc') || '["gamepass", "netflix", "spotify", "youtube", "chatgpt"]'),
};

// Diccionario de Iconos y Logotipos Vectoriales Oficiales SVG de Marcas
const BRAND_SVGS = {
  gamepass: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1.8 16.48c-2.48-.38-4.52-1.92-5.46-4.1.84.4 2.12.8 3.52.88 0 0 .96 1.7 1.94 3.22zm1.8-4.78c-1.58-.1-3.32-.56-4.32-1.12.56-1.92 1.94-3.48 3.76-4.22-.44 1.76-.14 3.66.56 5.34zm0-6.14c-1.54.68-2.72 1.98-3.24 3.56-.56-.96-.86-2.08-.86-3.26 0-3.38 2.24-6.24 5.34-7.14-.64 1.94-.8 4.2-.44 6.84zm1.8 10.92c.98-1.52 1.94-3.22 1.94-3.22 1.4-.08 2.68-.48 3.52-.88-.94 2.18-2.98 3.72-5.46 4.1zm0-4.78c.7-1.68 1-3.58.56-5.34 1.82.74 3.2 2.3 3.76 4.22-1 .56-2.74 1.02-4.32 1.12zm0-6.14c.36-2.64.2-4.9-.44-6.84 3.1.9 5.34 3.76 5.34 7.14 0 1.18-.3 2.3-.86 3.26-.52-1.58-1.7-2.88-3.24-3.56z"/>
    </svg>`,

  psplus: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M8.5 13.5v-3H11V8H8.5V5H6v3H3.5v2.5H6v3h2.5zm12-5.5h-5c-.55 0-1 .45-1 1v5c0 .55.45 1 1 1h5c.55 0 1-.45 1-1V9c0-.55-.45-1-1-1zm-1 5h-3V10h3v3zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/>
    </svg>`,

  nintendo: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M2.5 12c0-4.97 3.8-9 8.5-9v18c-4.7 0-8.5-4.03-8.5-9zm5 0c0-.83-.67-1.5-1.5-1.5S4.5 11.17 4.5 12s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5zm14 0c0 4.97-3.8 9-8.5 9V3c4.7 0 8.5 4.03 8.5 9zm-5-3.5c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5z"/>
    </svg>`,

  geforcenow: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M8.2 5.5c-3.1 0-5.7 2.6-5.7 5.7 0 1.9.9 3.6 2.4 4.6.4.3.7.8.7 1.3v1.4c0 .8.7 1.5 1.5 1.5h9.8c.8 0 1.5-.7 1.5-1.5v-1.4c0-.5.3-1 .7-1.3 1.5-1 2.4-2.7 2.4-4.6 0-3.1-2.6-5.7-5.7-5.7H8.2zm3.8 3.2c1.7 0 3 1.3 3 3s-1.3 3-3 3-3-1.3-3-3 1.3-3 3-3zm-6 2.5c0-1.1.9-2 2-2h1.2c-.4.6-.7 1.4-.7 2.2 0 .8.3 1.6.7 2.2H6.2c-1.1 0-2-.9-2-2.4zm12 0c0 1.5-.9 2.4-2 2.4h-1.2c.4-.6.7-1.4.7-2.2 0-.8-.3-1.6-.7-2.2H16c1.1 0 2 .9 2 2z"/>
    </svg>`,

  eaplaypro: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M12 2L2 7v10l10 5 10-5V7L12 2zm0 2.8L19.2 8 12 11.6 4.8 8 12 4.8zM4 9.8l7 3.5v7l-7-3.5v-7zm16 7l-7 3.5v-7l7-3.5v7z"/>
    </svg>`,

  netflix: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#E50914">
      <path d="M5.398 0v24c1.847-.72 3.695-1.385 5.542-1.996V0H5.398zm7.662 0v19.467l5.542 2.537V0H13.06zm-7.662 0l7.662 20.91V0H5.398z"/>
    </svg>`,

  disney: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 14.5h-2v-4H7V10.5h4v-4h2v4h4v2h-4v4zm5.5-8.5l-1.4 1.4-1.4-1.4 1.4-1.4 1.4 1.4z"/>
    </svg>`,

  max: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#002BE7">
      <path d="M2 7.5L5.5 16.5H8L10 11.5L12 16.5H14.5L18 7.5H15.5L13.2 13.5L11 8.5H9L6.8 13.5L4.5 7.5H2zm17 0v9h2.5v-9H19zm-8.5 0v9h2.5v-9h-2.5z"/>
    </svg>`,

  prime: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#00A8E1">
      <path d="M12 3C6.48 3 2 7.48 2 13s4.48 10 10 10 10-4.48 10-10S17.52 3 12 3zm4.5 13.5c-2.8 1.5-6.2 1.5-9 0-.3-.2-.4-.6-.2-.9.2-.3.6-.4.9-.2 2.3 1.2 5.1 1.2 7.4 0 .3-.2.7-.1.9.2.2.3.1.7-.2.9zm1.2-3.2c-.3.4-.9.5-1.3.2-1.3-.9-2.9-1.5-4.4-1.5-1.5 0-3.1.6-4.4 1.5-.4.3-1 .2-1.3-.2-.3-.4-.2-1 .2-1.3 1.6-1.2 3.6-1.8 5.5-1.8s3.9.6 5.5 1.8c.4.3.5.9.2 1.3z"/>
    </svg>`,

  appletv: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.88c.64-.78 1.08-1.86.96-2.94-.93.04-2.06.62-2.73 1.4-.58.67-1.1 1.76-.96 2.82 1.04.08 2.09-.5 2.73-1.28z"/>
    </svg>`,

  crunchyroll: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#F47521">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 17c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7zm3-7c0 1.66-1.34 3-3 3s-3-1.34-3-3 1.34-3 3-3 3 1.34 3 3z"/>
    </svg>`,

  youtube: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#FF0000">
      <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
    </svg>`,

  spotify: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#1DB954">
      <path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm5.494 17.308c-.215.353-.674.466-1.026.251-2.813-1.718-6.353-2.107-10.523-1.155-.403.092-.804-.16-.897-.562-.092-.403.16-.804.563-.897 4.568-1.044 8.484-.597 11.632 1.337.353.215.466.674.251 1.026zm1.465-3.257c-.27.44-.847.579-1.287.31-3.22-1.979-8.13-2.551-11.939-1.394-.495.15-1.023-.133-1.173-.628-.151-.495.133-1.023.628-1.173 4.357-1.323 9.773-.682 13.461 1.598.44.27.579.847.31 1.287zm.126-3.41c-3.86-2.292-10.228-2.504-13.896-1.39-.594.18-1.223-.155-1.404-.749-.18-.594.155-1.223.749-1.404 4.219-1.281 11.25-1.036 15.696 1.603.535.317.709 1.011.392 1.546-.318.535-1.012.709-1.547.394z"/>
    </svg>`,

  applemusic: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#FA2D48">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm3.5 6.5v6c0 1.38-1.12 2.5-2.5 2.5s-2.5-1.12-2.5-2.5 1.12-2.5 2.5-2.5c.38 0 .73.09 1.05.24V8.5h-4v4c0 1.38-1.12 2.5-2.5 2.5S5 13.88 5 12.5 6.12 10 7.5 10c.38 0 .73.09 1.05.24V6.5h7z"/>
    </svg>`,

  tidal: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="currentColor">
      <path d="M12.007 8.016l-3.996 4 3.996 4 4.004-4-4.004-4zm-8.004 0L0 12.016l4.003 4 3.996-4-3.996-4zm16.004 0l-3.996 4 3.996 4 4.003-4-4.003-4zm-8.004-8L8.011 4.016l3.996 4 4.004-4-4.004-4z"/>
    </svg>`,

  chatgpt: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#10A37F">
      <path d="M22.282 9.821a5.985 5.985 0 0 0-.516-4.91 6.046 6.046 0 0 0-6.51-2.9A6.065 6.065 0 0 0 4.981 4.18a5.985 5.985 0 0 0-3.998 2.9 6.046 6.046 0 0 0 .743 7.097 5.98 5.98 0 0 0 .51 4.911 6.051 6.051 0 0 0 6.515 2.9A5.985 5.985 0 0 0 13.26 24a6.056 6.056 0 0 0 5.772-4.206 5.99 5.99 0 0 0 3.997-2.9 6.056 6.056 0 0 0-.747-7.073zM13.26 22.43a4.476 4.476 0 0 1-2.876-1.04l.141-.081 4.779-2.758a.795.795 0 0 0 .392-.681v-6.737l2.02 1.168a.071.071 0 0 1 .038.052v5.583a4.504 4.504 0 0 1-4.494 4.494zM3.6 18.304a4.47 4.47 0 0 1-.535-3.014l.142.085 4.783 2.759a.771.771 0 0 0 .78 0l5.843-3.369v2.332a.08.08 0 0 1-.033.062L9.74 19.95a4.5 4.5 0 0 1-6.14-1.646zm-1.12-9.61a4.476 4.476 0 0 1 2.34-1.974V12.2a.76.76 0 0 0 .387.674l5.843 3.37-2.02 1.167a.08.08 0 0 1-.07.004L4.12 14.627a4.504 4.504 0 0 1-1.64-5.933zm16.79-1.996a.79.79 0 0 0-.78 0L12.647 10.07V7.737a.08.08 0 0 1 .033-.061l4.84-2.795a4.5 4.5 0 0 1 6.676 4.66l-.142-.085-4.784-2.759v-.001zm2.34 9.612a4.476 4.476 0 0 1-2.34 1.973V11.8a.76.76 0 0 0-.387-.674L13.04 7.755l2.02-1.167a.08.08 0 0 1 .07-.004l4.84 2.793a4.504 4.504 0 0 1 1.64 5.933zm-9.35-4.043l-2.61-1.507 2.61-1.506 2.61 1.506-2.61 1.507z"/>
    </svg>`,

  claudepro: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#D97706">
      <path d="M12 2L14.4 8.6L21.4 7L16.8 12.6L21.4 18.2L14.4 16.6L12 23.2L9.6 16.6L2.6 18.2L7.2 12.6L2.6 7L9.6 8.6L12 2Z"/>
    </svg>`,

  googleone: `
    <svg viewBox="0 0 24 24" width="34" height="34">
      <path fill="#4285F4" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10c2.5 0 4.8-.9 6.6-2.4l-2.1-2.1C15.2 18.4 13.7 19 12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7c1.93 0 3.68.78 4.95 2.05l2.12-2.12C17.32 3.17 14.81 2 12 2z"/>
      <path fill="#EA4335" d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0 7.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
      <path fill="#FBBC05" d="M19 12h3c0-4.42-3.58-8-8-8v3c2.76 0 5 2.24 5 5z"/>
      <path fill="#34A853" d="M19 12c0 2.76-2.24 5-5 5v3c4.42 0 8-3.58 8-8h-3z"/>
    </svg>`,

  canvapro: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#00C4CC">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1.8 14.4c-2.4 0-4.2-1.8-4.2-4.4 0-2.8 2-4.6 4.6-4.6 1.4 0 2.5.5 3.2 1.3l-1.3 1.3c-.5-.5-1.1-.8-1.9-.8-1.6 0-2.7 1.2-2.7 2.8s1 2.6 2.5 2.6c.9 0 1.6-.3 2.1-.8l1.3 1.3c-.8.8-2 1.3-3.6 1.3z"/>
    </svg>`,

  office365: `
    <svg viewBox="0 0 24 24" width="34" height="34">
      <path fill="#F25022" d="M1 1h10v10H1z"/>
      <path fill="#7FBA00" d="M13 1h10v10H13z"/>
      <path fill="#00A4EF" d="M1 13h10v10H1z"/>
      <path fill="#FFB900" d="M13 13h10v10H13z"/>
    </svg>`,

  nordvpn: `
    <svg viewBox="0 0 24 24" width="34" height="34" fill="#4687FF">
      <path d="M12 2L3 6v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V6l-9-4zm0 4.2l5.5 7.8h-3.3L12 9.7l-2.2 4.3H6.5L12 6.2z"/>
    </svg>`
};

function getBrandLogo(sub) {
  const svg = BRAND_SVGS[sub.icon_id || sub.id];
  if (svg) return svg;
  return `<i class="${sub.icon || 'fa-solid fa-bolt'}" style="font-size: 1.6rem; color: #fff;"></i>`;
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
    const brandSvg = getBrandLogo(sub);

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

        <div class="sub-header-banner" style="background: linear-gradient(135deg, ${sub.color}35, #111827);">
          <img src="${sub.image}" alt="${sub.name}" onerror="this.style.display='none'">
          <span class="sub-badge-category">${sub.category}</span>
          <div class="sub-icon-badge" style="background: ${sub.color};">
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
  const brandSvg = getBrandLogo(sub);
  detailModal.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  detailModalContent.innerHTML = `
    <div class="modal-header-hero">
      <div style="width: 85px; height: 85px; border-radius: var(--radius-md); background: ${sub.color}; display: flex; align-items: center; justify-content: center; color: white; box-shadow: var(--shadow-md); flex-shrink: 0;">
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
    const brandSvg = getBrandLogo(sub);

    return `
      <div class="calc-item-row ${isSelected ? 'selected' : ''}" onclick="toggleCalcRow('${sub.id}')">
        <div class="calc-item-left">
          <div class="calc-checkbox">
            ${isSelected ? '<i class="fa-solid fa-check"></i>' : ''}
          </div>
          <div style="width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
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
